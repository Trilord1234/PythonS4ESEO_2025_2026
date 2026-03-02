extends Node2D

var planet_manager = preload("res://planete_manager.tscn")
var count = 0

func _ready() :
	randomize()

func _on_generation_pressed():
	count += 1
	$"Background Manager/Info/NbPLanet".text = "NB Planet = " + str(count)
	var new_planet = planet_manager.instantiate()
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	new_planet.limit_x = box.size.x
	new_planet.limit_y = box.size.y
	new_planet.movement = Vector2(
		randf_range(100,box.size.x - 100),
		randf_range(100,box.size.y - 100)
	)
	box.add_child(new_planet)

func _on_clear_pressed():
	count = 0
	$"Background Manager/Info/NbPLanet".text = "NB Planet = " + str(count)
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	for child in box.get_children():
		child.queue_free()
