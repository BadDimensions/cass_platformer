extends CharacterBody2D

enum STATE { IDLE, ROAR, CHARGE }

@export var state: = STATE.IDLE

const speed = 100
var direction = Vector2.LEFT

@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var anchor: Node2D = $anchor
@onready var shaker: = Shaker.new(sprite_2d)
@onready var hurtbox: Hurtbox = $anchor/Hurtbox
@onready var roar_timer: Timer = $roar_timer
@onready var attack_timer: Timer = $attack_timer
@export var acceleration: = 200
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
	
	if roar_timer.time_left == 0 and attack_timer.time_left >= 0:
		state = STATE.ROAR
	if roar_timer.time_left == 0 and attack_timer.time_left == 0:
		state = STATE.CHARGE
	
	stats.no_health.connect(queue_free)

func _physics_process(delta: float) -> void:
	match state:
		STATE.IDLE:
			animation_player.play("boss_idle")
			roar_timer.start()
			attack_timer.start()
		
		STATE.ROAR:
			animation_player.play("boss_roar")
			is_invincible = true
			
		
		STATE.CHARGE:
			animation_player.play("boss_charge")
			velocity.x = direction.x * speed
			move_and_slide()
			if is_on_wall():
				direction.x *= -1
			apply_friction(delta)
			await animation_player.animation_finished
			STATE.IDLE
			
func change_state(new_state):
	state = new_state
	print(new_state)				
	#print(state, STATE)
func accelerate_horizontally(horizontal_direction: float, delta: float) -> void:
	var acceleration_amount = acceleration
	velocity.x = move_toward(velocity.x, speed * horizontal_direction, acceleration_amount * delta * abs(horizontal_direction))

func apply_friction(delta) -> void:
	var friction_amount = friction
	velocity.x = move_toward(velocity.x, 0.0, friction_amount * delta)
