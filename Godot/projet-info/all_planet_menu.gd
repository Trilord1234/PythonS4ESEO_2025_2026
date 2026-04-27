extends Control

var open = false

func _ready() :
	$".".visible = false

func PlanetMenuReload():
	var container = $"List/ScrollContainer/VBoxContainer"
	for child in container.get_children():
		child.queue_free()
	var box = $"../Background Manager/PlaneteBox/HitBox/HitBox_Box"
	
	for planet in box.get_children():
		if "data_IA_save" in planet:
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
					get_parent()._on_planet_selected(planet)
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
		$".".visible = true
		$"../Button Manager/ButtonBox".visible = false
		$"../Button Manager/LoadJSON".visible = false
		$"../Button Manager/Next".visible = false
		open = true
	else :
		$".".visible = false
		$"../Button Manager/ButtonBox".visible = true
		$"../Button Manager/LoadJSON".visible = true
		$"../Button Manager/Next".visible = true
		open = false
