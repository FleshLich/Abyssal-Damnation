extends KinematicBody2D

signal c_change(combo_points)

export var invincible = false
export var health = 1
export var max_health = 1
export var combo_points = 0
export var max_combo_points = 5

var last_combo_points = combo_points

export var attack_num = 0

export var SPEED = 10
export var DASH_SPEED = 30

export var damage = 20
export var second_damage = 25

onready var animplayer = $Sprite/AnimationPlayer
onready var hurtPlayer = $Sprite/HurtPlayer
onready var dashTimer = $DashTimer
onready var stunTimer = $StunTimer
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

var stunned = false

var i_counter = 0
var max_i = 3

export var dead = false

var last_direction = Vector2.DOWN

func _ready():
	screen_size = get_viewport_rect().size
	$"Attack Area/Attack Hitbox".disabled = true

func _physics_process(delta):
	var motion = Vector2()
	combo_points = 5
	
	if dead or stunned:
		return
	if last_combo_points != combo_points:
		emit_signal("c_change", combo_points)
		last_combo_points = combo_points
	
	if Input.is_action_pressed("Space") and not is_attacking and can_dash:
		set_collision_mask_bit(3, false)
		set_collision_layer_bit(2, false)
		set_collision_mask_bit(19, true)
		set_collision_layer_bit(19, true)
		can_dash = false
		is_dashing = true
		dashTimer.start()
	if Input.is_action_pressed("Invincible") and combo_points > 0:
		set_invincible()
		return
	
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
		
	
	if Input.is_action_pressed("Heavy") and not is_attacking and combo_points >= 5 and not invincible:
		combo_points = 0
		is_attacking = true
		is_combo = true
		animplayer.playback_speed = 0.5
		animplayer.play("Attack2")
		is_moving = false
	elif Input.is_action_pressed("Stun") and not is_attacking and combo_points >= 5:
		combo_points = 0
		stun_attack()
	if Input.is_action_pressed("LeftClick") and not is_attacking and not invincible:
		is_attacking = true
		animplayer.play("Attack")
		is_moving = false
	elif Input.is_action_pressed("RightClick") and not is_attacking and not invincible:
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
	
func stun(duration):
	is_attacking = false
	
	stunned = true
	animplayer.seek(0, true)
	animplayer.play("Idle")
	animplayer.seek(0, true)
	animplayer.stop()
	hurtPlayer.play("Stun")
	stunTimer.wait_time = duration
	stunTimer.start()

func add_combo_points(points):
	decayTimer.start()
	if combo_points >= max_combo_points:
		return
	combo_points += 1
	
func stun_attack():
	var siblings = get_parent().get_children()
	for N in siblings:
		if N.has_method("stun"):
			N.stun()
			
func set_invincible():
	var seconds = combo_points
	combo_points = 0
	invincible = true
	hurtPlayer.play("Hurt")
	
	$InvincibleTimer.wait_time = seconds
	$InvincibleTimer.start()
	

func take_damage(damage):
	if invincible:
		return
	if i_counter > 0:
		return
	health -= damage
	if combo_points > 0:
		combo_points -= 1
	if health <= 0 and not dead:
		animplayer.playback_speed = 1
		die()
	elif not dead:
		hurtPlayer.play("Hurt")

func die():
	dead = true
	animplayer.play("Dead")
	if Global.lives > 0:
		Global.lives -= 1
		get_tree().reload_current_scene()

func _on_AnimationPlayer_animation_finished(anim_name):
	if "Attack" in anim_name:
		is_attacking = false
	if anim_name == "Attack2" and is_combo:
		is_combo = false
		animplayer.playback_speed = 1

func _on_DashTimer_timeout():
	set_collision_mask_bit(19, false)
	set_collision_layer_bit(19, false)
	is_dashing = false
	cooldown.start()
	set_collision_mask_bit(3, true)
	set_collision_layer_bit(2, true)


func _on_DashCooldown_timeout():
	can_dash = true

func _on_Attack_Area_area_entered(area):
	var body = area.get_parent()
	if is_combo:
		body.take_damage(damage* 2 if attack_num == 1 else second_damage * 3)
	else:
		body.take_damage(damage if attack_num == 1 else second_damage)
		if body.get("stunned") == false and body.get("dead") == false and not body.get("is_blocking"):
			add_combo_points(1)
		elif body.get("block_stun") == true:
			stun(1)

func _on_ComboDecay_Timer_timeout():
	if combo_points <= 0:
		return
	combo_points -= 1


func _on_HurtPlayer_animation_finished(anim_name):
	if invincible:
		hurtPlayer.play("Hurt")
	else: 
		i_counter = 0


func _on_InvincibleTimer_timeout():
	hurtPlayer.seek(0, true)
	hurtPlayer.stop()
	invincible = false


func _on_StunTimer_timeout():
	stunned = false
	hurtPlayer.seek(0, true)
	hurtPlayer.stop()
	print(stunned)

