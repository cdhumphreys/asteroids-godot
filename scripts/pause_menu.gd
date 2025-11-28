extends CanvasLayer

class_name PauseMenu
@onready var popup_handler: PopupHandler = %PopupHandler

@onready var continue_button: Button = %ContinueButton


func on_show():
	popup_handler.focus_first_element()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	EventBus.continue_button_pressed.emit()
