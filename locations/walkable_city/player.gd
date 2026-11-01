extends CharacterBody2D

@export var speed = 200  # How fast the player will move (pixels/sec).
@export var movement_bounds: Rect2 = Rect2()
var facing := "down"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.x != 0:
		facing = "right" if velocity.x > 0 else "left"
	elif velocity.y > 0:
		facing = "down"
	elif velocity.y < 0:
		facing = "up"

	var animation_name := "idle_" + facing
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		# The PixelLab export only includes walking cycles for north and south.
		if animated_sprite.sprite_frames.has_animation("walk_" + facing):
			animation_name = "walk_" + facing
	animated_sprite.play(animation_name)

	move_and_slide()
	# The character's origin is at its feet, at the bottom center of a 32x32 frame.
	var bounds := movement_bounds
	if not bounds.has_area():
		bounds = Rect2(Vector2.ZERO, get_viewport_rect().size)
	position = position.clamp(bounds.position + Vector2(16, 32), bounds.end - Vector2(16, 0))
