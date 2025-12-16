extends CanvasLayer

class_name LivesCounter

@onready var lives_container: HBoxContainer = %LivesContainer
@onready var life_image: TextureRect = %LifeImage


func _clear_container() -> void:
	for child in lives_container.get_children():
		lives_container.remove_child(child)
		child.queue_free()

func display_lives(lives: int) -> void:
	_clear_container()
	for i in lives:
		var new_image: TextureRect = life_image.duplicate()
		lives_container.add_child(new_image)
		new_image.show()
