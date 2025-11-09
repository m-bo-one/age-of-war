extends Node2D

@onready var player_1_spawn_location = $player_1_spawn_location
@onready var player_2_spawn_location = $player_2_spawn_location
@onready var player_1_spawner = $player_1_multi_spawner
@onready var player_2_spawner = $player_2_multi_spawner
@onready var special_projectile_multi_spawner = $special_projectile_multi_spawner
@onready var player_1_base = $player_1_base
@onready var player_2_base = $player_2_base

var unit_array : Array
var unable_to_spawn: Dictionary[int, bool]
var main_node_path: String = "/root/multiplayer_game"


# Called when the node enters the scene tree for the first time.
func _ready():
    var player = LobbyManager.get_active_player()
    if player == null:
        print("not a multiplayer game")
        return

    if player.base_side == LobbyManager.BaseSide.LEFT: 
        $Camera2D.global_position = Vector2(550, 280)
        player_1_base.player_id = player.id
        player_1_base.player_side = player.base_side
    else:
        $Camera2D.global_position = Vector2(1650, 280)
        player_2_base.player_id = player.id
        player_2_base.player_side = player.base_side
    $Camera2D/in_game_menu.connect("spawn_melee", _on_melee_button_pressed)
    $Camera2D/in_game_menu.connect("spawn_range", _on_range_button_pressed)
    $Camera2D/in_game_menu.connect("spawn_tank", _on_tank_button_pressed)
    $Camera2D/in_game_menu.connect("spawn_super_soldier", _on_super_soldier_button_pressed)
    unable_to_spawn = {}
    
    SignalBus.spawn_projectile.connect(_on_spawn_projectile)
    LobbyManager.on_player_update.connect(_on_player_update)
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    $Camera2D/in_game_menu/money.text = str(GlobalVariables.player_money)
    $Camera2D/in_game_menu/exp.text = str(GlobalVariables.player_exp)
            
            
func _on_player_update(id: int) -> void:
    if not multiplayer.is_server():
        return
        
    print("_on_player_update trigger")
    var player = LobbyManager.get_player(id)

    if player.is_mass_heal_active:
        var tname = "medival_special_timer_" + str(player.id)
        var timer = get_node_or_null(tname)
        if not timer:
            timer = Timer.new()
            timer.connect("timeout", _on_medival_special_timer_timeout.bind(timer, player.id))
            timer.name = tname
            timer.wait_time = 10.0
            timer.autostart = true
            add_child(timer)
                
                
func is_spawnable() -> bool:
    var id = multiplayer.get_unique_id()
    if not unable_to_spawn.has(id):
        return true
    return not unable_to_spawn[id]
    
    
func set_unable_to_spawn(id: int, res: bool) -> void:
    unable_to_spawn[id] = res
    

@rpc("any_peer", "call_local")
func spawn_location_flash(base_side: LobbyManager.BaseSide):
    var player_spawn_location: Area2D

    if base_side == LobbyManager.BaseSide.LEFT:
        player_spawn_location = player_1_spawn_location
    else:
        player_spawn_location = player_2_spawn_location
        
    print("[PEER]=", multiplayer.get_unique_id(), " - spawn flash from: ", base_side)
    player_spawn_location.get_node("PlayerSpawnAura").flash()


@rpc("any_peer")
func create_player_unit(id: int, path: String):
    if not multiplayer.is_server():
        create_player_unit.rpc_id(1, id, path)
        return
    
    var player = LobbyManager.get_player(id)

    var player_spawn_location: Area2D
    var spawner: MultiplayerSpawner

    if player.base_side == LobbyManager.BaseSide.LEFT:
        player_spawn_location = player_1_spawn_location
        spawner = player_1_spawner
    else:
        player_spawn_location = player_2_spawn_location
        spawner = player_2_spawner
        
        
    var data = {
        "path": path,
        "player_id":  player.id,
        "position": player_spawn_location.global_position,
        "base_side": player.base_side,
        "is_player_owned": true,
    }
    spawner.spawn(data)
    
    spawn_location_flash.rpc(player.base_side)
    

# NOTE: stage should be from server
func _on_melee_button_pressed(stage: String):
    if not is_spawnable():
        return
    create_player_unit(multiplayer.get_unique_id(), "res://units/" + stage + "/melee/" + stage + "_melee.tscn")


func _on_range_button_pressed(stage: String):
    if not is_spawnable():
        return
    create_player_unit(multiplayer.get_unique_id(), "res://units/" + stage + "/range/" + stage + "_range.tscn")


func _on_tank_button_pressed(stage: String):
    if not is_spawnable():
        return
    create_player_unit(multiplayer.get_unique_id(), "res://units/" + stage + "/tank/" + stage + "_tank.tscn")
    

# Unused variable stage in this function
func _on_super_soldier_button_pressed(stage: String):
    if not is_spawnable():
        return
    create_player_unit(multiplayer.get_unique_id(), "res://units/" + stage + "/super_soldier/" + stage + "_super_soldier.tscn")


func _on_player_spawn_location_body_entered(body):
    if body.is_player_owned == true:
        print("[PEER]=", multiplayer.get_unique_id(), " - _on_player_spawn_location_body_entered: ", body.name)
        set_unable_to_spawn(body.player_id, true)


func _on_player_spawn_location_body_exited(body):
    if body.is_player_owned == true:
        print("[PEER]=", multiplayer.get_unique_id(), " - _on_player_spawn_location_body_exited: ", body.name)
        set_unable_to_spawn(body.player_id, false)
        
        
func _on_spawn_projectile(id: int, data: Dictionary):
    create_player_projectile(id, data)
        
        
@rpc("any_peer")
func create_player_projectile(id: int, data: Dictionary):
    # this function could be optimized (not neded at this moment) to broadcast a batch
    # in one rpc request
    if not multiplayer.is_server():
        create_player_projectile.rpc_id(1, id, data)
        return
    
    # Maybe we should remove this from here?
    var player = LobbyManager.get_player(id)
    data.player_id = id
    data.player_side = player.base_side
    data.is_player_owned = true
    special_projectile_multi_spawner.spawn(data)


func cave_special_attack():
    var i = 0
    while i < 25:
        var data = {}
        data.path = "res://cave_special_projectile.tscn"
        data.global_position = Vector2(randf_range(310, 1875), randf_range(-200, -1000))
        data.direction = Vector2(randf_range(-0.5, 0.5), randf_range(2, 4)).normalized()
        data.damage = 80
        data.speed = randi_range(250, 350)
        data.spawn_offspring = false
        data.time_to_die = 8.0
        data.sprite = {}
        data.sprite.rotation = data.direction.angle()
        data.particles = {}
        data.particles.direction = data.direction.normalized().rotated(PI/2)
        i += 1
        
        create_player_projectile(multiplayer.get_unique_id(), data)


func knight_special_attack():
    var i = 0
    while i < 35:
        var data = {}
        data.path = "res://arrow_special_projectile.tscn"
        data.global_position = Vector2(randf_range(310, 1875), randf_range(-200, -2000))
        data.direction = Vector2(randf_range(-0.5, 0.5), randf_range(2, 4)).normalized()
        data.damage = 150
        data.speed = 400
        data.spawn_offspring = false
        data.time_to_die = 12.0
        data.sprite = {}
        data.sprite.rotation = data.direction.angle()
        i += 1
        
        create_player_projectile(multiplayer.get_unique_id(), data)

 
func medival_special_attack():
    print("[PEER]=", multiplayer.get_unique_id(), " - medival_special_attack start")
    LobbyManager.set_mass_heal_special.rpc_id(1, multiplayer.get_unique_id(), true)
    
    
func _on_medival_special_timer_timeout(timer: Timer, id: int):
    print("[PEER]=", multiplayer.get_unique_id(), " - medival_special_attack finish")
    LobbyManager.set_mass_heal_special.rpc_id(1, id, false)
    timer.queue_free()


func miltary_special_attack():
    var data = {}
    data.path = "res://miltary_special_plane.tscn"
    
    var player = LobbyManager.get_active_player()
    if player.base_side == LobbyManager.BaseSide.LEFT:
        data.global_position = Vector2(-100, 150)
    else:
        data.global_position = Vector2(2300, 150)
    
    create_player_projectile(multiplayer.get_unique_id(), data)


func future_special_attack():
    var data = {}
    data.path = "res://future_special_laser_attack.tscn"
    
    create_player_projectile(multiplayer.get_unique_id(), data)


func _on_button_pressed() -> void:
    MusicManager.audioStreamPlayer.stop()
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
