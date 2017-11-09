extends Node


func _ready():
	pass


func get_projectile():
	var group_index = randi() % get_child_count()
	return get_child(group_index).duplicate()
