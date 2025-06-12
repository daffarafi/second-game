extends Control

@onready var story_image = $StoryContainer/IllustrationPanel/StoryImage
@onready var story_text = $StoryContainer/IllustrationPanel/DialogPanel/StoryText
@onready var continue_label = $StoryContainer/IllustrationPanel/ContinueLabel
@onready var audio_player = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var black_screen: ColorRect = $BlackScreen

var current_scene_index = 0
var current_part_index = 0  # Track which part of the scene we're on
var is_text_revealing = false
var text_speed = 0.05  # Speed of text reveal animation
var current_reveal_tween: Tween  # Store reference to current tween

# Story data - Trinity/NeuroCore mission storyline with multi-part scenes
var story_scenes = [
	{
		"parts": [
			{
				"image": preload("res://assets/images/prologue/scene1.png"),
				"text": "Seraph-09 Unit was deployed into the Blackline Zone—an uncharted anomaly disrupting NeuroCore's surveillance grid. Their objective: investigate the source of the signal disturbance.",
				"sound": null
			}
		]
	},
	{
		"parts": [
			{
				"image": preload("res://assets/images/prologue/scene2.png"),
				"text": "An energy surge struck without warning. Communications severed. ",
				"sound": null
			},
			{
				"image": preload("res://assets/images/prologue/scene3.png"),
				"text": "Diabunny—separated, disoriented, and offline. Location: unknown.",
				"sound": null
			}
		]
	},
	{
		"parts": [
			{
				"image": preload("res://assets/images/prologue/scene4.png"),
				"text": "She awakens inside the ruins of an abandoned facility.",
				"sound": null
			},
			{
				"image": preload("res://assets/images/prologue/scene5.png"),
				"text": "Debris, shattered terminals, corrupted logs... ",
				"sound": null
			},
			{
				"image": preload("res://assets/images/prologue/scene6.png"),
				"text": "and a single glowing mark: ⨁ 'Trinity'. ",
				"sound": null
			}
		]
	},
	{
		"parts": [
			{
				"image": preload("res://assets/images/prologue/scene6.png"),
				"text": "No signal. No backup. ",
				"sound": null
			},
			{
				"image": preload("res://assets/images/prologue/scene6.png"),
				"text": "Priority shift: survive, gather data, locate uplink. Extraction—secondary.",
				"sound": null
			}
		]
	},
	{
		"parts": [
			{
				"image": preload("res://assets/images/prologue/scene6.png"),
				"text": "Something's moving ahead...",
				"sound": null
			}
		]
	},
	{
		"parts": [
			{
				"image": preload("res://assets/images/prologue/scene6.png"),
				"text": "Unidentified threat detected. Combat mode: engaged.",
				"sound": null
			}
		]
	}
]

func _ready():
	# Play fade in animation first
	animation_player.play("fade_to_normal")
	
	# Setup initial state
	continue_label.visible = false
	setup_continue_label_animation()
	
	# Start with first scene, first part
	show_scene_part(0, 0)

func _input(event):
	# Handle any input to advance story
	if event is InputEventKey and event.pressed:
		advance_story()
	elif event is InputEventMouseButton and event.pressed:
		advance_story()

func advance_story():
	if is_text_revealing:
		# If text is still revealing, complete it immediately
		complete_text_reveal()
	else:
		# Move to next part or next scene
		next_part()

func show_scene_part(scene_index: int, part_index: int):
	if scene_index >= story_scenes.size():
		# End of prologue, go to game
		end_prologue()
		return
	
	var scene_data = story_scenes[scene_index]
	var part_data = scene_data.parts[part_index]
	
	current_scene_index = scene_index
	current_part_index = part_index
	
	# Hide continue label
	continue_label.visible = false
	
	# Change image with fade effect (only if it's different from current)
	change_image_with_fade(part_data.image)
	
	# Play sound effect if available
	if part_data.sound:
		audio_player.stream = part_data.sound
		audio_player.play()
	
	# Build cumulative text for this scene up to current part
	var cumulative_text = ""
	for i in range(part_index + 1):
		if i > 0:
			cumulative_text += " "  # Add space between parts
		cumulative_text += scene_data.parts[i].text
	
	# Start text reveal animation with cumulative text
	reveal_text_animated(cumulative_text)

func next_part():
	var current_scene = story_scenes[current_scene_index]
	
	# Check if there are more parts in current scene
	if current_part_index + 1 < current_scene.parts.size():
		# Show next part of current scene
		show_scene_part(current_scene_index, current_part_index + 1)
	else:
		# Move to next scene, first part
		show_scene_part(current_scene_index + 1, 0)

func show_scene(index: int):
	if index >= story_scenes.size():
		# End of prologue, go to game
		end_prologue()
		return
	
	var scene_data = story_scenes[index]
	current_scene_index = index
	
	# Hide continue label
	continue_label.visible = false
	
	# Change image with fade effect
	change_image_with_fade(scene_data.image)
	
	# Play sound effect if available
	if scene_data.sound:
		audio_player.stream = scene_data.sound
		audio_player.play()
	
	# Start text reveal animation
	reveal_text_animated(scene_data.text)

func change_image_with_fade(new_texture: Texture2D):
	var fade_tween = create_tween()
	
	# Fade out current image
	fade_tween.tween_property(story_image, "modulate:a", 0.0, 0.3)
	
	# Change texture and fade in
	fade_tween.tween_callback(func(): story_image.texture = new_texture)
	fade_tween.tween_property(story_image, "modulate:a", 1.0, 0.5)

func reveal_text_animated(text: String):
	# Stop any existing tween first
	if current_reveal_tween:
		current_reveal_tween.kill()
	
	is_text_revealing = true
	
	# Check if this is a continuation of the same scene
	var previous_text_length = 0
	if current_part_index > 0:
		# Calculate length of previous parts in the same scene
		var scene_data = story_scenes[current_scene_index]
		for i in range(current_part_index):
			previous_text_length += scene_data.parts[i].text.length()
			if i > 0:
				previous_text_length += 1  # Add space between parts
	
	# Set the full text
	story_text.text = text
	
	# If this is first part of scene, start from 0, otherwise start from previous length
	var start_ratio = 0.0
	if previous_text_length > 0:
		start_ratio = float(previous_text_length) / float(text.length())
	
	story_text.visible_ratio = start_ratio
	
	current_reveal_tween = create_tween()
	
	# Animate text reveal from current position to full
	current_reveal_tween.tween_property(story_text, "visible_ratio", 1.0, (text.length() - previous_text_length) * text_speed)
	current_reveal_tween.tween_callback(on_text_reveal_complete)

func complete_text_reveal():
	# Stop current tween if it's running
	if current_reveal_tween:
		current_reveal_tween.kill()
	
	# Immediately show all text
	story_text.visible_ratio = 1.0
	on_text_reveal_complete()

func on_text_reveal_complete():
	is_text_revealing = false
	continue_label.visible = true
	current_reveal_tween = null  # Clear tween reference

func next_scene():
	show_scene_part(current_scene_index + 1, 0)

func end_prologue():
	print("Prologue finished!")
	# Play fade to black animation, scene change akan dipanggil setelah animation selesai
	animation_player.play("fade_to_black")

func setup_continue_label_animation():
	# Reuse the flashing animation from your existing label
	var fade_tween = create_tween()
	fade_tween.set_loops()
	
	fade_tween.tween_property(continue_label, "modulate:a", 0.3, 0.5)
	fade_tween.tween_property(continue_label, "modulate:a", 1.0, 0.5)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_normal":
		# Fade in selesai, black_screen sudah tidak terlihat
		pass
	elif anim_name == "fade_to_black":
		# Fade out selesai, sekarang pindah scene
		get_tree().change_scene_to_file("res://scenes/game.tscn")
