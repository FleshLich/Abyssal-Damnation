extends Control

onready var text = $Label

func _ready():
	hide()

func _on_Player_c_change(combo_points):
	if combo_points <= 0:
		hide()
	else:
		show()
		text.text = str(combo_points)
