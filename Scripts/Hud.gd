extends Control


const digit_sprites = [ 
	preload("res://Sprites/Digits/0.png"),
	preload("res://Sprites/Digits/1.png"),
	preload("res://Sprites/Digits/2.png"),
	preload("res://Sprites/Digits/3.png"),
	preload("res://Sprites/Digits/4.png"),
	preload("res://Sprites/Digits/5.png"),
	preload("res://Sprites/Digits/6.png"),
	preload("res://Sprites/Digits/7.png"),
	preload("res://Sprites/Digits/8.png"),
	preload("res://Sprites/Digits/9.png")
]

var score setget set_score
var miss setget set_miss

var miss_sprite = preload("res://Sprites/Peasant/miss_icon.png")

onready var miss_container = get_node("MissContainer")
onready var score_container = get_node("Score")



# ***************
# SET FUNCTIONS
# functions to set values
# ***************

func set_score(value):
	# set the new score value
	score = value
	
	# for each digit in the current score display
	for digit in score_container.get_children():
		# remove the digit
		digit.queue_free()
	
	# loop through each digit in the score
	for digit in get_digits(score):
		# create a new digit node
		var digit_icon = create_digit(digit)
		# add the node to the container
		score_container.add_child(digit_icon)


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
		# create a new icon node
		var miss_icon = create_icon()
		# add the node to the container
		miss_container.add_child(miss_icon)
		# HBoxContainer will handle spacing the nodes in the container



# ***************
# HELPER FUNCTIONS
# ***************

func get_digits(number):
	var str_number = str(number)
	var digits = []
	
	for i in range(str_number.length()):
		digits.append(str_number[i].to_int())
	
	return digits



# ***************
# CREATION FUNCTIONS
# Create images to display in the hud
# ***************

func create_digit(digit):
	# create a new texture frame
	var texture_frame = TextureFrame.new()
	# set the sprite to the corresponding digit
	texture_frame.set_texture(digit_sprites[digit])
	# create a new sprite node
	var shadow = Sprite.new()
	# set the texture to the corresponding digit
	shadow.set_texture(digit_sprites[digit])
	# don't center the sprite
	shadow.set_centered(false)
	# set the shadow position
	shadow.set_pos(Vector2(2, 2))
	# set the shadow opacity
	shadow.set_opacity(0.3)
	# add the shadow to the icon
	texture_frame.add_child(shadow)
	# return the digit node
	return texture_frame


func create_icon():
	# create a new texture frame node
	var miss_icon = TextureFrame.new()
	# set the texture to the miss sprite
	miss_icon.set_texture(miss_sprite)
	# create a new sprite node
	var shadow = Sprite.new()
	# set the texture to the miss sprite
	shadow.set_texture(miss_sprite)
	# don't center the sprite
	shadow.set_centered(false)
	# set the shadow position
	shadow.set_pos(Vector2(2, 2))
	# set the shadow opacity
	shadow.set_opacity(0.3)
	# add the shadow to the icon
	miss_icon.add_child(shadow)
	# return the icon node
	return miss_icon

