extends CanvasLayer
class_name MainMenu
@onready var popup_handler: PopupHandler = %PopupHandler
@onready var foreground: PanelContainer = %Foreground

func _ready() -> void:
	foreground.modulate.a = 0

func _show():
	var tween = create_tween()
	tween.tween_property(foreground, "modulate:a", 1, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	return tween.finished

func _hide():
	var tween = create_tween()
	tween.tween_property(foreground, "modulate:a", 0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
func on_show() -> void:
	await _show()
	popup_handler.focus_first_element()
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	_hide()
	EventBus.start_button_pressed.emit()
