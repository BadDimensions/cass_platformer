extends CharacterBody2D

enum STATE { IDLE, WALK }
const speed = 100
var direction = Vector2.LEFT

@export var state: = STATE.IDLE
@export var is_invincible = false
@export var acceleration = 200
@export var friction = 10000

@onready var anchor: Node2D = $anchor
@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var hurtbox: Hurtbox = $anchor/Hurtbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var walk_timer: Timer = $walk_timer
@onready var idle_timer: Timer = $idle_timer
@onready var shaker: = Shaker.new(sprite_2d)
@export var stats: Stats:
	set(value):
		if value is not Stats: return
		stats = value
		stats = stats.duplicate()
func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

	hurtbox.hurt.connect(_on_hurt)
	idle_timer.timeout.connect(func(): change_state(STATE.IDLE))
	walk_timer.timeout.connect(func(): change_state(STATE.WALK))
	
	stats.no_health.connect(queue_free)

	change_state(STATE.IDLE)
			
	
func _physics_process(delta:float) -> void:
	match state:
		STATE.WALK:
			velocity.x = direction.x * speed
			move_and_slide()
			if is_on_wall():
				direction.x *= -1

func change_state(new_state = null):
	match state:
		STATE.IDLE:
			is_invincible = false
	state = new_state
		
	match state:	
		STATE.IDLE:
			animation_player.play("crab_idle")
			walk_timer.start()	
		STATE.WALK:
			animation_player.play("crab_walk")
			idle_timer.start()

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"crab_hit":
			animation_player.play("crab_idle")
		"crab_walk":
			change_state(STATE.IDLE)
		"crab_idle":
			change_state(STATE.WALK)			

func _on_hurt(other_hitbox: Hitbox) -> void:
	if is_invincible:
		return

	var newHealth = stats.health - other_hitbox.damage
	if newHealth <= 0:
		animation_player.play("crab_death")
		await animation_player.animation_finished
		stats.health = newHealth
	else:
		animation_player.play("crab_hit")
		shaker.shake(5, 0.2)
		stats.health = newHealth

func accelerate_horizontally(horizontal_direction: float, delta: float) -> void:
	var acceleration_amount = acceleration
	velocity.x = move_toward(velocity.x, speed * horizontal_direction, acceleration_amount * delta * abs(horizontal_direction))

func apply_friction(delta) -> void:
	var friction_amount = friction
	velocity.x = move_toward(velocity.x, 0.0, friction_amount * delta)
