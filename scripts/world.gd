extends Node


func _ready() -> void:
	$cass.no_health.connect(game_over)
	pass 

func game_over():
	print("game over called")
	$hud.show_game_over()
	$Music.stop()
	$GameOver.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func new_game():
	$Start_Timer.start()
	$cass.start($Starting_Position.position)
	$Music.play()
	pass


func _on_start_timer_timeout() -> void:
	pass # Replace with function body.
