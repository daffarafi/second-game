extends State
class_name DiabunnyDash

@onready var diabunny: CharacterBody2D = get_parent().get_parent()
@onready var sprite: Sprite2D = diabunny.get_node("Sprite2D")
@onready var animation_player: AnimationPlayer = diabunny.get_node("AnimationPlayer")

var dash_timer = 0.0
var dash_direction = 1.0

func Enter():
	# Get dash direction based on current facing direction
	dash_direction = diabunny.get_facing_direction()
	
	# Reset dash timer
	dash_timer = diabunny.DASH_DURATION
	
	# Set dash velocity - disable gravity during dash
	diabunny.velocity.x = dash_direction * diabunny.DASH_SPEED
	diabunny.velocity.y = 0  # Cancel any vertical movement
	
	# Play dash animation if available
	if animation_player and animation_player.has_animation("dash"):
		animation_player.play("dash")
	
	print("Dash started! Direction: ", dash_direction)

func Physics_Update(delta: float):
	# Countdown dash timer
	dash_timer -= delta
	
	# Maintain dash velocity (no gravity during dash)
	diabunny.velocity.x = dash_direction * diabunny.DASH_SPEED
	diabunny.velocity.y = 0
	
	# Check if dash duration finished
	if dash_timer <= 0:
		_finish_dash()

func _finish_dash():
	# Reset dash state
	diabunny.is_dashing = false
	
	# Restore normal physics
	diabunny.velocity.x = move_toward(diabunny.velocity.x, 0, 200)
	
	# Reset sprite effects
	sprite.modulate.a = 1.0
	
	Transitioned.emit(self, "Idle")
	
	print("Dash finished!")



func Exit():
	# Ensure sprite is fully visible when exiting
	sprite.modulate.a = 1.0
	diabunny.is_dashing = false
	
	# Stop any dash animation
	if animation_player and animation_player.current_animation == "dash":
		animation_player.stop()
