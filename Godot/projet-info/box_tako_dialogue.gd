extends TextureRect

@onready var chat_input = $ChatInput
@onready var chat_display = $ChatDisplay
@onready var  tako = $"../../../Tako Manager/Tako"

func _ready():
	chat_display.text += "[color=red]      Dialogue Box 3000[/color]" 
	chat_input.text_submitted.connect(tako_message)
	if tako:
		tako.play("Idle1")

func tako_message(user_text) :
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
	chat_display.text += "\n[color=green]Tako//: [/color]" + "[color=green]" + tako_text + "[/color]"
