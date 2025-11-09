extends multiplayer_projectile


var number_of_steps: int
var start_point: int
var i: int

# Called when the node enters the scene tree for the first time.
func _ready():
    $Timer.start(0.10)
    
    if player_id != 0:
        number_of_steps = 24
        start_point = 310 if player_side == base_side.left else 1875
    else:
        number_of_steps = 20
        start_point = 250


func _on_timer_timeout():
    if i == number_of_steps:
        self.queue_free()
    else:
        i += 1

        var data = {}
        data.path = "res://future_special_laser.tscn"
        if player_side == base_side.left:
            data.global_position = Vector2(start_point + 64 * i, 570)
        else:
            data.global_position = Vector2(start_point - 64 * i, 570)
        data.is_player_owned = is_player_owned
        data.player_id = player_id
        data.player_side = player_side

        if data.player_id != 0:
            SignalBus.spawn_projectile.emit(data.player_id, data)
        else:
            # should be revorked for single player and use bus mechanics
            var laser = load(data.path).instantiate()
            laser.global_position = data.global_position
            laser.is_player_owned = data.is_player_owned
            get_node("/root/main_game").add_child(laser)
