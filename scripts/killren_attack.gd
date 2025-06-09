extends State
class_name BasicAttack

@onready var killren: CharacterBody2D = get_parent().get_parent()
var current_animation = "basic_attack_1"

func Enter():
	# Handle combo logic
	if killren.combo_timer <= 0:
		killren.combo_count = 0
	
	killren.combo_count += 1
	killren.combo_timer = killren.combo_window
	
	# Determine animation based on combo
	match killren.combo_count:
		1:
			current_animation = "basic_attack_1"
		2:
			current_animation = "basic_attack_2"
		3:
			current_animation = "basic_attack_3"
		_:
			current_animation = "basic_attack_1"
			killren.combo_count = 1
	
	# Play animation
	killren.animation_player.play(current_animation)
	killren.is_attacking = true
	
	# Find and damage closest enemy in range
	perform_magic_attack()
	
	# Create a timer to handle animation end
	var timer = Timer.new()
	add_child(timer)
	
	# Set different timings for different attacks
	var wait_time = 0.3
	match current_animation:
		"basic_attack_1":
			wait_time = 0.3
		"basic_attack_2":
			wait_time = 0.35
		"basic_attack_3":
			wait_time = 0.4
	
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(_on_attack_finished)
	timer.start()

func perform_magic_attack():
	# Use Area2D detection to find target
	var target = null
	
	# Get first enemy in range (enemy_arr[0])
	if not killren.enemy_arr.is_empty():
		# Clean up invalid enemies first
		killren.enemy_arr = killren.enemy_arr.filter(func(enemy): return is_instance_valid(enemy))
		
		if not killren.enemy_arr.is_empty():
			target = killren.enemy_arr[0]  # Use first enemy in array
	
	if target:
		print("Magic attack targeting: ", target.name)
		# Spawn hitbox at target location based on combo count
		spawn_hitbox_at_target(target.global_position)
		
		# Create visual effect (you can add particles here)
		create_magic_effect(target.global_position)
	else:
		print("No enemy in range for magic attack")

func spawn_hitbox_at_target(target_position: Vector2):
	# Use single hitbox for all attacks
	killren.spawn_hitbox_at_target(target_position, current_animation)

func _on_hitbox_timeout(hitbox: CollisionShape2D, original_position: Vector2, timer: Timer):
	# This function is no longer needed since killren.gd handles it
	pass

func create_magic_effect(target_position: Vector2):
	# Simple visual feedback for magic attack
	# You can replace this with particle effects or magic projectiles
	print("Magic effect created at: ", target_position)
	
	# Optional: Create a simple tween effect
	var effect_sprite = Sprite2D.new()
	get_tree().current_scene.add_child(effect_sprite)
	effect_sprite.global_position = target_position
	effect_sprite.modulate = Color.CYAN
	
	# Animate the effect
	var tween = create_tween()
	tween.parallel().tween_property(effect_sprite, "scale", Vector2(2, 2), 0.3)
	tween.parallel().tween_property(effect_sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(effect_sprite.queue_free)

func _on_attack_finished():
	killren.is_attacking = false
	
	# Reset combo after 3rd attack
	if current_animation == "basic_attack_3":
		killren.reset_combo()
			
	# Transition back based on ground state and input
	if killren.is_on_floor():
		var direction = killren.get_input_direction()
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")
	else:
		Transitioned.emit(self, "Jump")

func Physics_Update(_delta: float):
	if killren.is_attacking:
		killren.velocity.x = 0  # Stop movement during attack
		return

func Exit():
	if killren:
		killren.is_attacking = false
