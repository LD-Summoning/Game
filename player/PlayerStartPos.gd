extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_parent().get_parent().get_node("Player")
	player.position = position
