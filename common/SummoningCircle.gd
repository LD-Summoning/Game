extends Node2D

@export var to_summon: PackedScene
@export var thumbnail: Texture2D

var progress = 0.0
var spawned = false

func _ready():
	$Thumbnail.texture = thumbnail


func _process(delta):
	if spawned && has_node("Thumbnail"):
		$Thumbnail.queue_free()
	if progress >= 1.0:
		return
	progress = min(1.0, progress + delta * 2)
	if has_node("Thumbnail"):
		$Thumbnail.material.set_shader_parameter("threshhold", progress)


func _on_summon_timer_timeout():
	$DeathTimer.start()
	spawned = true
	
	var summoned = to_summon.instantiate()
	summoned.position = global_position
	get_parent().get_parent().add_child(summoned)


func _on_death_timer_timeout():
	queue_free()
