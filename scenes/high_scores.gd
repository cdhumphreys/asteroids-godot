extends CanvasLayer

class_name HighScores
@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var template_row: HBoxContainer = %TemplateRow

func show_score_list(high_scores: Array[HighScore]):
	var idx = 0
	for high_score in high_scores:
		var new_row: HBoxContainer = template_row.duplicate()
		var position_label: Label = new_row.get_child(0)
		var score_label: Label = new_row.get_child(1)
		var username_label: Label = new_row.get_child(2)
		
		position_label.text = "%s." % (idx + 1)
		score_label.text = "%s" % high_score.score
		username_label.text = high_score.username
		idx += 1
		
		v_box_container.add_child(new_row)
		new_row.show()
		
