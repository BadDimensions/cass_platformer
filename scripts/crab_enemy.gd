extends Node2D

enum STATE { IDLE, WALK }
const speed = 100


@export var state: = STATE.IDLE

@onready var anchor: Node2D = $anchor
@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var hurtbox: Hurtbox = $anchor/Hurtbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var shaker: = Shaker.new(sprite_2d)
@export var stats: Stats:
	set(value):
		if value is not Stats: return
		stats = value
		stats = stats.duplicate()
func _ready() -> void:
	stats.no_health.connect(queue_free)
	animation_player.animation_finished.connect(func(anim_name):
		if anim_name == "crab_hit":
			animation_player.play("RESET")
	)
	
	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		stats.health -= other_hitbox.damage
		animation_player.play("crab_hit")
		#effects_animation_player.play("hit_flash")
		shaker.shake(2.0, 0.2)
	)	
	
func _physics_process(delta:float) -> void:
	match state:
		STATE.IDLE:
			pass

func change_state(new_state: STATE) -> void:
	state = new_state
	match state:
		STATE.IDLE:
			#animation_player.play("crab_idle")
			timer.wait_time = 5.0
			timer.start()
		STATE.WALK:
			#animation_player.play("crab_walk")
			timer.wait_time = 5.0
			timer.start()
			
func _on_timer_timeout():
	match state:
		STATE.IDLE:
			change_state(STATE.WALK)
			#animation_player.play("crab_walk")
		STATE.WALK:
			change_state(STATE.IDLE)			
			#animation_player.play("crab_idle")
