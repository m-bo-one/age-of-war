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
    var unit = load(data.path).instantiate()
    
    unit.player_id = data.player_id
    unit.position = data.position
    unit.is_player_owned = data.is_player_owned
    if data.base_side == 1:
        unit.position.x -= 32
    else:
        unit.position.x += 32
    
    unit.player_side = data.base_side
        
    print("[PEER]=", multiplayer.get_unique_id(), " - unit spawn: ", data)

    return unit
