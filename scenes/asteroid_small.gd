extends RigidBody2D

class_name AsteroidSmall

var sprites: Array[String] = [
	"res://assets/meteor_detailedSmall.png",
	"res://assets/meteor_small.png",
	"res://assets/meteor_squareDetailedSmall.png",
	"res://assets/meteor_squareSmall.png",
	
]

@onready var sprite = $Sprite2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
	# Pick one of the asteroid PNGs
	sprite.texture = load(sprites.pick_random())
	
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
