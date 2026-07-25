extends Node2D

var card_scene = load("res://card.tscn")

var inventory = {}

var card_types

var card_size = 250

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_inventory(owned_cards):
	for child in inventory: #clear all the previously displayed cards
		inventory[child].visible = false
		inventory[child].queue_free()
	
	inventory = {}
	print(owned_cards)
	var card_count = owned_cards.size()
	var scaling_factor = pow(0.978, card_count)
	var scaling_vector = Vector2(scaling_factor, scaling_factor)
	var this_one = 0
	for card in owned_cards:
		var card_inst = card_scene.instantiate()
		add_child(card_inst)
		card_inst.set_card_info(card, card_types[card])
		card_inst.scale = scaling_vector
		inventory[card] = card_inst
		var x_pos
		if fmod(card_count, 2) == 0:
			x_pos = ((card_count / 2) - this_one - .5) * (card_size + 10) * scaling_factor
		else:
			x_pos = ((card_count / 2) - this_one) * (card_size + 10) * scaling_factor
		this_one += 1
		
		card_inst.position.x += x_pos
		
		if "Max" in card_types[card]:
			card_inst.set_count(str(owned_cards[card]) + "/" + str(card_types[card]["Max"]))
		else:
			card_inst.set_count(str(owned_cards[card]))
		
func animate_card(card, bad = false):
	inventory[card].play_animation(bad)
	
func animate_negated_card(card):
	inventory[card].play_negate_animation()
	
func show_card_score(card, score):
	inventory[card].show_score(score)
