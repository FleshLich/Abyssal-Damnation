extends Node

var rng = RandomNumberGenerator.new()

var debug = true

var depth = 1

var lives = 999
#Health, dash, damage
var modifiers = [0, 0, 0]

func _ready():
	rng.randomize()
	
func rand_int(i, j):
	rng.randomize()
	return rng.randi_range(i, j)
