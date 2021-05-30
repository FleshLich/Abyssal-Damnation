extends KinematicBody2D

onready var animplayer = $Sprite/AnimationPlayer

export var damage = 10

var speed = 10

var thrown = false

var velocity = Vector2.ZERO

var target = null

var player = null

func _ready():
	player = get_parent().get_node("Player")
	target = player.position
	
func _physics_process(delta):
	if not thrown:
		return
	velocity = position.direction_to(target) * speed
	move_and_slide_with_snap(velocity / delta, Vector2(2, 2))
	if position.distance_to(target) < 5:
		thrown = false
		start()
	
func throw():
	thrown = true
	
func start():
	animplayer.play("Priming")

func _on_Explode_Area_area_entered(area):
	var body = area.get_parent()
	body.take_damage(damage)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Priming":
		animplayer.play("Exploding")
	if anim_name == "Exploding":
		queue_free()
