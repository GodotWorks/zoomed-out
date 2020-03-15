extends Node2D

onready var colorable_area = $Playfield/ColorableArea
onready var bar = $CanvasLayer/TextureProgress
onready var player = $Hero
onready var bucket_head = $CanvasLayer/BucketGuyHead

const fruits = [
	Fruit.types.apple,
	Fruit.types.banana,
	Fruit.types.tangerine,
	Fruit.types.grapes,
	Fruit.types.pineapple,
	Fruit.types.pear,
	Fruit.types.plum
]

var next_fruit_index = 0
var next_fruit = fruits[next_fruit_index]

func prepare_next_fruit():
	next_fruit_index = (next_fruit_index + 1) % len(fruits)
	next_fruit = fruits[next_fruit_index]

onready var pickup_sfxs = [
	$Pickup1,
	$Pickup2,
	$Pickup3,
#	$Pickup4,
	$Pickup5,
#	$Pickup6,
#	$Pickup7,
#	$Pickup8
]
var pickup_sfx_i = 0

func play_pickup_sfx():
	pickup_sfxs[pickup_sfx_i].play()
	pickup_sfx_i = (pickup_sfx_i+1) % len(pickup_sfxs)

var last_chosen_thingy = null

func _ready():
	player.connect("hurt", self, "_on_player_hurt")
	randomize()
	yield(get_tree().create_timer(0.1), "timeout")
	color()

func color():
	var next_color = Fruit.get_fruit_color(next_fruit)
	
	bar.tint_progress = next_color
	bucket_head.modulate = next_color
	player.modulate = next_color
	
	prepare_next_fruit()
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	# color a random thingy within the colorable area
	var colorable_thingies = colorable_area.get_overlapping_areas()
	
	if len(colorable_thingies) == 0:
		return
		
	var chosen_thingy = colorable_thingies[randi() % len(colorable_thingies)]
	while last_chosen_thingy == chosen_thingy or chosen_thingy is Enemy or chosen_thingy.type != next_fruit:
		chosen_thingy = colorable_thingies[randi() % len(colorable_thingies)]
	last_chosen_thingy = chosen_thingy
	
	chosen_thingy.color()
	chosen_thingy.connect('touched', self, '_on_colored_thingy_touched', [chosen_thingy], CONNECT_ONESHOT)
	
func _on_colored_thingy_touched(thingy):
	bar.increase_bar(thingy.point)
	play_pickup_sfx()
	color()
	
func _on_player_hurt(quantity):
	bar.decrease_bar(quantity)

func game_over():
	print("GAME OVER")
	
func _on_TextureProgress_value_changed(value):
	if value <= 0:
		game_over()
