extends KinematicBody2D

onready var animplayer = $Sprite/AnimationPlayer

export var damage = 10

var speed = 6

var velocity = Vector2.ZERO

var target = null

var player = null

func _ready():
	player = get_parent().get_node("Player")
	target = player.position
	animplayer.play("Traveling")
	
func _physics_process(delta):
	velocity = position.direction_to(target) * speed
	var collision = move_and_collide(velocity)
	if collision != null:
		target = position
		animplayer.play("Exploding")
	if position.distance_to(target) < 5:
		animplayer.play("Exploding")

func _on_Explode_Area_area_entered(area):
	var body = area.get_parent()
	body.slow()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Exploding":
		queue_free()
