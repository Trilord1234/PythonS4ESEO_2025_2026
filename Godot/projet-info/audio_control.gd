extends HSlider

@export var audio_bus_name: String
var audio_bus_id

func _ready():
	"""
	Initialise l'identifiant du bus audio au chargement du script.

	Cette fonction récupère l'index numérique unique du bus audio spécifié par 
	la variable 'audio_bus_name'. Cet identifiant permet de cibler précisément 
	le bon canal (Master, Musique ou SFX) pour les modifications ultérieures.

	Args:
	Aucun : S'appuie sur la variable de classe 'audio_bus_name'.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

func _on_value_changed(volume):
	"""
	Ajuste le volume du bus audio lors d'un changement de valeur du Slider.

	La fonction transforme la valeur linéaire reçue (0.0 à 1.0) en décibels 
	via 'linear_to_db'. Ce changement logarithmique assure que la perception 
	auditive de la baisse ou de la hausse du son soit fluide et naturelle.

	Args:
	volume (float) : La nouvelle valeur issue du contrôle utilisateur (Slider).

	Returns:
	void : Ne retourne aucune valeur.
	"""
	var db = linear_to_db(volume)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
