extends Area2D

class_name Bullet

const SPEED = 800



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta):
	position -= transform.y * SPEED * delta

func _on_lifetime_timeout() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:		
	area.queue_free()
	# remove bullet
	queue_free()
