extends Node2D

var card_scene = load("res://card.tscn")

var inventory = []

var card_types

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_inventory(owned_cards):
	for child in inventory: #clear all the previously displayed cards
		child.visible = false
		child.queue_free()
	inventory = []
	var card_count = owned_cards.size()
	var this_one = 0
	for card in owned_cards:
		this_one += 1
		var card_inst = card_scene.instantiate()
		add_child(card_inst)
		card_inst.set_card_type(card, card_types[card]["Desc"])
		inventory.append(card_inst)
		var x_pos = ((card_count / 2) - this_one) * 260
		
		card_inst.position.x += x_pos
		
		card_inst.set_happening(str(owned_cards[card]))
