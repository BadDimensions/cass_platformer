extends CanvasLayer

signal start_game


func show_message(text): 
	$Message.text = text
	$MessageTimer.start()

func show_game_over():
	show_message("GAME OVER")
	await $MessageTimer.timeout
	#this the game over funtion is not working im not sure why
	$Label.text = "SO BELEZA PURA"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func _on_start_button_pressed():
	$Label.hide()
	$StartButton.hide()
	start_game.emit()
	#cass can still move while the menu is up you dont have to start the game to
	#start the game?
func _on_message_timer_timeout():
		$Message.hide()
