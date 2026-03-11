extends Node2D

var planet_manager = preload("res://planete_manager.tscn")
var count = 0
var open = false

func _ready() :
	$AllPLanetMenu.visible = false
	randomize()

func _on_generation_pressed():
	count += 1
	$Info/Nb/NbPLanet.text = "NB Planet = " + str(count)
	var new_planet = planet_manager.instantiate()
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	new_planet.limit_x = box.size.x
	new_planet.limit_y = box.size.y
	new_planet.movement = Vector2(
		randf_range(100,box.size.x - 100),
		randf_range(100,box.size.y - 100)
	)
	new_planet.planet_selected.connect(_on_planet_selected)
	box.add_child(new_planet)

func _on_clear_pressed():
	count = 0
	$"Info/Nb/NbPLanet".text = "NB Planet = " + str(count)
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	for child in box.get_children():
		child.queue_free()
	erase_IA_memory()

func erase_IA_memory():
	var url = "http://127.0.0.1:8000/clear"
	var entetes = ["Content-Type: application/json"]
	var requeste_clear = HTTPRequest.new()
	add_child(requeste_clear)
	requeste_clear.request_completed.connect(func(_result, _response_code, _headers, _body): requeste_clear.queue_free())
	requeste_clear.request(url, entetes, HTTPClient.METHOD_POST, "{}")

func _on_planet_selected(targeted_planet):
	var planet_picture = $Info/InfoBox/PlanetVisual/PlanetPicture
	planet_picture.texture = targeted_planet.get_node("Planet").texture
	planet_picture.self_modulate = targeted_planet.get_node("Planet").self_modulate
	var layer_picture = $Info/InfoBox/PlanetVisual/LayerPicture
	layer_picture.texture = targeted_planet.get_node("Layer").texture
	layer_picture.self_modulate = targeted_planet.get_node("Layer").self_modulate
	$"Info/InfoBox/Label/Description".text = targeted_planet.prompt_IA
	
	if targeted_planet.data_IA_save != null:
		$"Info/InfoBox/Label/Name".text = targeted_planet.data_IA_save["name"]
		$"Info/InfoBox/Label/Type".text = "Type : " + str(targeted_planet.data_IA_save["type"])
		$"Info/InfoBox/Label/Weight".text = "Poids : " + str(targeted_planet.data_IA_save["weight"])
		$"Info/InfoBox/Label/Size".text = "Taille : " + str(targeted_planet.data_IA_save["size"])
		$"Info/InfoBox/Label/Gravity".text = "Gravité : " + str(targeted_planet.data_IA_save["gravity"])
		$"Info/InfoBox/Label/Habitable".text = "Habitable : " + str(targeted_planet.data_IA_save["habitable"])
		$"Info/InfoBox/Label/Level of danger".text = "Dangerosité : " + str(targeted_planet.data_IA_save["level of danger"])
		$"Info/InfoBox/Label/Description".text = str(targeted_planet.data_IA_save["description"])
	else:
		$"Info/InfoBox/Label/Name".text = "Analyse en cours..."
		$"Info/InfoBox/Label/Type".text = "Type : ..."
		$"Info/InfoBox/Label/Weight".text = "Poids : ..."
		$"Info/InfoBox/Label/Size".text = "Taille : ..."
		$"Info/InfoBox/Label/Gravity".text = "Gravité : ..."
		$"Info/InfoBox/Label/Habitable".text = "Habitable : ..."
		$"Info/InfoBox/Label/Level of danger".text = "Dangerosité : ..."
		$"Info/InfoBox/Label/Description".text = "Tako analyse l'atmosphère... Reclique dans un instant !"

func PlanetMenuReload():
	var container = $AllPLanetMenu/List/ScrollContainer/VBoxContainer
	for child in container.get_children():
		child.queue_free()
	var box = $"Background Manager/PlaneteBox/HitBox/HitBox_Box"
	
	for planet in box.get_children():
		if planet.data_IA_save != null and planet.data_IA_save.has("name"):
			var ligne = HBoxContainer.new()
			ligne.add_theme_constant_override("separation", 20)
			ligne.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var box_picture = Control.new()
			box_picture.custom_minimum_size = Vector2(80,80)
			
			var icone = TextureRect.new()
			icone.texture = planet.get_node("Planet").texture
			icone.self_modulate = planet.get_node("Planet").self_modulate
			icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icone.set_anchors_preset(Control.PRESET_FULL_RECT)
			
			var icone_layer = TextureRect.new()
			icone_layer.texture = planet.get_node("Layer").texture
			icone_layer.self_modulate = planet.get_node("Layer").self_modulate
			icone_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icone_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
			box_picture.add_child(icone)
			box_picture.add_child(icone_layer)
			
			var text_planet = Label.new()
			var planet_name = planet.data_IA_save["name"]
			var planet_type = planet.data_IA_save["type"]
			text_planet.text = planet_name + " - (" + planet_type + ")"
			text_planet.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			text_planet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			text_planet.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			text_planet.add_theme_font_size_override("font_size", 30)
			
			var btn_select = Button.new()
			btn_select.text = "Selectionner"
			btn_select.custom_minimum_size = Vector2(120, 50)
			btn_select.size_flags_horizontal = Control.SIZE_SHRINK_END
			btn_select.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			var btn_color = StyleBoxFlat.new()
			btn_color.bg_color = Color(0.18, 0.40, 0.58)
			btn_color.corner_radius_top_left = 5
			btn_color.corner_radius_top_right = 5
			btn_color.corner_radius_bottom_left = 5
			btn_color.corner_radius_bottom_right = 5
			btn_select.add_theme_stylebox_override("normal", btn_color)
			
			var btn_color_hover = btn_color.duplicate()
			btn_color_hover.bg_color = Color(0.28, 0.50, 0.68)
			btn_select.add_theme_stylebox_override("hover", btn_color_hover)
			
			btn_select.pressed.connect(func() :
				_on_planet_selected(planet)
			)
			
			var phantom = Control.new()
			phantom.custom_minimum_size = Vector2(5,0)
			
			ligne.add_child(box_picture)
			ligne.add_child(text_planet)
			ligne.add_child(btn_select)
			ligne.add_child(phantom)
			
			container.add_child(ligne)

func _on_planet_menu_pressed() :
	if open == false :
		PlanetMenuReload()
		$AllPLanetMenu.visible = true
		open = true
	else :
		$AllPLanetMenu.visible = false
		open = false
	
