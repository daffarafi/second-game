extends CharacterBody2D

const SPEED = 100
const JUMP_VELOCITY = -400.0

# Dash constants
const DASH_SPEED = 400
const DASH_DURATION = 0.1

@onready var animation_player = $AnimationPlayer
@onready var state_machine = $StateMachine
@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hitbox_1 = $Sprite2D/Hitbox/CollisionShape2D1
@onready var hitbox_2 = $Sprite2D/Hitbox2/CollisionShape2D2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false
var is_dashing = false
var combo_count = 0
var combo_timer = 0.0
var combo_window = 1  # 2-hit combo window

func _ready():
	# Ensure state machine is properly initialized after all nodes are ready
	if state_machine and state_machine.has_method("_initialize_state_machine"):
		state_machine.call_deferred("_initialize_state_machine")
	
	# Initialize facing direction (default to right)
	set_facing_direction(1.0)
	
var is_moving_front = false
var movement_target = Vector2.ZERO
var movement_speed = 200.0  # pixels per second

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle combo timer
	if combo_timer > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_count = 0  # Reset combo if timer expires
	
	# Handle smooth front movement
	if is_moving_front:
		handle_front_movement(delta)
	
	move_and_slide()

func handle_front_movement(delta: float):
	# Move towards target smoothly
	var distance_to_target = global_position.distance_to(movement_target)
	
	if distance_to_target < 2:  # Close enough
		global_position = movement_target
		is_moving_front = false
		movement_target = Vector2.ZERO
	else:
		# Move towards target
		var direction_to_target = (movement_target - global_position).normalized()
		var movement_this_frame = direction_to_target * movement_speed * delta
		global_position += movement_this_frame

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

func _on_animation_player_animation_finished():
	if animation_player and (animation_player.animation.begins_with("basic_attack") or animation_player.animation == "skill"):
		is_attacking = false

func move_front(pixels: int = 2):
	# Method 1: Smooth gradual movement (recommended)
	if not is_moving_front:  # Only start new movement if not already moving
		var direction = get_facing_direction()
		movement_target = global_position + Vector2(direction * pixels, 0)
		is_moving_front = true

func move_front_tween(pixels: int = 2):
	# Method 2: Tween movement (alternative)
	var direction = get_facing_direction()
	var target_position = global_position + Vector2(direction * pixels, 0)
	
	# Create tween for smooth movement
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.1)  # 0.1 seconds duration
