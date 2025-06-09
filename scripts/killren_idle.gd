extends State
class_name Idle

@onready var killren: CharacterBody2D = get_parent().get_parent()

func Enter():
	killren.animation_player.play("idle")

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
	
	var direction = killren.get_input_direction()
	if direction != 0:
		Transitioned.emit(self, "Walk")

func Physics_Update(_delta: float):
	# Apply slight deceleration when idle
	killren.velocity.x = move_toward(killren.velocity.x, 0, killren.SPEED)
