extends multiplayer_projectile

@export var damage: int = 10
@export var direction : Vector2 = Vector2(0,0)
@export var time_to_die : float = 5.0
@export var speed: float = 10

var acceleration : Vector2 = Vector2(0, 20)

# Called when the node enters the scene tree for the first time.
func _ready():
    $Timer.start(time_to_die)


func _on_body_entered(body):
    if player_id != 0 and not multiplayer.is_server():
        return

    if body is melee_unit or body is range_unit:
        if body.is_player_owned != self.is_player_owned:
            body.take_damage(damage)
            print("spawn explosion effect")
            self.queue_free()
    elif body.name == "floor":
        print("spawn explosion effect")
        self.queue_free()
