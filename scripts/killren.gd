extends CharacterBody2D

const SPEED = 100
const JUMP_VELOCITY = -300.0

# Dash constants
const DASH_SPEED = 400
const DASH_DURATION = 0.1

# Magic attack constants
const ATTACK_RANGE = 150  # Range for magic attacks
const SKILL_RANGE = 200   # Range for skill attacks
const ATTACK_DAMAGE = 20
const SKILL_DAMAGE = 35

#@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var state_machine = $StateMachine
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hitbox_area = $Hitbox
@onready var hitbox_collision = $Hitbox/CollisionShape2D
@onready var hitbox_animation = $Hitbox/AnimatedSprite2D
@onready var attack_area = $AttackRangeArea2D

var enemy_arr: Array[CharacterBody2D] = []

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false
var is_dashing = false
var combo_count = 0
var combo_timer = 0.0
var combo_window = 0.8  

func _ready():
	# Ensure state machine is properly initialized after all nodes are ready
	if state_machine and state_machine.has_method("_initialize_state_machine"):
		state_machine.call_deferred("_initialize_state_machine")
	
	# Initialize facing direction (default to right)
	set_facing_direction(1.0)
	
	# Initialize hitboxes as disabled
	initialize_hitboxes()

func initialize_hitboxes():
	# Ensure hitbox starts disabled
	if hitbox_collision:
		hitbox_collision.disabled = true
	if hitbox_area:
		hitbox_area.monitoring = false
	# Hide hitbox animation initially
	if hitbox_animation:
		hitbox_animation.visible = false

# Hitbox management functions
func enable_hitbox():
	if hitbox_area:
		hitbox_area.monitoring = true
	if hitbox_collision:
		hitbox_collision.disabled = false
	# Show and play strike animation when hitbox is enabled
	if hitbox_animation:
		hitbox_animation.visible = true
		hitbox_animation.play("strike")

func disable_hitbox():
	if hitbox_area:
		hitbox_area.monitoring = false
	if hitbox_collision:
		hitbox_collision.disabled = true
	# Hide and stop animation when hitbox is disabled
	if hitbox_animation:
		hitbox_animation.visible = false
		hitbox_animation.stop()

func setup_hitbox_damage(attack_type: String):
	# Set different damage for different attacks
	if hitbox_area and hitbox_area.has_method("set_damage"):
		match attack_type:
			"basic_attack_1":
				hitbox_area.damage = 10
			"basic_attack_2":
				hitbox_area.damage = 15
			"basic_attack_3":
				hitbox_area.damage = 25
			"skill":
				hitbox_area.damage = 35
			_:
				hitbox_area.damage = 10

func setup_hitbox_animation(attack_type: String):
	# Set different animations for different attacks (optional)
	if hitbox_animation:
		match attack_type:
			"basic_attack_1":
				hitbox_animation.play("light_strike")  # Normal strike
			"basic_attack_2":
				hitbox_animation.play("medium_strike")  # Same for now
			"basic_attack_3":
				hitbox_animation.play("heavy_strike")  # Same for now
			_:
				hitbox_animation.play("light_strike")

func spawn_hitbox_at_target(target_position: Vector2, attack_type: String):
	# Setup hitbox damage
	setup_hitbox_damage(attack_type)
	
	# Store original position
	var original_position = hitbox_area.global_position
	
	# Move hitbox to target location
	hitbox_area.global_position = target_position
	
	# Enable hitbox temporarily and setup animation
	enable_hitbox()
	setup_hitbox_animation(attack_type)
	
	print("Spawned hitbox at target location: ", target_position)
	
	# Create timer to disable hitbox and return to original position
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.32  # Hitbox active for 0.32 seconds
	timer.one_shot = true
	timer.timeout.connect(_on_hitbox_timeout.bind(original_position, timer))
	timer.start()

func _on_hitbox_timeout(original_position: Vector2, timer: Timer):
	# Disable hitbox and return to original position
	disable_hitbox()
	if hitbox_area:
		hitbox_area.global_position = original_position
	
	# Clean up timer
	if timer:
		timer.queue_free()

# Functions to manage enemy array from attack_area
func add_enemy_to_range(enemy: CharacterBody2D):
	if not enemy_arr.has(enemy):
		enemy_arr.append(enemy)
		print("Enemy added to range: ", enemy.name, " | Total enemies: ", enemy_arr.size())

func remove_enemy_from_range(enemy: CharacterBody2D):
	if enemy_arr.has(enemy):
		enemy_arr.erase(enemy)
		print("Enemy removed from range: ", enemy.name, " | Total enemies: ", enemy_arr.size())

func get_closest_enemy() -> CharacterBody2D:
	if enemy_arr.is_empty():
		return null
	
	# Clean up invalid enemies first
	enemy_arr = enemy_arr.filter(func(enemy): return is_instance_valid(enemy))
	
	if enemy_arr.is_empty():
		return null
		
	var closest_enemy = enemy_arr[0]  # Default to first enemy
	var closest_distance = global_position.distance_to(closest_enemy.global_position)
	
	# Find actually closest enemy
	for enemy in enemy_arr:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle combo timer
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_count = 0  # Reset combo if timer expires
	
	move_and_slide()

# Magic attack function - now uses Area2D detection
func find_closest_enemy_in_range(range: float) -> Node2D:
	# Use the Area2D detection instead of physics query
	return get_closest_enemy()

func get_input_direction() -> float:
	return Input.get_axis("move_left", "move_right")

func get_facing_direction() -> float:
	# Return 1 for right, -1 for left based on scale.x
	if sprite.scale.x > 0:
		return 1.0  # Facing right
	else:
		return -1.0  # Facing left

func set_facing_direction(direction: float):
	# Use scale.x to flip entire character (sprite + hitbox + all children)
	if direction > 0:
		sprite.scale.x = 1.0  # Face right
	elif direction < 0:
		sprite.scale.x = -1.0  # Face left

func reset_combo():
	combo_count = 0
	combo_timer = 0.0

func handle_movement(direction: float):
	if direction != 0:
		velocity.x = direction * SPEED
		# Flip entire character based on direction using scale.x
		set_facing_direction(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		return true
	return false

func attack():
	if not is_attacking:
		# Let the state machine handle the combo logic
		return true
	return false

func skill():
	if not is_attacking:
		is_attacking = true
		if animation_player:
			animation_player.play("skill")
		return true
	return false

func dash():
	# Dash functionality is handled by the dash state
	# This method can be used for additional dash logic if needed
	return true

func _on_animation_player_2d_animation_finished():
	if animation_player and (animation_player.animation.begins_with("basic_attack") or animation_player.animation == "skill"):
		is_attacking = false

func move_front(pixels: int = 2):
	var direction = get_facing_direction()
	var movement = Vector2(direction * pixels, 0)
	move_and_collide(movement)

func magic_attack():
	if not is_attacking:
		return true
	return false

func magic_skill():
	if not is_attacking:
		is_attacking = true
		return true
	return false
