extends CharacterBody2D
class_name UfoEnemy

@export var shooting_component: ShootingComponent

@export var speed: int = 20
@export var score_value: int = 10
@onready var initial_shoot_timer: Timer = %InitialShootTimer

@export var destroyed_sound: AudioStream

var player: Player

var width = 128 
var height = 128

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	shooting_component.can_shoot_changed.connect(_try_shoot)
	await initial_shoot_timer.timeout
	_try_shoot()

func _physics_process(_delta: float) -> void:
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	look_at(player.position)
	rotate(PI/2)
	move_and_slide()
	position = Utils.keep_body_in_screen_bounds(global_position, get_viewport_rect(), width, height)
	

func _try_shoot():
	shooting_component.try_shoot()


func _on_health_component_health_depleted() -> void:
	EventBus.enemy_hit.emit(self)
	queue_free()
