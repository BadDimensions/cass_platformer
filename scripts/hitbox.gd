class_name Hitbox extends Area2D

@export var damage = 1.0

signal hit(hurtbox: Hurtbox)



func _ready() -> void:
	area_entered.connect(on_area_entered)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_area_entered(area_2d: Area2D) -> void:
	assert(area_2d is Hurtbox, "The hitbox detected an area that wasn't a hurtbox.")
	var hurtbox = area_2d as Hurtbox 
	hurtbox.take_hit(self)
	hit.emit(hurtbox)

	
	
