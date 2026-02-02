extends Node2D

const speed = 200
var direction: Vector2:
	set(value):
		direction = value.normalized()
		if is_instance_valid(animated_sprite_2d):
			animated_sprite_2d.rotation = direction.angle()

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	hitbox.body_entered.connect(func(body:Node2D):
		queue_free()
	)
	

func _process(delta: float) -> void:
	if animated_sprite_2d.frame == 0: return
	translate(direction * speed * delta)
	pass
