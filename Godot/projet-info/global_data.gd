extends Node

var universe = {}
var scanned_planets = []

"""
Réinitialise la mémoire et l'état du serveur backend (Python / IA).

Cette fonction envoie une requête HTTP POST avec un corps JSON vide ("{}")
à l'API locale pour ordonner au serveur de vider son cache ou son historique
actuel. Elle nettoie ensuite le nœud de requête silencieusement, sans attendre
de données en retour.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func erase_python_memory():
	var url = "http://127.0.0.1:8000/clear"
	var entetes = ["Content-Type: application/json"]
	var requeste_clear = HTTPRequest.new()
	add_child(requeste_clear)
	requeste_clear.request_completed.connect(func(_result, _response_code, _headers, _body): requeste_clear.queue_free())
	requeste_clear.request(url, entetes, HTTPClient.METHOD_POST, "{}")


var server_pid = 0

"""
Initialise la scène et gère le lancement automatique du serveur backend.

Cette fonction construit le chemin absolu vers le serveur autonome
('Serveur_Tako_Space.exe') situé dans le même dossier que le jeu.
Si le jeu est exécuté depuis l'éditeur Godot, elle ignore le lancement
et demande à l'utilisateur de démarrer le serveur manuellement.
S'il s'agit d'une version exportée du jeu, elle lance le serveur en
arrière-plan et enregistre son identifiant de processus (PID) pour
pouvoir le gérer ultérieurement.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func _ready():
	var chemin_dossier = OS.get_executable_path().get_base_dir()
	var chemin_serveur = chemin_dossier + "/Serveur_Tako_Space.exe"
	if OS.has_feature("editor"):
		print("Mode Éditeur : Pense à lancer le serveur Python manuellement !")
		return
	server_pid = OS.create_process(chemin_serveur, [])
	print("Serveur Tako démarré avec le PID : ", server_pid)

"""
Intercepte les événements système pour garantir une fermeture propre du jeu et du serveur.

Cette fonction native de Godot écoute les notifications de bas niveau. Lorsqu'elle
détecte une requête de fermeture de la fenêtre (par exemple, si le joueur clique
sur la croix 'X'), elle vérifie si un processus serveur a été lancé précédemment.
Si c'est le cas, elle force l'arrêt de ce processus externe avant de fermer
définitivement l'application Godot, évitant ainsi les processus fantômes.

Args:
what (int): L'identifiant (constante) de la notification système envoyée par le moteur.

Returns:
void : Ne retourne aucune valeur.
"""

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if server_pid > 0:
			OS.kill(server_pid)
		get_tree().quit()
