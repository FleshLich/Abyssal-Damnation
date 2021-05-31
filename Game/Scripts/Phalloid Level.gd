extends Node2D

signal level_finished

onready var Viridan = load("res://Game/Enemies/Phalloid.tscn")
onready var miniboss = load("res://Game/Enemies/BossPhalloid.tscn")
onready var player = $Player
onready var sTimer = $SpawnTimer

var num_enems = Global.rand_int(6 + (3 * Global.depth), 9 + 6 + (3 * Global.depth))
var max_enems = 4 + (2 * Global.depth)

var last_point = null

func _ready():
	spawn_enemy()
	spawn_enemy()
	$AudioStreamPlayer.play()
	player.connect("died", self, "_on_death")	

func _physics_process(delta):
	if get_active_enemies() <= 0 and num_enems <= 0:
		print("test")
		Global.show_win()
	if Global.debug and Input.is_action_just_pressed("Reload"):
		Global.start_level()

func spawn_enemy(check=true):
	var spawn = Viridan.instance() if Global.rand_int(0, 100) < 90 else miniboss.instance()
	var desiredPoints = []
	num_enems -= 1
	if num_enems % 3 == 0:
		spawn = miniboss.instance()
	for point in get_tree().get_nodes_in_group("Spawns"):
		if player.position.distance_to(point.position) > 300:
			desiredPoints.append(point)
	var new_point = desiredPoints[Global.rand_int(0, desiredPoints.size() - 1)]
	if new_point == last_point:
		spawn_enemy()
		return
	spawn.position = new_point.position
	last_point = new_point
	add_child(spawn)
	
	
func get_active_enemies():
	var num = 0
	for s in get_tree().get_nodes_in_group("Enemy"):
		if s.get("dead") == false:
			num += 1
	return num

func _on_death():
	if Global.lives > 0:
		var scene = Global.life_lost_scene.instance()
		add_child(scene)
	else:
		Global.show_death()

func _on_SpawnTimer_timeout():
	var num = get_active_enemies()
	if num_enems <= 0:
		sTimer.stop()
	if num >= max_enems:
		return
	if num_enems > 0:
		spawn_enemy()
		spawn_enemy()
	else:
		spawn_enemy()
	var wait_min = 6 - (0.5 * Global.depth) if 6 - (0.5 * Global.depth) >= 2 else 2
	var wait_max = 9 - (0.5 * Global.depth) if 9 - (0.5 * Global.depth) >= 3 else 3
	sTimer.wait_time = Global.rand_int(wait_min, wait_max)


func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.stream = load(Global.get_music())
	$AudioStreamPlayer.seek(0)
	$AudioStreamPlayer.play()
