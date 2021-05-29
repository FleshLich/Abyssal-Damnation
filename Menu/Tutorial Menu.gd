extends Control

func _process(delta):
	if Input.is_action_pressed("Space"):
		get_tree().change_scene("res://Game/TutorialScene.tscn")
