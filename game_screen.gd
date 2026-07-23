extends Node

var card_types = {
	"Five for Fives": {
		"Desc": "Gain 5 points whenever the turn countdown is a multiple of five.",
		"Cost": 1,
		"Function": proc_timer_multiple, "Parameters": [fmod,5,5]
	},
	"One for Ones": {
		"Desc": "Gain 1 point whenever the turn countdown is a multiple of one.",
		"Cost": 1,
		"Function": proc_timer_multiple, "Parameters": [fmod,1,1]
	}
}

var turns_left = 10
var score = 0

var owned_cards = {} #title: number

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Bank.card_types = card_types
	$Inventory.card_types = card_types

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start():
	self.visible = true
	score = 0
	$Score.text = "Score:\n" + str(score)
	$Bank.new_hand(3)
	turns_left = 10
	owned_cards = {}
	$Inventory.display_inventory(owned_cards)
	update_turns(0)
	
func stop():
	self.visible = false
	
func update_turns(turns_lost):
	turns_left -= turns_lost
	$"TurnsLeft".text = "Turns Remaining\n" + str(turns_left)
	if turns_left <= 0:
		game_over.emit(score)
		
	#Run Card functions
	for card in owned_cards:
		for i in range(owned_cards[card]):
			card_types[card]["Function"].call(card_types[card]["Parameters"])

func _on_buy_pressed() -> void:
	var selected_cards = []
	selected_cards = $Bank.report_selected()
	
	var total_cost = 0
	
	for card in selected_cards:
		var card_title = card.get_title()
		total_cost += card_types[card_title]["Cost"]
		
		if card_title in owned_cards:
			owned_cards[card_title] += 1
		else:
			owned_cards[card_title] = 1
	
	if selected_cards.is_empty():
		print("empty")
	
	update_turns(total_cost)
		
	$Bank.new_hand(3)
	
	$Inventory.display_inventory(owned_cards)
	
	$Score.text = "Score:\n" + str(score)

func proc_timer_multiple(parameters):
	var proc_condition = parameters[0]
	var proc_compare_to = parameters[1]
	var reward = parameters[2]
	
	print("Is ", turns_left, " a multiple of ", proc_compare_to, "?")
	
	if proc_condition.call(turns_left, proc_compare_to) == 0:
		score += int(reward)
		print("Yes!")
	else:
		print("No :(")
