extends Node

var level: Node
@onready var timer = $LevelSwitchCooldown
var can_switch = true

func _ready():
	level = get_parent().get_node("Level")


func _on_level_scene_change(new_scene: PackedScene):
	if can_switch:
		can_switch = false
		var new_level = new_scene.instantiate()
		new_level.connect("scene_change", _on_level_scene_change)
		get_parent().add_child(new_level)
		get_parent().move_child(new_level, 0)
		level.queue_free()
		level = new_level
		timer.start()


func _on_level_switch_cooldown_timeout():
	can_switch = true
