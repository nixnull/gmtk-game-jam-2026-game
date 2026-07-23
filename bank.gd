extends Node2D

var drawn_cards = []
var selected_cards = []

var card_types

var card_scene = load("res://card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_cards(cards_to_draw) -> void:
	drawn_cards = []
	
	var i = 0
	
	while i < cards_to_draw:
		var card_inst = card_scene.instantiate()
		var rand_card = card_types.keys()[randi() % card_types.size()]
		add_child(card_inst)
		card_inst.set_card_type(rand_card, card_types[rand_card]["Desc"])
		drawn_cards.append(card_inst)
		
		var x_pos = ((cards_to_draw / 2) - i) * 260
		
		card_inst.position.x += x_pos
		
		i += 1		
		
func report_selected():
	var selected = []
	for child in drawn_cards:
		if child.selected:
			selected.append(child)
	return selected
	
func new_hand(card_count):
	for child in drawn_cards:
		child.queue_free()
	self.draw_cards(card_count)
