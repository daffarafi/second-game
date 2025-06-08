extends State
class_name DiabunnyWalk

@onready var diabunny:CharacterBody2D = get_parent().get_parent()

func Enter():
	diabunny.animation_player.play("walk")
	#diabunny.animated_sprite.play("walk")

func Update(_delta: float):
	# Check for input transitions
	if Input.is_action_just_pressed("jump"):
		Transitioned.emit(self, "Jump")
	
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "BasicAttack")
			
	if Input.is_action_just_pressed("skill"):
		Transitioned.emit(self, "Skill")
			
	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "Dash")
	
	var direction = diabunny.get_input_direction()
	if direction == 0:
		Transitioned.emit(self, "Idle")

func Physics_Update(_delta: float):
	var direction = diabunny.get_input_direction()
	diabunny.handle_movement(direction)
	
