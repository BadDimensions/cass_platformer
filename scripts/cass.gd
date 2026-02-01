extends CharacterBody2D

enum STATE { MOVE }

@export var state: = STATE.MOVE

@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var anchor: Node2D = $anchor
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const wall_jump_pushback = 100
const wall_slide_gravity = 100


var is_wall_sliding = false
var coyote_time = 0
var wall_normal = get_wall_normal()


@export var max_speed = 50
@export var acceleration = 100
@export var air_acceleration = 200
@export var friction = 10000
@export var air_friction = 500
@export var up_gravity = 500
@export var down_gravity = 600
@export var jump_amount = 700

func _ready() -> void:
	# adding this caused issues with animation not playing properly
	# it seems to conflict with the animation_player.play() calls in _physics_process

	# 	animation_player.current_animation_changed.connect(func(animation_name: String):
	# 		animation_player.play(animation_name)
	# )
	#
	# passing through for now
	pass

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
