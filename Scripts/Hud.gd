extends Control


var score setget set_score
var miss setget set_miss

var miss_sprite = preload("res://Sprites/player_icon.png")

onready var miss_container = get_node("MissContainer")
onready var score_label = get_node("ScoreLabel")


func _ready():
	miss = 0


func set_score(value):
	# set the new score value
	score = value
	# display the score
	score_label.set_text(str(score))


func set_miss(value):
	# set the new miss value
	miss = value
	
	# remove any miss icons over the miss count
	while miss_container.get_child_count() > miss:
		# get the first node in the container
		var miss_icon = miss_container.get_child(0)
		# remove the node from the container
		miss_container.remove_child(miss_icon)
		# free the node resources
		miss_icon.queue_free()
	
	# add any miss icons to match the miss count
	while miss_container.get_child_count() < miss:
		# create a new texture frame node
		var miss_icon = TextureFrame.new()
		# set the texture to the miss sprite
		miss_icon.set_texture(miss_sprite)
		# add the node to the container
		miss_container.add_child(miss_icon)
		# HBoxContainer will handle spacing the nodes in the container

