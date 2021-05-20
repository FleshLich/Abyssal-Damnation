extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Fade").get_node("AnimationPlayer").play("FadeIn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PlayButton_pressed():
	get_parent().get_node("Fade").get_node("AnimationPlayer").play("FadeOut")


func _on_CreditButton_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		get_tree().change_scene("res://Menu/Typewriter Cutscene.tscn")
