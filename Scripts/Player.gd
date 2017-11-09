extends Node


var min_frame = 0
var max_frame = 4
var current_frame = 0

onready var position_list = get_node("Positions")


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

