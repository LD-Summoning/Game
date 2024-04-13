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
@export var roll_cooldown = 1

@onready var _animation = $AnimatedSprite2D
@onready var _health = $Health
@onready var _roll_timer = $RollTimer
@onready var _roll_cooldown_timer = $RollCooldown

var state: AnimationStates = AnimationStates.IDLE
var rolling = false
var can_roll = true
var roll_direction_vector

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
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
