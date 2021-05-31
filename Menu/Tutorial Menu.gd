extends Control

func _process(delta):
	if Input.is_action_pressed("Space"):
		Global.set_play()
		get_tree().change_scene("res://Game/TutorialScene.tscn")
