extends multiplayer_projectile

var direction
var speed
var timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
    direction = Vector2.RIGHT
    speed = 200
    timer = get_node("Timer")
    timer.paused = true
    timer.wait_time = 1.5
    $AudioStreamPlayer2D.bus = &'sfx'
    $AudioStreamPlayer2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
    if player_id == 0:
        _process_singleplayer(delta)
        return

    _process_multiplayer(delta)
        
        
func _process_singleplayer(delta: float):
    position.x +=  speed * delta
    
    if position.x > 2400:
        self.queue_free()
    elif position.x > 1500:
        timer.stop()
    elif position.x > 200 and timer.is_paused() == true:
        timer.start(0.5)
        timer.paused = false
        

## Values for position is better to recheck
func _process_multiplayer(delta: float):
    if player_side == base_side.left:
        position.x += speed * delta
        $AnimatedSprite2D.flip_h = false
        
        if position.x > 2250:
            self.queue_free()
        elif position.x > 1875:
            timer.stop()
        elif position.x > 310 and timer.is_paused() == true:
            timer.start(0.5)
            timer.paused = false
    else:
        print("_process_multiplayer right plane: ", position)
        position.x -= speed * delta
        $AnimatedSprite2D.flip_h = true
        
        if position.x < -100:
            self.queue_free()
        elif position.x < 310:
            timer.stop()
        elif position.x < 1875 and timer.is_paused() == true:
            timer.start(0.5)
            timer.paused = false

    
func spawn_bomb():
    var data = {}
    data.path = "res://projectile_miltary_special_bomb.tscn"
    data.global_position = global_position
    
    if player_side == base_side.left:
        data.global_position.y += 16
    else:
        data.global_position.y -= 16
    data.is_player_owned = is_player_owned
    data.player_id = player_id
    data.player_side = player_side
    
    if data.player_id != 0:
        SignalBus.spawn_projectile.emit(data.player_id, data)
    else:
        # should be revorked for single player and use bus mechanics
        var bomb = load(data.path).instantiate()
        bomb.global_position = data.global_position
        bomb.is_player_owned = data.is_player_owned
        get_node("/root/main_game").add_child(bomb)


func _on_bomb_timer_timeout():
    spawn_bomb()
