extends CanvasLayer
class_name ScoreLabel

@onready var score_label: Label = %Score

func update_score(score: int):
	score_label.text = "%s" % score
