extends State
class_name Skill

@onready var killren: CharacterBody2D = get_parent().get_parent()

func Enter():
	killren.animation_player.play("skill")
	killren.is_attacking = true
	
	# Perform powerful magic skill
	perform_magic_skill()

func perform_magic_skill():
	# Find closest enemy in skill range (longer range than basic attack)
	var target = killren.find_closest_enemy_in_range(killren.SKILL_RANGE)
	
	if target:
		print("Magic skill hit: ", target.name)
		# Deal higher damage
		if target.has_method("take_damage"):
			target.take_damage(killren.SKILL_DAMAGE, killren.global_position)
		
		# Create more powerful visual effect
		create_skill_effect(target.global_position)
	else:
		print("No enemy in range for magic skill")

func create_skill_effect(target_position: Vector2):
	# More powerful visual effect for skill
	print("Powerful magic skill effect created at: ", target_position)
	
	# Create multiple effect sprites for more impact
	for i in range(3):
		var effect_sprite = Sprite2D.new()
		get_tree().current_scene.add_child(effect_sprite)
		effect_sprite.global_position = target_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		effect_sprite.modulate = Color.PURPLE
		effect_sprite.scale = Vector2(0.5, 0.5)
		

func Update(_delta: float):
	# Check if animation finished
	if killren and killren.animation_player:
		if not killren.animation_player.is_playing():
			killren.is_attacking = false
			
			# Transition back based on ground state and input
			if killren.is_on_floor():
				var direction = killren.get_input_direction()
				if direction == 0:
					Transitioned.emit(self, "Idle")
				else:
					Transitioned.emit(self, "Walk")
			else:
				Transitioned.emit(self, "Jump")

func Physics_Update(_delta: float):
	if killren.is_attacking:
		killren.velocity.x = 0  # Stop movement during skill
		return

func Exit():
	if killren:
		killren.is_attacking = false
