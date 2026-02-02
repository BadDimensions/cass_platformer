extends Sprite2D

const background_texture  = preload("res://sprite_sheets/background.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = background_texture
	
