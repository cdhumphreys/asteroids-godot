extends Node2D

class_name Asteroid

var speed: float

var movement_vector: Vector2 = Vector2(0, -1)

@onready var sprite: Sprite2D = $%Sprite2D;

@onready var hurtbox_shape: CollisionShape2D = %HurtboxShape
@onready var hitbox_shape: CollisionShape2D = %HitboxShape

@onready var health_component: HealthComponent = %HealthComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent

@export var stats: AsteroidStats

var small_asteroid_scene: PackedScene = preload("res://scenes/asteroid.tscn")
var small_asteroid_stat: AsteroidStats = preload("res://resources/asteroids/small_asteroid.tres")

func _ready() -> void:
	speed = randf_range(stats.MIN_SPEED, stats.MAX_SPEED)
	
	sprite.texture = stats.textures.pick_random()
	hurtbox_shape.shape = stats.collision_shape
	hitbox_shape.shape = stats.collision_shape

func _physics_process(delta: float) -> void:
	var sprite_dimensions = sprite.get_rect().size
	var width = sprite_dimensions.x
	var height = sprite_dimensions.y

	global_position += movement_vector.rotated(rotation) * speed * delta
	position = Utils.keep_body_in_screen_bounds(global_position, get_viewport_rect(), width, height)


func _on_hit_by_bullet():
	EventBus.asteroid_hit.emit(self)

	if stats.size == Enums.AsteroidSize.LARGE:
		_split_into_smaller()

	queue_free.call_deferred()

func _split_into_smaller():
	var parent_node = get_parent()
	for i in range(2):
		var new_asteroid: Asteroid = small_asteroid_scene.instantiate()
		new_asteroid.stats = small_asteroid_stat
		new_asteroid.global_position = global_position
		new_asteroid.rotation = rotation + randf_range(-PI/4, PI/4)
		parent_node.add_child.call_deferred(new_asteroid)

func _on_health_component_health_depleted() -> void:
	_on_hit_by_bullet()
