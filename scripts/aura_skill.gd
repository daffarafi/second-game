extends State
class_name AuraSkill

@onready var aura: CharacterBody2D = get_parent().get_parent()

func Enter():
	# Play skill animation
	if aura.animation_player:
		aura.animation_player.play("skill")
	
	aura.is_attacking = true
	
	# Enable hitboxes for skill (both hitboxes for area attack)
	if aura.hitbox_1:
		aura.hitbox_1.disabled = false
	if aura.hitbox_2:
		aura.hitbox_2.disabled = false
	
	# Move forward during skill
	aura.move_front(6)  # Longer movement for skill
	
	# Create a timer to handle animation end
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.875  # Skill duration
	timer.one_shot = true
	timer.timeout.connect(_on_skill_finished)
	timer.start()

func _on_skill_finished():
	aura.is_attacking = false
	
	# Disable all hitboxes
	if aura.hitbox_1:
		aura.hitbox_1.disabled = true
	if aura.hitbox_2:
		aura.hitbox_2.disabled = true
	
	# Transition back based on ground state and input
	if aura.is_on_floor():
		var direction = aura.get_input_direction()
		if direction == 0:
			Transitioned.emit(self, "Idle")
		else:
			Transitioned.emit(self, "Walk")
	else:
		Transitioned.emit(self, "Jump")

func Physics_Update(delta: float):
	if aura.is_attacking:
		aura.velocity.x = 0  # Stop movement during skill
		return

func Exit():
	if aura:
		aura.is_attacking = false
		# Disable all hitboxes when exiting
		if aura.hitbox_1:
			aura.hitbox_1.disabled = true
		if aura.hitbox_2:
			aura.hitbox_2.disabled = true
