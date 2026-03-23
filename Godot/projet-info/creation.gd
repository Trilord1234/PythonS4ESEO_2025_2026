extends Node2D

var planet_manager = preload("res://planete_manager.tscn")
var count = 0
var planet_selected = null
var line_created = []

func _ready() :
	$"Button Manager/Delete".visible = false
	randomize()

func _process(_delta):
	for dic in line_created :
		var L = dic["Line"]
		var PA = dic["Planet_A"]
		var PB = dic["Planet_B"]
		if is_instance_valid(L) and is_instance_valid(PA) and is_instance_valid(PB):
			var center_A = PA.position + Vector2(32, 32)
			var center_B = PB.position + Vector2(32, 32)
			L.set_point_position(0, center_A)
			L.set_point_position(1, center_B)

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
	planet_selected = targeted_planet
	
	var menu_link = $Info/InfoBox/LinkMenu
	if menu_link.open == true:
		menu_link.LinkMenuReload(targeted_planet)
	var planet_picture = $Info/InfoBox/PlanetVisual/PlanetPicture
	planet_picture.texture = targeted_planet.get_node("Planet").texture
	planet_picture.self_modulate = targeted_planet.get_node("Planet").self_modulate
	var layer_picture = $Info/InfoBox/PlanetVisual/LayerPicture
	layer_picture.texture = targeted_planet.get_node("Layer").texture
	layer_picture.self_modulate = targeted_planet.get_node("Layer").self_modulate
	$"Info/InfoBox/Label/ScrollContainer/Description".text = targeted_planet.prompt_IA
	$"Button Manager/Delete".visible = true
	if targeted_planet.data_IA_save != null:
		$"Info/InfoBox/Label/Name".text = targeted_planet.data_IA_save["name"]
		$"Info/InfoBox/Label/Type".text = "Type : " + str(targeted_planet.data_IA_save["type"])
		$"Info/InfoBox/Label/Weight".text = "Poids : " + str(targeted_planet.data_IA_save["weight"])
		$"Info/InfoBox/Label/Size".text = "Taille : " + str(targeted_planet.data_IA_save["size"])
		$"Info/InfoBox/Label/Gravity".text = "Gravité : " + str(targeted_planet.data_IA_save["gravity"])
		$"Info/InfoBox/Label/Habitable".text = "Habitable : " + str(targeted_planet.data_IA_save["habitable"])
		$"Info/InfoBox/Label/Level of danger".text = "Dangerosité : " + str(targeted_planet.data_IA_save["level of danger"])
		$"Info/InfoBox/Label/ScrollContainer/Description".text = str(targeted_planet.data_IA_save["description"])
		var planet_name = targeted_planet.data_IA_save["name"]
		var url = "http://127.0.0.1:8000/neighbors"
		var header = ["Content-Type: application/json"]
		var data = JSON.stringify({"planet": planet_name})
		var neighbors = HTTPRequest.new()
		add_child(neighbors)
		neighbors.request_completed.connect(func(_result, _response_code, _headers, _body):
			var json = JSON.new()
			var error = json.parse(_body.get_string_from_utf8())
			if error == OK:
				var reponse = json.get_data()
				if reponse.has("neighbors") and reponse["neighbors"].size() > 0:
					var neighbors_list = ", ".join(reponse["neighbors"])
					$"Info/InfoBox/Label/ScrollContainer/Description".text += "\n\nReliée à : " + neighbors_list
			neighbors.queue_free()
			)
		 
		neighbors.request(url, header, HTTPClient.METHOD_POST, data)
	else:
		$"Info/InfoBox/Label/Name".text = "Analyse en cours..."
		$"Info/InfoBox/Label/Type".text = "Type : ..."
		$"Info/InfoBox/Label/Weight".text = "Poids : ..."
		$"Info/InfoBox/Label/Size".text = "Taille : ..."
		$"Info/InfoBox/Label/Gravity".text = "Gravité : ..."
		$"Info/InfoBox/Label/Habitable".text = "Habitable : ..."
		$"Info/InfoBox/Label/Level of danger".text = "Dangerosité : ..."
		$"Info/InfoBox/Label/ScrollContainer/Description".text = "Tako analyse l'atmosphère... Reclique dans un instant !"

func create_line (planet_A, planet_B):
	var line = Line2D.new()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	line.width = 4
	line.default_color = Color(0.2,0.6,1.0,0.7)
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	box.add_child(line)
	box.move_child(line, 0)
	line_created.append({"Line": line, "Planet_A": planet_A, "Planet_B": planet_B})
	var name_planet_A = planet_A.data_IA_save["name"]
	var name_planet_B = planet_B.data_IA_save["name"]
	var url = "http://127.0.0.1:8000/link"
	var header = ["Content-Type: application/json"]
	var data = JSON.stringify({"planet_A": name_planet_A, "planet_B": name_planet_B})
	var requeste_link = HTTPRequest.new()
	add_child(requeste_link)
	requeste_link.request_completed.connect(func(_result, _response_code, _headers, _body): 
		requeste_link.queue_free()
		if planet_selected != null:
			if planet_selected == planet_A or planet_selected == planet_B:
				_on_planet_selected(planet_selected)
	)
	requeste_link.request(url, header, HTTPClient.METHOD_POST, data)

func _on_delete_pressed():
	if planet_selected == null:
		return
	count -= 1
	$"Info/Nb/NbPLanet".text = "NB Planet = " + str(count)
	for i in range(line_created.size() - 1, -1, -1):
		var dict = line_created[i]
		if dict["Planet_A"] == planet_selected or dict["Planet_B"] == planet_selected:
			dict["Line"].queue_free() 
			line_created.remove_at(i) 
	planet_selected.queue_free()
	planet_selected = null
	$"Info/InfoBox/Label/Name".text = "Planète supprimée."
	$"Info/InfoBox/Label/Type".text = ""
	$"Info/InfoBox/Label/ScrollContainer/Description".text = ""
	$Info/InfoBox/Label/Type.text = ""
	$Info/InfoBox/Label/Weight.text = ""
	$Info/InfoBox/Label/Size.text = ""
	$Info/InfoBox/Label/Gravity.text = ""
	$Info/InfoBox/Label/Habitable.text = ""
	$"Info/InfoBox/Label/Level of danger".text = ""
	

func _on_delete_link_pressed():
	if planet_selected == null:
		return
	
	
	for i in range(line_created.size() - 1, -1, -1):
		var dict = line_created[i]
		if dict["Planet_A"] == planet_selected or dict["Planet_B"] == planet_selected:
			dict["Line"].queue_free() 
			line_created.remove_at(i)
