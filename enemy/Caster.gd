extends CharacterBody2D


@export var speed = 50
@export var projectile_scene: PackedScene
@export var sprite2d: Sprite2D
@export var animated_sprite2d: AnimatedSprite2D

@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var cast_timer = $CastTimer
@onready var fireball_parent = get_parent().get_parent().get_node("CastedSpells")
@onready var agent = $NavigationAgent2D
var shader: ShaderMaterial

var can_cast = true
var active = false
var moving_left = false

enum AnimationState {
	IDLE = 0,
	MOVING = 8,
	DYING = 16
}

var animation_state = AnimationState.IDLE

func _ready():
	if animated_sprite2d != null:
		shader = animated_sprite2d.material
	else:
		shader = sprite2d.material

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	
	velocity = Vector2.ZERO
	if animation_state != AnimationState.DYING:
		if active:
			var next_path_pos = agent.get_next_path_position()
			var direction = global_position.direction_to(next_path_pos)
			velocity = direction * speed
			animation_state = AnimationState.MOVING
		if can_cast && can_see_player():
			cast_timer.start()
			cast_fireball()
			can_cast = false
	moving_left = velocity.x < 0
	move_and_slide()


func cast_fireball():
	var fireball = projectile_scene.instantiate()
	fireball.position = global_position
	var direction = (player.position + player.velocity * 0.5 - global_position).normalized()
	
	fireball.velocity = direction * 300
	fireball_parent.add_child(fireball)


func make_path():
	var player_position = player.position
	var target_position
	if can_see_player():
		
		var direction_to_player = (player_position - global_position).normalized()
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
		animation_state = AnimationState.IDLE


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
	if sprite2d != null:
		animate_sprite_frames()
	else:
		animate_with_animations()


func animate_sprite_frames():
	if animation_state == AnimationState.DYING && sprite2d.frame == animation_state + 7:
		return # Leave enemy in last dying frame if not dead yet
	var start_frame: int = animation_state
	var new_frame = sprite2d.frame + 1
	if new_frame >= start_frame + 8:
		new_frame = start_frame
	elif new_frame < start_frame:
		new_frame = start_frame
	sprite2d.frame = new_frame


func animate_with_animations():
	var animation_name = ""
	match animation_state:
		AnimationState.IDLE:
			animation_name = "idle"
		AnimationState.MOVING:
			animation_name = "moving"
		AnimationState.DYING:
			animation_name = "dying"
	
	if moving_left:
		animation_name += "_left"
	else:
		animation_name += "_right"
	
	if animated_sprite2d.animation != animation_name:
		animated_sprite2d.play(animation_name)


func _on_death_timer_timeout():
	queue_free()


func _on_death():
	if animation_state != AnimationState.DYING:
		$CollisionShape2D.set_deferred("disabled", true)
		animation_state = AnimationState.DYING
		if sprite2d != null:
			sprite2d.frame = AnimationState.DYING
		$DeathTimer.start()


func _on_health_health_changed(from, to):
	if from > to:
		shader.set_shader_parameter("flash_red", true)
		$RedFlashTimer.start()
		

func _on_red_flash_timer_timeout():
	shader.set_shader_parameter("flash_red", false)
