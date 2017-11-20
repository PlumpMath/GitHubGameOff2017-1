extends Node


signal tick(tick_index)

const miss_max = 3
const projectile_columns = 5

enum mode_type { DROP = -1, REST = 1 }

var tick_index = 0
var miss = 0
var current_mode = mode_type.DROP
var action_count = 0

onready var projectile_timer = get_node("ProjectileTimer")
onready var retry_timer = get_node("RetryTimer")
onready var hud = get_node("Hud")

var projectile_factory = preload("res://Objects/ProjectileFactory.tscn")
var player_scene = preload("res://Objects/Player.tscn")


func _ready():
	randomize()
	
	action_count = generate_action_count(current_mode)
	take_action()
	
	var player = get_node("Player")
	player.connect("collide", self, "_on_collision")
	player.connect("score", hud, "_on_score")
	
	retry_timer.connect("timeout", self, "_on_retry")
	retry_timer.connect("timeout", hud, "_on_retry")
	
	projectile_timer.connect("timeout", self, "_on_projectile_timeout")
	projectile_timer.start()


func _on_projectile_timeout():
	tick_index += 1
	emit_signal("tick", tick_index)
	
	if tick_index == projectile_columns:
		tick_index = 0
		take_action()


func rand_int_range(min_range, max_range):
	var mod_by = max_range - min_range + 1
	return (randi() % mod_by) + min_range


func generate_action_count(mode):
	if mode == mode_type.DROP:
		return rand_int_range(1, 3)
	
	return rand_int_range(1, 2)


func take_action():
	
	if current_mode == mode_type.DROP:
		drop_projectile()
	
	action_count -= 1
	if action_count == 0:
		current_mode = -current_mode
		action_count = generate_action_count(current_mode)


func drop_projectile():
	var projectile_index = rand_int_range(0, projectile_columns - 1)
	create_projectile(projectile_index)
	if rand_int_range(0, 3) == 0:
		var previous_index = projectile_index
		while previous_index == projectile_index:
			projectile_index = rand_int_range(0, projectile_columns - 1)
		create_projectile(projectile_index)


func create_projectile(index):
	var factory = projectile_factory.instance()
	var projectile = factory.get_projectile(index)
	connect("tick", projectile, "_on_tick")
	projectile.connect("collide", self, "_on_collision")
	add_child(projectile)


func _on_collision():
	miss += 1
	projectile_timer.stop()
	var player = get_node("Player")
	player.queue_free()
	hud.missed()
	
	if miss == miss_max:
		return
	
	retry_timer.start()


func _on_retry():
	projectile_timer.start()
	
	var player = player_scene.instance()
	player.connect("collide", self, "_on_collision")
	player.connect("score", hud, "_on_score")
	add_child(player)

