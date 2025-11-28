extends CanvasLayer

class_name HighScores

signal on_close

@onready var grid_container: GridContainer = %GridContainer
@onready var template_position_label: Label = %TemplatePositionLabel
@onready var template_score_label: Label = %TemplateScoreLabel
@onready var template_username_label: Label = %TemplateUsernameLabel
@onready var popup_handler: PopupHandler = %PopupHandler
@onready var close_button: Button = %CloseButton

func show_score_list(high_scores: Array[HighScore]):
	for item in grid_container.get_children():
		item.queue_free()
		
	var idx = 0
	for high_score in high_scores:
		var position_label: Label = template_position_label.duplicate()
		var score_label: Label = template_score_label.duplicate()
		var username_label: Label = template_username_label.duplicate()
		
		position_label.text = "%s." % (idx + 1)
		score_label.text = "%s" % high_score.score
		username_label.text = high_score.username
		idx += 1
		
		grid_container.add_child(position_label)
		grid_container.add_child(score_label)
		grid_container.add_child(username_label)
		
		position_label.show()
		score_label.show()
		username_label.show()
	
func on_show():
	popup_handler.focus_first_element()


func _on_close_button_pressed() -> void:
	on_close.emit()
	hide()
