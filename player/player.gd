extends CharacterBody2D

enum AnimationStates {
	MOVING_LEFT,
	MOVING_RIGHT,
	MOVING_UP,
	MOVING_DOWN,
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
			pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
