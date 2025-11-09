extends Area2D
class_name multiplayer_projectile

enum base_side {left = 1, right}

@export var is_player_owned: bool
@export var player_id: int:
    set(id):
        player_id = id
@export var player_side: base_side = base_side.left


func is_player_obj(obj: Node):
    if player_id == 0:
        return obj.is_player_owned == is_player_owned
    return obj.player_id == player_id
