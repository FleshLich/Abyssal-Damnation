extends Control

onready var animplayer = $Label/AnimationPlayer
onready var timer = $DialogueTimer

var dialogue_num = 1
var num_dialogues = 0
var lock = true



func _ready():
	num_dialogues = animplayer.get_animation_list().size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("RightClick"):
		get_tree().change_scene("res://Menu/Menu.tscn")
	if Input.is_action_pressed("LeftClick"):
		print(dialogue_num)
		if not lock and dialogue_num != num_dialogues:
			animplayer.play("Text" + str(dialogue_num))
			lock = true
		else:
			get_tree().change_scene("res://Game/TutorialScene.tscn")


func _on_AnimationPlayer_animation_finished(anim_name):
	dialogue_num += 1
	lock = false
	

