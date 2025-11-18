extends Area2D

class_name Bullet

const SPEED = 800

func _physics_process(delta):
	position -= transform.y * SPEED * delta

func _on_lifetime_timeout() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:		
	area.queue_free()
	# remove bullet
	queue_free()
