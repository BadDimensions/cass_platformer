extends CanvasLayer


@onready var sprite_2d: Sprite2D = $Sprite2D

var frame: Array = [ "frame_0","frame_1","frame_2", "frame_3" ]
#normally i would try to leav you some kinda of structure so you could at least see 
#what im trying to do but with this one im stumped


func update_health_display():
	sprite_2d.frame = 3
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_health_changed(delta: float) -> void:
	update_health_display()
	pass # Replace with function body.
