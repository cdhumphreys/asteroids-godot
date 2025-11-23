extends Node2D

class_name Game

@export var asteroid_stats: Array[AsteroidStats]
@export_range (1, 100) var MAX_ASTEROIDS: int
@export var lives:int = 3 


var asteroid_scene: PackedScene = preload("res://scenes/asteroid.tscn")

var score = 0

var asteroid_sizes = Enums.AsteroidSize.keys()

var active_asteroids = 0



@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer
@onready var player: Player = $Player
@onready var asteroid_spawn_location: PathFollow2D = $AsteroidSpawnBoundary/AsteroidSpawnLocation


@onready var score_label: ScoreLabel = %Score

@onready var pause_menu: PauseMenu = %PauseMenu
@onready var main_menu: MainMenu = %MainMenu
@onready var death_screen: DeathScreen = %DeathScreen

@onready var asteroids_container: Node = %AsteroidsContainer
@onready var bullets_container: Node = %BulletsContainer

func _ready() -> void:
	get_tree().paused = true
	EventBus.asteroid_hit.connect(_on_asteroid_destroyed)
	EventBus.start_button_pressed.connect(_on_start_button_pressed)
	EventBus.continue_button_pressed.connect(_on_continue_button_pressed)
	EventBus.new_game_button_pressed.connect(_new_game)
	main_menu.on_show()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
			pause_menu.hide()
		else:
			get_tree().paused = true
			pause_menu.show()
			pause_menu.on_show()
			

func _remove_bullets():
	for child in bullets_container.get_children():
		child.queue_free()

func _remove_asteroids():
	for child in asteroids_container.get_children():
		child.queue_free()

func _game_over() -> void:
	print("game over")
	get_tree().paused = true
	death_screen.show()
	death_screen.on_show()
	
	_remove_bullets()
	_remove_asteroids()

	Utils.save_game()
	
func _new_game() -> void:
	print("starting new game")
	_reset()
	asteroid_spawn_timer.start()
	get_tree().paused = false

func _reset():
	main_menu.hide()
	death_screen.hide()
	
	asteroid_spawn_timer.stop()
	
	_remove_bullets()
	_remove_asteroids()
		
	active_asteroids = 0
	score = 0
	score_label.update_score(score)
	
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
	
	asteroids_container.add_child(asteroid)
	active_asteroids += 1
	
func _on_asteroid_destroyed(asteroid: Asteroid):
	var asteroid_size = asteroid.stats.size
	if asteroid_size == Enums.AsteroidSize.SMALL:
		active_asteroids -= 1
	elif asteroid_size == Enums.AsteroidSize.LARGE:
		active_asteroids += 1

	score += asteroid.stats.score_value
	score_label.update_score(score)

func _on_start_button_pressed():
	_new_game()

func _on_continue_button_pressed():
	get_tree().paused = false
	pause_menu.hide()
