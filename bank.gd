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

func draw_cards(draw_count, inventory) -> void:
	for child in drawn_cards:
		child.queue_free()
	drawn_cards = []
		
	var i = 0
		
	while i < draw_count:
		var card_inst 
		var rand_card
		var suitable = false
		var drawn_counts = {}
		
		while not suitable:
			suitable = true
			rand_card = card_types.keys()[randi() % card_types.size()]
			if "Max" in card_types[rand_card]:
				if rand_card in inventory:
					var available = 0
					if rand_card in drawn_counts:
						available = drawn_counts[rand_card]
					if (inventory[rand_card] + available) >= card_types[rand_card]["Max"]:
						suitable = false
						
			
		card_inst = card_scene.instantiate()
		add_child(card_inst)
		
		card_inst.set_card_info(rand_card, card_types[rand_card])
		card_inst.show_cost()
		if rand_card not in drawn_counts:
			drawn_counts[rand_card] = 1
		else:
			drawn_counts += 1
		
		drawn_cards.append(card_inst)
		var x_pos = ((draw_count / 2) - i) * 260
		
		drawn_cards[i].position.x += x_pos
		i+=1
	
	print("did we get here")
		
func report_selected():
	var selected = []
	for child in drawn_cards:
		if child.selected:
			selected.append(child)
	return selected
