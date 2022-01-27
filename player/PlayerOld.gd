extends KinematicBody2D

onready var anim = $anim

var velocity := Vector2.ZERO

var maxSpeed := 70
export var step := 210

var gravitation := 175
var maxGravitation := 250

export var jumpHeight := -90
export var dashForce := 121

var grounded := false
var secondJump := false
var canDash := true
var firstButton := ""

func _ready():
	OS.window_fullscreen = !OS.is_debug_build()

func update_gronded():
	var bodies = $feets.get_overlapping_bodies()
	var touchingGround := false
	for body in bodies:
		if body.is_in_group("ground"):
			touchingGround = true
			secondJump = true
			break

	grounded = touchingGround

func jump():
	velocity.y = jumpHeight

func dash():
	canDash = false
	$dashTimer.start(2)
	var dir := Vector2.ZERO
	if firstButton == "left":
		dir.x = -1
	elif firstButton == "right":
		dir.x = 1
	else:
		dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))

	dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	if dir == Vector2.ZERO || (dir.y > 0 && grounded && dir.x == 0):
		print("cancled")
		$dashTimer.stop()
		canDash = true
	else:
		if dir.y > 0 && grounded:
			dir.y = 0
		print(dir.normalized())
		velocity += dashForce * dir.normalized()

func _process(delta):
	$trail.draw = abs(velocity.x) > maxSpeed*1.1 || velocity.y < jumpHeight

	var dir := 0

	if Input.is_action_pressed("ui_right") && firstButton != "left":
		dir = 1
	if Input.is_action_pressed("ui_left") && firstButton != "right":
		dir -= 1

	if Input.is_action_just_pressed("jump"):
		if grounded:
			jump()
		elif secondJump:
			jump()
			secondJump = false

	if Input.is_action_just_pressed("dash") && canDash:
		dash()

	velocity.x = move_toward(velocity.x, maxSpeed * dir, step * delta)
	velocity.y = move_toward(velocity.y, maxGravitation, gravitation * delta)

	if dir == 0:
		anim.play("idle")
	else:
		anim.play("run")

	if dir == 1:
		anim.set_flip_h(false)
	elif dir == -1:
		anim.set_flip_h(true)

	if Input.is_action_pressed("ui_right") && (firstButton == "" || firstButton == "right"):
		firstButton = "right"
	elif Input.is_action_pressed("ui_left") && (firstButton == "" || firstButton == "left"):
		firstButton = "left"
	else:
		firstButton = ""

	velocity = move_and_slide(velocity)


func _on_dashTimer_timeout():
	print("ready")
	canDash = true
