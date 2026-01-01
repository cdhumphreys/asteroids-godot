extends Area2D

class_name HitboxComponent

signal on_hit

@export var damage: int = 1

func hit():
	on_hit.emit()
