extends State
class_name Jump

@onready var killren: CharacterBody2D = get_parent().get_parent()

func Enter():
	killren.velocity.y = killren.JUMP_VELOCITY
	killren.animation_player.play("jump")

func Update(_delta: float):
	# Check for attack while jumping
	if Input.is_action_just_pressed("attack"):
		if killren.magic_attack():
			Transitioned.emit(self, "BasicAttack")
	
	# Check for skill while jumping
	if Input.is_action_just_pressed("skill"):
		if killren.magic_skill():
			Transitioned.emit(self, "Skill")
	
	# Check for dash while jumping (air dash)
	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "Dash")

func Physics_Update(_delta: float):
	var direction = killren.get_input_direction()
	killren.handle_movement(direction)
	
	# Land on ground
	if killren.is_on_floor() and killren.velocity.y >= 0:
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")
