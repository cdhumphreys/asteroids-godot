extends CharacterBody2D

class_name Player

signal on_hit

@onready var gun: Marker2D = $%Marker2D
@onready var collision_polygon_2d: CollisionPolygon2D = %CollisionPolygon2D
@onready var trail: Sprite2D = %Trail
@onready var ship_sprite: Sprite2D = %ShipA
@onready var thrust_audio_player: AudioStreamPlayer = $ThrustAudioPlayer

@export var thrust_stream: AudioStream
@export var shoot_cooldown: float = 1.0


const MAX_SPEED = 500
const ACCELERATION = 8.0
const ROTATION_SPEED = 5.0

var input_vector: Vector2
var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var can_shoot := true
var start_position: Vector2
var trail_tween: Tween
var flicker_tween: Tween


func _ready() -> void:
	start_position = global_position
	thrust_audio_player.stream = thrust_stream

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_shoot()
	
func _handle_shoot() -> void:
	if Input.is_action_pressed("shoot"):
		_try_shoot()
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("thrust_forward"):
		_reset_tween()
		trail_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		trail_tween.tween_property(trail, "scale", Vector2(trail.scale.x, 0.3), 0.3)
		thrust_audio_player.play()
		
	if event.is_action_released("thrust_forward"):
		_reset_tween()
		trail_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		trail_tween.tween_property(trail, "scale", Vector2(trail.scale.x, 0), 0.5)
		thrust_audio_player.stop()

func _reset_tween() -> void:
	if trail_tween:
		trail_tween.kill()
	trail_tween = create_tween()

func _handle_movement(delta: float) -> void:
	input_vector = Vector2(0, Input.get_axis("thrust_forward", "thrust_backward"))

	if Input.is_action_pressed("rotate_clockwise"):
		rotate(ROTATION_SPEED * delta)
	if Input.is_action_pressed("rotate_anticlockwise"):
		rotate(-ROTATION_SPEED * delta)
	
	velocity += input_vector.rotated(rotation) * ACCELERATION
	velocity = velocity.limit_length(MAX_SPEED)
	
	move_and_slide()

	position = Utils.keep_body_in_screen_bounds(global_position, get_viewport_rect())
	
func _try_shoot() -> void:
	if not can_shoot:
		return

	can_shoot = false
	var bullet: Bullet = bullet_scene.instantiate()
	var game_world: Game = get_parent()
	if not game_world is Game:
		push_error("Player parent is not a Game node")
		return
	game_world.bullets_container.add_child(bullet)
	bullet.transform = gun.global_transform
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
	
func hit() -> void:
	hide()
	collision_polygon_2d.set_deferred("disabled", true)
	on_hit.emit()

func _flicker() -> void:
	if flicker_tween:
		flicker_tween.kill()
	flicker_tween = create_tween()
	# Flicker 3 times (6 total tweens: fade out/in x3)
	for i in range(3):
		flicker_tween.tween_property(ship_sprite, "modulate:a", 0.0, 0.3)
		flicker_tween.tween_property(ship_sprite, "modulate:a", 1.0, 0.3)

func reset(in_game: bool = false) -> void:
	position = start_position
	velocity = Vector2.ZERO
	rotation = 0
	show()
	if in_game:
		# Flicker sprite to show invincibility period
		_flicker()
		await flicker_tween.finished
	collision_polygon_2d.set_deferred("disabled", false)
