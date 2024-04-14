extends Node2D

@export var to_summon: PackedScene
@export var summoned_by_player = true
@export var delay_until_summon = 0


func _ready():
	if summoned_by_player:
		$Sprite2D.frame = 1
	
	if delay_until_summon > 0:
		$SummonTimer.wait_time = delay_until_summon
		$SummonTimer.start()
	else:
		_on_summon_timer_timeout()


func _on_summon_timer_timeout():
	$DeathTimer.start()
	var summoned = to_summon.instantiate()
	summoned.position = position
	get_parent().add_child(summoned)


func _on_death_timer_timeout():
	queue_free()
