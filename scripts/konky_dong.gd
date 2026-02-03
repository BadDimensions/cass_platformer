extends Node

enum STATE { IDLE, ROAR, CHARGE }
const speed = 100

var state = STATE.IDLE# Called when the node enters the scene tree for the first time.

@onready var sprite_2d: Sprite2D = $Node2D/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var shaker: = Shaker.new(sprite_2d)
@onready var hurtbox: Hurtbox = $Node2D/Hurtbox

@export var stats: Stats


func _ready() -> void:
	pass # Replace with function body.
	animation_player.animation_finished.connect(func(anim_name):
		if anim_name == "boss_hit":
			animation_player.play("RESET")
	)
	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		var newHealth = stats.health - other_hitbox.damage
	
		if newHealth <= 0:
			animation_player.play("boss_death")
			await animation_player.animation_finished
			stats.health = newHealth
		else:
			animation_player.play("boss_hit")
			await animation_player.animation_finished
			stats.health = newHealth
			shaker.shake(5, 0.2)
	)

	stats.no_health.connect(queue_free)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
