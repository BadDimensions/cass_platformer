extends CanvasLayer

signal start_game
signal game_over

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var starting_position: Marker2D = $"../Starting_Position"

func _ready():
	get_tree().paused = true
	$Sprite2D.show()
	$StartButton.show()
	$GameOver.hide()

func show_game_over():
	# _on_start_button_pressed we hide the entire hud canvase
	# we need to show it again
	show();
	
	get_tree().paused = true
	$GameOver.show()
	$MessageTimer.start() # have to start the timer
	await $MessageTimer.timeout # then wait for the timeout
	$Sprite2D.show()
	$GameOver.hide()
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

func _on_message_timer_timeout():
		$GameOver.hide()
