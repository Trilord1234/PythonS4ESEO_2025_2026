extends Control

var planete = [
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet1.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet2.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet3.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet4.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet5.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet6.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet7.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet8.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet9.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet10.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Planet_Sprite/Planet11.png")
]

var layer = [
	null,
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer1.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer2.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer3.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer4.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer5.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer6.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer7.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer8.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer9.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer10.png"),
	preload("res://ARTWORKS/PLANET-ARTWORK/Layer_sprite/Layer11.png"),
]

var movement = Vector2.ZERO
var limit_x = 500
var limit_y = 500
var planet_size = 100

func _ready():
	$Planete.texture = planete.pick_random()
	$Layer.texture = layer.pick_random()
	var angle = randf_range(0,2 * PI)
	var speed = randf_range(100, 250)
	movement = Vector2.RIGHT.rotated(angle) * speed

func _process(delta):
	position += movement * delta
	if position.x <= 0 or position.x >= (limit_x - planet_size):
		movement.x *= -1
	if position.y <= 0 or position.y >= (limit_y - planet_size):
		movement.y *= -1
