extends CharacterBody2D

@export var speed: float = 200

var facing = "down"

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
    elif velocity.y != 0:
        facing = "down" if velocity.y > 0 else "up"

    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
        animated_sprite.play("walk_" + facing)
    else:
        animated_sprite.play("idle_" + facing)

    move_and_slide()
    