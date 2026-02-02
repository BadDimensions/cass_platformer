class_name Stats extends Resource

@export var health: = 10 :
	set(value):
		health = value
		if health <= 0: no_health.emit()

signal no_health()# Called when the node enters the scene tree for the first time.
