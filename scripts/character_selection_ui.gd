extends Control

@onready var diabunny_button = $VBoxContainer/HBoxContainer/DiabunnyButton
@onready var killren_button = $VBoxContainer/HBoxContainer/KillrenButton
@onready var aura_button = $VBoxContainer/HBoxContainer/AuraButton
@onready var current_character_label = $VBoxContainer/CurrentCharacterLabel

func _ready():
	# Setup button connections
	diabunny_button.pressed.connect(_on_diabunny_selected)
	killren_button.pressed.connect(_on_killren_selected)
	aura_button.pressed.connect(_on_aura_selected)
	
	# Connect to character switch signal
	CharacterManager.character_switched.connect(_on_character_changed)
	
	# Update initial UI
	update_ui_for_character(CharacterManager.current_character_type)

func _on_diabunny_selected():
	CharacterManager.switch_character(CharacterManager.CharacterType.DIABUNNY)

func _on_killren_selected():
	CharacterManager.switch_character(CharacterManager.CharacterType.KILLREN)

func _on_aura_selected():
	CharacterManager.switch_character(CharacterManager.CharacterType.AURA)

func _on_character_changed(new_character):
	update_ui_for_character(CharacterManager.current_character_type)

func update_ui_for_character(character_type):
	# Update character name label
	current_character_label.text = "Current: " + CharacterManager.get_character_name()
	
	# Update button highlights
	diabunny_button.modulate = Color.WHITE
	killren_button.modulate = Color.WHITE
	aura_button.modulate = Color.WHITE
	
	match character_type:
		CharacterManager.CharacterType.DIABUNNY:
			diabunny_button.modulate = Color.YELLOW
		CharacterManager.CharacterType.KILLREN:
			killren_button.modulate = Color.CYAN
		CharacterManager.CharacterType.AURA:
			aura_button.modulate = Color.ORANGE

func _input(event):
	# Toggle UI visibility
	if event.is_action_pressed("ui_cancel"):  # ESC key
		visible = !visible
