extends TextureRect

var target_planet = ""

@onready var radar_planet = $Radar/Planet
@onready var radar_layer = $Radar/Layer
@onready var log_display = $"Log&All/Texte Log"
@onready var btn_scan = $"../../../Button Manager/Scan"

func _ready():
	if log_display:
		log_display.text = "> SYSTÈME DÉMARRÉ.\n> Radar en attente..."
	hide_radar()
	
func prepare_new_scan(planet_name: String):
	target_planet = planet_name
	if GlobalData.scanned_planets.has(target_planet):
		log_display.text += "\n> Arrivée en orbite.\n> Données locales récupérées depuis la mémoire."
		display_planet_data() 
	else:
		hide_radar()
		log_display.text += "\n> Arrivée en orbite.\n> Prêt pour le scan."

func hide_radar():
	if radar_planet and radar_layer:
		radar_planet.hide()
		radar_layer.hide()

func _on_scan_pressed():
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
	display_planet_data()
	
func display_planet_data():
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
