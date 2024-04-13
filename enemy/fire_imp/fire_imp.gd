extends CharacterBody2D


@export var speed = 100
@onready var player = get_parent().get_node("Player")
@onready var cast_timer = get_node("CastTimer")
@onready var fireball_scene = preload("res://scenes/fireball.tscn")
@onready var fireball_parent = get_parent().get_node("Fireballs")

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
		cast_fireball()
		can_cast = false


func cast_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.position = position
	var direction = (player.position + player.velocity * 0.5 - position).normalized()
	
	fireball.velocity = direction * 300
	fireball_parent.add_child(fireball)

func _on_cast_timer_timeout():
	can_cast = true
