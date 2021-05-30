extends ColorRect

export var title = ""
export var subtitle = ""

func _ready():
	$Title.text = title
	$Title/Label.text = subtitle
	if not Global.level_started: 
		get_tree().paused = true
	else:
		queue_free()

func _process(delta):
	if Input.is_action_just_pressed("Space"):
		get_tree().paused = false
		Global.level_started = true
		queue_free()
