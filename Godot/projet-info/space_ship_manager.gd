extends Node2D

@onready var spaceship = $"."
@onready var box = $"../Background Manager/Box Manager/BoxExploration/HitBox_BoxExploration"
var targeted_position = Vector2.ZERO

func _ready():
	targeted_position = spaceship.global_position

func _process(delta):
	if not is_instance_valid(spaceship) or not is_instance_valid(box):
		return
	var cursor_position = get_global_mouse_position()
	var box_hitbox = Rect2(box.global_position, box.size)
	if box_hitbox.has_point(cursor_position):
		targeted_position = cursor_position
	var last_x = spaceship.global_position.x
	spaceship.global_position = spaceship.global_position.lerp(targeted_position, 5*delta)
	var left_wall = box.global_position.x + 36
	var right_wall = box.global_position.x + box.size.x - 36
	var up_wall = box.global_position.y + 40
	var down_wall = box.global_position.y + box.size.y - 24
	spaceship.global_position.x = clamp(spaceship.global_position.x, left_wall, right_wall)
	spaceship.global_position.y = clamp(spaceship.global_position.y, up_wall, down_wall)
	var targeted_rotation = 0
	var speed_spaceship = spaceship.global_position.x - last_x
	if abs(speed_spaceship) > 0.1 :
		targeted_rotation = clamp(speed_spaceship * 0.05, -0.5, 0.5)
	spaceship.rotation = lerp_angle(spaceship.rotation, targeted_rotation, 8*delta)
