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

var has_played = false

var depth = 0
var lives = 0
#Dash cool down, Combo point decay, damage
var modifiers = [0, 0, 0]

func init():
	level_started = false
	depth = 0
	lives = 5
	modifiers = [0, 0, 0]
	levels = ["res://Game/Levels/Viridan Level.tscn", "res://Game/Levels/SkeletonLevel.tscn"]
	
	var data = File.new()
	if data.file_exists("user://data.save"):
		data.open("user://data.save", File.READ)
		if data.get_line() == "1":
			has_played = true

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
	var level_started = false
	depth += 1
	var level = levels[rand_int(0, levels.size() - 1)] if level_name == "" else level_name
	get_tree().change_scene(level)
