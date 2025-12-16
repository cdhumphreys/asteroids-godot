extends CanvasLayer

class_name EnterNameMenu

signal on_name_submitted(name: String)

@onready var line_edit: LineEdit = %LineEdit
@onready var popup_handler: PopupHandler = %PopupHandler

func on_show() -> void:
	popup_handler.focus_first_element()

func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		return
	on_name_submitted.emit(new_text)
	line_edit.text = ""
	hide()
