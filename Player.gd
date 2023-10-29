extends CharacterBody2D

@export var speed = 1100

var health = 40
var damage_amount = 1

var health_regen = false

var input = Vector2.ZERO

func _ready():
	$AimDirection/Attack.visible = false
	$HealthBar.max_value = health
	$HealthBar.value = health

func _physics_process(delta):
	player_movement(delta)
	if health_regen == true:
		health_regen = false
		$HealthRegen.start()

func _process(delta):
	player_actions(delta)

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()
	
func player_movement(delta):
	input = get_input()
	
	velocity = input * speed * delta * 20
	velocity = velocity.limit_length(speed)
	
	move_and_slide()

func player_actions(delta):
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
		
	if velocity != Vector2.ZERO:
		$Sprite2D.play("Run")
	else:
		$Sprite2D.play("Idle")
		
	$AimDirection.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("Attack"):
		$AimDirection/Attack.visible = true
		$AimDirection/Attack.play("Attack")
		$AimDirection/Attack/Hitbox.monitoring = true

func _on_attack_animation_finished():
	$AimDirection/Attack/Hitbox.monitoring = false
	$AimDirection/Attack.visible = false

func _on_hitbox_area_entered(area):
	area.get_parent().take_damage(damage_amount)
	
func take_damage(damage):
	health -= damage
	$HealthBar.value = health
	if health <= 0:
		get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_health_regen_timeout():
	health += 1
	$HealthBar.value += 1
