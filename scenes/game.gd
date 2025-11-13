extends Node2D

@onready var leftEdge = $LeftEdge;
@onready var rightEdge = $RightEdge;
@onready var topEdge = $TopEdge;
@onready var bottomEdge = $BottomEdge;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_size_from_body(body: PhysicsBody2D) -> Vector2:
	var body_collision_shape: CollisionShape2D = body.get_node_or_null("CollisionShape2D")
	if !body_collision_shape:
		return Vector2.ZERO

	var sizes = body_collision_shape.shape.get_rect().size
	return sizes

# Handle player going off screen
func _on_left_edge_body_entered(body):
	if body is not PhysicsBody2D:
		return
		
	var sizes = get_size_from_body(body)
	if sizes != Vector2.ZERO:
		body.global_position.x = rightEdge.position.x - sizes.x


func _on_right_edge_body_entered(body):
	if body is not PhysicsBody2D:
		return
	var sizes = get_size_from_body(body)
	if sizes != Vector2.ZERO:
		body.global_position.x = leftEdge.position.x + sizes.x


func _on_top_edge_body_entered(body):
	if body is not PhysicsBody2D:
		return
		
	var sizes = get_size_from_body(body)
	if sizes != Vector2.ZERO:
		body.global_position.y = bottomEdge.position.y - sizes.y


func _on_bottom_edge_body_entered(body):
	if body is not PhysicsBody2D:
		return
	var sizes = get_size_from_body(body)
	if sizes != Vector2.ZERO:
		body.global_position.y = topEdge.position.y + sizes.y
