extends Node

const SAVE_DIR = "user://asteroids"
const SAVE_FILE_PATH = SAVE_DIR + "/save_game.tres"


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


func save_game(save: SaveGame):	
	print("saving...")
	# Create directory if it doesn't exist
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR);
		
	var error := ResourceSaver.save(save, SAVE_FILE_PATH)
	if error != OK:
		print("Error saving game", error_string(error))
	
func load_game() -> SaveGame:
	print("loading")
	var save:SaveGame = ResourceLoader.load(SAVE_FILE_PATH, "SaveGame")
	if !save:
		save = SaveGame.new()
		save_game(save)
	return save
