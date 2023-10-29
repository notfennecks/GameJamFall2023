extends CharacterBody2D

var speed
var player_pos
var target_pos
@onready var player = get_parent().get_parent().get_node("Player")

var health
var damage

func _ready():
	if get_child(0).name == "Fire":
		speed = 200
		health = 4
		damage = 2
	if get_child(0).name == "Poison":
		speed = 350
		health = 2
		damage = 1
		
	$HealthBar.max_value = health
	$HealthBar.value = health

func _physics_process(delta):
	apply_movement(delta)
	
func apply_movement(delta):
	player_pos = player.position
	target_pos = (player_pos - position).normalized()
	
	var direction = (player_pos - global_position).normalized()
	var desired_velocity = direction * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	move_and_slide()
	
func take_damage(damage):
	health -= damage
	$HealthBar.value = health
	if health <= 0:
		queue_free()


func _on_area_2d_body_entered(body):
	body.take_damage(damage)
