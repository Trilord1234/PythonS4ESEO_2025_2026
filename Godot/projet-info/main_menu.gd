extends Node2D
var particule = preload("res://particule_manager.tscn")
var time = 0.0
var delay = 0.01

"""
Initialise la scène au démarrage en réinitialisant l'interface et le serveur.

Cette fonction s'exécute lors de l'entrée du nœud dans l'arbre de la scène.
Elle masque par défaut la fenêtre pop-up des options pour ne pas obstruer
l'écran du joueur, puis fait appel au singleton 'GlobalData' pour envoyer
une requête de purge de la mémoire au serveur Python (backend).

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""
func _ready():
	$"Option Pop-up/OptionPopUp".visible = false
	GlobalData.erase_python_memory()

"""
Déclenche le démarrage du jeu en chargeant la scène de création de l'univers.

Cette fonction est exécutée lors du clic sur le bouton de démarrage (Start).
Elle fait appel à l'arbre de scène principal (SceneTree) de Godot pour basculer
immédiatement vers le fichier "res://Creation.tscn". L'ancienne scène (généralement
le menu principal) est automatiquement détruite et remplacée par la nouvelle interface.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Creation.tscn")

"""
Affiche la fenêtre contextuelle des options à l'écran.

Cette fonction est déclenchée lorsque le joueur clique sur le bouton "Option"
(ou "Paramètres"). Elle modifie la propriété de visibilité du nœud 'OptionPopUp'
pour le faire apparaître par-dessus l'interface actuelle, permettant ainsi
à l'utilisateur de modifier ses réglages.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func _on_option_pressed():
	$"Option Pop-up/OptionPopUp".visible = true

"""
Masque la fenêtre contextuelle des options pour retourner à l'écran principal.

Cette fonction est déclenchée lorsque le joueur clique sur le bouton "Retour"
ou "Fermer" depuis le menu des paramètres. Elle modifie la propriété de
visibilité du nœud 'OptionPopUp' pour le cacher, redonnant ainsi au joueur
l'accès complet à l'interface en arrière-plan sans avoir à recharger la scène.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func _on_back_pressed():
	$"Option Pop-up/OptionPopUp".visible = false

"""
Quitte l'application et ferme complètement le jeu.

Cette fonction est déclenchée lors du clic sur le bouton "Quitter".
Elle envoie une instruction à l'arbre de scène principal (SceneTree)
pour terminer son exécution, ce qui ferme la fenêtre du jeu proprement
et libère toutes les ressources allouées par Godot.

Args:
Aucun.

Returns:
void : Ne retourne aucune valeur.
"""

func _on_quit_pressed():
	get_tree().quit()

"""
Gère l'apparition continue de particules sous le curseur lors du maintien du clic gauche.

Cette fonction s'exécute à chaque frame. Elle agit comme un chronomètre (timer)
lorsque le bouton gauche de la souris est maintenu enfoncé. Chaque fois que le temps
cumulé ('delta') dépasse le délai ('delay') configuré, elle instancie une nouvelle
particule à la position globale actuelle de la souris. Relâcher le clic réinitialise
le compteur pour garantir qu'une particule apparaisse instantanément au prochain clic.

Args:
delta (float): Le temps écoulé (en secondes) depuis le rendu de la frame précédente, utilisé pour le calcul du délai.

Returns:
void : Ne retourne aucune valeur.
"""

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		time += delta
		if time >= delay:
			var clone = particule.instantiate()
			clone.global_position = get_global_mouse_position()
			add_child(clone)
			time = 0.0
	else:
		time = delay
