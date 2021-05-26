extends KinematicBody2D

onready var animplayer = $Sprite/AnimationPlayer

export var health = 150
export var damage = 40

export var SPEED = 3

var is_moving = false
var left = false
var right = true

var is_attacking = false

var player = null
var motion = Vector2()

func _ready():
	player = get_parent().get_node("Player")
	print(player.position)
	animplayer.play("Idle")

func _physics_process(delta):
	if not is_attacking:
		for bodyInArea in $"DetectArea".get_overlapping_bodies():
			if bodyInArea.name == "Player":
				is_attacking = true
				animplayer.play("Attack")
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
	health -= damage
	print(health)
	if health <= 0:
		queue_free()


func _on_Hit_Area_body_entered(body):
	body.take_damage(damage)
	print(body.health)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		is_attacking = false
