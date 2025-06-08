extends State
class_name DiabunnyJump

@onready var diabunny:CharacterBody2D = get_parent().get_parent()

func Enter():
	diabunny.velocity.y = diabunny.JUMP_VELOCITY
	diabunny.animation_player.play("jump")

func Update(_delta: float):
	# Check for attack while jumping
	if Input.is_action_just_pressed("attack"):
		if diabunny.attack():
			Transitioned.emit(self, "BasicAttack")
	
	# Check for skill while jumping
	if Input.is_action_just_pressed("skill"):
		if diabunny.skill():
			Transitioned.emit(self, "Skill")
	
	# Check for dash while jumping (air dash)
	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "Dash")

func Physics_Update(_delta: float):
	var direction = diabunny.get_input_direction()
	diabunny.handle_movement(direction)
	
	# Land on ground
	if diabunny.is_on_floor() and diabunny.velocity.y >= 0:
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")
