extends Area2D

class_name Asteroid

var speed: float

var movement_vector: Vector2 = Vector2(0, -1)

@onready var sprite: Sprite2D = $%Sprite2D;
@onready var collision_shape: CollisionShape2D = $%CollisionShape2D

@export var stats: AsteroidStats

func _ready() -> void:
	speed = randf_range(stats.MIN_SPEED, stats.MAX_SPEED)
	rotation = randf_range(0, 2*PI)
	
	sprite.texture = stats.textures.pick_random()
	collision_shape.shape = stats.collision_shape
		
	# Pick one of the asteroid PNGs
	collision_shape.shape = stats.collision_shape

func _physics_process(delta: float) -> void:
	var width = 0
	var height = 0
	
	var shape = collision_shape.shape
	
	if shape is CircleShape2D:
		width = shape.radius
		height = shape.radius

	global_position += movement_vector.rotated(rotation) * speed * delta
	position = Utils.keep_body_in_screen_bounds(global_position, get_viewport_rect(), width, height)
