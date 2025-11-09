extends multiplayer_projectile

@export var damage: int = 500
@export var direction : Vector2 = Vector2(0,1)
@export var speed: float = 10
@export var time_to_die : float = 5.0

var acceleration : Vector2 = Vector2(0, 20)
var random_rotation_speed

# Called when the node enters the scene tree for the first time.
func _ready():
    $Timer.start(time_to_die)
    random_rotation_speed = randf_range(-100.0, 100.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if player_side == base_side.left:
        position += direction * speed * delta
        direction += acceleration * delta
        rotation_degrees += random_rotation_speed * delta
        $Sprite2D.flip_h = false
    else:
        position -= direction * speed * delta
        direction -= acceleration * delta
        rotation_degrees -= random_rotation_speed * delta 
        $Sprite2D.flip_h = true
    if direction.y > 0:
        collision_mask = 1


func _on_timer_timeout():
    self.queue_free()


func _on_body_entered(body):
    if body is melee_unit or body is range_unit:
        if not is_player_obj(body):
            body.take_damage(damage)
            spawn_explosion_effect()
            self.queue_free()
    elif body.name == "floor":
        spawn_explosion_effect()
        self.queue_free()

func spawn_explosion_effect():
    var data = {}
    data.path = "res://effects/explosion_effect.tscn"
    data.global_position = global_position
    data.global_position.y -= 64

    var explosion = load(data.path).instantiate()
    explosion.global_position = data.global_position
    get_parent().add_child(explosion)
