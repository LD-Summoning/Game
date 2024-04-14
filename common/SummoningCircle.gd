extends Node2D

@export var to_summon: PackedScene


func _on_summon_timer_timeout():
	$DeathTimer.start()
	var summoned = to_summon.instantiate()
	summoned.position = global_position
	get_parent().get_parent().add_child(summoned)


func _on_death_timer_timeout():
	queue_free()
