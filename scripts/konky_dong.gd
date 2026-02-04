extends Node

enum STATE { IDLE, ROAR, CHARGE }

@export var state: = STATE.IDLE

const speed = 100
var velocity = 50
var direction: Vector2:
	set(value):
		direction = value.normalized()

@onready var sprite_2d: Sprite2D = $Node2D/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var shaker: = Shaker.new(sprite_2d)
@onready var hurtbox: Hurtbox = $Node2D/Hurtbox
@onready var idle_timer: Timer = $idle_timer
@onready var attack_timer: Timer = $attack_timer
@export var friction = 10000
@export var stats: Stats:
	set(value):
		if value is not Stats: return
		stats = value
		stats = stats.duplicate()

@export var is_invincible: = false

func _ready() -> void:
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

func _physics_process(delta: float) -> void:
	match state:
		STATE.IDLE:
			animation_player.play("boss_idle")
			idle_timer.start
			attack_timer.start
	if idle_timer.time_left == 0 and attack_timer.time_left >0:
			state = STATE.ROAR
			animation_player.play("boss_roar")
			is_invincible = true
	if idle_timer.time_left == 0 and attack_timer.time_left == 0:
			state = STATE.CHARGE
			animation_player.play("boss_charge")
			attack_timer.start
	print(state, STATE)
