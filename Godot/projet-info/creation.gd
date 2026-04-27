extends Node2D

var planet_manager = preload("res://planete_manager.tscn")
var count = 0
var planet_selected = null
var line_created = []
@onready var btn_load_json = $"Button Manager/LoadJSON"

func _ready() :
	$"Button Manager/Delete".visible = false
	if btn_load_json:
		btn_load_json.pressed.connect(_on_load_json_pressed)
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
	GlobalData.erase_python_memory()


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
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Type.text = "Type : " + str(targeted_planet.data_IA_save["type"])
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Weight.text = "Poids : " + str(targeted_planet.data_IA_save["weight"])
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Size.text = "Taille : " + str(targeted_planet.data_IA_save["size"])
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Gravity.text = "Gravité : " + str(targeted_planet.data_IA_save["gravity"])
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Habitable.text = "Habitable : " + str(targeted_planet.data_IA_save["habitable"])
		$"Info/InfoBox/Label/LabelScroll/LabelContainer/Level of danger".text = "Dangerosité : " + str(targeted_planet.data_IA_save["level of danger"])
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
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Type.text = "Type : ..."
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Weight.text = "Poids : ..."
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Size.text = "Taille : ..."
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Gravity.text = "Gravité : ..."
		$Info/InfoBox/Label/LabelScroll/LabelContainer/Habitable.text = "Habitable : ..."
		$"Info/InfoBox/Label/LabelScroll/LabelContainer/Level of danger".text = "Dangerosité : ..."
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

func delete_line(link):
	link["Line"].queue_free()
	line_created.erase(link)
	var url = "http://127.0.0.1:8000/unlink"
	var header = ["Content-Type: application/json"]
	var data = JSON.stringify({"planet_A": link["Planet_A"].data_IA_save["name"], "planet_B": link["Planet_B"].data_IA_save["name"]})
	var request_link = HTTPRequest.new()
	add_child(request_link)
	request_link.request_completed.connect(func(_result, _response_code, _headers, _body):
		request_link.queue_free()
		if planet_selected != null:
			if planet_selected == link["Planet_A"] or planet_selected == link["Planet_B"]:
				_on_planet_selected(planet_selected)
	)
	request_link.request(url, header, HTTPClient.METHOD_POST, data)

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
	$Info/InfoBox/Label/LabelScroll/LabelContainer/Type.text = ""
	$"Info/InfoBox/Label/ScrollContainer/Description".text = ""
	$"Info/InfoBox/Label/ScrollContainer/Description".text = ""
	$Info/InfoBox/Label/LabelScroll/LabelContainer/Weight.text = ""
	$Info/InfoBox/Label/LabelScroll/LabelContainer/Size.text = ""
	$Info/InfoBox/Label/LabelScroll/LabelContainer/Gravity.text = ""
	$Info/InfoBox/Label/LabelScroll/LabelContainer/Habitable.text = ""
	$"Info/InfoBox/Label/LabelScroll/LabelContainer/Level of danger".text = ""

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://exploration.tscn")

func _on_delete_all_link_pressed():
	for i in range(line_created.size() - 1, -1, -1):
		var dict = line_created[i]
		if dict["Planet_A"] == planet_selected or dict["Planet_B"] == planet_selected:
			dict["Line"].queue_free() 
			line_created.remove_at(i)

func _on_load_json_pressed() -> void:
	_on_clear_pressed()
	var url = "http://127.0.0.1:8000/get_graph"
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(func(_result, response_code, _headers, _body):
		request.queue_free()
		if response_code == 200:
			var json_data = JSON.parse_string(_body.get_string_from_utf8())
			if json_data:
				recreer_univers(json_data)
			else:
				print("Erreur JSON vide")
		else:
			print("Erreur : Impossible de charger le JSON (Code: ", response_code, ")")
	)
	request.request(url, [], HTTPClient.METHOD_GET)

func recreer_univers(data: Dictionary):
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	for p_name in data.keys():
		var p_data = data[p_name]
		var new_planet = planet_manager.instantiate()
		new_planet.is_loaded_from_save = true
		count += 1
		var look = p_data.get("look", {})
		var p_path = look.get("planet", "none")
		if p_path != "none" and p_path != "":
			new_planet.get_node("Planet").texture = load(p_path)
		var l_path = look.get("layer", "none")
		if l_path != "none" and l_path != "":
			new_planet.get_node("Layer").texture = load(l_path)
		new_planet.get_node("Planet").self_modulate = Color.from_string(look.get("planet_color", "#ffffff"), Color.WHITE)
		new_planet.get_node("Layer").self_modulate = Color.from_string(look.get("layer_color", "#ffffff"), Color.WHITE)
		new_planet.data_IA_save = p_data.get("caractéristiques", {})
		new_planet.limit_x = box.size.x
		new_planet.limit_y = box.size.y
		new_planet.position = Vector2(randf_range(100, box.size.x - 100), randf_range(100, box.size.y - 100))
		new_planet.planet_selected.connect(_on_planet_selected)
		box.add_child(new_planet)
		GlobalData.universe[p_name] = {
			"planet_texture": new_planet.get_node("Planet").texture,
			"planet_color": new_planet.get_node("Planet").self_modulate,
			"layer_texture": new_planet.get_node("Layer").texture,
			"layer_color": new_planet.get_node("Layer").self_modulate,
			"IA_data": new_planet.data_IA_save,
			"node_reference": new_planet
		}
	var liens_deja_faits = []
	for p_name in data.keys():
		var voisins = data[p_name].get("voisins", [])
		for voisin_name in voisins:
			var lien_id = [p_name, voisin_name]
			lien_id.sort()
			if not liens_deja_faits.has(lien_id):
				liens_deja_faits.append(lien_id)
				var planet_A_node = GlobalData.universe[p_name]["node_reference"]
				var planet_B_node = GlobalData.universe[voisin_name]["node_reference"]
				create_line(planet_A_node, planet_B_node)
	$Info/Nb/NbPLanet.text = "NB Planet = " + str(count)
	print("Univers rechargé avec succès !")
