extends State
class_name AuraAttack

@onready var aura: CharacterBody2D = get_parent().get_parent()
var current_animation = "basic_attack_1"

func Enter():
	# Handle 2-hit combo logic
	if aura.combo_timer <= 0:
		aura.combo_count = 0
	
	aura.combo_count += 1
	aura.combo_timer = aura.combo_window
	
	# Determine animation based on combo (only 2 attacks for Aura)
	match aura.combo_count:
		1:
			current_animation = "basic_attack_1"
		2:
			current_animation = "basic_attack_2"
		_:
			current_animation = "basic_attack_1"
			aura.combo_count = 1
	
	# Play animation
	aura.animation_player.play(current_animation)
	aura.is_attacking = true
	
	# Create a timer to handle animation end
	var timer = Timer.new()
	add_child(timer)
	
	# Set different timings for different attacks
	var wait_time = 0.3
	match current_animation:
		"basic_attack_1":
			wait_time = 0.6
		"basic_attack_2":
			wait_time = 1.2  # Slightly longer for second attack
	
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(_on_attack_finished)
	timer.start()



func _on_attack_finished():
	aura.is_attacking = false
	
	# Reset combo after 2nd attack (not 3rd like diabunny)
	if current_animation == "basic_attack_2":
		aura.reset_combo()
			
	# Transition back based on ground state and input
	if aura.is_on_floor():
		var direction = aura.get_input_direction()
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")
	else:
		Transitioned.emit(self, "Jump")

func Physics_Update(delta: float):
	if aura.is_attacking:
		aura.velocity.x = 0  # Stop movement during attack
		return

func Exit():
	if aura:
		aura.is_attacking = false
