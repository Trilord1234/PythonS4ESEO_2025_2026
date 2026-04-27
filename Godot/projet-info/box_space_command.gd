extends TextureRect

var target_planet = ""

@onready var radar_planet = $Radar/Planet
@onready var radar_layer = $Radar/Layer
@onready var log_display = $"Log&All/Texte Log"
@onready var btn_scan = $"../../../Button Manager/Scan"
@onready var btn_hyperspeed = $"../../../Button Manager/HyperSpeed"
@onready var scroll_menu = $"Log&All/HyperSpeedBox"
@onready var list_container = $"Log&All/HyperSpeedBox/ScrollContainer/VBoxContainer"
@onready var btn_save_json =$"../../../Button Manager/Save JSON"
@onready var hyper_speed_box = $"Log&All/HyperSpeedBox"
@onready var particles = $"../../../Button Manager/Battle/Conffettis"

func _ready():
	"""
	Initialise l'interface et les signaux au chargement de la scène.

	Configure le texte de démarrage du journal de bord, masque les éléments 
	secondaires (radar, menu hyperspatial) et connecte les signaux des boutons 
	(Hyperspeed, Sauvegarde JSON) à leurs fonctions respectives.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if log_display:
		log_display.text = "> SYSTÈME DÉMARRÉ.\n> Radar en attente..."
	hyper_speed_box.hide()
	hide_radar()
	if btn_hyperspeed:
		btn_hyperspeed.pressed.connect(_on_hyper_speed_pressed)
		update_hyperspeed_destinations()
	if btn_save_json:
		btn_save_json.pressed.connect(_on_save_json_pressed)

func update_hyperspeed_destinations():
	"""
	Génère dynamiquement l'interface de sélection des destinations hyperspatiales.

	Nettoie la liste actuelle puis crée un bouton interactif pour chaque planète 
	présente dans 'GlobalData.scanned_planets'. Chaque bouton intègre l'icône 
	générée procéduralement (texture + layer) et le nom de la planète.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if not list_container: return
	for child in list_container.get_children():
		child.queue_free()
	for p_name in GlobalData.scanned_planets:
		var data = GlobalData.universe[p_name]
		var btn_row = Button.new()
		btn_row.flat = true
		btn_row.custom_minimum_size = Vector2(0, 50)
		btn_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_row.pressed.connect(func():
			executer_saut_hyperspeed(p_name)
		)
		var ligne_layout = HBoxContainer.new()
		ligne_layout.set_anchors_preset(Control.PRESET_FULL_RECT)
		ligne_layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ligne_layout.add_theme_constant_override("separation", 15)
		btn_row.add_child(ligne_layout)
		var box_picture = Control.new()
		box_picture.custom_minimum_size = Vector2(40, 40)
		box_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icone = TextureRect.new()
		icone.texture = data["planet_texture"]
		icone.self_modulate = data["planet_color"]
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.set_anchors_preset(Control.PRESET_FULL_RECT)
		icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icone_layer = TextureRect.new()
		icone_layer.texture = data["layer_texture"]
		icone_layer.self_modulate = data["layer_color"]
		icone_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		icone_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box_picture.add_child(icone)
		box_picture.add_child(icone_layer)
		var text_planet = Label.new()
		text_planet.text = p_name
		text_planet.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text_planet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_planet.add_theme_font_size_override("font_size", 16)
		ligne_layout.add_child(box_picture)
		ligne_layout.add_child(text_planet)
		list_container.add_child(btn_row)

func executer_saut_hyperspeed(destination: String):
	"""
	Calcule et déclenche un saut hyperspatial vers la destination choisie.

	Envoie une requête HTTP POST à la route '/hyperspeed_route' du serveur Python 
	pour calculer le chemin via l'algorithme DFS. Si une route valide est renvoyée, 
	elle est affichée dans le log avant de lancer la transition vers la nouvelle planète.

	Args:
	destination (String) : Le nom de la planète cible à atteindre.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	scroll_menu.hide()
	log_display.show()
	log_display.text += "\n\n> CALCUL DE LA ROUTE HYPERSPATIALE..."
	var url = "http://127.0.0.1:8000/hyperspeed_route"
	var headers = ["Content-Type: application/json"]
	var data = JSON.stringify({"start": target_planet, "end": destination})
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(func(_result, _code, _headers, _body):
		request.queue_free()
		var json = JSON.new()
		if json.parse(_body.get_string_from_utf8()) == OK:
			var reponse = json.get_data()
			if reponse.has("status") and reponse["status"] == "success":
				var chemin = reponse["path"]
				var route_texte = " -> ".join(chemin)
				log_display.text += "\n> Route DFS validée :"
				log_display.text += "\n> " + route_texte
				log_display.text += "\n> SAUT IMMINENT !"
				get_tree().create_timer(1.5).timeout.connect(func():
					get_node("/root/Exploration").planet_exploration(destination)
				)
			else:
				log_display.text += "\n> ERREUR CRITIQUE : Aucune route hyperspatiale trouvée. Le réseau est peut-être coupé."
	)
	request.request(url, headers, HTTPClient.METHOD_POST, data)

func prepare_new_scan(planet_name: String):
	"""
	Configure le système de bord lors de l'arrivée en orbite d'une planète.

	Définit la nouvelle cible. Si la planète a déjà été scannée auparavant, 
	ses données visuelles et textuelles sont immédiatement restaurées. Sinon, 
	le radar est masqué en attendant une action de scan manuel de l'utilisateur.

	Args:
	planet_name (String) : Le nom de la planète sur laquelle le joueur vient d'arriver.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	target_planet = planet_name
	if GlobalData.scanned_planets.has(target_planet):
		log_display.text += "\n> Arrivée en orbite.\n> Données locales récupérées depuis la mémoire."
		display_planet_data() 
	else:
		hide_radar()
		log_display.text += "\n> Arrivée en orbite.\n> Prêt pour le scan."

func hide_radar():
	"""
	Masque l'affichage visuel de la planète sur le radar.

	Désactive la visibilité des nœuds 'TextureRect' de la planète de base 
	et de son calque superposé (layer).

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if radar_planet and radar_layer:
		radar_planet.hide()
		radar_layer.hide()

func _on_scan_pressed():
	"""
	Valide et exécute l'analyse d'une planète inconnue.

	Vérifie que la cible est valide et n'a pas déjà été analysée. Si les conditions 
	sont remplies, la planète est ajoutée à la base de données explorée, 
	les destinations hyperspatiales sont mises à jour, et les données sont affichées.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if target_planet == "":
		log_display.text += "\n> ERREUR : Aucune cible."
		return
	if not GlobalData.universe.has(target_planet):
		log_display.text += "\n> ERREUR : Données de la planète introuvables."
		return
	if GlobalData.scanned_planets.has(target_planet):
		log_display.text += "\n> INFO : Planète déjà analysée."
		return
	GlobalData.scanned_planets.append(target_planet)
	update_hyperspeed_destinations()
	display_planet_data()
	
func display_planet_data():
	"""
	Affiche les caractéristiques visuelles et les données de l'IA sur le radar.

	Récupère les informations générées par le serveur (textures, couleurs, 
	nom, type, niveau de danger) depuis 'GlobalData', met à jour les nœuds 
	visuels pour faire apparaître la planète, et imprime le rapport dans le log.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	var data = GlobalData.universe[target_planet]
	
	radar_planet.texture = data["planet_texture"]
	radar_layer.texture = data["layer_texture"]
	radar_planet.self_modulate = data["planet_color"]
	radar_layer.self_modulate = data["layer_color"]
	
	radar_planet.show()
	radar_layer.show()
	
	var p_name = target_planet
	var p_type = data["IA_data"]["type"]
	var p_danger = data["IA_data"]["level of danger"]

	log_display.text += "\n> Nom : " + str(p_name)
	log_display.text += "\n> Type : " + str(p_type)
	log_display.text += "\n> Danger : " + str(p_danger)

func _on_save_json_pressed():
	"""
	Déclenche la sauvegarde de l'état de l'univers sur le serveur.

	Envoie une requête HTTP POST à la route '/save_graph' du serveur Python 
	avec la liste des planètes scannées pour générer les fichiers JSON persistants. 
	Affiche un message de succès ou d'erreur dans le journal de bord.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	log_display.text += "\n\n> SAUVEGARDE JSON EN COURS..."
	var url = "http://127.0.0.1:8000/save_graph"
	var headers = ["Content-Type: application/json"]
	var data = JSON.stringify({"scanned_planets": GlobalData.scanned_planets})
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(func(_result, _code, _headers, _body):
		request.queue_free()
		if _code == 200:
			log_display.text += "\n> SUCCÈS : Fichiers graph_complet.json et graph_decouvert.json créés sur le serveur."
		else:
			log_display.text += "\n> ERREUR : Échec de la communication avec le serveur."
	)
	request.request(url, headers, HTTPClient.METHOD_POST, data)

func _on_hyper_speed_pressed():
	"""
	Alterne l'affichage entre le journal de bord et le menu de saut hyperspatial.

	Gère l'interface utilisateur en masquant le menu Hyperspeed pour afficher le log, 
	ou inversement. Met à jour la liste des destinations à chaque ouverture du menu.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if hyper_speed_box.visible:
		hyper_speed_box.hide()
		log_display.show()
	else:
		log_display.hide()
		hyper_speed_box.show()
		update_hyperspeed_destinations()

func _on_battle_pressed():
	"""
	Déclenche un événement humoristique (Easter Egg) dans l'interface.

	Active un émetteur de particules (confettis) et affiche un message ironique 
	de l'IA Tako dans le journal de bord concernant la survie de l'utilisateur.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	particles.restart() 
	particles.emitting = true
	log_display.text += "\n\n>FÉLICITATIONS !"
	log_display.text += "\n> Tako : Vous avez cliquer sur un bouton qui aurait pu amené a votre mort. C'est statistiquement miraculeux."
