extends CharacterBody2D

enum STATE { MOVE, HIT }

@onready var starting_position: Marker2D = $"../Starting_Position"
@export var state: = STATE.MOVE
@export var jump_cut_multiplier: float = 0.3

@onready var hurtbox: Hurtbox = $anchor/Hurtbox
@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var anchor: Node2D = $anchor
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shaker: = Shaker.new(anchor)
@onready var camera_2d: Camera2D = $Camera2D

const HEALTH = preload("res://health.tscn")
const wall_jump_pushback = 100
const wall_slide_gravity = 100
signal health_changed(newHealth : int)
signal no_health
var is_wall_sliding = false
var coyote_time = 0
var wall_normal = get_wall_normal()

@export var knockback_amount: int = 500
@export var is_invincible = false
@export var stats: Stats
@export var max_speed = 100
@export var acceleration = 200
@export var air_acceleration = 300
@export var friction = 10000
@export var air_friction = 500
@export var up_gravity = 500
@export var down_gravity = 600
@export var jump_amount = 700

func _ready() -> void:
	stats.no_health.connect(queue_free)
	
	
	#camera_2d.reparent(get_tree().current_scene)

	# Return to MOVE state when hit animation finishes
	animation_player.animation_finished.connect(func(anim_name):
		if anim_name == "cass_hit" and state == STATE.HIT:
			state = STATE.MOVE
	)

	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		var x_direction = sign(other_hitbox.global_position.direction_to(global_position).x)
		if x_direction == 0 : x_direction = -1
		velocity.x = x_direction * max_speed
		state = STATE.HIT
		var newHealth = stats.health - other_hitbox.damage
		if newHealth <= 0:
			animation_player.play("cass_death")
			
			# emit the signal so health bar deducts
			# doing this before the death animation completes, so it feels more snappy
			health_changed.emit(newHealth)
			await animation_player.animation_finished
			stats.health = newHealth
		else:
			animation_player.play("cass_hit")
			await animation_player.animation_finished
			stats.health = newHealth
			# emit the signal so health bar deducts
			health_changed.emit(stats.health)
			knockback() #dont know if knockback needs to be here
			#jump(jump_amount/2)
			shaker.shake(10,0.3)
	)

func _physics_process(delta:float) -> void:
	match state:
		STATE.MOVE:
			coyote_time -= delta

			var x_input = Input.get_axis("move_left", "move_right")

			apply_gravity(delta)
			wall_slide(delta)


			if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_time >= 0):
				jump()
			if Input.is_action_just_pressed("jump") and is_on_wall():
				jump()
			if Input.is_action_just_pressed("move_up"): jump()

			# how we implement "jump cut"
			if Input.is_action_just_released("jump") and velocity.y < 0:
				velocity.y *= jump_cut_multiplier

			if x_input == 0:
				apply_friction(delta)
			else:
				accelerate_horizontally(x_input, delta)
				anchor.scale.x = sign(x_input)

			# Check for attack first
			if Input.is_action_just_pressed("attack") and not is_on_floor():
				animation_player.play("cass_jumpattack")
			elif Input.is_action_just_pressed("attack") and is_on_floor():
				animation_player.play("cass_attack")
			# Only play movement animations if NOT currently playing an attack animation
			elif animation_player.current_animation not in ["cass_attack", "cass_jumpattack"]:
				if is_on_wall() and not is_on_floor():
					animation_player.play("cass_walltouch")
				elif not is_on_floor() and velocity.y <= 0:
					animation_player.play("cass_jump")
				elif not is_on_floor() and velocity.y >= 0:
					if animation_player.current_animation != "cass_fall":
						animation_player.play("cass_fall")
				elif x_input != 0:
					animation_player.play("cass_run")
				else:
					animation_player.play("cass_idle")

#
			var was_on_floor: = is_on_floor()
			move_and_slide()
			if was_on_floor and not is_on_floor() and velocity.y >= 0:
				coyote_time = 0.1

		STATE.HIT:
			is_invincible = true
			#the player needs to be invincible in the hit state so you cant
			#take another hit immediately
			if stats.health > 0:
				knockback()
			#tried to put arguments in this like other hitbox but that isnt declared
			#in physics process so it was breaking the code. the player will knocback
			#but barely and it shakes the camera horrbily and its inconsistent.
			#also when you die the knockback effect plays forever
			move_and_slide()
			apply_friction(delta)
			apply_gravity(delta)
			

func jump() -> void:
		if is_on_floor() or is_on_wall():
			velocity.y = -jump_amount
		if is_on_wall() and Input.is_action_pressed("move_right"):
			velocity.y = -jump_amount
			velocity.x = -wall_jump_pushback
		if is_on_wall() and Input.is_action_pressed("move_left"):
			velocity.y = -jump_amount
			velocity.x = wall_jump_pushback

func wall_slide(delta):
	if is_on_wall_only() and not Input.is_action_pressed("jump"):
		if Input.get_axis("move_left", "move_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false

	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)

func accelerate_horizontally(horizontal_direction: float, delta: float) -> void:
	var acceleration_amount = acceleration
	if not is_on_floor(): acceleration_amount = air_acceleration
	velocity.x = move_toward(velocity.x, max_speed * horizontal_direction, acceleration_amount * delta * abs(horizontal_direction))

func apply_friction(delta) -> void:
	var friction_amount = friction
	if not is_on_floor(): friction_amount = air_friction
	velocity.x = move_toward(velocity.x, 0.0, friction_amount * delta)

func apply_gravity(delta) -> void:
	if not is_on_floor():
		if velocity.y <= 0:
			velocity.y += up_gravity * delta
		else:
			velocity.y += down_gravity * delta
func knockback():
	var knockback_direction = -velocity.normalized() * knockback_amount
	velocity = knockback_direction
	move_and_slide()
#attempted to implement knockback to solve the issue of so cass would jump
#back when you take a hit so ydon immetdielty take another
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false 
