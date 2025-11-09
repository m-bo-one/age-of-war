extends Node2D

@onready var player_1_spawn_location = $player_1_spawn_location
@onready var player_2_spawn_location = $player_2_spawn_location
@onready var player_1_spawner = $player_1_multi_spawner
@onready var player_2_spawner = $player_2_multi_spawner
@onready var player_1_base = $player_1_base
@onready var player_2_base = $player_2_base

var unit_array : Array
var unable_to_spawn: Dictionary[int, bool]
var medival_special_active : bool

var main_node_path: String = "/root/multiplayer_game"

# Called when the node enters the scene tree for the first time.
func _ready():
    var player = LobbyManager.get_active_player()
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
    medival_special_active = false
    
    


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    $Camera2D/in_game_menu/money.text = str(GlobalVariables.player_money)
    $Camera2D/in_game_menu/exp.text = str(GlobalVariables.player_exp)
    if medival_special_active == true:
        if $medival_special_timer.is_stopped() == true:
            $medival_special_timer.start(5.0)
        for unit in get_node("player_units").get_children():
            # Might want to remove the if statement if I want overhealing to be in the game.
            # Overhealling is actually really good, all specials should be a "game saver".
            unit.max_health += 1
            unit.take_damage(-1)
            if unit.get_node("heal_sprite") == null:
                var sprite = Sprite2D.new()
                sprite.texture = load("res://age of war sprites/effects/heal/medival_special_heal.png")
                sprite.offset = Vector2(0, -74)
                sprite.scale = Vector2(0.8, 0.8)
                sprite.name = "heal_sprite"
                unit.add_child(sprite)
                
                
func is_spawnable() -> bool:
    var id = multiplayer.get_unique_id()
    if not unable_to_spawn.has(id):
        return true
    return not unable_to_spawn[id]
    
    
func set_unable_to_spawn(id: int, res: bool) -> void:
    unable_to_spawn[id] = res


func get_first_player_unit():
    pass
    
func get_first_enemy_unit():
    pass

func get_last_player_unit():
    pass
    
func get_last_enemy_unit():
    pass
    
    

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
    create_player_unit(multiplayer.get_unique_id(), "res://units/future/super_soldier/future_super_soldier.tscn")


func _on_player_spawn_location_body_entered(body):
    if body.is_player_owned == true:
        print("[PEER]=", multiplayer.get_unique_id(), " - _on_player_spawn_location_body_entered: ", body.name)
        set_unable_to_spawn(body.player_id, true)


func _on_player_spawn_location_body_exited(body):
    if body.is_player_owned == true:
        print("[PEER]=", multiplayer.get_unique_id(), " - _on_player_spawn_location_body_exited: ", body.name)
        set_unable_to_spawn(body.player_id, false)

    
func spawn_random_projectiles_from_sky():
    var i = 0
    while i < 25:
        var projectile = load("res://projectile.tscn").instantiate()
        projectile.global_position = Vector2(randf_range(300, 1500), randf_range(-200, -1000))
        projectile.direction = Vector2(randf_range(-0.5, 0.5), randf_range(2, 4)).normalized()
        projectile.damage = 60
        projectile.speed = 300
        projectile.is_player_owned = true
        projectile.spawn_offspring = false
        projectile.time_to_die = 8.0
        projectile.get_node("Sprite2D").texture = load("res://age of war sprites/bases/medival/turret_3/medival_turret_3_projectile_offspring.png")
        get_node(main_node_path).add_child(projectile)
        i += 1

func cave_special_attack():
    var i = 0
    while i < 25:
        var projectile = load("res://cave_special_projectile.tscn").instantiate()
        projectile.global_position = Vector2(randf_range(300, 1500), randf_range(-200, -1000))
        projectile.direction = Vector2(randf_range(-0.5, 0.5), randf_range(2, 4)).normalized()
        projectile.damage = 80
        projectile.speed = randi_range(250, 350)
        projectile.is_player_owned = true
        projectile.spawn_offspring = false
        projectile.time_to_die = 8.0
        projectile.get_node("Sprite2D").rotation = projectile.direction.angle()
        projectile.get_node("CPUParticles2D").direction = projectile.direction.normalized().rotated(PI/2)
        get_node(main_node_path).add_child(projectile)
        i += 1

func knight_special_attack():
    var i = 0
    while i < 35:
        var projectile = load("res://arrow_special_projectile.tscn").instantiate()
        projectile.global_position = Vector2(randf_range(300, 1500), randf_range(-200, -2000))
        projectile.direction = Vector2(randf_range(-0.5, 0.5), randf_range(2, 4)).normalized()
        projectile.damage = 150
        projectile.speed = 400
        projectile.is_player_owned = true
        projectile.spawn_offspring = false
        projectile.time_to_die = 12.0
        projectile.get_node("Sprite2D").rotation = projectile.direction.angle()
        get_node(main_node_path).add_child(projectile)
        i += 1

func medival_special_attack():
    medival_special_active = true

func miltary_special_attack():
    var plane = load("res://miltary_special_plane.tscn").instantiate()
    plane.global_position = Vector2(-100, 150)
    get_node(main_node_path).add_child(plane)

func future_special_attack():
    var laser = load("res://future_special_laser_attack.tscn").instantiate()
    get_node(main_node_path).add_child(laser)
    


func _on_medival_special_timer_timeout():
    medival_special_active = false
    $medival_special_timer.stop()
    for unit in get_node("player_units").get_children():
        if unit.get_node("heal_sprite") != null:
            unit.get_node("heal_sprite").queue_free()


func _on_button_pressed() -> void:
    MusicManager.audioStreamPlayer.stop()
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
