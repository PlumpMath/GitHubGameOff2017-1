extends Node


export(int) var process_order

signal collide

const widget_offset = Vector2(0, 16)

var projectile_index = 0
var previous_projectile = null

onready var sprite_list = get_node("Sprites")
onready var collision_widget = get_node("CollisionWidget")


func _ready():
	pass


func _on_tick(tick_index):
	if tick_index != process_order:
		return
	
	if projectile_index >= sprite_list.get_child_count():
		queue_free()
		return
	
	if previous_projectile:
		previous_projectile.hide()
	
	var next_projectile = sprite_list.get_child(projectile_index)
	next_projectile.show()
	
	projectile_index += 1
	previous_projectile = next_projectile
	
	var new_pos = collision_widget.get_pos() + widget_offset
	collision_widget.set_pos(new_pos)
	
	var detector = collision_widget.get_node("Detect")
	detector.force_raycast_update()
	if detector.is_colliding():
		emit_signal("collide")

