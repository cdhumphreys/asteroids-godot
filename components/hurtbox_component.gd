extends Area2D

class_name HurtboxComponent

signal on_hit(damage: int)

@export var health_component: HealthComponent


func _ready() -> void:
	connect("area_entered", _on_area_entered)	
	
func _on_area_entered(area: Area2D):
	if area is not HitboxComponent:
		return

	var hitbox: HitboxComponent = area
	on_hit.emit(hitbox.damage)
	hitbox.hit()
	
	if health_component != null:
		health_component.current_health -= hitbox.damage
