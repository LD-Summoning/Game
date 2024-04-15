extends Node2D

# All levels have this script
# All levels can emit this signal
signal scene_change(new_scene: PackedScene)


func _ready():
	for door in get_children():
		if door.is_in_group("doors"):
			door.connect("body_entered", callback.bind(door))


func callback(_ignored, door):
	if $Enemies.get_child_count() == 1:
		scene_change.emit(door.scene)
