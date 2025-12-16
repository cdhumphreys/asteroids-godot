extends Area2D

class_name Asteroid

var speed: float

var movement_vector: Vector2 = Vector2(0, -1)

@onready var sprite: Sprite2D = $%Sprite2D
@onready var collision_shape: CollisionShape2D = $%CollisionShape2D

@export var stats: AsteroidStats

var small_asteroid_scene: PackedScene = preload("res://scenes/asteroid.tscn")
var small_asteroid_stat: AsteroidStats = preload("res://resources/asteroids/small_asteroid.tres")


func _ready() -> void:
	speed = randf_range(stats.MIN_SPEED, stats.MAX_SPEED)
	
	sprite.texture = stats.textures.pick_random()
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


func _on_hit_by_bullet() -> void:
	EventBus.asteroid_hit.emit(self)
	
	if stats.size == Enums.AsteroidSize.SMALL:
		call_deferred("queue_free")
	elif stats.size == Enums.AsteroidSize.LARGE:
		_split_into_smaller()
		call_deferred("queue_free")

func _split_into_smaller() -> void:
	var parent_node = get_parent()
	if not parent_node:
		return
	for i in range(2):
		var new_asteroid: Asteroid = small_asteroid_scene.instantiate()
		new_asteroid.stats = small_asteroid_stat
		new_asteroid.global_position = global_position
		new_asteroid.rotation = rotation + randf_range(-PI / 4, PI / 4)
		parent_node.call_deferred("add_child", new_asteroid)
	

func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		area.queue_free()
		_on_hit_by_bullet()
	

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hit()
