extends Node
class_name PopupHandler

@export var initial_focus_element: Control

func focus_first_element() -> void:
	if initial_focus_element:
		await get_tree().process_frame
		initial_focus_element.call_deferred("grab_focus")
