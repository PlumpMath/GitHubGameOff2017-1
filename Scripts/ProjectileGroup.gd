extends Node


var projectile_index = 0


func _ready():
	var projectile = get_child(projectile_index)
	projectile.show()


func _on_tick():
	var previous_projectile = get_child(projectile_index)
	projectile_index += 1
	if projectile_index < get_child_count():
		var next_projectile = get_child(projectile_index)
		previous_projectile.hide()
		next_projectile.show()
	else:
		queue_free()
