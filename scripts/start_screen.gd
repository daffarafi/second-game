extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# Keep the GUI input function as backup
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		start_game()
