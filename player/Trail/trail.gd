extends Line2D

export var length = 30
var point := Vector2.ZERO
var draw := false
var time := 0.0


func _process(delta):
	time += delta
	if !draw:
		if get_point_count() > 0 && time > 0.005: # every 0.005 seconds
			remove_point(0)
			time = 0
		return
	global_position = Vector2.ZERO
	global_rotation = 0

	point = get_parent().global_position
	point.y += 2

	add_point(point)
	while get_point_count() > length:
		remove_point(0)
