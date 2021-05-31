extends ColorRect

func _ready():
	get_tree().paused = true
	$Title.text = Global.get_lost_life_text()
	$Title/Num.text = str(Global.lives + 1)

func _process(delta):
	if Input.is_action_just_pressed("Space"):
		if Global.lives > 0:
			get_tree().reload_current_scene()
			get_tree().paused = false
			queue_free()
		else:
			for N in get_tree().get_root().get_node("Node2D").get_children():
				N.queue_free()
			Global.show_death()
			queue_free()
			
func decrement_hidden():
	$Title/HiddenNum.text = str(Global.lives)
