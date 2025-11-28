extends CanvasLayer
class_name DeathScreen

@onready var new_game_button: Button = %NewGameButton
@onready var popup_handler: PopupHandler = %PopupHandler


func on_show():
	popup_handler.focus_first_element()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_new_game_button_pressed() -> void:
	EventBus.new_game_button_pressed.emit()
