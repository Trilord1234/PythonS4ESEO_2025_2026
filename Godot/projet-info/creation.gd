extends Node2D

var planet_manager = preload("res://planete_manager.tscn")
var count = 0

func _ready() :
	randomize()

func _on_generation_pressed():
	count += 1
	$Info/Nb/NbPLanet.text = "NB Planet = " + str(count)
	var new_planet = planet_manager.instantiate()
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	new_planet.limit_x = box.size.x
	new_planet.limit_y = box.size.y
	new_planet.movement = Vector2(
		randf_range(100,box.size.x - 100),
		randf_range(100,box.size.y - 100)
	)
	new_planet.planet_selected.connect(_on_planet_selected)
	box.add_child(new_planet)

func _on_clear_pressed():
	count = 0
	$"Info/Nb/NbPLanet".text = "NB Planet = " + str(count)
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	for child in box.get_children():
		child.queue_free()
	erase_IA_memory()

func erase_IA_memory():
	var url = "http://127.0.0.1:8000/clear"
	var entetes = ["Content-Type: application/json"]
	var requeste_clear = HTTPRequest.new()
	add_child(requeste_clear)
	requeste_clear.request_completed.connect(func(_result, _response_code, _headers, _body): requeste_clear.queue_free())
	requeste_clear.request(url, entetes, HTTPClient.METHOD_POST, "{}")

func _on_planet_selected(targeted_planet):
	var planet_picture = $Info/InfoBox/PlanetVisual/PlanetPicture
	planet_picture.texture = targeted_planet.get_node("Planet").texture
	planet_picture.self_modulate = targeted_planet.get_node("Planet").self_modulate
	var layer_picture = $Info/InfoBox/PlanetVisual/LayerPicture
	layer_picture.texture = targeted_planet.get_node("Layer").texture
	layer_picture.self_modulate = targeted_planet.get_node("Layer").self_modulate
	$"Info/InfoBox/Label/Description".text = targeted_planet.prompt_IA
	
	if targeted_planet.data_IA_save != null:
		$"Info/InfoBox/Label/Name".text = targeted_planet.data_IA_save["name"]
		$"Info/InfoBox/Label/Type".text = "Type : " + str(targeted_planet.data_IA_save["type"])
		$"Info/InfoBox/Label/Weight".text = "Poids : " + str(targeted_planet.data_IA_save["weight"])
		$"Info/InfoBox/Label/Size".text = "Taille : " + str(targeted_planet.data_IA_save["size"])
		$"Info/InfoBox/Label/Gravity".text = "Gravité : " + str(targeted_planet.data_IA_save["gravity"])
		$"Info/InfoBox/Label/Habitable".text = "Habitable : " + str(targeted_planet.data_IA_save["habitable"])
		$"Info/InfoBox/Label/Level of danger".text = "Dangerosité : " + str(targeted_planet.data_IA_save["level of danger"])
		$"Info/InfoBox/Label/Description".text = str(targeted_planet.data_IA_save["description"])
	else:
		$"Info/InfoBox/Label/Name".text = "Analyse en cours..."
		$"Info/InfoBox/Label/Type".text = "Type : ..."
		$"Info/InfoBox/Label/Weight".text = "Poids : ..."
		$"Info/InfoBox/Label/Size".text = "Taille : ..."
		$"Info/InfoBox/Label/Gravity".text = "Gravité : ..."
		$"Info/InfoBox/Label/Habitable".text = "Habitable : ..."
		$"Info/InfoBox/Label/Level of danger".text = "Dangerosité : ..."
		$"Info/InfoBox/Label/Description".text = "Tako analyse l'atmosphère... Reclique dans un instant !"
