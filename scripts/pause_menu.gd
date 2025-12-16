extends CanvasLayer

class_name PauseMenu

@onready var popup_handler: PopupHandler = %PopupHandler
@onready var continue_button: Button = %ContinueButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# DOOR_OPEN_002
const OPEN_SOUND = preload("uid://cl4e6fube4len")
# DOOR_CLOSE_002
const CLOSE_SOUND = preload("uid://b3ntcp4qu8uor")


func on_show():
	popup_handler.focus_first_element()
	
	audio_stream_player.stream = OPEN_SOUND
	audio_stream_player.play()

func on_hide():
	audio_stream_player.stream = CLOSE_SOUND
	audio_stream_player.play()

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_continue_button_pressed() -> void:
	on_hide()
	EventBus.continue_button_pressed.emit()
