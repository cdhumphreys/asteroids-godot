extends Node2D

class_name Game

# ============================================================================
# EXPORTS
# ============================================================================
@export var asteroid_stats: Array[AsteroidStats]
@export_range(1, 100) var MAX_ASTEROIDS: int
@export var MAX_LIVES: int = 3
@export var MAX_ENEMIES:int = 3

# ============================================================================
# SCENE REFERENCES
# ============================================================================
var asteroid_scene: PackedScene = preload("res://scenes/asteroid.tscn")
var enemy_scene: PackedScene = preload("res://scenes/ufo_enemy.tscn")

# ============================================================================
# GAME STATE
# ============================================================================
var score: int = 0
var username: String = ""
var active_asteroids: int = 0
var active_enemies:int = 0
var lives: int
var active_save_game: SaveGame
var difficulty_level: int = 0: set = _set_difficulty_level
var time_elapsed:float = 0

var current_max_asteroids: int
var current_max_enemies: int

var initial_asteroid_spawn_wait_time: float
var initial_enemy_spawn_wait_time: float

# ============================================================================
# NODE REFERENCES - UI
# ============================================================================
@onready var high_scores_screen: HighScores = %HighScores
@onready var score_label: ScoreLabel = %Score
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var main_menu: MainMenu = %MainMenu
@onready var death_screen: DeathScreen = %DeathScreen
@onready var enter_name_menu: EnterNameMenu = %EnterNameMenu
@onready var lives_counter: LivesCounter = %LivesCounter
@onready var time_elapsed_label: Label = %TimeElapsedLabel
@onready var difficulty_timer: Timer = %DifficultyTimer

# ============================================================================
# NODE REFERENCES - CONTAINERS
# ============================================================================
@onready var asteroids_container: Node = %AsteroidsContainer
@onready var bullets_container: Node = %BulletsContainer
@onready var enemies_container: Node = %EnemiesContainer

# ============================================================================
# NODE REFERENCES - TIMERS
# ============================================================================
@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer
@onready var enemy_spawn_timer: Timer = %EnemySpawnTimer

# ============================================================================
# NODE REFERENCES - OTHER
# ============================================================================
@onready var player: Player = $Player
@onready var asteroid_spawn_location: PathFollow2D = $AsteroidSpawnBoundary/AsteroidSpawnLocation

# ============================================================================
# LIFECYCLE
# ============================================================================
func _ready() -> void:
	lives = MAX_LIVES
	get_tree().paused = true
	active_save_game = Utils.load_game()
	
	current_max_asteroids = MAX_ASTEROIDS
	current_max_enemies = MAX_ENEMIES
	
	initial_asteroid_spawn_wait_time = asteroid_spawn_timer.wait_time
	initial_enemy_spawn_wait_time = enemy_spawn_timer.wait_time

	_connect_signals()
	_initialize_ui()
	
func _process(delta: float):
	if not get_tree().paused:
		time_elapsed += delta
		_update_time_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
			
			pause_menu.hide()
		else:
			get_tree().paused = true
			
			pause_menu.show()
			pause_menu.on_show()

func _connect_signals() -> void:
	EventBus.asteroid_hit.connect(_on_asteroid_destroyed)
	EventBus.start_button_pressed.connect(_on_start_button_pressed)
	EventBus.continue_button_pressed.connect(_on_continue_button_pressed)
	EventBus.new_game_button_pressed.connect(_new_game)
	EventBus.enemy_hit.connect(_on_enemy_destroyed)
	enter_name_menu.on_name_submitted.connect(_on_user_enters_username)
	enemy_spawn_timer.timeout.connect(_spawn_enemy)
	difficulty_timer.timeout.connect(_increase_difficulty_level)
	player.on_hit.connect(_on_player_hit)

func _initialize_ui() -> void:
	main_menu.on_show()
	lives_counter.display_lives(lives)

# ============================================================================
# GAME FLOW
# ============================================================================
func _new_game() -> void:
	_reset()
	asteroid_spawn_timer.start()
	difficulty_timer.start()
	get_tree().paused = false

func _reset() -> void:
	time_elapsed_label.show()
	main_menu.hide()
	death_screen.hide()
	asteroid_spawn_timer.stop()
	difficulty_timer.stop()
	
	_clear_all_entities()
	_reset_game_state()
	_update_ui()
	player.reset()

func _clear_all_entities() -> void:
	_remove_bullets()
	_remove_asteroids()
	_remove_enemies()

func _reset_game_state() -> void:
	active_asteroids = 0
	active_enemies = 0
	current_max_asteroids = MAX_ASTEROIDS
	current_max_enemies = MAX_ENEMIES
	
	score = 0
	lives = MAX_LIVES
	username = ""
	time_elapsed = 0
	difficulty_level = 0

func _update_time_label():
	var minutes := time_elapsed / 60
	var seconds := fmod(time_elapsed, 60)
	var milliseconds := fmod(time_elapsed, 1) * 100
	var time_string := "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	time_elapsed_label.text = time_string

func _update_ui() -> void:
	score_label.update_score(score)
	lives_counter.display_lives(lives)
	_update_time_label()
	

func _on_player_hit() -> void:
	lives -= 1
	lives_counter.display_lives(lives)
	
	if lives > 0:
		_play_hit_sound()
		player.reset(true)
		return

	_handle_player_death()

func _handle_player_death() -> void:
	_clear_all_entities()
	_play_destroyed_sound()
	get_tree().paused = true

	# If new high score (anywhere in top 10) then show name entry screen
	if _check_for_new_high_score():
		enter_name_menu.show()
		enter_name_menu.on_show()
		await enter_name_menu.on_name_submitted
	
	_save_game()
	
	# Show high scores
	high_scores_screen.show()
	high_scores_screen.show_score_list(active_save_game.high_scores)
	high_scores_screen.on_show()
	await high_scores_screen.on_close
	
	# Show death screen
	death_screen.show()
	death_screen.on_show()

func _increase_difficulty_level():
	print("increasing difficulty")
	difficulty_level += 1

func _set_difficulty_level(new_value: int):
	if new_value != difficulty_level:
		difficulty_level = new_value
	
	#increase max asteroids & enemies
	current_max_asteroids = MAX_ASTEROIDS + difficulty_level
	current_max_enemies = MAX_ENEMIES + difficulty_level

	#decrease time to spawn enemies & asteroids
	asteroid_spawn_timer.wait_time = max(initial_asteroid_spawn_wait_time - difficulty_level * 0.5, 2)
	enemy_spawn_timer.wait_time = max(initial_enemy_spawn_wait_time - difficulty_level * 0.5, 3)
	
	
# ============================================================================
# ASTEROIDS
# ============================================================================
func _on_asteroid_spawn_timer_timeout() -> void:
	if active_asteroids == current_max_asteroids:
		return
	
	var asteroid: Asteroid = asteroid_scene.instantiate()
	var asteroid_stat: AsteroidStats = _get_random_asteroid_stat()
	asteroid.stats = asteroid_stat

	# Get random point along boundary
	asteroid_spawn_location.progress_ratio = randf()
	asteroid.global_position = asteroid_spawn_location.position
	
	# Perpendicular to "spawn" vector - points inwards, not sure why PI and not PI/2
	# Must be something up with the asteroid rotation?
	var direction = asteroid_spawn_location.rotation + PI
	
	# Add random offset 
	direction += randf_range(-PI / 4, PI / 4)
	
	# Set direction
	asteroid.rotate(direction)
	
	asteroids_container.add_child(asteroid)
	active_asteroids += 1

func _get_random_asteroid_stat() -> AsteroidStats:
	var res: AsteroidStats = asteroid_stats.pick_random()
	return res.duplicate()

func _on_asteroid_destroyed(asteroid: Asteroid) -> void:
	_play_asteroid_destroyed_sound(asteroid)
	
	var asteroid_size = asteroid.stats.size
	if asteroid_size == Enums.AsteroidSize.SMALL:
		active_asteroids -= 1
	elif asteroid_size == Enums.AsteroidSize.LARGE:
		active_asteroids += 1
		
	_update_score(asteroid.stats.score_value)

func _remove_asteroids() -> void:
	for child in asteroids_container.get_children():
		asteroids_container.call_deferred("remove_child", child)
		child.call_deferred("queue_free")

# ============================================================================
# ENEMIES
# ============================================================================
func _spawn_enemy() -> void:
	if active_enemies >= current_max_enemies:
		return
	active_enemies += 1
	
	var edge: float = [0.0, 1.0].pick_random()
	var enemy: UfoEnemy = enemy_scene.instantiate()
	var enemy_sprite: Sprite2D
	for child in enemy.get_children():
		if child is Sprite2D:
			enemy_sprite = child
			break
	if enemy_sprite == null:
		print("can't find sprite")
		return

	var sprite_size = enemy_sprite.get_rect().size
#	0 or 1 * viewport +/- enemy sprite to appear offscreen
	var offset = -1 * sprite_size.x if edge == 0 else sprite_size.x
	var x = edge * get_viewport_rect().size.x + offset
	var y = randi_range(0, 200)
	enemy.look_at(player.position)
	enemies_container.add_child(enemy)
	enemy.global_position = Vector2(x, y)

func _on_enemy_destroyed(enemy: UfoEnemy) -> void:
	active_enemies -= 1
	_play_enemy_destroyed_sound(enemy)
	_update_score(enemy.score_value)

func _remove_enemies() -> void:
	for child in enemies_container.get_children():
		enemies_container.call_deferred("remove_child", child)
		child.call_deferred("queue_free")

# ============================================================================
# BULLETS
# ============================================================================
func _remove_bullets() -> void:
	for child in bullets_container.get_children():
		bullets_container.call_deferred("remove_child", child)
		child.call_deferred("queue_free")

# ============================================================================
# SCORE
# ============================================================================
func _update_score(score_value: int) -> void:
	score += score_value
	score_label.update_score(score)

# ============================================================================
# HIGH SCORES
# ============================================================================
func _check_for_new_high_score() -> bool:
	if active_save_game.high_scores.size() < 10:
		return true
	
	for entry in active_save_game.high_scores:
		if score > entry.score:
			return true
			
	return false

func _save_game() -> void:
	var is_new_high_score := _check_for_new_high_score()
	if !is_new_high_score:
		return

	# Get username from entry, set up new HighScore
	var new_high_score_entry = HighScore.new()
	new_high_score_entry.score = score
	new_high_score_entry.username = username
	
	_add_new_high_score(new_high_score_entry)
	Utils.save_game(active_save_game)

func _add_new_high_score(new_high_score_entry: HighScore) -> void:
	# Add to array & sort by score
	active_save_game.high_scores.append(new_high_score_entry)
	active_save_game.high_scores.sort_custom(func(a: HighScore, b: HighScore):
		return a.score > b.score)
	
	# If more than 10 entries then remove last one
	if active_save_game.high_scores.size() > 10:
		active_save_game.high_scores.pop_back()

# ============================================================================
# AUDIO
# ============================================================================
func _create_one_off_sound(stream: AudioStream, volume_percentage: float = 1.0) -> void:
	var new_audio_player = AudioStreamPlayer.new()
	new_audio_player.stream = stream
	new_audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if volume_percentage:
		new_audio_player.volume_linear = volume_percentage
		
	get_tree().root.add_child(new_audio_player)
	new_audio_player.play(0)
	
	await new_audio_player.finished
	new_audio_player.queue_free()

func _play_asteroid_destroyed_sound(asteroid: Asteroid) -> void:
	var stream = asteroid.stats.destroyed_sound
	_create_one_off_sound(stream)

func _play_enemy_destroyed_sound(enemy: UfoEnemy) -> void:
	if not enemy.destroyed_sound:
		return
	_create_one_off_sound(enemy.destroyed_sound, 0.5)

func _play_hit_sound() -> void:
	_create_one_off_sound(player.hit_sound, 0.5)

func _play_destroyed_sound() -> void:
	_create_one_off_sound(player.destroyed_sound, 0.75)

# ============================================================================
# UI EVENT HANDLERS
# ============================================================================
func _on_user_enters_username(new_text: String) -> void:
	username = new_text

func _on_start_button_pressed() -> void:
	_new_game()

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()
