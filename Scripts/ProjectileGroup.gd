extends Node


var projectile_index = 0
var widget_offset = Vector2(0, 16)

onready var sprite_list = get_node("Sprites")
onready var collision_widget = get_node("CollisionWidget")


func _ready():
	var projectile = sprite_list.get_child(projectile_index)
	projectile.show()


func _on_tick():
	var previous_projectile = sprite_list.get_child(projectile_index)
	projectile_index += 1
	
	if projectile_index >= sprite_list.get_child_count():
		queue_free()
		return
	
	var next_projectile = sprite_list.get_child(projectile_index)
	previous_projectile.hide()
	next_projectile.show()
	
	var new_pos = collision_widget.get_pos() + widget_offset
	collision_widget.set_pos(new_pos)
	
	var detector = collision_widget.get_node("Detect")
	detector.force_raycast_update()
	if detector.is_colliding():
		print("projectile hit player")

