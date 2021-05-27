extends KinematicBody2D

export var health = 100
export var max_health = 100
export var combo_points = 0
export var max_combo_points = 5

export var attack_num = 0

export var SPEED = 10
export var DASH_SPEED = 30

export var damage = 10
export var second_damage = 15

onready var animplayer = $Sprite/AnimationPlayer
onready var hurtPlayer = $Sprite/HurtPlayer
onready var dashTimer = $DashTimer
onready var cooldown = $DashCooldown
onready var decayTimer = $"ComboDecay Timer"

var screen_size

var is_moving = false
var moving_left = false
var moving_right = false

var is_attacking = false
var is_combo = false

var can_dash = true
var is_dashing = false

var i_counter = 0
var max_i = 3

export var dead = false

var last_direction = Vector2.DOWN

func _ready():
	screen_size = get_viewport_rect().size
	$"Attack Area/Attack Hitbox".disabled = true

func _physics_process(delta):
	var motion = Vector2()
	
	if dead:
		return
	
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
		
	
	if Input.is_action_pressed("Heavy") and not is_attacking and combo_points >= 5:
		combo_points = 0
		is_attacking = true
		is_combo = true
		animplayer.playback_speed = 0.5
		animplayer.play("Attack2")
		is_moving = false
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
	

func add_combo_points(points):
	decayTimer.start()
	if combo_points >= max_combo_points:
		return
	combo_points += 1

func take_damage(damage):
	if i_counter > 0:
		return
	health -= damage
	if combo_points > 0:
		combo_points -= 1
	if health <= 0 and not dead:
		die()
	elif not dead:
		hurtPlayer.play("Hurt")

func die():
	dead = true
	animplayer.play("Dead")

func _on_AnimationPlayer_animation_finished(anim_name):
	if "Attack" in anim_name:
		is_attacking = false
	if anim_name == "Attack2" and is_combo:
		is_combo = false
		animplayer.playback_speed = 1

func _on_DashTimer_timeout():
	is_dashing = false
	cooldown.start()
	set_collision_mask_bit(3, true)
	set_collision_layer_bit(2, true)


func _on_DashCooldown_timeout():
	can_dash = true

func _on_Attack_Area_body_entered(body):
	if is_combo:
		body.take_damage(damage* 2 if attack_num == 1 else second_damage * 2)
	else:
		body.take_damage(damage if attack_num == 1 else second_damage)
		add_combo_points(1)

func _on_ComboDecay_Timer_timeout():
	if combo_points <= 0:
		return
	combo_points -= 1


func _on_HurtPlayer_animation_finished(anim_name):
	if i_counter < max_i:
		i_counter += 1 
		hurtPlayer.play("Hurt")
	else: 
		i_counter = 0
