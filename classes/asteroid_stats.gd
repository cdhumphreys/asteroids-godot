extends Resource

class_name AsteroidStats

@export var textures: Array[Texture2D] = [AtlasTexture.new()]

@export var size: Enums.AsteroidSize = Enums.AsteroidSize.SMALL

@export var collision_shape: CircleShape2D

@export var score_value: int

@export var destroyed_sound: AudioStream

const MIN_SPEEDS = {
	Enums.AsteroidSize.SMALL: 150,
	Enums.AsteroidSize.LARGE: 50,
}

const MAX_SPEEDS = {
	Enums.AsteroidSize.SMALL: 300,
	Enums.AsteroidSize.LARGE: 100,
}

var MIN_SPEED = MIN_SPEEDS[size]
var MAX_SPEED = MAX_SPEEDS[size]
