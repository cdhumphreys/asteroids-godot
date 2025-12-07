extends Node2D

class_name Game

@export var asteroid_stats: Array[AsteroidStats]
@export_range (1, 100) var MAX_ASTEROIDS: int
@export var lives:int = 3 

var asteroid_scene: PackedScene = preload("res://scenes/asteroid.tscn")
var score = 0
var username = "";
var asteroid_sizes = Enums.AsteroidSize.keys()
var active_asteroids = 0

var active_save_game: SaveGame

@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer
@onready var player: Player = $Player
@onready var asteroid_spawn_location: PathFollow2D = $AsteroidSpawnBoundary/AsteroidSpawnLocation

@onready var high_scores_screen: HighScores = %HighScores

@onready var score_label: ScoreLabel = %Score

@onready var pause_menu: PauseMenu = %PauseMenu
@onready var main_menu: MainMenu = %MainMenu
@onready var death_screen: DeathScreen = %DeathScreen
@onready var enter_name_menu: EnterNameMenu = %EnterNameMenu

@onready var asteroids_container: Node = %AsteroidsContainer
@onready var bullets_container: Node = %BulletsContainer


func _ready() -> void:
	get_tree().paused = true
	EventBus.asteroid_hit.connect(_on_asteroid_destroyed)
	EventBus.start_button_pressed.connect(_on_start_button_pressed)
	EventBus.continue_button_pressed.connect(_on_continue_button_pressed)
	EventBus.new_game_button_pressed.connect(_new_game)
	
	enter_name_menu.on_name_submitted.connect(_on_user_enters_username)
	
	active_save_game = Utils.load_game()
	
	main_menu.on_show()


func _on_user_enters_username(new_text: String):
	username = new_text

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
		bullets_container.remove_child.call_deferred(child)
		child.queue_free.call_deferred()


func _remove_asteroids():
	for child in asteroids_container.get_children():
		asteroids_container.remove_child.call_deferred(child)
		child.queue_free.call_deferred()


func _game_over() -> void:
	_remove_bullets()
	_remove_asteroids()

	get_tree().paused = true

	# If new high score (anywhere in top 10) then show name entry screen
	if _check_for_new_high_score():
		enter_name_menu.show()
		enter_name_menu.on_show()
		await enter_name_menu.on_name_submitted
	
	_save_game()
	
#	Show high scores
	high_scores_screen.show()
	high_scores_screen.show_score_list(active_save_game.high_scores)
	high_scores_screen.on_show()
	
	await high_scores_screen.on_close
	
#	Show death screen
	death_screen.show()
	death_screen.on_show()


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
	username = ""
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


func _save_game():
	var is_new_high_score := _check_for_new_high_score()
	if !is_new_high_score:
		return

	# Get username from entry, set up new HighScore
	var new_high_score_entry = HighScore.new()
	new_high_score_entry.score = score
	new_high_score_entry.username = username
	
	_add_new_high_score(new_high_score_entry)
	
	Utils.save_game(active_save_game)

func _add_new_high_score(new_high_score_entry: HighScore):
	# Add to array & sort by score
	active_save_game.high_scores.append(new_high_score_entry)
	active_save_game.high_scores.sort_custom(func(a: HighScore, b: HighScore):
		return a.score > b.score)
	
	# if more than 10 entries then remove last one
	if len(active_save_game.high_scores) > 10:
		active_save_game.high_scores.pop_back()
	

func _check_for_new_high_score() -> bool:	
	if len(active_save_game.high_scores) < 10:
		return true
	
	for entry in active_save_game.high_scores:
		if score > entry.score:
			return true
			
	return false
