extends Control

var upgrade = null

func _ready():
	$Label2.hide()

func _process(delta):
	if upgrade != null:
		$Label2.show()
		if Input.is_action_pressed("Space"):
			match upgrade:
				1:
					Global.modifiers[0] -= 0.05
				2:
					Global.modifiers[1] += 0.1
				3:
					Global.modifiers[2] += 10
			Global.start_level()

func _on_Button_mouse_entered():
	$Label.text = "Decreases the time it takes before you can dash again by 0.05 seconds. Your current dash cooldown is: " + str(1 - Global.modifiers[0]) + " seconds"
	
func _on_Button2_mouse_entered():
	$Label.text = "Increases the amount of time before a combo point decays by 0.1 seconds. Your current combo point decay time is: " + str(2 + Global.modifiers[1]) + " seconds"
	
func _on_Button3_mouse_entered():
	$Label.text = "Increases damage by 10 points. Your current damage is: " + str(20 + Global.modifiers[2])


func _on_Button_pressed():
	upgrade = 1

func _on_Button2_pressed():
	upgrade = 2

func _on_Button3_pressed():
	upgrade = 3
