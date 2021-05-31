extends ColorRect

export var title = ""
export var subtitle = ""

func _ready():
	if Global.level_started:
		get_tree().paused = false
		queue_free()
		return
	$Title.text = title
	$Title/Label.text = subtitle
	get_tree().paused = true

func _process(delta):
	if Input.is_action_just_pressed("Space"):
		Global.level_started = true
		get_tree().paused = false
		queue_free()
