extends Node2D

var current_planet = ""
var planet_position = {}

@onready var line_folder = Node2D.new()
@onready var planet_folder = Node2D.new()

func _ready():
	if GlobalData.universe.is_empty():
		print("L'univers est vide")
		return
	add_child(line_folder)
	add_child(planet_folder)
	current_planet = GlobalData.universe.keys().pick_random()
	get_planet_map(current_planet)

func get_planet_map(planet_name) :
	var url = "http://127.0.0.1:8000/radar"
	var headers = ["Content-Type: application/json"]
	var data = JSON.stringify({"planet": planet_name})
	
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(func(_result, _code, _headers, _body):
		request.queue_free()
		var json = JSON.new()
		if json.parse(_body.get_string_from_utf8()) == OK:
			build_planet_map(json.get_data())
	)
	request.request(url, headers, HTTPClient.METHOD_POST, data)

func build_planet_map(data):
	planet_position.clear()
	for child in line_folder.get_children(): child.queue_free()
	for child in planet_folder.get_children(): child.queue_free()
	
	var box = $"Background Manager/Box Manager/BoxExploration/HitBox_BoxExploration"
	var left_border = box.global_position.x
	var width_border = box.size.x
	var right_border = left_border + width_border
	var up_border = box.global_position.y
	var height_border = box.size.y
	var down_border = up_border + height_border
	var box_border = {
		"0" : {"y" : down_border - (height_border*0.15), "scale" : 2.5},
		"1" : {"y" : down_border - (height_border*0.45), "scale" : 1.7},
		"2" : {"y" : down_border - (height_border*0.70), "scale" : 1.2},
		"3" : {"y" : up_border + (height_border*0.10), "scale" : 0.6},
	}
	var rank = data["rank"]
	for depth in ["0","1","2","3"] :
		if rank.has(depth) and rank[depth].size() > 0 :
			var liste = rank[depth]
			var nb_planet = liste.size()
			var distance_btw_planet = width_border / nb_planet
			for i in range(nb_planet):
				var planet_name = liste[i]
				if not GlobalData.universe.has(planet_name): continue
				var x_location = 0
				if depth == "0":
					x_location = left_border + (width_border/2)
				else :
					var min_x = left_border + (i * distance_btw_planet) + 40
					var max_x = left_border + ((i+1) * distance_btw_planet) -40
					x_location = randf_range(min_x, max_x)
				var coordinates = Vector2(x_location, box_border[depth]["y"])
				planet_position[planet_name] = coordinates
				var noeud = create_visual_map(planet_name, box_border[depth]["scale"])
				noeud.position = coordinates
				planet_folder.add_child(noeud)
	var link = data["link"]
	for family in link :
		var parent = family[0]
		var child = family[1]
		if planet_position.has(parent) and planet_position.has(child):
			var line = Line2D.new()
			line.add_point(planet_position[parent])
			line.add_point(planet_position[child])
			line.width = 3
			line.default_color = Color(0.2, 0.6, 1.0, 0.6)
			line_folder.add_child(line)

func create_visual_map(planet_name, size):
	var data = GlobalData.universe[planet_name]
	var visual = Node2D.new()
	visual.scale = Vector2(size, size)
	var planet = Sprite2D.new()
	planet.texture = data["planet_texture"]
	planet.self_modulate = data["planet_color"]
	var layer = Sprite2D.new()
	layer.texture = data["layer_texture"]
	layer.self_modulate = data["layer_color"]
	visual.add_child(planet)
	visual.add_child(layer)
	var btn = Button.new()
	btn.flat = true
	btn.custom_minimum_size = Vector2(100,100)
	btn.position = Vector2(-50,-50)
	btn.pressed.connect(func(): planet_exploration(planet_name))
	visual.add_child(btn)
	return visual

func planet_exploration(destination_name):
	current_planet = destination_name
	print("On se déplace en: " + destination_name)
	get_planet_map(current_planet)
