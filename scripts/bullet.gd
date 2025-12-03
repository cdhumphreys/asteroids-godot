@tool
extends Area2D

class_name Bullet

const SPEED = 800

@export var gradient: Gradient: set = set_gradient

@onready var line_2d: Line2D = %Line2D

func _ready() -> void:
	set_gradient(gradient)

func _physics_process(delta):
	if not Engine.is_editor_hint():
		position -= transform.y * SPEED * delta


func _on_lifetime_timeout() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:		
	area.queue_free()
	# remove bullet
	queue_free()

func set_gradient(new_gradient: Gradient):
	gradient = new_gradient
	
	if line_2d == null:
		return
	
	line_2d.gradient = new_gradient
