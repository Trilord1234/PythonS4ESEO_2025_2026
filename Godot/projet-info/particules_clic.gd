extends GPUParticles2D

func _ready():
	"""
	Gère le cycle de vie d'un effet de particules à usage unique.

	Dès l'apparition du nœud dans la scène, l'émission des particules démarre 
	automatiquement. Une fois l'animation totalement terminée (via le signal 
	'finished'), le nœud s'autodétruit proprement (queue_free) pour éviter 
	toute fuite de mémoire.

	Args:
	Aucun.

	Returns:
	void : Ne retourne aucune valeur.
	"""
	emitting = true
	finished.connect(queue_free)
