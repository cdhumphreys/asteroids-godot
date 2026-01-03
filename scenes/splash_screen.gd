extends Control

@export var load_scene: PackedScene
@export var start_pause_time_seconds : float = 0.5
@export var end_pause_time_seconds : float = 1
@export var apex_pause_time_seconds : float = 1

@onready var ship_sprite: TextureRect = %ShipSprite
@onready var title_label: Label = %TitleLabel
@onready var backgrounds: Node2D = %Backgrounds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_fade()
	
func _fade():
	ship_sprite.position.y = 720
	title_label.modulate.a = 0
	
	var tween = create_tween()
	# Start
	tween.tween_interval(start_pause_time_seconds)
	
	tween.tween_property(ship_sprite, "position:y", 0, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(title_label, "modulate:a", 1, 1)
	
	# Pause
	tween.tween_interval(apex_pause_time_seconds)
	
	tween.tween_property(ship_sprite, "modulate:a", 0, 0.5)
	tween.parallel().tween_property(title_label, "modulate:a", 0, 0.5)
	tween.parallel().tween_property(backgrounds, "modulate:a", 0, 0.5)
	
	# End
	tween.tween_interval(end_pause_time_seconds)
	
	await tween.finished
	
	get_tree().change_scene_to_packed(load_scene)
	
