extends Node2D

signal level_finished

onready var skeleton = load("res://Game/Enemies/Skeleton.tscn")
onready var miniboss = load("res://Game/Enemies/BossSkeleton.tscn")
onready var player = $Player
onready var sTimer = $SpawnTimer

var num_skels = Global.rand_int(5, 7)
var max_skels = 4

var finished = false

var last_point = null

func _ready():
	spawn_skeleton()
	spawn_skeleton()
	player.connect("died", self, "_on_death")	

func _physics_process(delta):
	if get_active_skeletons() <= 0 and num_skels <= 0:
		Global.show_win()
	if Global.debug and Input.is_action_just_pressed("Reload"):
		Global.start_level()

func spawn_skeleton():
	var spawn = skeleton.instance()
	var desiredPoints = []
	num_skels -= 1
	if num_skels <= 0:
		sTimer.stop()
		spawn = miniboss.instance()
	for point in get_tree().get_nodes_in_group("Spawns"):
		if player.position.distance_to(point.position) > 300:
			desiredPoints.append(point)
	var new_point = desiredPoints[Global.rand_int(0, desiredPoints.size() - 1)]
	if new_point == last_point:
		spawn_skeleton()
		return
	spawn.position = new_point.position
	last_point = new_point
	add_child(spawn)
	
func get_active_skeletons():
	var num = 0
	for s in get_tree().get_nodes_in_group("Enemy"):
		if s.get("dead") == false:
			num += 1
	return num

func _on_death():
	var scene = Global.life_lost_scene.instance()
	add_child(scene)

func _on_SpawnTimer_timeout():
	var num = get_active_skeletons()
	if num >= max_skels:
		return
	spawn_skeleton()
	sTimer.wait_time = Global.rand_int(2 * num, 4 * num)

