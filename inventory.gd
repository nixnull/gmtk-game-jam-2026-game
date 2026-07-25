extends Node2D

var card_scene = load("res://card.tscn")

var inventory = {}

var card_types

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
	var this_one = 0
	for card in owned_cards:
		this_one += 1
		var card_inst = card_scene.instantiate()
		add_child(card_inst)
		card_inst.set_card_info(card, card_types[card])
		inventory[card] = card_inst
		var x_pos = ((card_count / 2) - this_one) * 260
		
		card_inst.position.x += x_pos
		
		card_inst.set_count(str(owned_cards[card]))
		
func animate_card(card, bad = false):
	inventory[card].play_animation(bad)
