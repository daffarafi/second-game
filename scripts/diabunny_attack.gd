extends State
class_name DiabunnyBasicAttack

@onready var diabunny:CharacterBody2D = get_parent().get_parent()
var current_animation = ""

func Enter():
	# Handle combo logic
	if diabunny.combo_timer <= 0:
		# If combo window expired, reset combo
		diabunny.combo_count = 0
	
	# Get current combo count and play appropriate animation
	diabunny.combo_count += 1
	diabunny.combo_timer = diabunny.combo_window  # Reset combo timer
	
	# Determine which animation to play
	match diabunny.combo_count:
		1:
			current_animation = "basic_attack_1"
		2:
			current_animation = "basic_attack_2"
		3:
			current_animation = "basic_attack_3"
			# Don't reset combo_count here, let it reset after animation finishes
		_:
			current_animation = "basic_attack_1"
			diabunny.combo_count = 1
	
	diabunny.animation_player.play(current_animation)
	diabunny.is_attacking = true
	
	# Create a timer to handle animation end
	var timer = Timer.new()
	add_child(timer)
	
	# Set different timings for different attacks if needed
	var wait_time = 0.2
	match current_animation:
		"basic_attack_1":
			wait_time = 0.4
		"basic_attack_2":
			wait_time = 0.2667
		"basic_attack_3":
			wait_time = 0.2667
	
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(_on_attack_finished)
	timer.start()

func _on_attack_finished():
	diabunny.is_attacking = false
	
	# Reset combo after 3rd attack
	if current_animation == "basic_attack_3":
		diabunny.reset_combo()
			
	# Transition back based on ground state and input
	if diabunny.is_on_floor():
		var direction = diabunny.get_input_direction()
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")
	else:
		Transitioned.emit(self, "Jump")

func Physics_Update(_delta: float):
	if diabunny.is_attacking :
		diabunny.velocity.x = 0
		return
	

func Exit():
	diabunny.is_attacking = false
