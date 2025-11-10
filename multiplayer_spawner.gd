extends MultiplayerSpawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    spawn_function = _on_unit_spawn


# data is
#"path": path,
#"player_id":  player_id,
#"position": player_unit_spawn_position,
#"base_side": base_side,
#"is_player_owned": true,
# 
func _on_unit_spawn(data: Dictionary) -> Node:
    var unit: multiplayer_unit = load(data.path).instantiate()
    
    unit.player_id = data.player_id
    unit.position = data.position
    unit.is_player_owned = data.is_player_owned
    if data.base_side == 1:
        unit.position.x -= 32
    else:
        unit.position.x += 32
    
    unit.player_side = data.base_side
    unit.visible = false
    
    # adding for medieval special
    var sprite = Sprite2D.new()
    sprite.name = "heal_sprite"
    sprite.texture = load("res://age of war sprites/effects/heal/medival_special_heal.png")
    sprite.offset = Vector2(0, -74)
    sprite.scale = Vector2(0.8, 0.8)
    sprite.visible = false
    
    unit.add_child(sprite)
    
    # adding unit fog detector
    var fog_detector = load("res://scenes/multiplayer/unit_fog_detector.tscn").instantiate()
    unit.add_child(fog_detector)
        
    print("[PEER]=", multiplayer.get_unique_id(), " - unit spawn: ", data)

    return unit
