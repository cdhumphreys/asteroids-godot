extends CanvasLayer
class_name MainMenu
@onready var popup_handler: PopupHandler = %PopupHandler

func on_show():
	popup_handler.focus_first_element()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	EventBus.start_button_pressed.emit()
