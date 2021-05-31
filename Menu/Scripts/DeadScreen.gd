extends ColorRect

export var title = ""
export var subtitle = ""

var can_input = false

func _ready():
	$Title.text = title
	$Title/Label.text = subtitle
	get_tree().paused = true

func _process(delta):
	if Input.is_action_just_pressed("Space") and can_input:
		get_tree().paused = false
		get_tree().change_scene("res://Menu/Menu.tscn")
		queue_free()

func increment_hidden():
	$Title/HiddenNum.text = str(Global.lives + 1)
	Global.lives += 1

func _on_KeyTimer_timeout():
	can_input = true
