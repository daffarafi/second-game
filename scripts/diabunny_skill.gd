extends State
class_name DiabunnySkill

@onready var diabunny:CharacterBody2D = get_parent().get_parent()

func Enter():
	diabunny.animation_player.play("skill")
	diabunny.is_attacking = true

func Update(_delta: float):
	# Check if animation finished
	if diabunny and diabunny.animation_player:
		if not diabunny.animation_player.is_playing():
			diabunny.is_attacking = false
			
			# Transition back based on ground state and input
			if diabunny.is_on_floor():
				var direction = diabunny.get_input_direction()
				if direction == 0:
					Transitioned.emit(self, "Idle")
				else:
					Transitioned.emit(self, "Walk")
			else:
				Transitioned.emit(self, "Jump")

func Physics_Update(_delta: float):
	if diabunny.is_attacking :
		diabunny.velocity.x = 0
		return

func Exit():
	if diabunny:
		diabunny.is_attacking = false
