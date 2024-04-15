extends Control


@onready var first_level = preload("res://scenes/main_scene.tscn")


func _on_button_pressed():
	get_tree().change_scene_to_packed(first_level)
