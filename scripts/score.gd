extends CanvasLayer
class_name ScoreLabel

@onready var score_label: Label = %Score

func update_score(score: int) -> void:
	score_label.text = "%d" % score
