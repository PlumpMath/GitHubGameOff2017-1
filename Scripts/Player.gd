extends Node


const widget_offset = Vector2(32, 0)

var min_frame = 0
var max_frame = 4
var current_frame = 0

onready var position_list = get_node("Positions")
onready var collision_widget = get_node("CollisionWidget")


func _ready():
	set_process_input(true)
	
	current_frame = 0
	position_list.get_child(current_frame).show()


func _input(event):
	if event.is_action_pressed("move_left"):
		move(-1)
	elif event.is_action_pressed("move_right"):
		move(1)


func move(direction):
	var new_frame = current_frame + direction
	if new_frame < min_frame or new_frame > max_frame:
		return
	
	position_list.get_child(current_frame).hide()
	position_list.get_child(new_frame).show()
	current_frame = new_frame
	
	var new_pos = collision_widget.get_pos() + (widget_offset * direction)
	collision_widget.set_pos(new_pos)
	var detector = collision_widget.get_node("Detect")
	detector.force_raycast_update()
	if detector.is_colliding():
		print("player hit projectile")

