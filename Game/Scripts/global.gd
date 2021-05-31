extends Node

var rng = RandomNumberGenerator.new()

var debug = true

var current_scene = null
var life_lost_scene = load("res://LifeLost.tscn")
var LevelTitle_scene = load("res://LevelTitle.tscn")
var Win_scene = load("res://WinScreen.tscn")
var Dead_scene = load("res://DeadScreen.tscn")

var levels = []
var level_started = false

var music = []

var has_played = false

var music_times = [0, 0, 0, 0, 0]

var depth = 0
var lives = 0
#Dash cool down, Combo point decay, damage
var modifiers = [0, 0, 0]

func level_init():
	levels = ["res://Game/Levels/Viridan Level.tscn", "res://Game/Levels/SkeletonLevel.tscn", "res://Game/Levels/Phalloid Level.tscn"]
	
func music_init():
	music = ["res://Art/Music/5-BattleField5.mp3", "res://Art/Music/11-Fight2.mp3", "res://Art/Music/22-Raid3.mp3", "res://Art/Music/21-Raid2.mp3"]
	
func init():
	level_started = false
	depth = 0
	lives = 5
	modifiers = [0, 0, 0]
	level_init()
	music_init()
	
	var data = File.new()
	if data.file_exists("user://data.save"):
		data.open("user://data.save", File.READ)
		print(data.get_line())
		if data.get_line() == "1":
			has_played = true
		data.close()

func _ready():
	rng.randomize()
	
func rand_int(i, j):
	rng.randomize()
	return rng.randi_range(i, j)

func get_lost_life_text():
	var t = ["Your Humours are failing", "The void approaches", "Do not let this be it", "Are you even trying?"]
	return t[Global.rand_int(0, t.size() - 1)]

func change_scene(scene):
	current_scene = scene
	get_tree().change_scene(scene)
	
func set_play():
	var data = File.new()
	data.open("user://ABdata.save", File.WRITE)
	data.store_line(str(1))
	print(data)
	data.close()
	has_played = true
	
func show_win():
	var win_titles = ["Not this time", "You have survived", "The void stays hungry today", "Well done"]
	var win_subtitles = ["You have survived this battle, prepare for the next one.",
	"Due to luck or skill you live to suffer another day.", 
	"Your skills have left the void without a meal... Be ready for when it next pounces"]
	
	var scene = Win_scene.instance()
	
	scene.title = win_titles[rand_int(0, win_titles.size() - 1)]
	scene.subtitle = win_subtitles[rand_int(0, win_subtitles.size() - 1)]
	get_tree().get_root().add_child(scene)
	
func show_death():
	var dead_titles = ["Pathetic", "Unsuprising", "An end to the suffering", 
	"Mortis", "The abyss is sated"]
	var dead_subtitles = ["Finally, an end to your suffering", 
	"That was all you could do? Disappointing", 
	"Your corpse will make a wonderful meal for the abyss.", 
	"Death has finally arrived"]
	
	var scene = Dead_scene.instance()
	scene.title = dead_titles[rand_int(0, dead_titles.size() - 1)]
	scene.subtitle = dead_subtitles[rand_int(0, dead_subtitles.size() - 1)]
	get_tree().get_root().add_child(scene)
	
func do_upgrade():
	change_scene("res://Menu/UpgradeMenu.tscn")
	
func start_level(level_name=""):
	if levels.size() == 0:
		level_init()
		level_name = "res://Game/Levels/MenagerieLevel.tscn"
		depth += 1
	level_started = false
	var level_num = rand_int(0, levels.size() - 1)
	var level = levels[level_num] if level_name == "" else level_name
	levels.remove(level_num)
	get_tree().change_scene(level)
	
func get_music():
	if music.size() == 0:
		music_init()
	var choice = rand_range(0, music.size() - 1)
	var track = music[choice]
	music.remove(choice)
	return track
	
