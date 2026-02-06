extends CanvasLayer

signal start_game
signal game_over

@onready var sprite_2d: Sprite2D = $Sprite2D

func init():
	get_tree().paused = true
	$Sprite2D.show()
	$StartButton.show()
	$GameOver.hide()
	
func show_game_over():
	get_tree().paused = true
	$GameOver.show()
	await $MessageTimer.timeout
	$Sprite2D.show()
	$StartButton.show()

func _on_game_start():
	get_tree().paused = false
	$Sprite2D.show()	
	$GameOver.hide()
func _on_start_button_pressed():
	$Sprite2D.hide()
	$StartButton.hide()
	start_game.emit()
	get_tree().paused = false
	hide()
	
	#cass can still move while the menu is up you dont have to start the game to
	#start the game?
func _on_message_timer_timeout():
		$GameOver.hide()
