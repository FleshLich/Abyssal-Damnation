extends Node

var rng = RandomNumberGenerator.new()

var debug = true

var current_scene = null
var life_lost_scene = load("res://LifeLost.tscn")
var LevelTitle_scene = load("res://LifeLost.tscn")

var levels = []
var level_started = false

var depth = 1
var lives = 999
#Health, dash, damage
var modifiers = [0, 0, 0]

func init():
	levels = []

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
