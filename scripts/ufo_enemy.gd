class_name UfoEnemy extends CharacterBody2D

@export var shooting_component: ShootingComponent

@export var min_distance: float
@export var speed: int = 20
@export var enemy_repulsion_force: float = 50000.0

@export var score_value: int = 10
@export var destroyed_sound: AudioStream


@onready var initial_shoot_timer: Timer = %InitialShootTimer
@onready var sprite: Sprite2D = %EnemyA

var player: Player

var width: float
var height: float

var intention := Vector2.ZERO

func _ready():
	_get_sprite_dimensions()
	player = get_tree().get_first_node_in_group("Player")
	shooting_component.can_shoot_changed.connect(_try_shoot)
	await initial_shoot_timer.timeout
	_try_shoot()

func _get_sprite_dimensions():
	var size = sprite.get_rect().size
	width = size.x
	height = size.y
	

func _physics_process(_delta: float) -> void:
	_handle_movement()
	
	# keep looking at the player so bullets go in that direction, 
	# lerp so it's not immediate and jarring
	var target_angle = get_angle_to(player.position)
	rotation = lerp_angle(rotation, rotation + target_angle, 0.05)
	
	
	move_and_slide()
	
	#bounds checks
	position = Utils.keep_body_in_screen_bounds(global_position, get_viewport_rect(), width, height)

func _handle_movement():
	intention = Vector2.ZERO
	_get_player_movement_intention()
	_get_enemy_movement_intention()
	
	# Only bother moving if above a threshold
	if intention.abs().length() < 0.5:
		intention = Vector2.ZERO
		
	var normalised_intention = intention.normalized()
	
	velocity.x = lerp(velocity.x, normalised_intention.x * speed, 0.02)
	velocity.y = lerp(velocity.y, normalised_intention.y * speed, 0.02)
	
	
func _get_player_movement_intention():
	var difference = player.position - position
	var distance = difference.length()
	var direction = difference.normalized()
	var spring_strength = (distance - min_distance)
	
	intention += spring_strength * direction
	

func _get_enemy_movement_intention():
	var enemy_container = get_tree().get_first_node_in_group("EnemyContainer")
	var enemies = enemy_container.get_children()

	if len(enemies) == 1:
		return
		
	for e in enemies:
		if e == self or e is not UfoEnemy:
			continue
		var enemy := e as UfoEnemy
		var difference := enemy.global_position - global_position
		var distance := difference.length()
		
		# Skip if too far away (optimization)
		if distance > 200.0:
			continue
			
		var direction := difference.normalized()
		
		# Inverse square law: repulsion increases quadratically as distance decreases
		# Small epsilon prevents division by zero when enemies overlap
		var epsilon: float = 1.0
		var spring_strength: float = enemy_repulsion_force / (distance * distance + epsilon)
		
		# Push away from each other
		intention -= spring_strength * direction

func _try_shoot():
	shooting_component.try_shoot()


func _on_health_component_health_depleted() -> void:
	EventBus.enemy_hit.emit(self)
	queue_free()
