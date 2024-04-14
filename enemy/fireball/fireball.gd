extends Node2D


@export var velocity = Vector2(0, 0)
@export var damage = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta


func _on_body_entered(body):
	print(body)
	if body.has_node("Health"):
		body.get_node("Health").signal_damage(damage)
	# queue_free()
