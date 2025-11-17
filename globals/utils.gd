extends Node

func keep_body_in_screen_bounds(pos: Vector2, screen_rect: Rect2, width = 0, height = 0) -> Vector2:
	var screen_width = screen_rect.size.x
	var screen_height = screen_rect.size.y
	
	if pos.y - height > screen_height:
		pos.y = -height
	elif pos.y + height < 0:
		pos.y = screen_height + height
	
	if pos.x - width > screen_width:
		pos.x = -width
	elif pos.x + width < 0:
		pos.x = screen_width + width
		
	return pos
	
