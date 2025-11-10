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

var fog_visible: bool = false:
    set(value):
        if value == fog_visible:
            return

        fog_visible = value
        _update_visibility()

var heal_tick_accum: float


func take_damage(outside_damage: int):
    health -= outside_damage
    $Control/health_bar.size.x = 48 * health / max_health
    
    
func _ready() -> void:
    _update_visibility()
    
    var fog_detector = get_node_or_null("UnitFogDetector")
    if fog_detector != null:
        if is_right_side():
            fog_detector.scale.x = -1
        else:
            fog_detector.scale.x = 1
        
        
func _is_local_owner() -> bool:
    # single player
    if player_id == 0:
        return true

    var player = LobbyManager.get_active_player()
    if player == null:
        return false
    return player.id == player_id


var _fade_tween: Tween
        
func _update_visibility() -> void:
    print("[PEER]=", multiplayer.get_unique_id(), "_update_visibility - ", player_id, " ; local owner ", _is_local_owner(), " ; fog_visible ", fog_visible)
    var should_be_visible = _is_local_owner() or fog_visible
    
    var sprite = get_node_or_null("AnimatedSprite2D")
    if sprite == null:
        visible = should_be_visible
        print("sprite not found")
        return
        
    if should_be_visible:
        visible = true

    if _fade_tween and _fade_tween.is_running():
        _fade_tween.kill()

    _fade_tween = create_tween()
    if should_be_visible:
        print("should be visible")
        _fade_tween.tween_property(sprite, "modulate:a", 1, 1)
    else:
        _fade_tween.tween_property(sprite, "modulate:a", 0, 1)
        _fade_tween.tween_callback(func (): visible = false)
        

func _process(delta: float) -> void:
    # healing through ticks, only for multiplayer
    if player_id == 0:
        return

    var heal_aura: Sprite2D = get_node_or_null("heal_sprite")
    var player = LobbyManager.get_player(player_id)
    
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
