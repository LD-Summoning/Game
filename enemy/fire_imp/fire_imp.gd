extends CharacterBody2D


@export var speed = 100
var player_position
var direction
@onready var player = get_parent().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	player_position = player.position
	direction = (player_position - position).normalized()
	
	if position.distance_squared_to(player_position) > 9:
		move_and_collide(direction * speed)
