extends Control


var score = 0

var miss_sprite = preload("res://Sprites/player_icon.png")

onready var miss_indicator = get_node("MissIndicator")
onready var miss_container = get_node("MissContainer")


func _ready():
	pass


func missed():
	miss_indicator.show()
	
	var miss_icon = TextureFrame.new()
	miss_icon.set_texture(miss_sprite)
	miss_container.add_child(miss_icon)


func _on_retry():
	miss_indicator.hide()


func _on_score():
	score += 1
	var label = get_node("ScoreLabel")
	label.set_text(str(score))
