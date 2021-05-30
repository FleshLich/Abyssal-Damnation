extends KinematicBody2D

var rng = RandomNumberGenerator.new()

onready var animplayer = $Sprite/AnimationPlayer
onready var hurtPlayer = $Sprite/hurtPlayer
onready var stunTimer = $StunTimer
onready var blockTimer = $BlockTimer
onready var hbox = $Hitbox2/Hitbox

export var health = 100
export var damage = 40

export var SPEED = 2

export var stunned = false
var dead = false

var is_moving = false
var left = false
var right = false

var is_attacking = false
var is_blocking = false
var is_parrying = false

var i_counter = 0
var max_i = 3

var player = null
var target = null
var motion = Vector2()

var parry_progress = 0

func _ready():
	player = get_parent().get_node("Player")
	SPEED = 3
	animplayer.play("Idle")

func _physics_process(delta):
	target = player.position
	
	if dead or stunned:
		return
	if is_blocking:
		return
		
	if parry_progress >= 3:
		is_parrying = true
		hurtPlayer.play("Parry")
		parry_progress = 0
	
	if target.x >= position.x:
		target.x = target.x - ($CollisionShape2D.shape.radius * 5)
	elif target.x < position.x:
		target.x = target.x + ($CollisionShape2D.shape.radius * 5)
	
	if not is_attacking:
		for areaInArea in $"Detect Area".get_overlapping_areas():
			if areaInArea.get_parent().name == "Player" and is_parrying:
				set_blocking()
				return
			elif areaInArea.get_parent().name == "Player":
				is_attacking = true
				is_blocking = false
				parry_progress += 0.5
				animplayer.play("Attack")
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
	motion = move_and_collide(motion)
		
func take_damage(damage, body=null):
	if is_blocking and not is_parrying:
		animplayer.play("Shield")
		if (right and player.position.x > position.x) or (left and player.position.x < position.x):
			if body.has_method("stun"): body.stun(1)
			return
	if is_parrying and ((right and player.position.x > position.x) or (left and player.position.x < position.x)):
		animplayer.playback_speed = 2
		animplayer.play("Attack")
		is_blocking = false
		is_parrying = false
		hurtPlayer.seek(0, true)
		hurtPlayer.stop()
		return
	health -= damage
	if is_parrying:
		is_parrying = false
	if health <= 0 and not dead:
		die()
	elif not dead and not stunned:
		set_blocking()
		i_counter = 0
		hurtPlayer.play("Hurt")
		parry_progress += 1
		
func set_blocking():
	if right and not player.position.x >= position.x:
		right = false
		left = true
		scale.x = scale.y
	elif left and not player.position.x < position.x:
		right = true
		left = false
		scale.x *= -1
	is_blocking = true
	blockTimer.start()
	animplayer.play("Shield")
	animplayer.seek(0, true)
	animplayer.stop()
	set_collision_mask_bit(19, true)
	set_collision_layer_bit(19, true)

func stun():
	if dead:
		return
	animplayer.play("Idle")
	hurtPlayer.play("Stun")
	stunTimer.start()
	stunned = true

func die():
	$CollisionShape2D.queue_free()
	$Hitbox2.queue_free()
	z_index = -1
	animplayer.seek(0, true)
	animplayer.stop()
	dead = true
	hurtPlayer.seek(0)
	hurtPlayer.stop()
	animplayer.play("Dead")

func _on_Hit_Area_area_entered(area):
	if not is_attacking:
		return
	var body = area.get_parent()
	body.take_damage(damage)

func _on_AnimationPlayer_animation_finished(anim_name):
	if "Attack" in anim_name:
		animplayer.playback_speed = 1
		is_attacking = false

func _on_hurtPlayer_animation_finished(anim_name):
	if anim_name == "Hurt":
		if i_counter < max_i:
			i_counter += 1
			hurtPlayer.play("Hurt")
			return
		if is_parrying:
			hurtPlayer.play("Parry")
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
	set_collision_mask_bit(19, false)
	set_collision_layer_bit(19, false)

