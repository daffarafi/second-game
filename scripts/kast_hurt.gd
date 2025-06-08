extends State
class_name KastHurt

@onready var kast: CharacterBody2D = get_parent().get_parent()
@onready var animated_sprite: AnimatedSprite2D = kast.get_node("AnimatedSprite2D")
@onready var timer: Timer = kast.get_node("Timer")

var hurt_duration = 0.2  # Duration of hurt state in seconds
var knockback_force = 100  # Knockback force when hurt
var knockback_direction = 1  # Direction of knockback (1 = right, -1 = left)

func Enter():
	# Play hurt animation if available
	animated_sprite.play("hurt")
	
	kast.velocity.x = knockback_direction * knockback_force
	
	# Set timer for hurt duration
	timer.wait_time = hurt_duration
	timer.one_shot = true
	timer.timeout.connect(_on_hurt_finished)
	timer.start()
	
	# Make Kast invulnerable during hurt state (disable hurtbox)
	var hurtbox = kast.get_node("Hurtbox")
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)

func _on_hurt_finished():
	# Re-enable hurtbox
	var hurtbox = kast.get_node("Hurtbox")
	if hurtbox:
		hurtbox.set_deferred("monitoring", true)
	
	# Reset hurt state
	kast.reset_hurt_state()
	
	# Transition back to idle
	Transitioned.emit(self, "Idle")

func Physics_Update(_delta: float):
	# Apply gravity during hurt state
	if not kast.is_on_floor():
		kast.velocity += kast.get_gravity() * _delta
	
	# Gradually reduce knockback
	kast.velocity.x = move_toward(kast.velocity.x, 0, 200 * _delta)

func Exit():
	# Ensure sprite is fully visible when exiting hurt state
	animated_sprite.modulate.a = 1.0
	
	# Disconnect timer signal if still connected
	if timer.timeout.is_connected(_on_hurt_finished):
		timer.timeout.disconnect(_on_hurt_finished)

func set_knockback_direction(direction: float):
	knockback_direction = sign(direction)
