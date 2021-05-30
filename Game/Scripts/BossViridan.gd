extends KinematicBody2D

var rng = RandomNumberGenerator.new()

onready var animplayer = $Sprite/AnimationPlayer
onready var hurtPlayer = $Sprite/hurtPlayer
onready var stunTimer = $StunTimer
onready var hbox = $Hitbox2/Hitbox
onready var tTimer = $ThrowTimer

var bomb = load("res://Game/Enemies/EnemyProps/Bomb.tscn")

export var health = 40
export var damage = 40

export var SPEED = 6

export var stunned = false
var dead = false

var is_moving = false
var left = false
var right = false

var is_attacking = false
var is_throwing = false

var i_counter = 0
var max_i = 3

var player = null
var target = null
var motion = Vector2()

func _ready():
	player = get_parent().get_node("Player")
	SPEED = Global.rand_int(5, 7)
	animplayer.play("Idle")
	tTimer.start()

func _physics_process(delta):
	target = player.position
	
	if dead or stunned or is_throwing:
		return
	
	if target.x >= position.x:
		target.x = target.x - ($CollisionShape2D.shape.radius * 2)
	elif target.x < position.x:
		target.x = target.x + ($CollisionShape2D.shape.radius * 2)
	
	if not is_attacking:
		for areaInArea in $"Detect Area".get_overlapping_areas():
			if areaInArea.get_parent().name == "Player":
				is_attacking = true
				animplayer.play("Attack")
				break
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
	health -= damage
	if health <= 0 and not dead:
		die()
	elif not dead and not stunned:
		i_counter = 0
		hurtPlayer.play("Hurt")
		

func stun():
	if dead:
		return
	animplayer.play("Idle")
	hurtPlayer.play("Stun")
	stunTimer.start()
	stunned = true
	
func throw_bomb():
	tTimer.wait_time = Global.rand_int(3, 5)
	var drop = bomb.instance()
	drop.position = position
	get_parent().add_child(drop)
	tTimer.start()
	drop.throw()

func die():
	$CollisionShape2D.queue_free()
	$Hitbox2.queue_free()
	z_index = -1
	animplayer.seek(0)
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
		is_attacking = false
	if anim_name == "Throw":
		is_throwing = false
		throw_bomb()

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
	

func _on_ThrowTimer_timeout():
	animplayer.play("Throw")
	is_throwing = true
