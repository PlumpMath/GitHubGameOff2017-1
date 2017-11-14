extends Node


signal collide
signal score

const widget_offset = Vector2(32, 0)

var min_frame = 0
var max_frame = 4
var current_frame = 0
var has_treasure = false

onready var position_list = get_node("Positions")
onready var treasure_list = get_node("Treasure")
onready var collision_widget = get_node("CollisionWidget")
onready var animation = get_node("GatherAnimation")


func _ready():
	set_process_input(true)
	
	animation.connect("finished", self, "_on_treasure_collected")
	
	current_frame = 0
	position_list.get_child(current_frame).show()


func _input(event):
	if event.is_action_pressed("move_left"):
		move(-1)
	elif event.is_action_pressed("move_right") && ! animation.is_playing():
		move(1)


func move(direction):
	var new_frame = current_frame + direction
	
	if new_frame < min_frame or new_frame > max_frame:
		if new_frame > max_frame && !has_treasure:
			collect_treasure()
		
		if new_frame < min_frame && has_treasure:
			return_treasure()
		
		return
	
	if animation.is_playing():
		animation.stop()
		var coin = get_node("Coin")
		coin.hide()
	
	position_list.get_child(current_frame).hide()
	position_list.get_child(new_frame).show()
	
	if has_treasure:
		treasure_list.get_child(current_frame).hide()
		treasure_list.get_child(new_frame).show()
	
	current_frame = new_frame
	
	var new_pos = collision_widget.get_pos() + (widget_offset * direction)
	collision_widget.set_pos(new_pos)
	var detector = collision_widget.get_node("Detect")
	detector.force_raycast_update()
	if detector.is_colliding():
		emit_signal("collide")
		queue_free()


func collect_treasure():
	animation.play("collect")


func _on_treasure_collected():
	has_treasure = true
	treasure_list.get_child(current_frame).show()
	emit_signal("score")


func return_treasure():
	has_treasure = false
	treasure_list.get_child(current_frame).hide()
	emit_signal("score")

