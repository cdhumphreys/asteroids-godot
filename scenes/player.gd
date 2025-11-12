extends CharacterBody2D

const MAX_SPEED = 300
const ACCELERATION = 5.0
const ROTATION_SPEED = 0.1
var speed = 0;

func _physics_process(delta):
	if Input.is_action_pressed("thrust_forward"):
		velocity.x += ACCELERATION * sin(rotation)
		velocity.y += -1 * ACCELERATION * cos(rotation)
	if Input.is_action_pressed("thrust_backward"):
		velocity.x += -1 * ACCELERATION * sin(rotation)
		velocity.y += ACCELERATION * cos(rotation)
	if Input.is_action_pressed("rotate_clockwise"):
		rotation += ROTATION_SPEED
	if Input.is_action_pressed("rotate_anticlockwise"):
		rotation -= ROTATION_SPEED
	
	# Cap speed
	if velocity.x > MAX_SPEED:
		velocity.x = MAX_SPEED
	
	if velocity.x < -1 * MAX_SPEED:
		velocity.x = -1 * MAX_SPEED
	
	if velocity.y > MAX_SPEED:
		velocity.y = MAX_SPEED
		
	if velocity.y < -1 * MAX_SPEED:
		velocity.y = -1 * MAX_SPEED

	move_and_slide()
