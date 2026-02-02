extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const speed = 200
var direction: Vector2:
	set(value):
		direction = value.normalized()
		if is_instance_valid(animated_sprite_2d):
			animated_sprite_2d.rotation = direction.angle()
 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(direction * speed * delta)
