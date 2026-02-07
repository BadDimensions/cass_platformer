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
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var acceleration: = 200
@export var friction = 10000
@export var stats: Stats:
	set(value):
		if value is not Stats: return
		stats = value
		stats = stats.duplicate()

@export var is_invincible: = false

# reference to Cass
var player: CharacterBody2D = null

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

	hurtbox.hurt.connect(_on_hurt)

	roar_timer.timeout.connect(func(): change_state(STATE.ROAR))

	attack_timer.timeout.connect(func(): change_state(STATE.CHARGE))

	stats.no_health.connect(queue_free)

	# Find the player in the scene
	await get_tree().process_frame # wait one frame to ensure player exists
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Konky Dong couldn't find player!")

	change_state(STATE.IDLE)

func _physics_process(_delta: float) -> void:

	match state:
		STATE.CHARGE:
			velocity.x = direction.x * speed
			move_and_slide()
			if is_on_wall():
				direction.x *= -1

func _face_player() -> void:
	if player == null: return #safety check
	
	if player.global_position.x < global_position.x:
		anchor.scale.x = 1
		# Player is to the left
		#sprite_2d.flip_h = false
		direction = Vector2.LEFT
	else:
		anchor.scale.x = -1
		#sprite_2d.flip_h = true
		direction = Vector2.RIGHT

func change_state(new_state = null):
	match state:
		STATE.ROAR:
			# unset previous invincible state
			is_invincible = false

	state = new_state

	match state:
		STATE.IDLE:
			animation_player.play("boss_idle")
			roar_timer.start()

		STATE.ROAR:
			_face_player()
			animation_player.play("boss_roar")
			is_invincible = true

		STATE.CHARGE:
			_face_player()
			animation_player.play("boss_charge")

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"boss_hit":
			animation_player.play("RESET")
		"boss_roar":
			change_state(STATE.CHARGE)
		"boss_charge":
			change_state(STATE.IDLE)

func _on_hurt(other_hitbox: Hitbox) -> void:
	if is_invincible:
		return

	var newHealth = stats.health - other_hitbox.damage
	if newHealth <= 0:
		animation_player.play("boss_death")
		await animation_player.animation_finished
		stats.health = newHealth
	else:
		animation_player.play("boss_hit")
		shaker.shake(5, 0.2)
		stats.health = newHealth

func accelerate_horizontally(horizontal_direction: float, delta: float) -> void:
	var acceleration_amount = acceleration
	velocity.x = move_toward(velocity.x, speed * horizontal_direction, acceleration_amount * delta * abs(horizontal_direction))

func apply_friction(delta) -> void:
	var friction_amount = friction
	velocity.x = move_toward(velocity.x, 0.0, friction_amount * delta)
