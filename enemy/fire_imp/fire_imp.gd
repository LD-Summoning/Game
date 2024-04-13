extends CharacterBody2D


@export var speed = 100
@onready var player = get_parent().get_node("Player")
@onready var cast_timer = get_node("CastTimer")

var can_cast = true

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	var player_position = player.position
	var direction_to_player = (player_position - position).normalized()
	direction_to_player *= 100
	var target_position = player_position - direction_to_player
	var direction = (target_position - position).normalized()
	if position.distance_squared_to(target_position) > 9:
		move_and_collide(direction * speed * delta)
	elif can_cast:
		cast_timer.start()
		# todo: cast
		can_cast = false


func _on_cast_timer_timeout():
	can_cast = true
