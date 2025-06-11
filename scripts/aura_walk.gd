extends State
class_name AuraWalk

@onready var aura: CharacterBody2D = get_parent().get_parent()

func Enter():
	if aura.animation_player:
		aura.animation_player.play("walk")

func Physics_Update(delta: float):
	# Handle gravity
	if not aura.is_on_floor():
		aura.velocity += aura.get_gravity() * delta
	
	# Handle input
	var direction = aura.get_input_direction()
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and aura.is_on_floor():
		Transitioned.emit(self, "Jump")
		return
	
	# Handle attack
	if Input.is_action_just_pressed("attack") and aura.attack():
		Transitioned.emit(self, "BasicAttack")
		return
	
	# Handle skill
	if Input.is_action_just_pressed("skill") and aura.skill():
		Transitioned.emit(self, "Skill")
		return
	
	# Handle dash
	if Input.is_action_just_pressed("dash"):
		Transitioned.emit(self, "Dash")
		return
	
	# Handle movement
	if direction == 0:
		Transitioned.emit(self, "Idle")
	else:
		aura.handle_movement(direction)

func Exit():
	pass
