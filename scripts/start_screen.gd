extends Control

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var black_screen:ColorRect = $BlackScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("fade_to_normal")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_game():
	# Play fade to black animation, scene change akan dipanggil setelah animation selesai
	animation_player.play("fade_to_black")

# Keep the GUI input function as backup
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		start_game()

func _input(event):
	# Handle any input to start game
	if event is InputEventKey and event.pressed:
		start_game()
	elif event is InputEventMouseButton and event.pressed:
		start_game()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		# Fade out selesai, sekarang pindah scene
		get_tree().change_scene_to_file("res://scenes/prelogue.tscn")
