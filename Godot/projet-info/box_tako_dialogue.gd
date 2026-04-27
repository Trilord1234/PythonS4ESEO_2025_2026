extends TextureRect

@onready var chat_input = $ChatInput
@onready var chat_display = $ChatDisplay
@onready var  tako = $"../../../Tako Manager/Tako"

func _ready():
	"""
	Initialise l'interface de communication textuelle au chargement.

	Affiche le titre de la boîte de dialogue, connecte le signal de validation 
	du texte par l'utilisateur à la fonction d'envoi, et démarre l'animation 
	d'attente de base (Idle) du personnage Tako.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	chat_display.text += "[color=red]      Dialogue Box 3000[/color]" 
	chat_input.text_submitted.connect(tako_message)
	if tako:
		tako.play("Idle1")

func tako_message(user_text) :
	"""
	Traite la saisie de l'utilisateur et interroge le serveur IA.

	Vérifie que le message n'est pas vide, l'affiche dans l'interface (en bleu), 
	vide la barre de saisie, puis génère et envoie une requête HTTP POST asynchrone 
	vers la route '/chat' du serveur Python.

	Args:
	user_text (String) : Le texte saisi et validé par l'utilisateur.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	if user_text.strip_edges() == "":
		return
	chat_display.text += "\n[color=blue]User//: [/color]" + "[color=blue]" + user_text + "[/color]"
	chat_input.text = ""
	var url = "http://127.0.0.1:8000/chat"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({"message": user_text})
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(tako_responded.bind(request))
	request.request(url, headers, HTTPClient.METHOD_POST, body)

func tako_responded(_result, _code, _headers, body, request_node):
	"""
	Réceptionne et interprète la réponse JSON de l'IA Tako.

	Détruit le nœud de requête pour libérer la mémoire. En cas de succès (code 200), 
	extrait le texte et l'émotion générés par l'API Groq. Met à jour l'animation 
	de Tako en fonction de l'émotion, affiche la réponse, et programme un retour 
	automatique à une animation de repos (Idle) selon la longueur du texte.

	Args:
	_result (int) : Le code de résultat interne à Godot.
	_code (int) : Le code de statut de la réponse HTTP (ex: 200 pour OK).
	_headers (PackedStringArray) : Les en-têtes HTTP retournés par le serveur.
	body (PackedByteArray) : Le corps de la réponse contenant le JSON en UTF-8.
	request_node (HTTPRequest) : Le nœud responsable de la requête.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	request_node.queue_free()
	if _code != 200:
		tako_reply("Erreur de connexion. Mes circuits principaux sont débranchés.")
		tako.play("Bug")
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json and json.has("answer") and json.has("emotion"):
		var texte_ia = json["answer"]
		var tako_face = json["emotion"]
		var emotions = ["Bug", "Dead", "Huh?", "Idle1", "Idle2", "Love", "Silly", "Talk"]
		if tako_face in emotions:
			tako.play(tako_face)
		else:
			tako.play("Talk")
		tako_reply(texte_ia)
		var lecture_time = max(texte_ia.length() *0.05, 1.5)
		get_tree().create_timer(lecture_time).timeout.connect(func():
			var random = randi_range(1,2)
			if random == 1 :
				tako.play("Idle1")
			elif random == 2:
				tako.play("Idle2"))
	else:
		tako_reply("Erreur avec Tako")
		tako.play("Huh?")

func tako_reply(tako_text):
	"""
	Formate et affiche la réponse textuelle de l'IA dans l'interface.

	Ajoute un retour à la ligne, le préfixe 'Tako//:' et applique une coloration 
	verte au texte via les balises BBCode pour différencier visuellement 
	l'IA des messages du joueur.

	Args:
	tako_text (String) : Le message généré par l'intelligence artificielle.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	chat_display.text += "\n[color=green]Tako//: [/color]" + "[color=green]" + tako_text + "[/color]"
