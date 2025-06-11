extends Node

enum CharacterType {
	DIABUNNY,
	KILLREN,
	AURA
}

var current_character_type = CharacterType.DIABUNNY
var current_character: CharacterBody2D
var character_scenes = {
	CharacterType.DIABUNNY: preload("res://scenes/diabunny.tscn"),
	CharacterType.KILLREN: preload("res://scenes/killren.tscn"),
	CharacterType.AURA: preload("res://scenes/aura.tscn")
}

var spawn_position = Vector2.ZERO
var game_scene: Node

signal character_switched(new_character: CharacterBody2D)

func _ready():
	# Set as autoload singleton in project settings
	print("CharacterManager initialized")

func initialize(game_scene_ref: Node, initial_position: Vector2):
	game_scene = game_scene_ref
	spawn_position = initial_position
	spawn_character(current_character_type)

func switch_character(new_type: CharacterType):
	if new_type == current_character_type:
		return
		
	# Store current position if character exists
	if current_character and is_instance_valid(current_character):
		spawn_position = current_character.global_position
		current_character.queue_free()
	
	# Spawn new character
	current_character_type = new_type
	spawn_character(new_type)

func spawn_character(type: CharacterType):
	var character_scene = character_scenes[type]
	current_character = character_scene.instantiate()
	current_character.global_position = spawn_position
	
	game_scene.add_child(current_character)
	
	# Emit signal so game.gd can handle camera
	character_switched.emit(current_character)
	
	print("Switched to: ", CharacterType.keys()[type])

func setup_camera_follow():
	# Find camera in scene and set it to follow current character
	var camera = game_scene.get_node_or_null("Camera2D")
	if not camera:
		camera = current_character.get_node_or_null("Camera2D")
	
	if camera:
		# If camera has a follow target property, set it
		if camera.has_method("set_target"):
			camera.set_target(current_character)
		else:
			# Simple camera follow by making it child of character
			if camera.get_parent() != current_character:
				camera.reparent(current_character)

func get_current_character() -> CharacterBody2D:
	return current_character

func get_character_name() -> String:
	match current_character_type:
		CharacterType.DIABUNNY:
			return "Diabunny"
		CharacterType.KILLREN:
			return "Killren"
		CharacterType.AURA:
			return "Aura"
		_:
			return "Unknown"

func _input(event):
	# Handle character switching input
	if event.is_action_pressed("switch_to_diabunny"):  # Key 1
		switch_character(CharacterType.DIABUNNY)
	elif event.is_action_pressed("switch_to_killren"):  # Key 2
		switch_character(CharacterType.KILLREN)
	elif event.is_action_pressed("switch_to_aura"):  # Key 3
		switch_character(CharacterType.AURA)
	elif event.is_action_pressed("switch_character"):  # Tab key
		switch_to_next_character()

func switch_to_next_character():
	var next_type = (current_character_type + 1) % CharacterType.size()
	switch_character(next_type as CharacterType)
