extends CharacterBody2D

@onready var state_machine = $StateMachine
@onready var animated_sprite = $AnimatedSprite2D

var max_health = 100
var current_health = 100
var is_hurt = false

func _ready():
	current_health = max_health

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func take_damage(amount: int, attacker_position: Vector2 = Vector2.ZERO) -> void:
	if is_hurt:
		return  # Already hurt, ignore additional damage
	
	current_health -= amount
	print("Kast took damage: " + str(amount) + ". Health: " + str(current_health) + "/" + str(max_health))
	
	# Calculate knockback direction based on attacker position
	var knockback_dir = 1
	if attacker_position != Vector2.ZERO:
		knockback_dir = sign(global_position.x - attacker_position.x)
		if knockback_dir == 0:
			knockback_dir = 1
	
	# Transition to hurt state
	is_hurt = true
	if state_machine:
		var hurt_state = state_machine.states.get("hurt")
		if hurt_state and hurt_state.has_method("set_knockback_direction"):
			hurt_state.set_knockback_direction(knockback_dir)
		state_machine.on_child_transition(state_machine.current_state, "Hurt")
	
	# Check if dead
	if current_health <= 0:
		die()

func die():
	print("Kast died!")
	# TODO: Implement death logic
	# For now, just reset health
	current_health = max_health
	is_hurt = false

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	print("Kast healed: " + str(amount) + ". Health: " + str(current_health) + "/" + str(max_health))

func reset_hurt_state():
	is_hurt = false
