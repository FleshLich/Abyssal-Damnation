extends KinematicBody2D

var rng = RandomNumberGenerator.new()
var screen_size = 0

onready var animplayer = $Sprite/AnimationPlayer
onready var hurtPlayer = $Sprite/hurtPlayer
onready var stunTimer = $StunTimer
onready var hbox = $Hitbox2/Hitbox

export var health = 70
export var damage = 2

export var SPEED = 6

export var stunned = false
var dead = false

var is_moving = false
var left = false
var right = false

var is_attacking = false

var i_counter = 0
var max_i = 3

var special_progress = 0

var held = null

var player = null
var target = null
var motion = Vector2()

var gives_points = true

func _ready():
	screen_size = get_viewport_rect().size
	player = get_parent().get_node("Player")
	SPEED = Global.rand_int(1, 3)
	animplayer.play("Idle")

func _physics_process(delta):
	$"Knockback Area"/CollisionShape2D.disabled = false
	target = player.position
	if special_progress >= 3:
		hurtPlayer.play("Prep")
	
	if dead or stunned:
		return
	
	if target.x >= position.x:
		target.x = target.x - ($CollisionShape2D.shape.radius * 4)
	elif target.x < position.x:
		target.x = target.x + ($CollisionShape2D.shape.radius * 4)
		
	if not is_attacking:
		for areaInArea in $"Detect Area".get_overlapping_areas():
			if areaInArea.get_parent().name == "Player" and held == null:
				if special_progress < 3:
					is_attacking = true
					animplayer.playback_speed = 0.75
					animplayer.play("Attack")
				else:
					is_attacking = true
					animplayer.play("Attack2")
				break
	if held != null:
		held.position = position
		$"Detect Area/CollisionShape2D".disabled = true
		$PickupTimer.start()
	if is_attacking:
		return
	if is_moving:
		animplayer.play("Walk")
	else:
		animplayer.play("Idle")
	
	if target.x >= position.x and not right:
		right = true
		left = false
	elif target.x < position.x and not left:
		left = true
		right = false
	
	motion = position.direction_to(target) * SPEED
	if right:
		scale.x = scale.y
	elif left:
		scale.x = scale.y * -1 
	
	is_moving = true
	target.x = clamp(target.x, 0, screen_size.x)
	target.y = clamp(target.y, 0, screen_size.y)
	motion = move_and_slide(motion / delta)
		
func take_damage(damage, body=null):
	health -= damage
	if health <= 0 and not dead:
		die()
	elif not dead and not stunned:
		i_counter = 0
		hurtPlayer.play("Hurt")
		special_progress += 1
		

func stun():
	if dead:
		return
	is_attacking = false
	animplayer.play("Idle")
	hurtPlayer.play("Stun")
	stunTimer.start()
	stunned = true
	

func die():
	$CollisionShape2D.queue_free()
	$Hitbox2.queue_free()
	z_index = -1
	animplayer.seek(0)
	animplayer.stop()
	dead = true
	hurtPlayer.play("Hurt")
	hurtPlayer.seek(0, true)
	hurtPlayer.stop()
	animplayer.play("Dead")

func _on_Hit_Area_area_entered(area):
	if not is_attacking:
		return
	var body = area.get_parent()
	if is_attacking and special_progress >= 3:
		body.stun(1.5)
		return
	body.take_damage(damage)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		animplayer.playback_speed = 1
		is_attacking = false
	elif anim_name == "Attack2":
		is_attacking = false
		special_progress = 0
		hurtPlayer.seek(0, true)
		hurtPlayer.stop()

func _on_hurtPlayer_animation_finished(anim_name):
	if anim_name == "Hurt":
		if i_counter < max_i:
			i_counter += 1
			hurtPlayer.play("Hurt")
		else:
			i_counter = 0


func _on_StunTimer_timeout():
	stunned = false
	is_attacking = false
	hurtPlayer.seek(0, true)
	hurtPlayer.stop()

func _on_Knockback_Area_body_entered(body):
	return
	body.knockback(self)


func _on_PickupTimer_timeout():
	held = null
	$"Detect Area/CollisionShape2D".disabled = false
