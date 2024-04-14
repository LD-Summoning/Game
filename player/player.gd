extends CharacterBody2D

enum AnimationStates {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	IDLE
}

enum Direction{
	UP,
	UP_RIGHT,
	RIGHT,
	DOWN_RIGHT,
	DOWN,
	DOWN_LEFT,
	LEFT,
	UP_LEFT
}

@export var speed = 90
@export var roll_speed = 200
@export var roll_time = 0.5
@export var roll_cooldown = 0.8
@export var attack_cooldown = 0.5
@export var attack_time = 0.3
@export var attack_update_time = 0.025
@export var swipe_angle = deg_to_rad(135)
@export var melee_damage = 10


@onready var _animation = $PlayerSprite
@onready var _health = $Health
@onready var _roll_timer = $RollTimer
@onready var _roll_cooldown_timer = $RollCooldown
@onready var _attack_cooldown_timer = $AttackCooldownTimer
@onready var _attack_timer = $AttackTimer
@onready var _attack_anchor = $AttackAnchor
@onready var _attack_update_timer = $AttackUpdateTimer
@onready var _attack_area = $AttackAnchor/AttackArea

var state: AnimationStates = AnimationStates.IDLE
var rolling = false
var can_roll = true
var roll_direction_vector
var attacking = false
var can_attack = true
var attack_hit_targets

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	if rolling:
		velocity = roll_direction_vector * roll_speed
	else: 
		get_input()
	move_and_slide()

# Called when the node enters the scene tree for the first time.
func _ready():
	_animation.play("idle")



# Attacking


const attack_anchor_distance = 6
func attack():
	var attack_direction = Vector2.RIGHT.angle_to(get_local_mouse_position())
	attack_hit_targets = []
	_attack_timer.start(attack_time)
	_attack_update_timer.start(attack_update_time)
	_attack_cooldown_timer.start(attack_cooldown)
	attacking = true
	can_attack = false
	_attack_anchor.visible = true
	_attack_anchor.rotation = attack_direction - swipe_angle/2
	_attack_area.set_collision_mask_value(3, true)


func _on_attack_update_timer_timeout():
	_attack_anchor.rotation += swipe_angle * attack_update_time / attack_time


func _on_attack_area_body_entered(body):
	if attack_hit_targets.find(body) < 0:
		attack_hit_targets.push_back(body)


func stop_attack():
	_attack_update_timer.stop()
	_attack_anchor.visible = false
	attacking = false
	_attack_area.set_collision_mask_value(3, false)
	for body in attack_hit_targets:
		if body.has_node("Health"):
			body.get_node("Health").signal_damage(melee_damage)


func _on_attack_timer_timeout():
	stop_attack()


func _on_attack_cooldown_timer_timeout():
	can_attack = true



# Rolling


func roll_direction_map(roll_direction: Direction) -> StringName:
	match roll_direction:
		Direction.UP: return "rolling_up"
		Direction.DOWN: return "rolling_down"
		Direction.LEFT, Direction.UP_LEFT, Direction.DOWN_LEFT: return "rolling_left"
		Direction.RIGHT, Direction.DOWN_RIGHT, Direction. UP_RIGHT: return "rolling_right"
	return "rolling_left"


func get_move_direction() -> Direction:
	if Input.is_action_pressed("up"):
		if Input.is_action_pressed("right"):
			return Direction.UP_RIGHT
		elif Input.is_action_pressed("left"):
			return Direction.UP_LEFT
		else:
			return Direction.UP
	elif Input.is_action_pressed("down"):
		if Input.is_action_pressed("right"):
			return Direction.DOWN_RIGHT
		elif Input.is_action_pressed("left"):
			return Direction.DOWN_LEFT
		else:
			return Direction.DOWN
	elif Input.is_action_pressed("right"):
		return Direction.RIGHT
	else:
		return Direction.LEFT


func roll():
	_health.add_invinicibility()
	var roll_direction = get_move_direction()
	roll_direction_vector = Input.get_vector("left", "right", "up", "down")
	rolling = true
	can_roll = false
	_animation.stop()
	_animation.play(roll_direction_map(roll_direction))
	_roll_timer.start(roll_time)
	_roll_cooldown_timer.start(roll_cooldown)
	set_collision_mask_value(3, false)
	set_collision_mask_value(4, false)
	set_collision_layer_value(1, false)


func _on_roll_timer_timeout():
	rolling = false
	_health.revoke_invincibility()
	update_animationState()
	_animation.stop()
	_animation.play(animationStateMap(state))
	set_collision_mask_value(3, true)
	set_collision_mask_value(4, true)
	set_collision_layer_value(1, true)


func _on_roll_cooldown_timeout():
	can_roll = true



# Animations


func animationStateMap(state: AnimationStates) -> StringName:
	match state:
		AnimationStates.LEFT: return "left_walk"
		AnimationStates.RIGHT: return "right_walk"
		AnimationStates.UP: return "up_walk"
		AnimationStates.DOWN: return "down_walk"
		_: return "idle"


func actionStateMap(action: StringName) -> AnimationStates:
	match action:
		"left": return AnimationStates.LEFT
		"right": return AnimationStates.RIGHT
		"up": return AnimationStates.UP
		"down": return AnimationStates.DOWN
		_: return AnimationStates.IDLE


func changeAnimationState(action: StringName):
	var animation = actionStateMap(action)
	state = animation
	_animation.stop()
	_animation.play(animationStateMap(animation))


func update_animationState():
	if Input.is_action_pressed("down"):
		state = AnimationStates.DOWN
	elif Input.is_action_pressed("right"):
		state = AnimationStates.RIGHT
	elif Input.is_action_pressed("up"):
		state = AnimationStates.UP
	elif Input.is_action_pressed("left"):
		state = AnimationStates.LEFT
	else:
		state = AnimationStates.IDLE


func _input(event):
	if rolling:
		return
	elif event.is_action_pressed("roll") and can_roll and state != AnimationStates.IDLE:
		roll()
		return
	elif can_attack and !attacking and event.is_action_pressed("attack"):
		attack()
	match state:
		AnimationStates.IDLE:
			if event.is_action_pressed("down"):
				changeAnimationState("down")
			elif event.is_action_pressed("right"):
				changeAnimationState("right")
			elif event.is_action_pressed("up"):
				changeAnimationState("up")
			elif event.is_action_pressed("left"):
				changeAnimationState("left")
		AnimationStates.DOWN:
			if event.is_action_released("down"):
				if !Input.is_anything_pressed():
					changeAnimationState("idle")
				elif Input.is_action_pressed("right"):
					changeAnimationState("right")
				elif Input.is_action_pressed("up"):
					changeAnimationState("up")
				elif Input.is_action_pressed("left"):
					changeAnimationState("left")
				else:
					changeAnimationState("idle")
		AnimationStates.RIGHT:
			if event.is_action_pressed("down"):
				changeAnimationState("down")
			elif event.is_action_released("right"):
				if !Input.is_anything_pressed():
					changeAnimationState("idle")
				elif Input.is_action_pressed("up"):
					changeAnimationState("up")
				elif Input.is_action_pressed("left"):
					changeAnimationState("left")
				else:
					changeAnimationState("idle")
		AnimationStates.UP:
			if event.is_action_pressed("down"):
				changeAnimationState("down")
			elif event.is_action_pressed("right"):
				changeAnimationState("right")
			elif event.is_action_released("up"):
				if !Input.is_anything_pressed():
					changeAnimationState("idle")
				elif Input.is_action_pressed("left"):
					changeAnimationState("left")
				else:
					changeAnimationState("idle")
		AnimationStates.LEFT:
			if event.is_action("down"):
				changeAnimationState("down")
			elif event.is_action_pressed("right"):
				changeAnimationState("right")
			elif event.is_action_pressed("up"):
				changeAnimationState("up")
			elif event.is_action_released("left"):
				changeAnimationState("idle")



# Processing

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

