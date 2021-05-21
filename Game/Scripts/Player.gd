extends KinematicBody2D


const SPEED = 8

onready var animplayer = get_node("Sprite/AnimationPlayer")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var motion = Vector2()
	var is_moving = false
	var moving_left = false
	var moving_right = false
	
	var is_attacking = false
	
	print(animplayer.current_animation)
	if animplayer.current_animation == "Attack":
		is_attacking = true
	
	
	if Input.is_action_pressed("Up"):
		motion.y -= 1
		is_moving = true
	elif Input.is_action_pressed("Down"):
		motion.y += 1
		is_moving = true
	if Input.is_action_pressed("Right"):
		motion.x += 1
		moving_right = true
		is_moving = true
	elif Input.is_action_pressed("Left"):
		motion.x -= 1
		moving_left = true
		is_moving = true
		
	if Input.is_action_pressed("LeftClick"):
		motion = Vector2.ZERO
		animplayer.play("Attack")
		is_attacking = true
		print(animplayer.current_animation)
	
	if is_attacking:
		return
		
	if moving_right:
		scale.x = scale.y
	elif moving_left:
		scale.x = scale.y * -1

	print(self.scale.x)
		
	if is_moving:
		animplayer.play("Run")
	else:
		animplayer.play("Idle")
		
	motion = motion.normalized() * SPEED
	motion = move_and_collide(motion)
	
