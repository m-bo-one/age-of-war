extends multiplayer_projectile

@export var damage: int
@export var direction : Vector2 # My guess is that direction should be normalised?
@export var speed: float
@export var time_to_die : float = 3.0
var spawn_offspring = false
var offspring_texture


# Called when the node enters the scene tree for the first time.
func _ready():
    self.connect("body_entered", _on_body_entered)
    $Timer.connect("timeout", _on_timer_timeout)
    $Timer.start(time_to_die)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    position += direction * speed * delta


func _on_body_entered(body):
    if player_id != 0 and not multiplayer.is_server():
        return

    if body is melee_unit or body is range_unit:
        print("cave _on_body_entered", body)
        if not is_player_obj(body):
            # not using right now and should be redesigned for multi support
            #if spawn_offspring == true:
                #print("spawn offspring")
                #var i = 0
                #while i < 3:
                    #var offspring = load("res://projectile_offspring.tscn").instantiate()
                    #offspring.global_position = self.global_position
                    #offspring.damage = 10
                    #offspring.direction = Vector2(randf_range(-10, 10), randf_range(-20, -30))
                    #offspring.speed = 10
                    #offspring.is_player_owned = self.is_player_owned
                    #offspring.get_node("Sprite2D").texture = offspring_texture
                    #get_node("/root/main_game").add_child(offspring)
                    #i += 1
            body.take_damage(damage)
            wait_for_particles_to_finish()
    elif body.name == "floor":
        wait_for_particles_to_finish()


func _on_timer_timeout():
    self.queue_free()


func wait_for_particles_to_finish():
    speed = 0
    $Timer.stop()
    $Timer.start(3.0)
    $CPUParticles2D.emitting = false
    $CollisionShape2D.set_deferred("disabled", true)
    $Sprite2D.hide()
