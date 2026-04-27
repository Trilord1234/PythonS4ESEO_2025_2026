extends Node2D

var current_planet = ""
var planet_position = {}

@onready var line_folder = Node2D.new()
@onready var planet_folder = Node2D.new()

"""
Initialise la scène d'exploration et configure le point de départ du joueur.

Cette fonction s'exécute au chargement de la scène. Elle vérifie d'abord si
les données globales de l'univers ('GlobalData.universe') sont présentes. Si
l'univers contient des données, elle ajoute les conteneurs nécessaires à la scène,
sélectionne une planète de départ de manière aléatoire, puis déclenche la
préparation du scan et la génération de la carte pour cette planète spécifique.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func _ready():
	if GlobalData.universe.is_empty():
		print("L'univers est vide")
		return
	add_child(line_folder)
	add_child(planet_folder)
	current_planet = GlobalData.universe.keys().pick_random()
	$"Background Manager/Box Manager/BoxSpaceCommand".prepare_new_scan(current_planet)
	get_planet_map(current_planet)

"""
Récupère les données radar (ou carte locale) d'une planète spécifique via le serveur.

Cette fonction envoie une requête HTTP POST à l'API locale pour obtenir les informations
spatiales autour de la planète ciblée. Une fois la réponse reçue, elle libère le nœud
de requête, analyse le contenu JSON et, si les données sont valides, transmet le
résultat à la fonction 'build_planet_map()' pour générer l'affichage visuel.

Args:
planet_name (String): Le nom de la planète servant de point d'origine pour le scan radar.

Returns:
void : Ne retourne aucune valeur (le traitement des données est géré de manière asynchrone par un callback).
"""

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

"""
Génère et affiche la carte spatiale locale en simulant une perspective de profondeur.

Cette fonction nettoie d'abord la carte précédente. Elle utilise ensuite les données radar
pour positionner les planètes sur quatre niveaux de profondeur (0 à 3) à l'intérieur de
la zone d'exploration. Pour simuler l'éloignement, la taille et la luminosité des planètes
diminuent au fur et à mesure qu'elles sont loin. Enfin, elle trace les lignes de connexion
primaires et secondaires entre les planètes affichées.

Args:
data (Dictionary): Les données radar fournies par le serveur, contenant les planètes triées par rang de profondeur ('rank'), les liens principaux ('link') et potentiellement secondaires ('secondary_link').

Returns:
void : Ne retourne aucune valeur.
"""

func build_planet_map(data):
	planet_position.clear()
	for child in line_folder.get_children(): child.queue_free()
	for child in planet_folder.get_children(): child.queue_free()
	
	var box = $"Background Manager/Box Manager/BoxExploration/HitBox_BoxExploration"
	var left_border = box.global_position.x
	var width_border = box.size.x
	var _right_border = left_border + width_border
	var up_border = box.global_position.y
	var height_border = box.size.y
	var down_border = up_border + height_border
	var box_border = {
		"0" : {"y" : down_border - (height_border*0.15), "scale" : 3},
		"1" : {"y" : down_border - (height_border*0.45), "scale" : 2},
		"2" : {"y" : down_border - (height_border*0.70), "scale" : 1.4},
		"3" : {"y" : up_border + (height_border*0.10), "scale" : 0.8},
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
				var y_variation = 0
				if depth == "0":
					x_location = left_border + (width_border/2)
				else :
					var min_x = left_border + (i * distance_btw_planet) + 40
					var max_x = left_border + ((i+1) * distance_btw_planet) -40
					x_location = randf_range(min_x, max_x)
					y_variation = randf_range(-40,40)
				var coordinates = Vector2(x_location, box_border[depth]["y"] + y_variation)
				planet_position[planet_name] = coordinates
				var noeud = create_visual_map(planet_name, box_border[depth]["scale"])
				noeud.position = coordinates
				var depth_int = depth.to_int()
				var light = 1 - (depth_int*0.125)
				noeud.modulate = Color(light, light, light, 1)
				planet_folder.add_child(noeud)
	if data.has("secondary_link"):
		var secondary_link = data["secondary_link"]
		for family in secondary_link :
			var parent = family[0]
			var child = family[1]
			if planet_position.has(parent) and planet_position.has(child):
				var line = Line2D.new()
				line.add_point(planet_position[parent])
				line.add_point(planet_position[child])
				line.width = 2
				line.default_color = Color(1, 0, 1, 0.6)
				line_folder.add_child(line)
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

"""
Construit le rendu visuel interactif et animé d'une planète pour la carte d'exploration.

Cette fonction génère un nœud complexe contenant les sprites de la planète (base et couche),
les colore via les données globales, et superpose un bouton transparent pour les interactions.
Elle met également en place des animations fluides (Tweens) : un flottement naturel continu,
ainsi qu'un effet de grossissement et de "tremblement" (wiggle) lorsque le joueur passe
sa souris sur la planète.

Args:
planet_name (String): Le nom de la planète, servant de clé pour récupérer ses textures et couleurs dans 'GlobalData.universe'.
size (float): Le facteur d'échelle (scale) de la planète, simulant sa profondeur ou sa taille sur la carte.

Returns:
Node2D : Le nœud racine fraîchement créé contenant les sprites animés et le bouton, prêt à être ajouté à l'écran.
"""

func create_visual_map(planet_name, size):
	var data = GlobalData.universe[planet_name]
	var visual = Node2D.new()
	var animated_visual = Node2D.new()
	animated_visual.scale = Vector2(size,size)
	visual.add_child(animated_visual)
	var planet = Sprite2D.new()
	planet.texture = data["planet_texture"]
	planet.self_modulate = data["planet_color"]
	var layer = Sprite2D.new()
	layer.texture = data["layer_texture"]
	layer.self_modulate = data["layer_color"]
	animated_visual.add_child(planet)
	animated_visual.add_child(layer)
	var btn = Button.new()
	btn.flat = true
	btn.custom_minimum_size = Vector2(100,100)
	btn.position = Vector2(-50,-50)
	btn.pressed.connect(func(): 
		planet_exploration(planet_name)
		update_tako_location(data)
	)
	animated_visual.add_child(btn)
	var float_animation = visual.create_tween().set_loops()
	var random = randf_range(2,4)
	var float_height = randf_range(8,15)
	float_animation.tween_property(animated_visual, "position:y", -float_height, random).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_animation.tween_property(animated_visual, "position:y", float_height, random).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_animation.custom_step(randf_range(0.0, 2.0))
	var base_scale = Vector2(size,size)
	var hoever_scale = base_scale * 1.2
	visual.set_meta("hoever_animation", null)
	visual.set_meta("wiggle_animation", null)
	btn.mouse_entered.connect(func():
		var hoever_t = visual.create_tween()
		hoever_t.tween_property(animated_visual, "scale", hoever_scale, 0.2).set_trans(Tween.TRANS_QUAD)
		visual.set_meta("hoever_animation", hoever_t)
		var wiggle_t = visual.create_tween().set_loops()
		wiggle_t.tween_property(animated_visual, "rotation_degrees",5, 0.3).set_ease(Tween.EASE_IN_OUT)
		wiggle_t.tween_property(animated_visual, "rotation_degrees",-5, 0.6).set_ease(Tween.EASE_IN_OUT)
		wiggle_t.tween_property(animated_visual, "rotation_degrees", 0, 0.3).set_ease(Tween.EASE_IN_OUT)
		visual.set_meta("wiggle_animation", wiggle_t)
	)
	btn.mouse_exited.connect(func():
		var hoever_kill = visual.get_meta("hoever_animation")
		if hoever_kill != null and hoever_kill.is_valid(): hoever_kill.kill()
		var wiggle_kill = visual.get_meta("wiggle_animation")
		if wiggle_kill != null and wiggle_kill.is_valid(): wiggle_kill.kill()
		var reset = visual.create_tween().set_parallel(true)
		reset.tween_property(animated_visual, "scale", base_scale,0.2).set_trans(Tween.TRANS_QUAD)
		reset.tween_property(animated_visual, "rotation_degrees", 0, 0.2).set_trans(Tween.TRANS_QUAD)
	)
	return visual

"""
Gère le déplacement du joueur vers une nouvelle planète et actualise l'environnement.

Cette fonction met à jour la position courante du joueur en enregistrant le nom
de la nouvelle planète. Elle prépare ensuite l'interface de commande spatiale
(BoxSpaceCommand) pour cette nouvelle localisation et lance une requête radar
pour générer et afficher la carte des alentours de la nouvelle destination.

Args:
destination_name (String): Le nom de la planète vers laquelle le joueur a choisi de se déplacer.

Returns:
void : Ne retourne aucune valeur.
"""

func planet_exploration(destination_name):
	current_planet = destination_name
	print("On se déplace en: " + destination_name)
	$"Background Manager/Box Manager/BoxSpaceCommand".prepare_new_scan(current_planet)
	get_planet_map(current_planet)

"""
Met à jour la position actuelle du joueur (Tako) sur le serveur.

Cette fonction envoie une requête HTTP POST à l'API locale pour informer le backend
(et potentiellement l'IA) de la nouvelle localisation du joueur. Elle transmet les
données de la planète ciblée au format JSON, puis libère silencieusement la mémoire
une fois la requête terminée, sans attendre de traitement particulier de la réponse.

Args:
planet_info (Dictionary): Les données détaillées de la planète de destination (généralement issues de 'GlobalData.universe').

Returns:
void : Ne retourne aucune valeur.
"""

func update_tako_location(planet_info):
	var url = "http://127.0.0.1:8000/set_current_planet"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(planet_info)
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(func(_r, _c, _h, _b): request.queue_free())
	request.request(url, headers, HTTPClient.METHOD_POST, body)
