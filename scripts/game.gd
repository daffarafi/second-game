extends Node2D

var game_camera: Camera2D

func _ready():
	# Setup camera before initializing character manager
	setup_game_camera()
	
	# Initialize character manager
	CharacterManager.initialize(self, Vector2(32, -35))  # Starting position (where Aura was)
	
	# Connect to character switch signal
	CharacterManager.character_switched.connect(_on_character_switched)
	
	# Remove the existing Aura from scene since CharacterManager will handle it
	var existing_aura = get_node_or_null("Aura")
	if existing_aura:
		existing_aura.queue_free()
	
	print("Game scene initialized with CharacterManager")

func setup_game_camera():
	# First, try to get the existing camera from Aura
	var existing_camera = get_node_or_null("Aura/Camera2D")
	
	if existing_camera:
		# Take the existing camera and make it independent
		game_camera = existing_camera
		game_camera.reparent(self)  # Move to game scene root
		print("Using existing camera")
	else:
		# Create a new camera if none exists
		game_camera = Camera2D.new()
		add_child(game_camera)
		print("Created new camera")
	
	# Set camera properties
	game_camera.zoom = Vector2(2, 2)
	game_camera.position_smoothing_enabled = true

func _on_character_switched(new_character: CharacterBody2D):
	print("Game: Character switched to: ", new_character.name)
	
	# Setup camera for new character
	setup_camera_for_character(new_character)

func setup_camera_for_character(character: CharacterBody2D):
	if game_camera and character:
		# Move camera to follow new character
		game_camera.reparent(character)
		game_camera.position = Vector2(0, 0)  # Keep same relative position
		print("Camera attached to: ", character.name)
	else:
		print("No camera or character found!")

func _input(event):
	# Display current character info
	if event.is_action_pressed("ui_accept"):  # Space key for info
		var current_char = CharacterManager.get_current_character()
		if current_char:
			print("Current character: ", CharacterManager.get_character_name())
			print("Position: ", current_char.global_position)
