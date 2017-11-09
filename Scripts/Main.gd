extends Node


var tick_index = 0;

onready var projectile_timer = get_node("ProjectileTimer")

var projectile_factory = preload("res://Objects/ProjectileFactory.tscn")


func _ready():
	create_projectile()
	projectile_timer.connect("timeout", self, "_on_projectile_timeout")
	projectile_timer.start()
	pass


func _on_projectile_timeout():
	tick_index += 1
	if tick_index % 2 == 0:
		create_projectile()


func create_projectile():
	var factory = projectile_factory.instance()
	var projectile = factory.get_projectile()
	projectile_timer.connect("timeout", projectile, "_on_tick")
	add_child(projectile)

