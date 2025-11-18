extends Node2D

@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer
@onready var player: Player = $Player
@onready var asteroid_spawn_location: PathFollow2D = $AsteroidSpawnBoundary/AsteroidSpawnLocation

var asteroid_scene: PackedScene = preload("res://scenes/asteroid.tscn")

@export var asteroid_stats: Array[AsteroidStats]

var score = 0
var asteroid_sizes = [Enums.AsteroidSize.SMALL, Enums.AsteroidSize.LARGE]


@export_range (1, 100) var MAX_ASTEROIDS: int

var active_asteroids = 0


func _ready() -> void:
	EventBus.asteroid_hit.connect(_on_asteroid_destroyed)

func _game_over() -> void:
	print("game over")
	get_tree().paused = true
	asteroid_spawn_timer.stop()
	
func _new_game() -> void:
	print("starting new game")
	score = 0
	asteroid_spawn_timer.start()
	player.reset()
	

func _get_random_asteroid_stat() -> AsteroidStats:
	var res: AsteroidStats = asteroid_stats.pick_random()
	
	return res.duplicate()
			

func _on_asteroid_spawn_timer_timeout() -> void:
	if active_asteroids == MAX_ASTEROIDS:
		return
#	Create new asteroid & set stats
	var asteroid: Asteroid = asteroid_scene.instantiate()
	var asteroid_stat: AsteroidStats = _get_random_asteroid_stat()
	asteroid.stats = asteroid_stat

	# Get random point along boundary
	asteroid_spawn_location.	progress_ratio = randf()
	asteroid.global_position = asteroid_spawn_location.position
	
	# Perpendicular to "spawn" vector - points inwards, not sure why PI and not PI/2
	# Must be something up with the asteroid rotation?
	var direction = asteroid_spawn_location.rotation + PI
	
	# Add random offset 
	direction += randf_range(-PI/4, PI/4)
	
	# Set direction
	asteroid.rotate(direction)
	
	add_child(asteroid)
	active_asteroids += 1
	
func _on_asteroid_destroyed(asteroid_size: Enums.AsteroidSize):
	if asteroid_size == Enums.AsteroidSize.SMALL:
		active_asteroids -= 1
	elif asteroid_size == Enums.AsteroidSize.LARGE:
		active_asteroids += 1

	print("Active asteroids:", active_asteroids)
