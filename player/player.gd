extends CharacterBody2D

enum AnimationStates {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	ROLLING,
	IDLE
}

@export var speed = 90
@onready var _animation = $AnimatedSprite2D
var state: AnimationStates = AnimationStates.IDLE

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	get_input()
	move_and_slide()

# Called when the node enters the scene tree for the first time.
func _ready():
	_animation.play("idle")


func _input(event):
	match state:
		AnimationStates.IDLE:
			if event.is_action_pressed("down"):
				state= AnimationStates.DOWN
				_animation.stop()
				_animation.play("down_walk")
			elif event.is_action_pressed("right"):
				state = AnimationStates.RIGHT
				_animation.stop()
				_animation.play("right_walk")
			elif event.is_action_pressed("up"):
				state = AnimationStates.UP
				_animation.stop()
				_animation.play("up_walk")
			elif event.is_action_pressed("left"):
				state = AnimationStates.LEFT
				_animation.stop()
				_animation.play("left_walk")
			
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
