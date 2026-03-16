extends Node2D

var planet = ""

func _ready():
	var planet_list = GlobalData.univers_visual.keys()
	planet = planet_list.pick_random()
	
