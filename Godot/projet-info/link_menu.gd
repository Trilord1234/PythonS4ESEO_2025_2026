extends Control

var open = false

func _ready() :
	$".".visible = false
	$"../../../Button Manager/DeleteAll_Link".visible = false

func LinkMenuReload(planet_source):
	var container = $ScrollContainer/VBoxContainer
	for child in container.get_children():
		child.queue_free()
	var box = $"../../../Background Manager/PlaneteBox/HitBox/HitBox_Box"
	var line_created = get_node("/root/Creation").line_created
	
	for planet in box.get_children():
		if "data_IA_save" in planet:
			if planet.data_IA_save != null and planet.data_IA_save.has("name"):
				
				if planet == planet_source:
					continue
					
				var link_already_created = false
				for dict in line_created:
					if (dict["Planet_A"] == planet_source and dict["Planet_B"] == planet) or (dict["Planet_A"] == planet and dict["Planet_B"] == planet_source):
						link_already_created = true
						break
				if link_already_created == true:
					continue
					
				var ligne = HBoxContainer.new()
				ligne.add_theme_constant_override("separation", 10)
				ligne.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var box_picture = Control.new()
				box_picture.custom_minimum_size = Vector2(40,40)
				
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
				text_planet.add_theme_font_size_override("font_size", 14)
				
				var btn_link = Button.new()
				btn_link.text = "Link"
				btn_link.custom_minimum_size = Vector2(70, 30)
				btn_link.size_flags_horizontal = Control.SIZE_SHRINK_END
				btn_link.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				
				var btn_color = StyleBoxFlat.new()
				btn_color.bg_color = Color(0.18, 0.40, 0.58)
				btn_color.corner_radius_top_left = 5
				btn_color.corner_radius_top_right = 5
				btn_color.corner_radius_bottom_left = 5
				btn_color.corner_radius_bottom_right = 5
				btn_link.add_theme_stylebox_override("normal", btn_color)
				
				var btn_color_hover = btn_color.duplicate()
				btn_color_hover.bg_color = Color(0.28, 0.50, 0.68)
				btn_link.add_theme_stylebox_override("hover", btn_color_hover)
				
				btn_link.pressed.connect(func() :
					get_node("/root/Creation").create_line(planet_source, planet)
					$".".visible = false
					open = false
				)
				
				var phantom = Control.new()
				phantom.custom_minimum_size = Vector2(5,0)
				
				ligne.add_child(box_picture)
				ligne.add_child(text_planet)
				ligne.add_child(btn_link)
				ligne.add_child(phantom)
				
				container.add_child(ligne)
				
func DeleteLinkMenuReload(planet_source):
	var container = $ScrollContainer/VBoxContainer
	for child in container.get_children():
		child.queue_free()
	var box = $"../../../Background Manager/PlaneteBox/HitBox/HitBox_Box"
	var line_created = get_node("/root/Creation").line_created
	
	for planet in box.get_children():
		if "data_IA_save" in planet:
			if planet.data_IA_save != null and planet.data_IA_save.has("name"):
				
				var link = null
				for dict in line_created:
					if (dict["Planet_A"] == planet_source and dict["Planet_B"] == planet) or (dict["Planet_A"] == planet and dict["Planet_B"] == planet_source):
						link = dict
						break
				if link == null:
					continue
					
				var ligne = HBoxContainer.new()
				ligne.add_theme_constant_override("separation", 10)
				ligne.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var box_picture = Control.new()
				box_picture.custom_minimum_size = Vector2(40,40)
				
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
				text_planet.add_theme_font_size_override("font_size", 14)
				
				var btn_delink = Button.new()
				btn_delink.text = "deLink"
				btn_delink.custom_minimum_size = Vector2(70, 30)
				btn_delink.size_flags_horizontal = Control.SIZE_SHRINK_END
				btn_delink.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				
				var btn_color = StyleBoxFlat.new()
				btn_color.bg_color = Color(0.18, 0.40, 0.58)
				btn_color.corner_radius_top_left = 5
				btn_color.corner_radius_top_right = 5
				btn_color.corner_radius_bottom_left = 5
				btn_color.corner_radius_bottom_right = 5
				btn_delink.add_theme_stylebox_override("normal", btn_color)
				
				var btn_color_hover = btn_color.duplicate()
				btn_color_hover.bg_color = Color(0.28, 0.50, 0.68)
				btn_delink.add_theme_stylebox_override("hover", btn_color_hover)
				
				btn_delink.pressed.connect(func() :
					get_node("/root/Creation").delete_line(link)
					$".".visible = false
					$"../../../Button Manager/DeleteAll_Link".visible = false
					open = false
				)
				
				var phantom = Control.new()
				phantom.custom_minimum_size = Vector2(5,0)
				
				ligne.add_child(box_picture)
				ligne.add_child(text_planet)
				ligne.add_child(btn_delink)
				ligne.add_child(phantom)
				
				container.add_child(ligne)

func _on_link_pressed():
	var planet_active = get_node("/root/Creation").planet_selected
	if planet_active == null :
		return
	if open == false :
		LinkMenuReload(planet_active)
		$".".visible = true
		open = true
	else :
		$".".visible = false
		open = false

func _on_delete_link_pressed():
	var planet_active = get_node("/root/Creation").planet_selected
	if planet_active == null :
		return
	if open == false :
		DeleteLinkMenuReload(planet_active)
		$".".visible = true
		$"../../../Button Manager/DeleteAll_Link".visible = true
		open = true
	else :
		$".".visible = false
		$"../../../Button Manager/DeleteAll_Link".visible = false
		open = false
	
