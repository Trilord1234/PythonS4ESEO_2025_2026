extends TextureRect

@onready var chat_input = $ChatInput
@onready var chat_display = $ChatDisplay

func _ready():
	chat_display.text += "[color=red]      Dialogue Box 3000[/color]" 
	chat_input.text_submitted.connect(tako_message)

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
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json and json.has("answer"):
		var texte_ia = json["answer"]
		tako_reply(texte_ia)
	else:
		tako_reply("Erreur avec Tako")

func tako_reply(tako_text):
	chat_display.text += "\n[color=green]Tako//: [/color]" + "[color=green]" + tako_text + "[/color]"
