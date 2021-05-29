extends KinematicBody2D

var rng = RandomNumberGenerator.new()

onready var animplayer = $Sprite/AnimationPlayer
onready var hurtPlayer = $Sprite/hurtPlayer
onready var stunTimer = $StunTimer
onready var blockTimer = $BlockTimer
onready var hbox = $Hitbox

export var health = 40
export var damage = 40

export var SPEED = 2

export var stunned = false
var dead = false

var is_moving = false
var left = false
var right = false

var is_attacking = false
var is_blocking = false

var i_counter = 0
var max_i = 3

var block_stun = false

var player = null
var target = null
var motion = Vector2()

func _ready():
	player = get_parent().get_node("Player")
	SPEED = rng.randi_range(1, 3)
	animplayer.play("Idle")

func _physics_process(delta):
	target = player.position
	if dead or stunned:
		return
	if is_blocking:
		block_stun = true
		return
	
	if not is_attacking:
		for areaInArea in $"Detect Area".get_overlapping_areas():
			if areaInArea.get_parent().name == "Player":
				is_attacking = true
				animplayer.play("Attack")
	if is_attacking:
		return
	if is_moving:
		animplayer.play("Walk")
	else:
		animplayer.play("Idle")
	
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
	if is_blocking:
		animplayer.play("Shield")
		if right and target.x > position.x:
			block_stun = true
			return
		elif left and target.x < position.x:
			block_stun = true
			return
		block_stun = false
	health -= damage
	if health <= 0 and not dead:
		die()
	elif not dead and not stunned:
		if right and not target.x > position.x:
			right = false
			left = true
			scale.x = scale.y
		elif left and not target.x < position.x:
			right = true
			left = false
			scale.x *= -1
		i_counter = 0
		is_blocking = true
		blockTimer.start()
		animplayer.play("Shield")
		animplayer.seek(0, true)
		animplayer.stop()
		set_collision_mask_bit(19, true)
		set_collision_layer_bit(19, true)
		hurtPlayer.play("Hurt")
		

func stun():
	if dead:
		return
	animplayer.play("Idle")
	hurtPlayer.play("Stun")
	stunTimer.start()
	stunned = true

func die():
	set_collision_layer_bit(3, false)
	set_collision_layer_bit(4, false)
	set_collision_mask_bit(2, false)
	set_collision_mask_bit(4, false)
	animplayer.seek(0)
	animplayer.stop()
	dead = true
	hurtPlayer.seek(0)
	hurtPlayer.stop()
	animplayer.play("Dead")

func _on_Hit_Area_area_entered(area):
	var body = area.get_parent()
	body.take_damage(damage)

func _on_AnimationPlayer_animation_finished(anim_name):
	if "Attack" in anim_name:
		is_attacking = false

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


func _on_BlockTimer_timeout():
	is_attacking = false
	is_blocking = false
	block_stun = false

