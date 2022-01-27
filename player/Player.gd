extends KinematicBody2D

onready var sprite = $Sprite
onready var anim = $anim.get("parameters/playback")

var velocity := Vector2.ZERO

var maxSpeed := 70
export var step := 210

var gravitation := 180
var maxGravitation := 270

export var jumpHeight := -90
export var dashForce := 130

export var dashing := false
var grounded := false
var secondJump := false
var canDash := true
var firstButton := ""

func update_gronded():
	var bodies = get_node("collider/feets").get_overlapping_bodies()
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
		dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if dir == Vector2.ZERO || (dir.y > 0 && grounded && dir.x == 0):
		print("cancled")
		$dashTimer.stop()
		canDash = true
	else:
		if dir.y > 0 && grounded:
			dir.y = 0

		if velocity.y < -50:
			print(velocity.y)
			velocity.y += abs(velocity.y)-abs(velocity.y)*0.17
			print(velocity.y)

		if abs(dir.y) + abs(dir.x) > 1.4:
			velocity += dashForce * dir.normalized()
		else:
			velocity += dashForce * dir

			print("dashed")

func _process(delta):
	$trail.draw = abs(velocity.x) > maxSpeed*1.05 || velocity.y < jumpHeight
	update_gronded()

	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

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

	velocity = move_and_slide(velocity)

	if dir == 1:
		sprite.set_flip_h(false)
		$collider.position.x = 0
	elif dir == -1:
		sprite.set_flip_h(true)
		$collider.position.x = 1

	if $trail.get_point_count() > 0 || $trail.draw || dashing:
		anim.travel("dash")
	elif velocity.y > 1 && !grounded:
		anim.travel("fall")
	elif velocity.x != 0 && grounded:
		anim.travel("run")
	elif velocity == Vector2.ZERO && grounded:
		anim.travel("idle")

	if Input.is_action_pressed("ui_right") && (firstButton == "" || firstButton == "right"):
		firstButton = "right"
	elif Input.is_action_pressed("ui_left") && (firstButton == "" || firstButton == "left"):
		firstButton = "left"
	else:
		firstButton = ""

func _on_dashTimer_timeout():
	print("ready")
	canDash = true
