extends CanvasLayer


@onready var sprite_2d: Sprite2D = $Sprite2D

var frame: Array = [ 
	"frame_0", # full health
	"frame_1",
	"frame_2", 
	"frame_3" # empty health
]

func _ready():
	# Get a reference to player and connect to health changes
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("health_changed"):
		# listen to Cass's `health_changed` signal
		player.health_changed.connect(_on_health_changed)

func update_health_display(current_health: int):
	# frame 0 is full health
	# Cass at full health = 3
	# 3 - cass_full_health = 0 (full health frame)
	sprite_2d.frame = 3 - current_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_health_changed(new_health: int) -> void:
	update_health_display(new_health)
	pass
