extends Node2D

signal level_finished

onready var s = load("res://Game/Enemies/Skeleton.tscn")
onready var sB = load("res://Game/Enemies/BossSkeleton.tscn")
onready var v = load("res://Game/Enemies/Viridan.tscn")
onready var vB = load("res://Game/Enemies/BossViridan.tscn")
onready var p = load("res://Game/Enemies/Phalloid.tscn")
onready var pB = load("res://Game/Enemies/BossPhalloid.tscn")
onready var player = $Player
onready var sTimer = $SpawnTimer

var num_enems = Global.rand_int(12 + (4 * Global.depth), 15 + (4 * Global.depth))
var max_enems = 7 + (2 * Global.depth)
#S, V, P
var enemy_count = [0, 0, 0]
var max_count = [4 + (2 * Global.depth), 7 + (2 * Global.depth), 2 + (2 * Global.depth)]
var enemyB_count = [0, 0, 0]
var boss_count = [1 + (1 * Global.depth), 3 + (1 * Global.depth), 2 + (1 * Global.depth)]

var last_point = null

func _ready():
	spawn_enemy()
	spawn_enemy()
	sTimer.wait_time = 3 - (0.5 * Global.depth) if 3 - (0.5 * Global.depth) >= 1 else 1
	player.connect("died", self, "_on_death")	

func _physics_process(delta):
	if get_active_enemies() <= 0 and num_enems <= 0:
		Global.show_win()
	if Global.debug and Input.is_action_just_pressed("Reload"):
		Global.start_level()
		
func get_unique_point():
	var l = get_tree().get_nodes_in_group("Spawns")
	var choice = l[Global.rand_int(0, l.size() - 1)]
	if choice == last_point:
		return get_unique_point()
	last_point = choice
	return choice

func spawn_enemy():
	num_enems -= 1
	var choices = []
	if enemy_count[0] < max_count[0]:
		choices.append(s)
	if enemy_count[1] < max_count[1]:
		choices.append(v)
	if enemy_count[2] < max_count[2]:
		choices.append(p)
	
	if choices.size() == 0:
		spawn_boss()
		return 
		
	var choice = choices[Global.rand_int(0, choices.size() - 1)]
	var spawn = choice.instance()
	spawn.position = get_unique_point().position
	add_child(spawn)
	
func spawn_boss():
	num_enems -= 1
	var choices = []
	if enemyB_count[0] < boss_count[0]:
		choices.append(sB)
	if enemyB_count[1] < boss_count[1]:
		choices.append(vB)
	if enemyB_count[2] < boss_count[2]:
		choices.append(pB) 
	
	if choices.size() == 0:
		spawn_enemy()
		return
		
	var choice = choices[Global.rand_int(0, choices.size() - 1)]
	var spawn = choice.instance()
	spawn.position = get_unique_point().position
	add_child(spawn)
	
	
func get_active_enemies():
	var num = 0
	enemy_count = [0, 0, 0]
	enemyB_count = [0, 0, 0]
	for s in get_tree().get_nodes_in_group("Enemy"):
		if s.get("dead") == false:
			num += 1
		if s.name == "Skeleton":
			enemy_count[0] += 1
		elif s.name == "Viridan":
			enemy_count[1] += 1
		elif s.name == "Phalloid":
			enemy_count[2] += 1
		if s.name == "BossSkeleton":
			enemyB_count[0] += 1
		elif s.name == "BossViridan":
			enemyB_count[1] += 1
		elif s.name == "BossPhalloid":
			enemyB_count[2] += 1
	return num

func _on_death():
	if Global.lives > 0:
		var scene = Global.life_lost_scene.instance()
		add_child(scene)
	else:
		Global.show_death()

func _on_SpawnTimer_timeout():
	if get_active_enemies() >= max_enems:
		return
	if num_enems <= 0:
		sTimer.stop()
		return
	if num_enems % 2 == 0:
		spawn_enemy() if Global.rand_int(0, 100) < 75 else spawn_boss()
		spawn_enemy() if Global.rand_int(0, 100) < 75 else spawn_boss()
	else:
		spawn_enemy() if Global.rand_int(0, 100) < 75 else spawn_boss()
	

