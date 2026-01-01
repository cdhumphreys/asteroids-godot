extends Node
class_name ShootingComponent

@export var bullet_scene: PackedScene
@export var bullet_spawn_position: Marker2D
@export var shoot_audio_stream: AudioStream
@export var shoot_cooldown: float = 1.0
@export_range (0.0, 1.0) var shoot_volume: float = 1.0

var bullet_sound_players_container: Node
var bullet_sound_players: Array[AudioStreamPlayer]

signal can_shoot_changed

var can_shoot := true : 
	set(new_value):
		if can_shoot != new_value:
			can_shoot = new_value
			can_shoot_changed.emit()
		

func _ready() -> void:
	_setup_bullet_sound_players()

func _setup_bullet_sound_players() -> void:
	# create new one if container doesn't exist or clear existing players
	bullet_sound_players = []
	if bullet_sound_players_container == null:
		var container_node = Node.new()
		container_node.name = "BulletSoundsContainer"
		add_child(container_node)
		bullet_sound_players_container = container_node
	else:
		for child in bullet_sound_players_container.get_children():
			child.queue_free()
		
	var required_number_of_players: float = ceili(shoot_audio_stream.get_length() / shoot_cooldown)
	#Create a new player to cover max overlapping shot sounds
	for i in range(required_number_of_players):
		var new_player = AudioStreamPlayer.new()
		bullet_sound_players_container.add_child(new_player)
		new_player.stream = shoot_audio_stream
		new_player.volume_linear = shoot_volume
		bullet_sound_players.append(new_player)

# Main function called by entity (Player/Enemy)
func try_shoot() -> void:
	if not can_shoot:
		return

	can_shoot = false
	var bullet: Bullet = bullet_scene.instantiate()
	var game_world: Game = get_tree().get_first_node_in_group("Game")
	if not game_world is Game:
		push_error("Cannot find Game world")
		return
	game_world.bullets_container.add_child(bullet)
	bullet.transform = bullet_spawn_position.global_transform
	
	_play_shoot_sound()
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
	
func _play_shoot_sound():
	#find the first player not already playing and play it
	for player in bullet_sound_players:
		if not player.playing:
			#add a random pitch variation to make it sound less repetetive
			player.pitch_scale = randf_range(0.8, 1.2)
			player.play(0)
			break
	
