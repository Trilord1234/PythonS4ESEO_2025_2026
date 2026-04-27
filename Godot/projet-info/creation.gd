extends Node2D

var planet_manager = preload("res://planete_manager.tscn")
var count = 0
var planet_selected = null
var line_created = []
@onready var btn_load_json = $"Button Manager/LoadJSON"

"""
Initialise le script lors de l'entrée du nœud dans l'arbre de la scène.

Cette fonction configure l'état initial de l'interface en masquant le bouton de suppression,
établit la connexion sécurisée pour le chargement des fichiers JSON si le bouton
correspondant est défini, et initialise le générateur de nombres aléatoires pour
garantir des résultats variés durant la session.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""
func _ready() :
	$"Button Manager/Delete".visible = false
	if btn_load_json:
		btn_load_json.pressed.connect(_on_load_json_pressed)
	randomize()
"""
Met à jour en temps réel la position des lignes reliant les planètes.

Cette fonction parcourt la liste des connexions établies et synchronise les
extrémités de chaque ligne ('Line2D') avec les centres respectifs des deux
planètes liées. Elle inclut une vérification de validité des instances pour
éviter les erreurs si une planète ou une ligne est supprimée en cours de jeu.

Args:
_delta (float): Le temps écoulé depuis la dernière image (inutilisé ici mais requis par Godot).

Returns:
void : Ne retourne aucune valeur.
"""

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

"""
Gère l'affichage détaillé des informations lorsqu'une planète est sélectionnée.

Cette fonction met à jour l'interface utilisateur pour afficher l'apparence visuelle
de la planète (textures et couleurs), remplit les champs de données techniques
(poids, gravité, habitabilité, etc.) et affiche la description. Si les données
sont disponibles, elle lance également une requête HTTP vers un serveur local
pour récupérer et afficher la liste des planètes voisines.

Args:
targeted_planet (Node): L'instance de la planète qui a été sélectionnée.

Returns:
void : Ne retourne aucune valeur.
"""


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


"""
Crée une ligne visuelle entre deux planètes et enregistre leur liaison sur le serveur.

Cette fonction génère un nœud 'Line2D' placé en arrière-plan pour connecter graphiquement
les planètes 'planet_A' et 'planet_B'. Elle stocke ces références pour permettre la mise à
jour visuelle (via '_process'), puis effectue une requête HTTP POST vers l'API locale
pour persister cette nouvelle relation. Enfin, elle rafraîchit les informations à l'écran
si l'une des planètes impliquées est actuellement sélectionnée.

Args:
planet_A (Node): L'instance de la première planète à relier.
planet_B (Node): L'instance de la seconde planète à relier.

Returns:
void : Ne retourne aucune valeur.
"""
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

"""
Supprime la connexion visuelle entre deux planètes et détruit leur liaison sur le serveur.

Cette fonction supprime le nœud 'Line2D' associé, retire l'entrée de la liste des
lignes actives ('line_created') pour stopper sa mise à jour, et envoie une requête
HTTP POST pour notifier l'API locale de la suppression du lien. Elle rafraîchit
ensuite l'affichage si l'une des planètes concernées est actuellement sélectionnée.

Args:
link (Dictionary): Un dictionnaire contenant la ligne ("Line") et les deux planètes liées ("Planet_A", "Planet_B").

Returns:
void : Ne retourne aucune valeur.
"""

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

"""
Supprime la planète actuellement sélectionnée, nettoie ses liaisons et réinitialise l'interface.

Cette fonction vérifie d'abord si une planète est bien sélectionnée. Si c'est le cas,
elle met à jour le compteur global, détruit toutes les lignes visuelles (Line2D)
qui étaient connectées à cette planète, puis supprime le nœud de la planète
elle-même. Enfin, elle efface toutes les informations affichées dans le panneau
de détails (InfoBox).

Args:
Aucun : Utilise la variable globale ou de classe 'planet_selected'.

Returns:
void : Ne retourne aucune valeur.
"""

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

"""
Déclenche la transition vers la phase d'exploration du jeu.

Cette fonction est appelée lors du clic sur le bouton "Suivant" (Next).
Elle utilise l'arbre de scène de Godot (SceneTree) pour charger et basculer
directement vers le fichier "res://exploration.tscn", ce qui aura pour effet
de fermer la scène actuelle et de libérer ses ressources.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://exploration.tscn")

"""
Supprime toutes les connexions visuelles associées à la planète actuellement sélectionnée.

Cette fonction parcourt la liste des liaisons actives et identifie toutes celles
impliquant la planète sélectionnée (que ce soit en tant que point de départ ou
d'arrivée). Pour chaque liaison trouvée, elle détruit la ligne visuelle ('Line2D')
et retire la référence du tableau de suivi pour stopper son rendu.

Args:
Aucun : Utilise la variable globale 'planet_selected' et le tableau 'line_created'.

Returns:
void : Ne retourne aucune valeur.
"""

func _on_delete_all_link_pressed():
	for i in range(line_created.size() - 1, -1, -1):
		var dict = line_created[i]
		if dict["Planet_A"] == planet_selected or dict["Planet_B"] == planet_selected:
			dict["Line"].queue_free() 
			line_created.remove_at(i)

"""
Charge l'état du graphe depuis le serveur pour recréer l'univers.

Cette fonction réinitialise d'abord l'affichage actuel (via '_on_clear_pressed()').
Elle lance ensuite une requête HTTP GET vers l'API locale pour récupérer les données
de sauvegarde au format JSON. Si la requête réussit (code HTTP 200) et que le JSON
est valide, elle déclenche la fonction de reconstruction ('recreer_univers()').
Dans le cas contraire, elle renvoie des messages d'erreur dans la console.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

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


"""
Reconstruit l'univers complet (planètes et liaisons) à partir d'une sauvegarde.

Cette fonction traite un dictionnaire de données pour instancier dynamiquement
chaque planète, restaurer son apparence (textures et couleurs), réinjecter ses
statistiques IA et la placer aléatoirement dans la zone de jeu. Elle enregistre
ensuite ces nœuds dans un dictionnaire global avant de recréer visuellement
et logiquement toutes les connexions entre les planètes voisines, en veillant
à ne pas générer de liens en double.

Args:
data (Dictionary): Le dictionnaire contenant la sauvegarde de l'univers (incluant l'apparence, les caractéristiques et les voisins pour chaque planète).

Returns:
void : Ne retourne aucune valeur.
"""

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
