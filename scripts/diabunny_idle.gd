extends State
class_name DiabunnyIdle

@onready var diabunny:CharacterBody2D = get_parent().get_parent()

func Enter():
	diabunny.animation_player.play("idle")

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
	if direction != 0:
		Transitioned.emit(self, "Walk")

func Physics_Update(_delta: float):
	# Apply slight deceleration when idle
	diabunny.velocity.x = move_toward(diabunny.velocity.x, 0, diabunny.SPEED)
	
