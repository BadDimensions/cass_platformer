extends Node


func _ready() -> void:
	pass 

func game_over():
	$hud.show_game_over()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func new_game():
	$Start_Timer.start()
	$cass.start($Starting_Position.position)
	pass


func _on_start_timer_timeout() -> void:
	pass # Replace with function body.
