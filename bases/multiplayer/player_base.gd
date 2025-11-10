extends StaticBody2D

enum base_side {left = 1, right}

@export var is_player_owned: bool = true
@export var health: int
@export var max_health: int
@export var player_id: int = 0:
    set(id):
        player_id = id
@export var player_side: base_side = base_side.left

var turret_array : Array
var turret_data : Array

# I am so stupid -> this is required so units can attack the base
var current_state = 9999
enum state {attack, die, idle, walk}

# Called when the node enters the scene tree for the first time.
func _ready():
    health = 500
    max_health = 500
    # -1 unavailable to build (because no space)
    # 0 means no turret (but there is space to build)
    # 1 means there is a turret
    # first element is for base
    # second is for bottom
    # third is for part
    # fourth is for top
    turret_array = [-1,-1,-1,-1]
    turret_data = [null, null, null, null]
    $tower_bottom.hide()
    $tower_part.hide()
    $tower_top.hide()
    
    if scale.x == -1:
        $Label.scale.x = -1
        $Label.position.x = -20
    $Label.text = str(health)
    
    deactivate_buttons()


func activate_buttons():
    for button in get_node("button_container").get_children():
        button.disabled = false

func deactivate_buttons():
    for button in get_node("button_container").get_children():
        button.disabled = true

func hide_buttons():
    for button in get_node("button_container").get_children():
        button.hide()


func take_damage(damage):
    health -= damage
    $PanelContainer/current_health.custom_minimum_size.y = 250 * health/max_health
    $Label.text = str(health)
    if health <= 0:
        if player_id == multiplayer.get_unique_id():
            MusicManager.audioStreamPlayer.stop()
            get_tree().change_scene_to_file("res://scenes/game_over.tscn")
        else:
            MusicManager.audioStreamPlayer.stop()
            get_tree().change_scene_to_file("res://scenes/win_screen.tscn")


@rpc("any_peer", "call_local")
func advance_base_sprite(stage: GlobalVariables.stage):
    if stage == GlobalVariables.stage.knight:
        $base_main_sprite.texture = load("res://age of war sprites/bases/knight/base/base.png")
        $tower_bottom.texture = load("res://age of war sprites/bases/knight/tower_base/base_tower_bottom.png")
        $tower_part.texture = load("res://age of war sprites/bases/knight/tower_part/base_tower_part.png")
        $tower_top.texture = load("res://age of war sprites/bases/knight/tower_top/base_tower_top.png")
        health += 600
        max_health = 1100
        $PanelContainer/current_health.custom_minimum_size.y = 250 * health/max_health
    elif stage == GlobalVariables.stage.medival:
        $base_main_sprite.texture = load("res://age of war sprites/bases/medival/base/base.png")
        $tower_bottom.texture = load("res://age of war sprites/bases/medival/tower_base/base_tower_bottom.png")
        $tower_part.texture = load("res://age of war sprites/bases/medival/tower_part/base_tower_part.png")
        $tower_top.texture = load("res://age of war sprites/bases/medival/tower_top/base_tower_top.png")
        health += 900
        max_health = 2000
        $PanelContainer/current_health.custom_minimum_size.y = 250 * health/max_health
    elif stage == GlobalVariables.stage.miltary:
        $base_main_sprite.texture = load("res://age of war sprites/bases/miltary/base/base.png")
        $tower_bottom.texture = load("res://age of war sprites/bases/miltary/tower_base/base_tower_bottom.png")
        $tower_part.texture = load("res://age of war sprites/bases/miltary/tower_part/base_tower_part.png")
        $tower_top.texture = load("res://age of war sprites/bases/miltary/tower_top/base_tower_top.png")
        health += 1200
        max_health = 3200
        $PanelContainer/current_health.custom_minimum_size.y = 250 * health/max_health
    elif stage == GlobalVariables.stage.future:
        $base_main_sprite.texture = load("res://age of war sprites/bases/future/base/base.png")
        $tower_bottom.texture = load("res://age of war sprites/bases/future/tower_base/base_tower_bottom.png")
        $tower_part.texture = load("res://age of war sprites/bases/future/tower_part/base_tower_part.png")
        $tower_top.texture = load("res://age of war sprites/bases/future/tower_top/base_tower_top.png")
        health += 1500
        max_health = 4700
        $PanelContainer/current_health.custom_minimum_size.y = 250 * health/max_health
    $Label.text = str(health)
