extends CharacterBody2D

enum STATE { MOVE, HIT }

@export var state: = STATE.MOVE

@onready var hurtbox: Hurtbox = $Hurtbox

@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var anchor: Node2D = $anchor
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shaker: = Shaker.new(anchor)
@onready var camera_2d: Camera2D = $Camera2D

const wall_jump_pushback = 100
const wall_slide_gravity = 100


var is_wall_sliding = false
var coyote_time = 0
var wall_normal = get_wall_normal()

@export var stats: Stats
@export var max_speed = 50
@export var acceleration = 100
@export var air_acceleration = 200
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

		# calcuate the new health before applying it to the state
		# play the correct animation based on if dead or not
		var newHealth = stats.health - other_hitbox.damage
		if newHealth <= 0:
			animation_player.play("cass_death")
			await animation_player.animation_finished
			stats.health = newHealth
		else:
			animation_player.play("cass_hit")
			await animation_player.animation_finished
			stats.health = newHealth

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
