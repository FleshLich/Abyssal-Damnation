extends Node2D

onready var skeleton = load("res://Game/Enemies/TutSkeleton.tscn")
onready var spawner = $SpawnPos

func _process(delta):
	if Input.is_action_pressed("Reload"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("Spawn"):
		var spawn = skeleton.instance()
		spawn.position = spawner.position
		add_child(spawn)
	elif Input.is_action_pressed("Next"):
		Global.start_level()
