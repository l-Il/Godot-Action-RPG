extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 60
export var ROLL_SPEED = 75
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animation_Player = $AnimationPlayer
onready var animation_Tree = $AnimationTree
onready var animation_State = animation_Tree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

func _ready():
	animation_Tree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animation_Tree.set("parameters/Idle/blend_position", input_vector)
		animation_Tree.set("parameters/Run/blend_position", input_vector)
		animation_Tree.set("parameters/Attack/blend_position", input_vector)
		animation_Tree.set("parameters/Roll/blend_position", input_vector)
		animation_State.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_State.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()

	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animation_State.travel("Roll")
	move()

func attack_state(delta):
	velocity = Vector2.ZERO
	animation_State.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity / 2
	state = MOVE

func attack_animation_finished():
	state = MOVE
