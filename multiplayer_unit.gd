extends base_unit
class_name multiplayer_unit

var _fog_visible: bool = false
var fog_visible: bool:
    get(): return _fog_visible
    set(value):
        if value == _fog_visible:
            return

        _fog_visible = value
        _update_visibility()

var heal_tick_accum: float

var _fog_seen_count: int = 0


func add_fog_source() -> void:
    _fog_seen_count += 1
    fog_visible = _fog_seen_count > 0


func remove_fog_source() -> void:
    _fog_seen_count = max(_fog_seen_count - 1, 0)
    fog_visible = _fog_seen_count > 0


func on_die_callback() -> void:
    pass
        
        
func _on_death() -> void:
    if _health <= 0 and current_state != state.die:
        on_die_callback()
        
        if player_id != 0:
            if multiplayer.is_server():
                var op_player = LobbyManager.get_opponent_player(player_id)
                LobbyManager.update_money.rpc_id(op_player.id, op_player.id, money_die_reward)
                spawn_show_death_money.rpc_id(op_player.id)
        elif is_ai():
            GlobalVariables.player_exp += int(money_die_reward/2)
        else:
            GlobalVariables.player_money += money_die_reward
            GlobalVariables.player_exp += 2 * money_die_reward
            spawn_show_death_money()


@rpc("any_peer", "call_local")
func spawn_show_death_money():
    var effect = load("res://show_death_money.tscn").instantiate()
    effect.global_position = $Control.global_position
    effect.get_node("Label").text = " +" + str(money_die_reward)
    get_parent().add_child(effect)


func take_damage(outside_damage: int):
    if multiplayer.is_server():
        health -= outside_damage
    
    
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
    print("[PEER]=", multiplayer.get_unique_id(), " update_visibility - ", player_id, " ; local owner ", _is_local_owner(), " ; fog_visible ", _fog_visible)
    var should_be_visible = _is_local_owner() or _fog_visible
    
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
