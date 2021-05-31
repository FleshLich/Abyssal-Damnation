extends VBoxContainer



# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.debug:
		Global.set_play()
	Global.init()
	if Global.has_played:
		$CenterContainer5/TutorialButton.show()
	else:
		$CenterContainer5/TutorialButton.hide()
	print(get_tree().get_root().get_children())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Test") and Global.debug:
		Global.start_level()
		#Global.change_scene("res://Game/Levels/MenagerieLevel.tscn")
	

func _on_PlayButton_pressed():
	get_parent().get_node("Fade").get_node("AnimationPlayer").play("FadeOut")
	
func _on_QPlayButton_pressed():
	Global.has_played = true
	Global.change_scene("res://Game/TutorialScene.tscn")
	
func _on_TutorialButton_pressed():
	Global.change_scene("res://Menu/Tutorial Menu.tscn")

func _on_CreditButton_pressed():
	Global.change_scene("res://Menu/Credits.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		Global.change_scene("res://Menu/Typewriter Cutscene.tscn")

