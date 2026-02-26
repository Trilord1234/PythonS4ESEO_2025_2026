extends Node2D
var particule = preload("res://particule_manager.tscn")
var time = 0.0
var delay = 0.01

func _ready():
	$"Option Pop-up/OptionPopUp".visible = false

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Creation.tscn")

func _on_option_pressed():
	$"Option Pop-up/OptionPopUp".visible = true

func _on_back_pressed():
	$"Option Pop-up/OptionPopUp".visible = false

func _on_quit_pressed():
	get_tree().quit()

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		time += delta
		if time >= delay:
			var clone = particule.instantiate()
			clone.global_position = get_global_mouse_position()
			add_child(clone)
			time = 0.0
	else:
		time = delay
