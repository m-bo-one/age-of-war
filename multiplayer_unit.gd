extends RigidBody2D
class_name multiplayer_unit

enum base_side {left = 1, right}

@export var player_id: int = 0:
    set(id):
        player_id = id
@export var player_side: base_side = base_side.left
