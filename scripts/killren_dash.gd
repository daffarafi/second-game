extends State
class_name KillrenDash

@onready var killren: CharacterBody2D = get_parent().get_parent()
@onready var sprite: Sprite2D = killren.get_node("Sprite2D")
@onready var animation_player: AnimationPlayer = killren.get_node("AnimationPlayer")

var dash_timer = 0.0
var dash_direction = 1.0

func Enter():
	# Get dash direction based on current facing direction
	dash_direction = killren.get_facing_direction()
	
	# Reset dash timer
	dash_timer = killren.DASH_DURATION
	
	# Set dash velocity - disable gravity during dash
	killren.velocity.x = dash_direction * killren.DASH_SPEED
	killren.velocity.y = 0  # Cancel any vertical movement
	
	# Play dash animation if available
	if animation_player and animation_player.has_animation("dash"):
		animation_player.play("dash")
	
	# Create simple visual effect
	create_dash_effect()
	
	print("Dash started! Direction: ", dash_direction)

func Physics_Update(delta: float):
	# Countdown dash timer
	dash_timer -= delta
	
	# Maintain dash velocity (no gravity during dash)
	killren.velocity.x = dash_direction * killren.DASH_SPEED
	killren.velocity.y = 0
	
	# Check if dash duration finished
	if dash_timer <= 0:
		_finish_dash()

func _finish_dash():
	# Reset dash state
	killren.is_dashing = false
	
	# Restore normal physics
	killren.velocity.x = move_toward(killren.velocity.x, 0, 200)
	
	# Reset sprite effects
	sprite.modulate.a = 1.0
	
	# Transition back to appropriate state
	if killren.is_on_floor():
		var direction = killren.get_input_direction()
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")
	else:
		Transitioned.emit(self, "Jump")
	
	print("Dash finished!")

func create_dash_effect():
	# Create simple visual effect - make sprite semi-transparent
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate:a", 0.6, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

func Exit():
	# Ensure sprite is fully visible when exiting
	sprite.modulate.a = 1.0
	killren.is_dashing = false
	
	# Stop any dash animation
	if animation_player and animation_player.current_animation == "dash":
		animation_player.stop()
