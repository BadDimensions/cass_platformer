extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var anchor: Node2D = $anchor
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var max_speed = 50
@export var acceleration = 100
@export var air_acceleration = 200
@export var friction = 10000
@export var air_friction = 500
@export var up_gravity = 500
@export var down_gravity = 600
@export var jump_amount = 500


func _physics_process(delta:float) -> void:
	var x_input = Input.get_axis("move_left", "move_right")
	velocity.x = x_input * 50
	
	if not is_on_floor():
		velocity.y += up_gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		animation_player.play("cass_jump")
		velocity.y = -jump_amount
	
	apply_gravity(delta)
	
	if x_input == 0:
		apply_friction(delta)
		animation_player.play("cass_idle")
	else:
		accelerate_horizontally(x_input, delta)
		anchor.scale.x = sign(x_input)
		animation_player.play("cass_run")
	
	if not is_on_floor():
		animation_player.play("cass_jump")
		
	move_and_slide()
	

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
