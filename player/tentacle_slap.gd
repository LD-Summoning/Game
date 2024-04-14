extends Area2D

@onready var _slap_timer = $SlapTimer

var slap_hit_targets = []
var tentacle_slap_damage = 0
var tentacle_slap_duration = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	_slap_timer.start(tentacle_slap_duration)


func _on_body_entered(body):
	if slap_hit_targets.find(body) < 0:
		slap_hit_targets.push_back(body)
		if body != null && body.has_node("Health"):
			body.get_node("Health").signal_damage(tentacle_slap_damage)


func _on_slap_timer_timeout():
	queue_free()
