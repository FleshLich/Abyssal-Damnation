extends KinematicBody2D

export var health = 100
export var combo_points = 0

export var attack_num = 0

export var SPEED = 10
export var DASH_SPEED = 30

onready var animplayer = $Sprite/AnimationPlayer
onready var dashTimer = $DashTimer
onready var cooldown = $DashCooldown

var screen_size

var is_moving = false
var moving_left = false
var moving_right = false
var is_attacking = false
var is_combo = false

var can_dash = true
var is_dashing = false

var last_direction = Vector2.DOWN



# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var motion = Vector2()	
	
	if Input.is_action_pressed("Space") and not is_attacking and can_dash:
		set_collision_mask_bit(3, false)
		set_collision_layer_bit(2, false)
		can_dash = false
		is_dashing = true
		dashTimer.start()
	
	is_moving = false
	if Input.is_action_pressed("Up"):
		motion.y -= 1
		is_moving = true
		last_direction = Vector2.UP
	elif Input.is_action_pressed("Down"):
		motion.y += 1
		is_moving = true
		last_direction = Vector2.DOWN
	if Input.is_action_pressed("Right"):
		motion.x += 1
		moving_right = true
		moving_left = false
		is_moving = true
		last_direction = Vector2.RIGHT
	elif Input.is_action_pressed("Left"):
		motion.x -= 1
		moving_left = true
		moving_right = false
		is_moving = true
		last_direction = Vector2.LEFT
	
		
	if Input.is_action_pressed("LeftClick") and not is_attacking:
		is_attacking = true
		animplayer.play("Attack")
		is_moving = false
	elif Input.is_action_pressed("RightClick") and not is_attacking:
		is_attacking = true
		animplayer.play("Attack2")
		is_moving = false
	
	if is_attacking or is_combo:
		return
		
	if moving_right:
		scale.x = scale.y
	elif moving_left:
		scale.x = scale.y * -1
	
	if is_dashing:
		$Sprite.frame = 69
	elif is_moving:
		animplayer.play("Run")
	else:
		animplayer.play("Idle")
	
	if not is_dashing:
		motion = motion.normalized() * SPEED
	else:
		motion = last_direction * DASH_SPEED
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	motion = move_and_collide(motion)
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if "Attack" in anim_name:
		is_attacking = false


func _on_DashTimer_timeout():
	is_dashing = false
	cooldown.start()
	set_collision_mask_bit(3, true)
	set_collision_layer_bit(2, true)


func _on_DashCooldown_timeout():
	can_dash = true

func _on_Attack_Area_body_entered(body):
	print(attack_num)
	body.print_hello()
