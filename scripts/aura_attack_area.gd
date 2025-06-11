extends Area2D

var owner_character: CharacterBody2D  # Reference ke aura

func _ready() -> void :
	# Set owner reference ke parent character
	owner_character = get_parent() as CharacterBody2D

func _on_body_entered(body: Node2D) -> void:
	# Exclude owner character (aura itself)
	if body == owner_character:
		return
		
	# Only include valid enemies
	if body.has_method("take_damage") and body is CharacterBody2D:
		if owner_character and owner_character.has_method("add_enemy_to_range"):
			owner_character.add_enemy_to_range(body)
			print("Enemy entered Aura's range: ", body.name)
	
func _on_body_exited(body: Node2D) -> void:
	if owner_character and owner_character.has_method("remove_enemy_from_range"):
		owner_character.remove_enemy_from_range(body)
		print("Enemy exited Aura's range: ", body.name)
