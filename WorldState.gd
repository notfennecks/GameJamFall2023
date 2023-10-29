extends Node2D

var fire_enemy = preload("res://FireEnemy.tscn")
var poison_enemy = preload("res://PoisonEnemy.tscn")

@export var level_label: Label
var level = 1
var spawnNextLevel = false

@onready var player = get_node("Player")

@onready var pause_menu = $PauseMenu
var paused = false

@onready var dialogueControl = $UI/Control/MarginContainer/VBoxContainer/Dialogues

var dialogue = ["You encounter a shy child-like mirror. They ask you if you could help get their kite in a tree.",
				 "A group of mirrors approach you and try to talk to you about video games. You are debating talking to them as its obvious they only want to talk."]
var prompt_good = ["1: Help her get the kite but sacrifice some health.", "1: Talk to them anyways as they seem like nice kids."]
var prompt_bad = ["2: Ignore her kite and keep your health.", "2: Ignore them as it doesn't benefit you in any way talking to them."]

var prompt_ready = false

var endless_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogueEvent(0)
	
func apply_effect(level, x):
	print("applying effect level: ", level, " option: ", x)
	if level == 1 and x == 1:
		#Health regen
		player.health_regen = true
		player.take_damage(10)
	if level == 1 and x == 2:
		#decreased speed more damage
		player.speed /= 1.5
		player.damage_amount = 2
	if level == 2 and x == 1:
		#speed boost
		player.speed *= 1.5
	if level == 2 and x == 2:
		#More health bigger hitbox
		player.health = 35
		player.scale = Vector2(1.5, 1.5)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if($Enemies.get_child_count() == 0 and spawnNextLevel == true):
		if level == 2:
			dialogueEvent(1)
			spawnNextLevel = false
			
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if prompt_ready:
		if Input.is_action_just_pressed("option1"):
			print("Option 1")
			prompt_ready = false
			spawnLevel(level)
			$CanvasModulate.hide()
			dialogueControl.hide()
			if level == 1:
				apply_effect(level, 1)
				print("You gained passive health regen")
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.show()
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.text = "You helped her get her kite and lost some health but gained a (passive health regen)."
				await get_tree().create_timer(4).timeout
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.hide()
			if level == 2:
				apply_effect(level, 1)
				print("You gained speed boost")
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.show()
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.text = "You can be around anyone regardless of what they can do for you, you gain extra speed."
				await get_tree().create_timer(4).timeout
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.hide()
		if Input.is_action_just_pressed("option2"):
			print("Option 2")
			prompt_ready = false
			spawnLevel(level)
			$CanvasModulate.hide()
			dialogueControl.hide()
			if level == 1:
				apply_effect(level, 2)
				print("Decreased speed but more damage")
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.show()
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.text = "Your lack of empathy caused a slight decrease in speed, but you do more damage."
				await get_tree().create_timer(4).timeout
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.hide()
			if level == 2:
				apply_effect(level, 2)
				print("More health but bigger hitbox")
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.show()
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.text = "Your over exagerrated self-importance gave your more health but you are easier to hit."
				await get_tree().create_timer(4).timeout
				$UI/Control/MarginContainer/VBoxContainer/PowerUp.hide()
	
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
	
func dialogueEvent(n):
	$CanvasModulate.show()
	dialogueControl.show()
	dialogueControl.get_node("Dialogue").text = dialogue[n]
	dialogueControl.get_node("Prompts").get_child(0).text = prompt_good[n]
	dialogueControl.get_node("Prompts").get_child(1).text = prompt_bad[n]
	prompt_ready = true
	
func generate_spawn_location():
	randomize()
	var random = randi_range(0, 15)
	var position = get_node("SpawnLocations").get_child(random).position
	return position
	
func spawnLevel(n):
	if n == 1:
		spawnLevel1()
	if n == 2:
		spawnLevel2()
	
func spawnLevel1():
	var wave_count = 5
	var time_between_waves = 3
	var time_between_spawns = 0.5
	var total_enemies = 2
	var additional_enemies_per_wave = 2
	var time_till_next_level = 5
	
	for x in wave_count:
		update_level(1, x + 1)
		print("Wave: ", x + 1, " spawning")
		for n in total_enemies:
			await get_tree().create_timer(time_between_spawns).timeout
			#Fire 100% chance to spawn
			var instance = fire_enemy.instantiate()
			var spawning_position = generate_spawn_location()
			instance.position = spawning_position
			$Enemies.add_child(instance)
		total_enemies += additional_enemies_per_wave
		await get_tree().create_timer(time_between_waves).timeout
		
	await get_tree().create_timer(time_till_next_level).timeout
	level = 2
	spawnNextLevel = true
		
func spawnLevel2():
	var wave_count = 5
	var time_between_waves = 3
	var time_between_spawns = 0.5
	var total_enemies = 3
	var additional_enemies_per_wave = 3
	
	for x in wave_count:
		update_level(2, x + 1)
		for n in total_enemies:
			await get_tree().create_timer(time_between_spawns).timeout
			#Fire 33% chance to spawn Poison 66% chance
			var random = randi_range(0, 2)
			var instance
			if random == 0:
				instance = fire_enemy.instantiate()
			elif random == 1 or 2:
				instance = poison_enemy.instantiate()
			var spawning_position = generate_spawn_location()
			instance.position = spawning_position
			$Enemies.add_child(instance)
		total_enemies += additional_enemies_per_wave
		await get_tree().create_timer(time_between_waves).timeout
	
	endless()

func endless():
	print("Started Endless Good luck")
	endless_time = 0
	level_label.text = str(endless_time)
	$EndlessTimer.start()
	
	var time_between_waves = 5
	var time_between_spawns = 0.5
	var total_enemies = 1
	var additional_enemies_per_wave = 2
	
	var init = [200, 350, 4, 2, 2, 1]
	
	spawnEndlessWave(total_enemies, additional_enemies_per_wave, time_between_spawns,  time_between_waves, init)
	
func spawnEndlessWave(total, additional, spawnTimes, waveGrace, increases):
	print("Spawning endless wave...")
	for n in total:
		await get_tree().create_timer(spawnTimes).timeout
		#Fire 50% chance to spawn Poison 50% chance
		var random = randi_range(0, 1)
		var instance
		if random == 0:
			instance = fire_enemy.instantiate()
			instance.speed = increases[0]
			instance.health = increases[2]
			instance.damage = increases[4]
		elif random == 1:
			instance = poison_enemy.instantiate()
			instance.speed = increases[1]
			instance.health = increases[3]
			instance.damage = increases[5]
		var spawning_position = generate_spawn_location()
		instance.position = spawning_position
		$Enemies.add_child(instance)
			
		increases[0] += 5 #fire speed
		increases[1] += 10 #poison speed
		increases[2] += 0.5 #fire health
		increases[3] += 0.25 #poison health
		increases[4] += 0.5 #fire damage
		increases[5] += 0.25 #poison damage
		
	
	await get_tree().create_timer(waveGrace).timeout
	
	spawnEndlessWave(total + additional, additional, spawnTimes, waveGrace - 0.1, increases)

func update_level(level, wave):
	print(level, "-", wave)
	level_label.text = str(level, "-", wave)


func _on_endless_timer_timeout():
	endless_time += 1
	level_label.text = str(endless_time)
