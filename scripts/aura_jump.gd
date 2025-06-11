extends State
class_name AuraJump

@onready var aura: CharacterBody2D = get_parent().get_parent()

func Enter():
	aura.velocity.y = aura.JUMP_VELOCITY
	aura.animation_player.play("jump")

func Physics_Update(delta: float):
	# Handle gravity
	aura.velocity += aura.get_gravity() * delta
	
	# Handle input
	var direction = aura.get_input_direction()
	
	# Handle attack while jumping
	if Input.is_action_just_pressed("attack") and aura.attack():
		Transitioned.emit(self, "BasicAttack")
		return
	
	# Handle skill while jumping
	if Input.is_action_just_pressed("skill") and aura.skill():
		Transitioned.emit(self, "Skill")
		return
	
	# Handle dash while jumping
	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "Dash")
		return
	
	# Handle movement
	aura.handle_movement(direction)
	
	# Check if landed
	if aura.is_on_floor():
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")

func Exit():
	pass
