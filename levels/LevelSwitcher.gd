extends Node

var level: Node
var new_level_scene: PackedScene
@onready var timer = $LevelSwitchCooldown
@onready var player_casts = get_parent().get_node("PlayerCasts")
var can_switch = true

func _ready():
	level = get_parent().get_node("Level")


func _process(_delta):
	if can_switch && new_level_scene != null:
		can_switch = false
		var new_level = new_level_scene.instantiate()
		new_level.connect("scene_change", _on_level_scene_change)
		get_parent().add_child(new_level)
		get_parent().move_child(new_level, 0)
		level.queue_free()
		level = new_level
		timer.start()
		new_level_scene = null
		
		for cast in player_casts.get_children():
			cast.queue_free()


func _on_level_scene_change(new_scene: PackedScene):
	new_level_scene = new_scene


func _on_level_switch_cooldown_timeout():
	can_switch = true
