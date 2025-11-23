extends Node
class_name PopupHandler

@export var initial_focus: Control

func focus_first_button():
	if initial_focus:
		initial_focus.grab_focus()
