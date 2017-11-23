extends Node


# signal inidicating collision with a projectile
signal collide
# signal indicating a scoring action was performed
signal score

# enum for the different player states
enum mode_type { TRAVEL, GATHER, TREASURE, RETURN }

# amount to move the controller when the player switches positions
const controller_offset = Vector2(32, 0)

# the player's current position in the list of position sprites
var current_position = 0
# the player's current state
var current_mode = mode_type.TRAVEL

# node containing the player's sprites
onready var position_list = get_node("Positions")
# node containing the treasure sprites
onready var treasure_list = get_node("Treasure")
# node containing collision information for the player
onready var controller = get_node("MovementController")


func _ready():
	# turn on input processing
	set_process_input(true)
	
	# set initial current values
	current_position = 0
	current_mode = mode_type.TRAVEL
	
	# show the player's sprite
	position_list.get_child(current_position).show()


func _input(event):
	# check if the player is returning the treasure
	if current_mode == mode_type.RETURN:
		# don't move until the player is finished returning the treasure
		return
	
	# check if player is moving left
	if event.is_action_pressed("move_left"):
		# check if the player is doing normal travel or has the treasure
		if current_mode == mode_type.TRAVEL || current_mode == mode_type.TREASURE:
			# get the left detection raycast
			var detector = controller.get_node("LeftDetection")
			# ray collides when moving left of the first position or into the safe zone
			if detector.is_colliding():
				# check if player is doing normal travel
				if current_mode == mode_type.TRAVEL:
					# return without moving
					return
				
				# player has treasure so setup the return
				current_mode = mode_type.RETURN
			# end if detector.is_colliding()
		# end if current_mode == mode_type.TRAVEL || current_mode == mode_type.TREASURE
		
		# check if the player is gathering treasure
		if current_mode == mode_type.GATHER:
			# get the animated sprite
			var anim = position_list.get_child(current_position)
			# stop the animation
			anim.stop()
			# reset to the normal sprite
			anim.set_animation("default")
			# reset mode to travel
			current_mode = mode_type.TRAVEL
		
		# move left one position
		move(-1)
	# end if event.is_action_pressed("move_left")
	
	# check if the player is moving right
	elif event.is_action_pressed("move_right"):
		# check if the player is gathering treasure
		if current_mode == mode_type.GATHER:
			# they can't move any further right
			return
		
		# check if the player is doing normal travel or they have the treasure
		if current_mode == mode_type.TRAVEL || current_mode == mode_type.TREASURE:
			# get the right detection raycast
			var detector = controller.get_node("RightDetection")
			# if the ray is colliding the player is trying to gather treasure
			if detector.is_colliding():
				# check if the player is has treasure
				if current_mode == mode_type.TREASURE:
					# treasure must be returned before more can be gathered
					return
				
				# change the current mode
				current_mode = mode_type.GATHER
				# get the animated sprite
				var anim = position_list.get_child(current_position)
				# play the gather animation
				anim.play("gather")
				# return without moving
				return
			# end if detector.is_colliding()
		# end if current_mode == mode_type.TRAVEL || current_mode == mode_type.TREASURE
		
		# move right one position
		move(1)
	#end if event.is_action_pressed("move_right")


func move(direction):
	# determine the new index in the position list
	var new_position = current_position + direction
	
	# hide the player sprite at the old index
	position_list.get_child(current_position).hide()
	# show the player sprite at the new index
	position_list.get_child(new_position).show()
	
	# check if the player has the treasure is returning the treasure
	if current_mode == mode_type.TREASURE || current_mode == mode_type.RETURN:
		# hide the treasure sprite at the old index
		treasure_list.get_child(current_position).hide()
		# show the treasure sprite at the new index
		treasure_list.get_child(new_position).show()
		
		# check if the player is returning the treasure
		if current_mode == mode_type.RETURN:
			# play the return animation
			treasure_list.get_child(new_position).play("default")
	
	# update the current position to the new index
	current_position = new_position
	
	# determine the new pos for the controller
	var controller_pos = controller.get_pos() + (controller_offset * direction)
	# move the controller to the new pos
	controller.set_pos(controller_pos)
	# get the projectile detection raycast
	var detector = controller.get_node("ProjectileDetection")
	# force an update since we moved the raycast
	detector.force_raycast_update()
	# check if the player moved into a projectile
	if detector.is_colliding():
		# emit the collide signal
		emit_signal("collide")


func _on_gather_finished():
	# get the animated sprite
	var anim = position_list.get_child(current_position)
	# reset to the normal sprite
	anim.set_animation("default")
	# show the treasure sprite
	treasure_list.get_child(current_position).show()
	# update the current mode
	current_mode = mode_type.TREASURE
	# emit the score signal
	emit_signal("score")


func _on_return_finished():
	# get the animated sprite
	var anim = treasure_list.get_child(current_position)
	# hide the treasure sprite
	anim.hide()
	# stop the animation
	anim.stop()
	# reset the animation
	anim.set_frame(0)
	# update the current mode
	current_mode = mode_type.TRAVEL
	# emit the score signal
	emit_signal("score")

