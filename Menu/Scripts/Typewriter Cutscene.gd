extends Control

#Not including first one 
var dialogue_num = 1
var lock = true

onready var animplayer = $Label/AnimationPlayer
onready var timer = $DialogueTimer

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("RightClick"):
		get_tree().change_scene("res://Menu/Menu.tscn")
	if Input.is_action_pressed("LeftClick"):
		print(dialogue_num)
		if not lock:
			animplayer.play("Text" + str(dialogue_num))
			lock = true


func _on_AnimationPlayer_animation_finished(anim_name):
	dialogue_num += 1
	lock = false
	

