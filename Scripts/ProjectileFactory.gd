extends Node


func get_projectile(group_index):
	# return a duplicate of the projectile node at the given index
	return get_child(group_index).duplicate()
