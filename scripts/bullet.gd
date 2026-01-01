@tool
extends Node2D

class_name Bullet

const SPEED = 800


@onready var line_2d: Line2D = %Line2D

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		position -= transform.y * SPEED * delta


func _on_lifetime_timeout() -> void:
	queue_free()

func _on_hitbox_component_on_hit() -> void:
	queue_free()
