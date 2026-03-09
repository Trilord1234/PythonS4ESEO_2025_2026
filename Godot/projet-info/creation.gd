extends Node2D

var planet_manager = preload("res://planete_manager.tscn")
var count = 0

func _ready() :
	randomize()

func _on_generation_pressed():
	count += 1
	$"Background Manager/Info/Nb/NbPLanet".text = "NB Planet = " + str(count)
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
	$"Background Manager/Info/Nb/NbPLanet".text = "NB Planet = " + str(count)
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
	var planet_picture = $"Background Manager/Info/InfoBox/PlanetVisual/PlanetPicture"
	planet_picture.texture = targeted_planet.get_node("Planet").texture
	planet_picture.self_modulate = targeted_planet.get_node("Planet").self_modulate
	var layer_picture = $"Background Manager/Info/InfoBox/PlanetVisual/LayerPicture"
	layer_picture.texture = targeted_planet.get_node("Layer").texture
	layer_picture.self_modulate = targeted_planet.get_node("Layer").self_modulate
	$"Background Manager/Info/InfoBox/Label/Description".text = targeted_planet.prompt_IA
	
	if targeted_planet.donnees_ia_sauvegardees != null:
		$"Background Manager/Info/InfoBox/Label/Name".text = targeted_planet.donnees_ia_sauvegardees["name"]
		$"Background Manager/Info/InfoBox/Label/Type".text = "Type : " + str(targeted_planet.donnees_ia_sauvegardees["type"])
		$"Background Manager/Info/InfoBox/Label/Weight".text = "Poids : " + str(targeted_planet.donnees_ia_sauvegardees["weight"])
		$"Background Manager/Info/InfoBox/Label/Size".text = "Taille : " + str(targeted_planet.donnees_ia_sauvegardees["size"])
		$"Background Manager/Info/InfoBox/Label/Gravity".text = "Gravité : " + str(targeted_planet.donnees_ia_sauvegardees["gravity"])
		$"Background Manager/Info/InfoBox/Label/Habitable".text = "Habitable : " + str(targeted_planet.donnees_ia_sauvegardees["habitable"])
		$"Background Manager/Info/InfoBox/Label/Level of danger".text = "Dangerosité : " + str(targeted_planet.donnees_ia_sauvegardees["level of danger"])
		$"Background Manager/Info/InfoBox/Label/Description".text = str(targeted_planet.donnees_ia_sauvegardees["description"])
	else:
		$"Background Manager/Info/InfoBox/Label/Name".text = "Analyse en cours..."
		$"Background Manager/Info/InfoBox/Label/Type".text = "Type : ..."
		$"Background Manager/Info/InfoBox/Label/Weight".text = "Poids : ..."
		$"Background Manager/Info/InfoBox/Label/Size".text = "Taille : ..."
		$"Background Manager/Info/InfoBox/Label/Gravity".text = "Gravité : ..."
		$"Background Manager/Info/InfoBox/Label/Habitable".text = "Habitable : ..."
		$"Background Manager/Info/InfoBox/Label/Level of danger".text = "Dangerosité : ..."
		$"Background Manager/Info/InfoBox/Label/Description".text = "Tako analyse l'atmosphère... Reclique dans un instant !"
