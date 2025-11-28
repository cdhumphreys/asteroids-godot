extends Node
class_name PopupHandler

@export var initial_focus_element: Control

func focus_first_element():
	if initial_focus_element:
		await get_tree().process_frame
		initial_focus_element.grab_focus.call_deferred()
