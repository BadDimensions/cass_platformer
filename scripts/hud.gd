extends CanvasLayer

signal start_game
@onready var sprite_2d: Sprite2D = $Sprite2D

func init():
	get_tree().paused = true
	$Sprite2D.show()
	$StartButton.show()

func show_message(text): 
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	get_tree().paused = true
	show()	
	
	$Sprite2D.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
func _on_game_start():
	get_tree().paused = false
	show()	

func _on_start_button_pressed():
	$Sprite2D.hide()
	$StartButton.hide()
	start_game.emit()
	get_tree().paused = false
	hide()
	
	#cass can still move while the menu is up you dont have to start the game to
	#start the game?
func _on_message_timer_timeout():
		$Message.hide()
