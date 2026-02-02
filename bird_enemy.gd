extends Node2D

const ROCK_SCENE = preload("res://rock.tscn")

@onready var effects_animation_player: AnimationPlayer = $anchor/EffectsAnimationPlayer
@onready var sprite_2d: Sprite2D = $anchor/Sprite2D
@onready var shaker: = Shaker.new(sprite_2d)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Area2D = $anchor/Hurtbox
@export var stats: Stats:
	set(value):
		if value is not Stats: return
		stats = value
		stats = stats.duplicate()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurtbox.hurt.connect(func(other_hitbox: Hitbox):
		stats.health -= other_hitbox.damage
		effects_animation_player.play("hit_flash")
		shaker.shake(2.0, 0.2)
	)	
	stats.no_health.connect(func():
		queue_free()
	)
func physics_process() -> void:
	pass	


func fire() -> void:
	var rock = ROCK_SCENE.instantiate()
	get_tree().current_scene.add_child(rock)
	rock.direction = Vector2.LEFT
