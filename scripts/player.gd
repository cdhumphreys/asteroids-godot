extends CharacterBody2D

class_name Player

const MAX_SPEED = 500
const ACCELERATION = 8.0
const ROTATION_SPEED = 5.0
var speed = 0;
var input_vector: Vector2
var bullet_scene : PackedScene = preload("res://scenes/bullet.tscn")

@export var shoot_cooldown: float = 1.0
@onready var gun: Marker2D = $%Marker2D

var can_shoot := true;


func _physics_process(delta:float):
	_handle_movement(delta)
	_handle_shoot()
	
func _handle_shoot():
	if Input.is_action_pressed("shoot"):
		_try_shoot()
	
func _handle_movement(delta:float):
	
	
	input_vector = Vector2(0, Input.get_axis("thrust_forward", "thrust_backward"))

	if Input.is_action_pressed("rotate_clockwise"):
		rotate(ROTATION_SPEED*delta)
	if Input.is_action_pressed("rotate_anticlockwise"):
		rotate(-ROTATION_SPEED * delta)
	
	velocity += input_vector.rotated(rotation) * ACCELERATION
	velocity = velocity.limit_length(MAX_SPEED)
	
	move_and_slide()

	position = Utils.keep_body_in_screen_bounds(global_position, get_viewport_rect())
	
func _try_shoot():
	if not can_shoot:
		return

	can_shoot = false
	var b = bullet_scene.instantiate()
	var game_world = get_parent()
	game_world.add_child(b)
	b.transform = gun.global_transform
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
