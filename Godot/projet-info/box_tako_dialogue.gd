extends TextureRect

@onready var chat_input = $ChatInput
@onready var chat_display = $ChatDisplay

func _ready():
	chat_display.text += "[color=red]      Dialogue Box 3000[/color]" 
	chat_input.text_submitted.connect(tako_message)

func tako_message(user_text) :
	if user_text.strip_edges() == "":
		return
	chat_display.text += "\n[color=blue]User//: [/color]" + user_text
	chat_input.text = ""
	tako_reply("Bip boop! Je parle pas du tout...")

func tako_reply(tako_text):
	chat_display.text += "\n[color=green]Tako//: [/color]" + tako_text
