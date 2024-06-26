extends CharacterBody2D


@export var speed = 50
@export var animated_sprite2d: AnimatedSprite2D
@export var summonables: Array[PackedScene]
@export var thumbnails: Array[Texture2D]
@export var boss_bar: TextureProgressBar

@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var cast_timer = $CastTimer
@onready var summonables_parent = get_parent().get_node("CastedSpells")
@onready var agent = $NavigationAgent2D
@onready var shader = animated_sprite2d.material
@onready var summoning_circle_scene = preload("res://scenes/SummoningCircle.tscn")
@onready var credits_scene = preload("res://scenes/credits.tscn")

var can_summon = true
var active = false
var moving_left = false
var moving_y = false

enum AnimationState {
	IDLE,
	MOVING,
	ATTACKING,
	MASK_OFF,
	DYING,
}

const animation_to_name = ["idle", "moving", "attacking", "mask_off", "dying"]

var animation_state = AnimationState.IDLE


func _ready():
	boss_bar.max_value = $Health._health
	boss_bar.value = $Health._health

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	
	velocity = Vector2.ZERO
	if animation_state != AnimationState.DYING:
		if active:
			var next_path_pos = agent.get_next_path_position()
			var direction = global_position.direction_to(next_path_pos)
			velocity = direction * speed
			if animation_state == AnimationState.IDLE:
				animation_state = AnimationState.MOVING
		if can_summon && can_see_player():
			cast_timer.start()
			summon_random_enemy()
			animation_state = AnimationState.ATTACKING
			can_summon = false
	moving_left = velocity.x < 0
	moving_y = abs(velocity.x) < abs(velocity.y)
	if velocity == Vector2.ZERO && animation_state == AnimationState.MOVING:
		animation_state = AnimationState.IDLE
	move_and_slide()


func summon_random_enemy():
	var index = randi() % summonables.size()
	var enemy = summonables[index]
	var thumbnail = thumbnails[index]
	var summoning_circle = summoning_circle_scene.instantiate()
	summoning_circle.to_summon = enemy
	summoning_circle.position = player.global_position
	summoning_circle.thumbnail = thumbnail
	summonables_parent.add_child(summoning_circle)


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
	can_summon = true
	if animation_state == AnimationState.ATTACKING:
		animation_state = AnimationState.IDLE


func _on_pathfinding_timer_timeout():
	if animation_state != AnimationState.DYING:
		make_path()


func _on_animation_timer_timeout():
	animate_with_animations()


func animate_with_animations():
	var animation_name = animation_to_name[animation_state]
	
	if animation_state == AnimationState.MOVING:
		if moving_y:
			animation_name += "_y"
		elif moving_left:
			animation_name += "_left"
		else:
			animation_name += "_right"
	
	if animated_sprite2d.animation != animation_name:
		animated_sprite2d.play(animation_name)


func _on_death_timer_timeout():
	get_tree().change_scene_to_packed(credits_scene)


func _on_death():
	if animation_state != AnimationState.DYING:
		$CollisionShape2D.set_deferred("disabled", true)
		animation_state = AnimationState.DYING
		$DeathTimer.start()
		boss_bar.hide()


func _on_health_health_changed(from, to):
	if from > to:
		shader.set_shader_parameter("flash_red", true)
		$RedFlashTimer.start()
	boss_bar.value = to

func _on_red_flash_timer_timeout():
	shader.set_shader_parameter("flash_red", false)
