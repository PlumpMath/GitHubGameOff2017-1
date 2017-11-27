extends Node


# the tick index this projectile should be processed at
export(int) var process_index

# signal inidicating collision with the player
signal collide

# amount to move the controller when the projectile moves positions
const controller_offset = Vector2(0, 16)

# index of the next projectile in the list
var projectile_index = 0
# projectile displayed during the last tick
var previous_projectile = null

onready var sprite_list = get_node("Sprites")
onready var controller = get_node("ProjectileController")


func process_projectile():
	# check if the index is past the end of the sprite list
	if projectile_index >= sprite_list.get_child_count():
		# destroy this node
		queue_free()
		# don't do anything else
		return
	
	# check if there was a previously displayed projectile
	if previous_projectile:
		# hide the previous projectile
		previous_projectile.hide()
	
	# get the sprite for the next projectile
	var next_projectile = sprite_list.get_child(projectile_index)
	# and display it
	next_projectile.show()
	
	# increment the index to the next position
	projectile_index += 1
	# store the current projectile as the previous
	previous_projectile = next_projectile
	
	# determine the new pos for the controller
	var controller_pos = controller.get_pos() + (controller_offset)
	# move the controller to the new pos
	controller.set_pos(controller_pos)
	# get the projectile detection raycast
	var detector = controller.get_node("PlayerDetection")
	# force an update since we moved the raycast
	detector.force_raycast_update()
	# check if the projectile hit the player
	if detector.is_colliding():
		# emit the collide signal
		emit_signal("collide")

