extends KinematicBody2D

onready var animplayer = $Sprite/AnimationPlayer
onready var hurtPlayer = $Sprite/hurtPlayer
onready var stunTimer = $StunTimer

export var health = 150
export var damage = 40

export var SPEED = 3

export var stunned = false
var dead = false

var is_moving = false
var left = false
var right = false

var heavy_progress = 0

var is_attacking = false

var i_counter = 0
var max_i = 3

var player = null
var motion = Vector2()

var stun1 = 0
var stun2 = 0

func _ready():
	player = get_parent().get_node("Player")
	animplayer.play("Idle")

func _physics_process(delta):
	if dead or stunned:
		return
	
	if not is_attacking:
		for bodyInArea in $"DetectArea".get_overlapping_bodies():
			if bodyInArea.name == "Player" and heavy_progress != 3:
				is_attacking = true
				animplayer.play("Attack")
			else:
				is_attacking = true
				animplayer.play("Heavy Attack")
	if is_attacking:
		return
	if is_moving:
		animplayer.play("Walk")
	else:
		animplayer.play("Idle")
	
	var target = player.position
	
	if target.x > position.x and not right:
		right = true
		left = false
	elif target.x < position.x and not left:
		left = true
		right = false
	
	motion = (target - position).normalized() * SPEED
	if right:
		scale.x = scale.y
	elif left:
		scale.x = scale.y * -1 
	
	if (target - position).length() > 7:
		is_moving = true
		motion = move_and_collide(motion)

func take_damage(damage):
	heavy_progress += 1
	health -= damage
	if stunned:
		stun2 += damage
	if health <= 0 and not dead:
		die()
	elif not dead and not stunned:
		i_counter = 0
		hurtPlayer.play("Hurt")

func stun():
	stun1 = health
	animplayer.play("Idle")
	hurtPlayer.play("Stun")
	stunTimer.start()
	stunned = true

func die():
	dead = true
	animplayer.play("Dead")

func flip():
	scale.x *= -1

func _on_Hit_Area_body_entered(body):
	body.take_damage(damage)

func _on_AnimationPlayer_animation_finished(anim_name):
	if "Attack" in anim_name:
		is_attacking = false
	if anim_name == "Heavy Attack":
		heavy_progress = 0


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
	print(stun2)
