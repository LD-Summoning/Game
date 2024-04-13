extends CharacterBody2D


@export var speed = 125
@export var damage = 10

@onready var player = get_parent().get_parent().get_parent().get_node("Player")
@onready var agent = $NavigationAgent2D
@onready var sprite = $Sprite2D
@onready var attack_timer = $AttackTimer
@onready var target_area = $TargetArea

var active = false
var attack_in_progress = false

# Called when the node enters the scene tree for the first time.
func _physics_process(_delta):
	
	velocity = Vector2.ZERO
	if !attack_in_progress:
		if active:
			var next_path_pos = agent.get_next_path_position()
			var direction = global_position.direction_to(next_path_pos)
			velocity = direction * speed
		if (position - player.position).length_squared() < 20*20:
			attack_in_progress = true
			sprite.frame = 1
			attack_timer.start()
			target_area.rotate(Vector2.RIGHT.angle_to(position.direction_to(player.position)))
	move_and_slide()


func make_path():
	var target_position = player.position
	if (target_position - global_position).length_squared() > 20*20:
		agent.target_position = target_position
		active = true
	else:
		active = false


func _on_pathfinding_timer_timeout():
	if !attack_in_progress:
		make_path()


func _on_attack_timer_timeout():
	attack_in_progress = false
	sprite.frame = 0
	target_area.rotation_degrees = 0
	for body in target_area.get_overlapping_bodies():
		if body.has_node("Health"):
			body.get_node("Health").signal_damage(damage)
