extends Node2D

signal level_finished

onready var skeleton = load("res://Game/Enemies/Skeleton.tscn")
onready var player = $Player
onready var sTimer = $SpawnTimer

var num_skels = Global.rng.randi_range(5, 7)
var max_skels = 4

var finished = false

var last_point = null

func _ready():
	spawn_skeleton()
	spawn_skeleton()
	player.connect("died", self, "_on_death")

func _physics_process(delta):
	if Global.debug and Input.is_action_just_pressed("Reload"):
		get_tree().change_scene("res://Game/Levels/SkeletonLevel.tscn")

func spawn_skeleton():
	var spawn = skeleton.instance()
	var desiredPoints = [$Spawn5]
	num_skels -= 1
	if num_skels <= 0:
		sTimer.stop()
	for point in get_tree().get_nodes_in_group("SkelSpawns"):
		if player.position.distance_to(point.position) > 300:
			desiredPoints.append(point)
	var new_point = desiredPoints[Global.rng.randi_range(0, desiredPoints.size() - 1)]
	if new_point == last_point:
		spawn_skeleton()
		return
	spawn.position = new_point.position
	last_point = new_point
	add_child(spawn)

func _on_death():
	get_tree().change_scene("res://Game/Levels/SkeletonLevel.tscn")

func _on_SpawnTimer_timeout():
	var num = 0
	for s in get_tree().get_nodes_in_group("Enemy"):
		if s.get("dead") == false:
			num += 1
	if num >= max_skels:
		return
	spawn_skeleton()
	sTimer.wait_time = Global.rng.randi_range(1 * num, 3 * num)
