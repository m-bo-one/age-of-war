extends RigidBody2D
class_name base_unit

enum base_side {left = 1, right}

@export var max_health: int

var _health: int = 100
@export var health: int:
    get(): return _health
    set(value):
        _apply_health(value)

@export var damage: int
@export var is_player_owned: bool
@export var player_id: int:
    set(id):
        player_id = id
@export var player_side: base_side = base_side.left


enum state {die, idle, idle_attack, melee_attack, walk, walk_attack}
var current_state: state
var die_sfx: AudioStreamPlayer2D
var money_die_reward


func _apply_health(value: int) -> void:
    # if not max_health means no initialization, so just set health as it is
    if max_health == 0:
        _health = value
        return

    var prev = _health
    _health = clamp(value, 0, max_health)
    $Control/health_bar.size.x = 48 * _health / max_health
    if prev > 0 and _health <= 0:
        _on_death()
        
        
func _on_death() -> void:
    pass


func is_ai():
    return player_id == 0 and is_player_owned == false


func is_player_obj(obj: Node):
    if player_id == 0:
        return obj.is_player_owned == is_player_owned
    return obj.player_id == player_id


func is_right_side():
    return is_player_owned == false or player_side == base_side.right
