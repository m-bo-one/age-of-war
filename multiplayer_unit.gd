extends RigidBody2D
class_name multiplayer_unit

enum base_side {left = 1, right}

@export var max_health: int
@export var health: int
@export var damage: int
@export var is_player_owned: bool
@export var player_id: int:
    set(id):
        player_id = id
@export var player_side: base_side = base_side.left

var heal_tick_accum: float


func take_damage(outside_damage: int):
    health -= outside_damage
    $Control/health_bar.size.x = 48 * health / max_health


func _process(delta: float) -> void:
    # healing through ticks, only for multiplayer
    if player_id == 0:
        print("not a multiplayer unit")
        return

    var heal_aura: Sprite2D = get_node_or_null("heal_sprite")
    var player = LobbyManager.get_player(player_id)
    print("[PEER]=", multiplayer.get_unique_id(), " player: ", player.to_dict())
    
    if player != null and player.is_mass_heal_active:
        if heal_aura != null:
            heal_aura.show()

        heal_tick_accum += delta
        if heal_tick_accum >= 0.1:
            heal_tick_accum = 0.0
            max_health += 5
            take_damage(-5)
    else:
        heal_tick_accum = 0
        if heal_aura != null:
            heal_aura.hide()


func is_player_obj(obj: Node):
    if player_id == 0:
        return obj.is_player_owned == is_player_owned
    return obj.player_id == player_id


func is_right_side():
    return is_player_owned == false or player_side == base_side.right


func is_ai():
    return player_id == 0 and is_player_owned == false
