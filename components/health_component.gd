extends Node

class_name HealthComponent

@export var max_health: int = 1 : set = _set_max_health, get = _get_max_health
@export var is_invincible = false
var current_health: int : set = _set_current_health, get = _get_current_health

signal health_changed(difference: int)
signal health_depleted

func _ready() -> void:
	current_health = max_health

func _set_max_health(new_value: int):
	if new_value == max_health:
		return
	# clamp above 0
	new_value = max(1, new_value)
	max_health = new_value
	if max_health < current_health:
		current_health = max_health
	
func _get_max_health():
	return max_health

func _set_current_health(new_value: int):
	if is_invincible:
		return

	if new_value == current_health:
		return
	var difference = current_health - new_value
	health_changed.emit(difference)
	
	current_health = new_value
	
	if current_health <= 0:
		current_health = 0
		health_depleted.emit()
	

func _get_current_health():
	return current_health
