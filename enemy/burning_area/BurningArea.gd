extends Node2D

@export var target_position: Vector2
@export var damage_per_frame = 10

var damageables_inside = []
var start_pos: Vector2
var t: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	$Sprite2D.material.set_shader_parameter("time_offset", randf_range(0, 100))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for damageable in damageables_inside:
		damageable.signal_damage(damage_per_frame)
	if t > 1:
		return
	t = min(t+delta, 1)
	position = start_pos * (1-t) + target_position * t
	scale = Vector2.ONE * t * 0.1


func _on_death_timer_timeout():
	queue_free()


func _on_area_2d_body_entered(body):
	if body.has_node("Health"):
		damageables_inside.push_back(body.get_node("Health"))

func _on_area_2d_body_exited(body):
	if body.has_node("Health"):
		var index = damageables_inside.find(body.get_node("Health"))
		if index >= 0:
			damageables_inside.remove_at(index)
