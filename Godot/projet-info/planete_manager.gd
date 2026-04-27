extends Control

var movement = Vector2.ZERO
var limit_x = 500
var limit_y = 500
var planet_size = 100
var prompt_IA = ""
var data_IA_save = null
var is_loaded_from_save = false

func _ready():
	"""
	Initialise la planète en définissant sa physique et son apparence visuelle unique.

	Cette fonction gère deux scénarios :

	Si la planète est chargée depuis une sauvegarde, elle se contente de lui attribuer
	un vecteur de mouvement aléatoire.

	Sinon, elle génère procéduralement l'apparence de la planète en choisissant des
	textures (base et couches supérieures) et des couleurs aléatoires. Elle construit
	simultanément un 'prompt' textuel décrivant ces caractéristiques visuelles, puis
	interroge un script Python pour générer dynamiquement les données narratives
	(nom, gravité, anecdotes, etc.) cohérentes avec le visuel obtenu.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if is_loaded_from_save:
		var load_angle = randf_range(0, 2 * PI)
		var load_speed = randf_range(100, 250)
		movement = Vector2.RIGHT.rotated(load_angle) * load_speed
		return
	prompt_IA = "Invente un nom, le poids, la taille, l'habitabilité, son type, sa gravité, sa dangerosité et une anecdote pour cette planète. "
	
	if randf() > 0.5:
		var planet_choice = PlanetData.planete_BW.pick_random()
		$Planet.texture = planet_choice["image"]
		var planet_color = Color.from_hsv(randf(), randf_range(0.3,0.8), 1.0)
		$Planet.self_modulate = planet_color
		var code_hexa = planet_color.to_html(false)
		prompt_IA += "Visuellement : " + planet_choice["description"] + " Ses couleurs sont #" + code_hexa + ". "
		
	else:
		var choix_planete = PlanetData.planete.pick_random()
		$Planet.texture = choix_planete["image"]
		$Planet.self_modulate = Color.WHITE
		prompt_IA += "Visuellement : " + choix_planete["description"] + " Ses couleurs sont : " + choix_planete["couleurs"] + ". "
		
	if randf() < 0.5:
		var layer_choice = PlanetData.layer_BW.pick_random()
		$Layer.texture = layer_choice["image"]
		if layer_choice["image"] != null:
			var layer_color = Color.from_hsv(randf(), randf_range(0.3, 0.8), 1.0)
			$Layer.self_modulate = layer_color
			var code_hexa = layer_color.to_html(false)
			prompt_IA += layer_choice["description"] + " Ses couleurs sont #" + code_hexa + "."
		else:
			prompt_IA += layer_choice["description"]
	else:
		var layer_choice = PlanetData.layer.pick_random()
		$Layer.texture = layer_choice["image"]
		$Layer.self_modulate = Color.WHITE
		if layer_choice["image"] != null:
			prompt_IA += layer_choice["description"] + " Ses couleurs sont : " + layer_choice["couleurs"] + ". "
		else:
			prompt_IA += layer_choice["description"]
			
	var angle = randf_range(0,2 * PI)
	var speed = randf_range(100, 250)
	movement = Vector2.RIGHT.rotated(angle) * speed
	
	python_call(prompt_IA)
	print(prompt_IA)

func _process(delta):
	"""
	Gère le mouvement continu de la planète et les collisions avec les bords de l'écran.

	À chaque image (frame), la position de la planète est mise à jour en fonction de son
	vecteur de mouvement. La fonction vérifie si la planète dépasse les limites
	définies ('limit_x' et 'limit_y'). Si un bord est touché, la position est
	rectifiée pour rester dans la zone de jeu et la direction du mouvement est
	inversée sur l'axe concerné (effet de rebond).

	Args:
	delta (float): Le temps écoulé depuis la dernière frame, utilisé pour rendre le mouvement indépendant du taux de rafraîchissement (FPS).

	Returns:
	void : Ne retourne aucune valeur.
	"""
	position += movement * delta
	if position.x <= 0:
		position.x = 0 
		movement.x = abs(movement.x)
	elif position.x >= (limit_x - planet_size):
		position.x = limit_x - planet_size
		movement.x = -abs(movement.x)
	if position.y <= 0:
		position.y = 0
		movement.y = abs(movement.y)
	elif position.y >= (limit_y - planet_size):
		position.y = limit_y - planet_size
		movement.y = -abs(movement.y)

signal planet_selected(planete_node)

func _on_planet_button_pressed():
	"""
	Émet le signal de sélection lorsque l'utilisateur clique sur la planète.

	Cette fonction sert d'intermédiaire entre l'interaction physique (le clic sur
	le bouton ou la zone de collision) et la logique globale du jeu. En émettant
	le signal 'planet_selected' avec une référence à elle-même ('self'), elle
	permet aux gestionnaires d'interface ou de liens de savoir précisément quelle
	planète est devenue la cible active du joueur.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	planet_selected.emit(self)

func python_call(prompt):
	"""
	Envoie la description visuelle et le prompt narratif au serveur d'IA.

	Cette fonction prépare un paquet de données contenant le prompt textuel ainsi que
	les informations esthétiques de la planète (chemins des textures et codes couleurs
	hexadécimaux). Elle configure ensuite le nœud 'RequestIA' pour envoyer une requête
	HTTP POST au serveur local. Elle s'assure également que le signal de réponse est
	correctement connecté à la fonction de traitement '_on_response_received'.

	Args:
	prompt (String): Le texte descriptif généré lors du '_ready' détaillant les caractéristiques visuelles.

	Returns:
	void : Ne retourne aucune valeur (la réponse est traitée de manière asynchrone).
	"""
	var url = "http://127.0.0.1:8000/analyse"
	var headers = ["Content-Type: application/json"]
	var p_path = "none"
	if $Planet.texture != null:
		p_path = $Planet.texture.resource_path
	var l_path = "none"
	if $Layer.texture != null:
		l_path = $Layer.texture.resource_path
	var look_data = {
		"planet": p_path,
		"layer": l_path,
		"planet_color": "#" + $Planet.self_modulate.to_html(false),
		"layer_color": "#" + $Layer.self_modulate.to_html(false)
	}
	var data_to_send = JSON.stringify({
		"prompt": prompt,
		"look": look_data
	})
	if not $RequestIA.request_completed.is_connected(_on_response_received):
		$RequestIA.request_completed.connect(_on_response_received)
	$RequestIA.request(url, headers, HTTPClient.METHOD_POST, data_to_send)

func _on_response_received(_result, response_code, _headers, body):
	"""
	Traite la réponse du serveur d'IA et enregistre l'identité de la planète.

	Cette fonction est appelée automatiquement dès que le serveur Python répond.
	Elle décode le corps de la réponse en JSON pour récupérer les caractéristiques
	narratives (nom, type, etc.). Si les données sont valides, elles sont stockées
	localement dans la planète et enregistrées dans le dictionnaire global
	'GlobalData.universe' avec toutes les propriétés visuelles associées.

	Args:
	_result : Résultat de la requête (non utilisé).
	response_code (int): Le code de statut HTTP (200 indique un succès).
	_headers : En-têtes de la réponse (non utilisés).
	body (PackedByteArray): Le contenu brut de la réponse du serveur.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if response_code == 200:
		var reponse_texte = body.get_string_from_utf8()
		var IA_data = JSON.parse_string(reponse_texte)
		
		if IA_data != null:
			data_IA_save = IA_data
			var planet_name = IA_data["name"]
			GlobalData.universe[planet_name] = {
				"planet_texture": $Planet.texture,
				"planet_color": $Planet.self_modulate,
				"layer_texture": $Layer.texture,
				"layer_color": $Layer.self_modulate,
				"IA_data": IA_data}
			print("Infos IA générées pour une planète !")
