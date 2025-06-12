extends MarginContainer

@export var menu_screen: VBoxContainer
@export var open_menu_screen: VBoxContainer

func toggle_visibility(object) :
	object.visible = !object.visible


func _on_button_pressed() -> void:
	toggle_visibility(menu_screen)
	toggle_visibility(open_menu_screen)
