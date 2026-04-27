extends Node

var universe = {}
var scanned_planets = []

func erase_python_memory():
	var url = "http://127.0.0.1:8000/clear"
	var entetes = ["Content-Type: application/json"]
	var requeste_clear = HTTPRequest.new()
	add_child(requeste_clear)
	requeste_clear.request_completed.connect(func(_result, _response_code, _headers, _body): requeste_clear.queue_free())
	requeste_clear.request(url, entetes, HTTPClient.METHOD_POST, "{}")


var server_pid = 0
func _ready():
	var chemin_dossier = OS.get_executable_path().get_base_dir()
	var chemin_serveur = chemin_dossier + "/Serveur_Tako_Space.exe"
	if OS.has_feature("editor"):
		print("Mode Éditeur : Pense à lancer le serveur Python manuellement !")
		return
	server_pid = OS.create_process(chemin_serveur, [])
	print("Serveur Tako démarré avec le PID : ", server_pid)
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if server_pid > 0:
			OS.kill(server_pid)
		get_tree().quit()
