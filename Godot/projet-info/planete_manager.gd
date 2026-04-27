extends Control

var planete = [
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet1.png"), "description": "Elle présente de larges bandes obliques et ondulées évoquant des courants atmosphériques d'une planète gazeuse ou aquatique.", "couleurs": "Dominante bleue (bandes bleu clair sur fond bleu moyen)"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet2.png"), "description": "La surface est parsemée de taches et de cratères irréguliers, donnant un aspect rocheux, aride et martien.", "couleurs": "Dominante rouge vif (avec des taches et cratères rouge foncé/bordeaux)"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet3.png"), "description": "La planète est composée de rayures diagonales épaisses, nettes et parallèles.", "couleurs": "Dominante verte (alternance de rayures vert clair/pomme et vert foncé)"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet4.png"), "description": "Des motifs tourbillonnants, nébuleux et asymétriques se détachent sur un fond plus sombre. Aspect gazeux ou magique.", "couleurs": "Dominante violette (motifs violet clair sur fond violet sombre)"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet5.png"), "description": "Planète lumineuse. Un motif en spirale se fond dans un centre très clair. La surface est décorée de petites étincelles en forme de croix.", "couleurs": "Couleurs chaudes (centre jaune vif, spirale orange, étincelles blanches)"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet6.png"), "description": "Fond très sombre avec d'épaisses nervures ou coulées organiques qui semblent couler ou enlacer la planète.", "couleurs": "Fond rouge très sombre/bordeaux, nervures rose vif/magenta"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet7.png"), "description": "Planète de type 'Terre'. Composée de masses entremêlées évoquant des océans et des masses continentales ou végétales.", "couleurs": "Océans bleu moyen, continents en différentes nuances de vert"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet8.png"), "description": "Planète avec des motifs de quartiers ou de fuseaux incurvés convergeant vers les pôles, rappelant la structure d'un ballon de basket ou d'un melon.", "couleurs": "Alternance de bandes orange et marron"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet9.png"), "description": "Planète où sa surface est marquée par des tâches et des nuages irréguliers et nébuleux, se détachant sur un fond très sombre.", "couleurs": "Fond bleu nuit très sombre, taches violettes/magenta clair"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet10.png"), "description": "Représente une planète en destruction. L'écorce est rocheuse et parcourue de fissures. Une grande faille en diagonale laisse apparaître un noyau incandescent en fusion. Des débris de roche s'envolent en haut à gauche.", "couleurs": "Écorce gris foncé, noyau en dégradé jaune, orange et rouge"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet11.png"), "description": "Planète monstrueuse. Fond très sombre incrusté de multiples yeux avec pupilles. Les yeux sont répartis de manière chaotique et regardent dans plusieurs directions.", "couleurs": "Fond noir et violet foncé, yeux blancs avec pupilles noires"}
]

var planete_BW = [
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet1_B&W.png"), "description": "Elle présente de larges bandes obliques et ondulées évoquant des courants atmosphériques d'une planète gazeuse ou aquatique."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet2_B&W.png"), "description": "La surface est parsemée de taches et de cratères irréguliers, donnant un aspect rocheux, aride et martien."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet3_B&W.png"), "description": "La planète est composée de rayures diagonales épaisses, nettes et parallèles."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet4_B&W.png"), "description": "Des motifs tourbillonnants, nébuleux et asymétriques se détachent sur un fond plus sombre. Aspect gazeux ou magique."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet5_B&W.png"), "description": "Planète lumineuse. Un motif en spirale se fond dans un centre très clair. La surface est décorée de petites étincelles en forme de croix."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet6_B&W.png"), "description": "Fond très sombre avec d'épaisses nervures ou coulées organiques qui semblent couler ou enlacer la planète."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet7_B&W.png"), "description": "Planète de type 'Terre'. Composée de masses entremêlées évoquant des océans et des masses continentales ou végétales."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet8_B&W.png"), "description": "Planète avec des motifs de quartiers ou de fuseaux incurvés convergeant vers les pôles, rappelant la structure d'un ballon de basket ou d'un melon."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet9_B&W.png"), "description": "Planète où sa surface est marquée par des tâches et des nuages irréguliers et nébuleux, se détachant sur un fond très sombre."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet10_B&W.png"), "description": "Représente une planète en destruction. L'écorce est rocheuse et parcourue de fissures. Une grande faille en diagonale laisse apparaître un noyau incandescent en fusion. Des débris de roche s'envolent en haut à gauche."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Planet_sprite_B&W/Planet11_B&W.png"), "description": "Planète monstrueuse. Fond très sombre incrusté de multiples yeux avec pupilles. Les yeux sont répartis de manière chaotique et regardent dans plusieurs directions."}
]

var layer = [
	{"image": null, "description": "Il n'y a rien de particulier en orbite autour de cette planète."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer1.png"), "description": "Autour de la planète flottent plusieurs nuages épais et cotonneux, aux formes irrégulières.", "couleurs": "Blanc et gris"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer2.png"), "description": "La planète est traversée en diagonale par un grand trait ou anneau d'énergie lumineux, accompagné de quelques étoiles scintillantes.", "couleurs": "Jaune vif"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer3.png"), "description": "De petits véhicules spatiaux gravitent autour de la planète, notamment une soucoupe volante classique à dôme transparent, une petite fusée et un extraterrestre qui est tombé de son vaisseau.", "couleurs": "Soucoupe grise avec dôme bleu clair, fusée rouge avec vitre bleue, vaisseau extraterrestre vert"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer4.png"), "description": "La planète est infestée par une créature ressemblant à un ver spatial titanesque.", "couleurs": "Violet avec des pattes/pointes noires et des yeux rouges"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer5.png"), "description": "À l'intérieur de la planète, un grand œil avec une pupille incandescente y vit, et ses tentacules spectraux entourent la planète.", "couleurs": "Œil blanc, pupille rouge et jaune, tentacules blancs/gris clair"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer6.png"), "description": "L'environnement direct de la planète est parsemé de plusieurs bulles brillantes, de différentes tailles, flottant en apesanteur.", "couleurs": "Bleu clair avec des reflets blancs"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer7.png"), "description": "La planète est accompagnée d'un grand cristal volant et de projectiles.", "couleurs": "Losange rouge, projectiles noirs et blancs"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer8.png"), "description": "Une petite lune couverte de cratères orbite à proximité.", "couleurs": "Lune grise avec des cratères plus foncés, étincelles jaunes"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer9.png"), "description": "La scène est parasitée par des éléments d'interface rétro : une petite fenêtre d'erreur, entourée de croix et de cubes évoquant une 'texture manquante' en damier.", "couleurs": "Fenêtre grise et bleue, croix rouges, cubes en damier noir et magenta (rose fluo)"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer10.png"), "description": "Une adorable petite entité cosmique avec des marques sur les joues et deux points pour les yeux flotte joyeusement, enlaçant la planète.", "couleurs": "Corps blanc, yeux noirs, joues roses"},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer11.png"), "description": "Une étoile filante dotée d'une longue double traînée lumineuse traverse l'espace à proximité, accompagnée d'une petite étoile scintillante à quatre branches.", "couleurs": "Jaune vif"}
]

var layer_BW = [
	{"image": null, "description": "Il n'y a rien de particulier en orbite autour de cette planète."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer1_B&W.png"), "description": "Autour de la planète flottent plusieurs nuages épais et cotonneux, aux formes irrégulières."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer2_B&W.png"), "description": "La planète est traversée en diagonale par un grand trait ou anneau d'énergie lumineux, accompagné de quelques étoiles scintillantes."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer3_B&W.png"), "description": "De petits véhicules spatiaux gravitent autour de la planète, notamment une soucoupe volante classique à dôme transparent, une petite fusée et un extraterrestre qui est tombé de son vaisseau."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer4_B&W.png"), "description": "La planète est infestée par une créature ressemblant à un ver spatial titanesque."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer5_B&W.png"), "description": "À l'intérieur de la planète, un grand œil avec une pupille incandescente y vit, et ses tentacules spectraux entourent la planète."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer6_B&W.png"), "description": "L'environnement direct de la planète est parsemé de plusieurs bulles brillantes, de différentes tailles, flottant en apesanteur."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer7_B&W.png"), "description": "La planète possède un visage ouvrant la bouche en 'O' avec des yeux rigolos louchant."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer8_B&W.png"), "description": "Une petite lune couverte de cratères orbite à proximité, décorée de petites étincelles en forme de croix."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer9_B&W.png"), "description": "La scène est parasitée par des éléments d'interface rétro : une petite fenêtre d'erreur, entourée de croix et de cubes évoquant une 'texture manquante' en damier."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer10_B&W.png"), "description": "Une adorable petite entité cosmique avec des marques sur les joues et deux points pour les yeux flotte joyeusement, enlaçant la planète."},
	{"image": preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite_B&W/Layer11_B&W.png"), "description": "Une étoile filante dotée d'une longue double traînée lumineuse traverse l'espace à proximité, accompagnée d'une petite étoile scintillante à quatre branches."}
]

var movement = Vector2.ZERO
var limit_x = 500
var limit_y = 500
var planet_size = 100
var prompt_IA = ""
var data_IA_save = null
var is_loaded_from_save = false

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

func _ready():
	if is_loaded_from_save:
		var load_angle = randf_range(0, 2 * PI)
		var load_speed = randf_range(100, 250)
		movement = Vector2.RIGHT.rotated(load_angle) * load_speed
		return
	prompt_IA = "Invente un nom, le poids, la taille, l'habitabilité, son type, sa gravité, sa dangerosité et une anecdote pour cette planète. "
	
	if randf() > 0.5:
		var planet_choice = planete_BW.pick_random()
		$Planet.texture = planet_choice["image"]
		var planet_color = Color.from_hsv(randf(), randf_range(0.3,0.8), 1.0)
		$Planet.self_modulate = planet_color
		var code_hexa = planet_color.to_html(false)
		prompt_IA += "Visuellement : " + planet_choice["description"] + " Ses couleurs sont #" + code_hexa + ". "
		
	else:
		var choix_planete = planete.pick_random()
		$Planet.texture = choix_planete["image"]
		$Planet.self_modulate = Color.WHITE
		prompt_IA += "Visuellement : " + choix_planete["description"] + " Ses couleurs sont : " + choix_planete["couleurs"] + ". "
		
	if randf() < 0.5:
		var layer_choice = layer_BW.pick_random()
		$Layer.texture = layer_choice["image"]
		if layer_choice["image"] != null:
			var layer_color = Color.from_hsv(randf(), randf_range(0.3, 0.8), 1.0)
			$Layer.self_modulate = layer_color
			var code_hexa = layer_color.to_html(false)
			prompt_IA += layer_choice["description"] + " Ses couleurs sont #" + code_hexa + "."
		else:
			prompt_IA += layer_choice["description"]
	else:
		var layer_choice = layer.pick_random()
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

func _process(delta):
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

func _on_planet_button_pressed():
	planet_selected.emit(self)

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

func python_call(prompt):
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

func _on_response_received(_result, response_code, _headers, body):
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
