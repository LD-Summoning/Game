extends CharacterBody2D


@export var speed = 50

@onready var player = get_parent().get_parent().get_parent().get_node("Player")
@onready var cast_timer = $CastTimer
@onready var fireball_scene = preload("res://scenes/fireball.tscn")
@onready var fireball_parent = get_parent().get_node("CastedSpells")
@onready var agent = $NavigationAgent2D
@onready var sprite2d = $Sprite2D

var can_cast = true
var active = false

enum AnimationState {
	IDLE = 0,
	MOVING = 8,
	DYING = 16
}

var animation_state = AnimationState.IDLE

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	
	velocity = Vector2.ZERO
	
	if active:
		var next_path_pos = agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		velocity = direction * speed
	if can_cast && can_see_player():
		cast_timer.start()
		cast_fireball()
		can_cast = false
	move_and_slide()


func cast_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.position = position
	var direction = (player.position + player.velocity * 0.5 - position).normalized()
	
	fireball.velocity = direction * 300
	fireball_parent.add_child(fireball)


func make_path():
	var player_position = player.position
	var target_position
	if can_see_player():
		
		var direction_to_player = (player_position - position).normalized()
		direction_to_player *= 100
		target_position = player_position - direction_to_player
		target_position = target_position
	else:
		target_position = player_position
		
	if (target_position - global_position).length_squared() > 16:
		agent.target_position = target_position
		active = true
	else:
		active = false


func can_see_player() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	var result = space_state.intersect_ray(query)
	return result && result.collider == player


func _on_cast_timer_timeout():
	can_cast = true


func _on_pathfinding_timer_timeout():
	make_path()


func _on_animation_timer_timeout():
	var start_frame: int = animation_state
	sprite2d.frame += 1
	if sprite2d.frame >= start_frame + 8:
		sprite2d.frame = start_frame
	elif sprite2d.frame < start_frame:
		sprite2d.frame = start_frame
