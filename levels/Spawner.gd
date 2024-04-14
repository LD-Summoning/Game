extends Node2D

# Scene to spawn when 
@export var scene_to_spawn: PackedScene
# 
@export var distance: int = 300


var has_seen_player = false
@onready var player = get_parent().get_parent().get_parent().get_node("Player")
@onready var distance_sq = distance * distance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !has_seen_player && position.distance_squared_to(player.position) < distance_sq:
		print("Spawning")
		has_seen_player = true
		var object = scene_to_spawn.instantiate()
		object.position = position
		get_parent().add_child(object)
		queue_free()
