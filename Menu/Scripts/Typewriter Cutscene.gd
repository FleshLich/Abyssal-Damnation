extends Control

onready var animplayer = $Label/AnimationPlayer
onready var timer = $DialogueTimer

var dialogue_num = 0
var dialogue_index = 0
var text_num = 0
var lock = true

var text = [[
	"You are disgraced.",
	"Your sins are severe.",
	"For severe sins comes severe punishment.",
], [
	"Your life is forfeit.",
	"Your past is irrelevant.",
	"Your future is nonexistent.",
	"You have been cast into the deepest abyss known to man."
], [
	"You will die."
], [
	"The circumstances around your death, however, will be up to you.",
	"Will you brave the abominable depths to seek some type of solace for the evils you have commited?",
	"Or will you accept your fate and decay to death like the degenerate you are?"
], [
	"No one will remember you.",
	"No one will know of your deeds.",
	"Everything you do must be for yourself.",
	"Die with dignity."
]]


func _ready():
	$Label.text = ""

func _process(delta):
	if Input.is_action_pressed("RightClick"):
		get_tree().change_scene("res://Menu/Menu.tscn")
	if Input.is_action_just_pressed("LeftClick"):
		if dialogue_index == text[text.size() - 1].size() - 1 and dialogue_num == text.size() - 1 and not lock:
			get_tree().change_scene("res://Menu/Tutorial Menu.tscn")
		if not lock:
			dialogue_index += 1
			text_num = 0
			lock = true

func inc_text():
	if text_num == 0 and dialogue_index != text[dialogue_num].size():
		$Label.text += "\n\n"
	if dialogue_index >= text[dialogue_num].size():
		$Label.text = ""
		dialogue_index = 0
		dialogue_num += 1
		return
	if text_num >= text[dialogue_num][dialogue_index].length():
		lock = false
		return
	$Label.text = $Label.text + text[dialogue_num][dialogue_index][text_num]
	text_num += 1

func _on_AnimationPlayer_animation_finished(anim_name):
	dialogue_num += 1
	lock = false
	

func _on_TextTimer_timeout():
	inc_text()
