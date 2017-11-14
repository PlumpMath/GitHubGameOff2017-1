extends Node

const miss_max = 3

var tick_index = 0;
var miss = 0;

onready var projectile_timer = get_node("ProjectileTimer")
onready var retry_timer = get_node("RetryTimer")
onready var hud = get_node("Hud")

var projectile_factory = preload("res://Objects/ProjectileFactory.tscn")
var player_scene = preload("res://Objects/Player.tscn")

func _ready():
	create_projectile()
	
	var player = get_node("Player")
	player.connect("collide", self, "_on_collision")
	player.connect("score", hud, "_on_score")
	
	retry_timer.connect("timeout", self, "_on_retry")
	retry_timer.connect("timeout", hud, "_on_retry")
	
	projectile_timer.connect("timeout", self, "_on_projectile_timeout")
	projectile_timer.start()


func _on_projectile_timeout():
	tick_index += 1
	if tick_index % 2 == 0:
		create_projectile()


func create_projectile():
	var factory = projectile_factory.instance()
	var projectile = factory.get_projectile()
	projectile_timer.connect("timeout", projectile, "_on_tick")
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



