extends Node


# the min/max values for generating actions for a given mode
# these could be changed to alter the dificulty
const drop_min_action = 1
const drop_max_action = 3
const rest_min_action = 1
const rest_max_action = 2
# 1/x chance of two projectiles being created in one round
const multiple_projectile_chance = 4
# the maximum number of misses allowed
const miss_max = 3
# number or projectile columns
const projectile_columns = 5

# enum for the different round types
enum mode_type { DROP = -1, REST = 1 }

# the number of actions to take before switching modes
# an action occurs when all the projectile columns have been processed
var action_count = 0
# tracks the current game mode; dropping projectiles or not
var current_mode = mode_type.DROP
# the tick index of the current round
var tick_index = 0
# factory used to create new projectiles
var factory
# the voice id of the score sound effect
var score_voice = 0
# flag indicating if the game has ended
var game_over = false

# frequently used nodes
onready var projectile_timer = get_node("ProjectileTimer")
onready var retry_timer = get_node("RetryTimer")
onready var hud = get_node("Hud")
onready var audio_player = get_node("AudioPlayer")
onready var projectile_list = get_node("Projectiles")
onready var player_miss = get_node("PlayerMiss")

# scene containing the variuos projectile types
var projectile_factory = preload("res://Objects/ProjectileFactory.tscn")
# sceen containing the player logic
var player_scene = preload("res://Objects/Peasant.tscn")



# ***************
# AUTO FUNCTIONS
# called by the engine or connected through signals
# ***************

func _ready():
	# make sure the random numbers are always different
	randomize()
	
	# process input
	set_process_input(true)
	
	# start in the drop mode
	current_mode = mode_type.DROP
	
	# create the projectile factory
	factory = projectile_factory.instance()
	
	# initialize the score
	hud.score = 0
	
	# generate a random number of actions to take based on the current mode
	action_count = generate_action_count(current_mode)
	# start the game having taken an action
	take_action()
	
	# create the player
	create_player()
	
	# start the projectile timer
	projectile_timer.start()


func _input(event):
	# check if the game is not over 
	if !game_over:
		# don't process any input
		return
	
	# check if spacebar was pressed
	if event.is_action_pressed("ui_select"):
		# reload the game
		get_tree().reload_current_scene()


func _on_projectile_timer_timeout():
	# increment the tick index
	tick_index += 1
	
	# flag indicating if there is a projectile at this index
	var has_projectile = false
	
	# loop through all the projectiles
	for projectile in projectile_list.get_children():
		# check if this projectile's index matches the tick's
		if projectile.process_index == tick_index:
			# handle the projectile logic
			projectile.process_projectile()
			# indicate that there is a projectile for this index
			has_projectile = true
	
	# check if there is a projectile at this index and the score sound isn't playing
	if has_projectile && !audio_player.is_voice_active(score_voice):
		# play the drop sound
		audio_player.play("drop")
	
	# check if we've reached the end of the projectiles
	if tick_index == projectile_columns:
		# reset the tick index
		tick_index = 0
		# end the round and take another action
		take_action()


func _on_retry_timer_timeout():
	# restart the projectile timer
	projectile_timer.start()
	# hide the player miss sprite
	player_miss.hide()
	# create a new player
	create_player()


func _on_collision():
	# increment the miss count
	hud.miss += 1
	# stop projectile processing
	projectile_timer.stop()
	# get the player node
	var player = get_node("Peasant")
	# and remove it
	player.queue_free()
	
	# play the die sound
	audio_player.play("die")
	
	# show the player miss sprite
	player_miss.show()
	
	# check if the max misses has been reached
	if hud.miss == miss_max:
		# update the game over flag
		game_over = true
		# end the game
		return
	
	# start the retry timer
	retry_timer.start()


func _on_score():
	hud.score += 1
	# play the score sound and store its id
	score_voice = audio_player.play("score")


# ***************
# HELPER FUNCTIONS
# ***************

func rand_int_range(min_range, max_range):
	# returns a random integer for a given range (inclusive)
	var mod_by = max_range - min_range + 1
	return (randi() % mod_by) + min_range



# ***************
# ACTION FUNCTIONS
# functions controlling the game play
# ***************

func generate_action_count(mode):
	if mode == mode_type.DROP:
		return rand_int_range(drop_min_action, drop_max_action)
	
	return rand_int_range(rest_min_action, rest_max_action)


func take_action():
	# check if the current mode is drop
	if current_mode == mode_type.DROP:
		# handle projectile creation
		drop_projectile()
	
	# decrement the action count
	action_count -= 1
	# check if that was the last action
	if action_count == 0:
		# change to the other mode
		current_mode = -current_mode
		# generate a new action count for the new mode
		action_count = generate_action_count(current_mode)


func drop_projectile():
	# select a random projectile column
	var projectile_index = rand_int_range(0, projectile_columns - 1)
	# create that projectile
	create_projectile(projectile_index)
	# check for a chance of a second projectile
	if rand_int_range(1, multiple_projectile_chance) == 1:
		# remember the last projectile column used
		var previous_index = projectile_index
		# pick a new random column that is different from the first
		while previous_index == projectile_index:
			projectile_index = rand_int_range(0, projectile_columns - 1)
		# create that projectile
		create_projectile(projectile_index)


func create_projectile(index):
	# get the projectile at the specified column
	var projectile = factory.get_projectile(index)
	# connect the projectile's collide signal
	projectile.connect("collide", self, "_on_collision")
	# add the projectile to the scene
	projectile_list.add_child(projectile)


func create_player():
	# create a player node from the scene
	var player = player_scene.instance()
	# connect the player's collide signal
	player.connect("collide", self, "_on_collision")
	# connect the player's score signal
	player.connect("score", self, "_on_score")
	# add the player to the scene
	add_child(player)

