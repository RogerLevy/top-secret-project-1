extends CharacterBody2D

@export var WALK_FORCE = 600
@export var WALK_MAX_SPEED = 200
@export var STOP_FORCE = 1300
@export var JUMP_SPEED = 200
@export var FALL_MAX_SPEED = 220

@export var gravity = 700
@export var ball = false

@export var camera:Camera2D

signal juice_changed
signal give_juice

@export var MAX_JUICE = 20

@export var juice = 20:
	set( n ):
		juice = n
		emit_signal( "juice_changed", n )

@onready var bullet_scene = preload("res://objects/bullet/testbullet.tscn")

func _ready():
	juice = juice

func _physics_process(delta):
	var walk = WALK_FORCE * (Input.get_axis(&"move_left", &"move_right"))
	
	if is_on_floor():
		if walk:
			$AnimatedSprite2D.play("run")
			$AnimatedSprite2D.speed_scale = 4
			$AnimatedSprite2D.flip_h = sign(walk) < 0	
		else:
			$AnimatedSprite2D.play("idle")
	else:
		if walk != 0:
			$AnimatedSprite2D.flip_h = sign(walk) < 0	
		
		if velocity.y > 0:
			$AnimatedSprite2D.play("jump")
		else:
			if Input.is_action_pressed("jump"):
				velocity.y += 0.1
			else:
				if velocity.y < 0:
					velocity.y *= .75
			$AnimatedSprite2D.play("jump")
	
	if abs(walk) < WALK_FORCE * 0.2:
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		velocity.x += walk * delta

	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
	velocity.y += gravity * delta
	velocity.y = clamp( velocity.y, -9999999999, FALL_MAX_SPEED )
	move_and_slide()		

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED

	if Input.is_action_just_pressed("ball"):
		ball = true
		$AnimatedSprite2D.rotation = 0
		$AnimatedSprite2D.position.y = 4
	
	if Input.is_action_just_pressed("stand"):
		ball = false
		$AnimatedSprite2D.rotation = 0
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.position.y = 0
		$CollisionShape2DBall.disabled = true
		$CollisionShape2D.disabled = false

	if ball:
		$AnimatedSprite2D.rotate(0.01 * (velocity.x))
		$AnimatedSprite2D.play("ball")
		$AnimatedSprite2D.offset.x = 0
		$CollisionShape2DBall.disabled = false
		$CollisionShape2D.disabled = true
		if is_on_floor():
			STOP_FORCE = 500
		else:
			STOP_FORCE = 500
	else:
		STOP_FORCE = 99999
	
		if Input.is_action_just_pressed("shoot") && juice > 0:
			var bullet:CharacterBody2D = bullet_scene.instantiate()
			get_tree().current_scene.add_child( bullet )
			bullet.global_position = find_child("gun_marker").global_position
			if $AnimatedSprite2D.flip_h:
				bullet.velocity.x = -5
			else:
				bullet.velocity.x = 5
			juice -= 1
	
	$flipstuff.scale.x = -1 if $AnimatedSprite2D.flip_h else 1
	
#	if Input.is_action_pressed("look_up"):
#		$RemoteTransform2D.position.y = -64
#	elif Input.is_action_pressed("look_down"):
#		$RemoteTransform2D.position.y = 64
#	else:
#		$RemoteTransform2D.position.y = 2

# rooms
func _on_area_2d_area_entered(area:Area2D):
	if not camera: return
	if not area is Room: return
	var cs:CollisionShape2D = area.find_child("CollisionShape2D")
	var rect:Rect2 = cs.shape.get_rect()
	rect.position = area.position
	rect.size *= area.scale
	print_debug(rect)
	camera.limit_left = rect.position.x
	camera.limit_right = rect.position.x + rect.size.x
	camera.limit_top = rect.position.y + 4
	camera.limit_bottom = rect.position.y + rect.size.y


func _on_give_juice(n,area):
	juice = min( MAX_JUICE, juice + n )
