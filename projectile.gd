extends multiplayer_projectile

@export var damage: int
@export var direction: Vector2 # My guess is that direction should be normalised?
@export var speed: float
@export var time_to_die : float = 3.0

var spawn_offspring = false
var offspring_texture
var rotation_speed: float

var spawn_explosion_effect

# Called when the node enters the scene tree for the first time.
func _ready():
    self.connect("body_entered", _on_body_entered)
    $Timer.start(time_to_die)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    position += direction * speed * delta
    $Sprite2D.rotation_degrees += rotation_speed * delta



func _on_body_entered(body):
    if body is melee_unit or body is range_unit:
        if not is_player_obj(body):
            #if spawn_offspring == true:
                #var i = 0
                #while i < 3:
                    #var offspring = load("res://projectile_offspring.tscn").instantiate()
                    #offspring.global_position = self.global_position
                    #offspring.damage = 10
                    #offspring.direction = Vector2(randf_range(-10, 10), randf_range(-20, -30))
                    #offspring.speed = 10
                    #offspring.is_player_owned = self.is_player_owned
                    #offspring.get_node("Sprite2D").texture = offspring_texture
                    #if spawn_explosion_effect == true:
                        #offspring.spawn_explosion_effect = true
                    #get_node("/root/main_game").add_child(offspring)
                    #i += 1
            body.take_damage(damage)
            if spawn_explosion_effect == true:
                var data = {}
                data.path = "res://effects/explosion_effect.tscn"
                data.global_position = global_position
                data.global_position.y -= 32
                data.scale = Vector2(0.25, 0.25)
                data.is_player_owned = is_player_owned
                data.player_id = player_id
                data.player_side = player_side
                
                if data.player_id != 0:
                    SignalBus.spawn_projectile.emit(data.player_id, data)
                else:
                    # should be revorked for single player and use bus mechanics
                    var explosion = load(data.path).instantiate()
                    explosion.global_position = data.global_position
                    explosion.scale = data.scale
                    explosion.is_player_owned = data.is_player_owned
                    get_node("/root/main_game").add_child(explosion)
            self.queue_free()
    #elif body.name == "floor":
        #if spawn_offspring == true:
            #var i = 0
            #while i < 3:
                #var offspring = load("res://projectile_offspring.tscn").instantiate()
                #offspring.global_position = self.global_position
                #offspring.damage = 10
                #offspring.direction = Vector2(randf_range(-10, 10), randf_range(-20, -30))
                #offspring.speed = 10
                #offspring.is_player_owned = self.is_player_owned
                #offspring.get_node("Sprite2D").texture = offspring_texture
                #if spawn_explosion_effect == true:
                    #offspring.spawn_explosion_effect = true
                #get_node("/root/main_game").add_child(offspring)
                #i += 1
            #if spawn_explosion_effect == true:
                #var explosion = load("res://effects/explosion_effect.tscn").instantiate()
                #explosion.global_position = self.global_position
                #explosion.global_position.y -= 48 - randi_range(0, 32)
                #explosion.scale = Vector2(0.25, 0.25)
                #get_node("/root/main_game").add_child(explosion)
                #
                #var fire = load("res://effects/fire_effect.tscn").instantiate()
                #fire.global_position = self.global_position
                #fire.global_position.y -= 32 - randi_range(0, 32)
                #fire.scale = Vector2(0.125, 0.125)
                #get_node("/root/main_game").add_child(fire)
            #self.queue_free()
        #
    


func _on_timer_timeout():
    self.queue_free()
