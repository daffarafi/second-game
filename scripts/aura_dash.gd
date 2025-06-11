extends State
class_name AuraDash

@onready var aura: CharacterBody2D = get_parent().get_parent()
var dash_timer = 0.0

func Enter():
	# Play dash animation
	if aura.animation_player:
		aura.animation_player.play("dash")
	
	aura.is_dashing = true
	dash_timer = aura.DASH_DURATION
	
	# Apply dash velocity in facing direction
	var dash_direction = aura.get_facing_direction()
	aura.velocity.x = dash_direction * aura.DASH_SPEED
	
	print("Aura dashing in direction: ", dash_direction)

func Physics_Update(delta: float):
	# Handle gravity during dash
	if not aura.is_on_floor():
		aura.velocity += aura.get_gravity() * delta
	
	# Handle dash timer
	dash_timer -= delta
	
	# Gradually reduce dash speed
	aura.velocity.x = move_toward(aura.velocity.x, 0, aura.DASH_SPEED * 2 * delta)
	
	# End dash when timer expires
	if dash_timer <= 0:
		aura.is_dashing = false
		
		# Transition based on state
		if aura.is_on_floor():
			var direction = aura.get_input_direction()
			if direction == 0:
				Transitioned.emit(self, "Idle")
			else:
				Transitioned.emit(self, "Walk")
		else:
			Transitioned.emit(self, "Jump")

func Exit():
	aura.is_dashing = false
	dash_timer = 0.0
