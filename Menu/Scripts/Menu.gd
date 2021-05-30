extends VBoxContainer



# Called when the node enters the scene tree for the first time.
func _ready():
	Global.init()
	get_parent().get_node("Fade").get_node("AnimationPlayer").play("FadeIn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Test"):
		Global.change_scene("res://Game/Levels/Viridan Level.tscn")
		#Global.change_scene("res://LifeLost.tscn")


func _on_PlayButton_pressed():
	get_parent().get_node("Fade").get_node("AnimationPlayer").play("FadeOut")
	
func _on_QPlayButton_pressed():
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

