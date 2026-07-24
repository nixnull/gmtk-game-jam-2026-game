extends Node

var card_types = {
	"One for Ones": {
		"Desc": "Gain $100 whenever years left is a multiple of one.",
		"Cost": 1,
		"Type": "birch",
		"Function": proc_timer_multiple, "Parameters": [fmod,1,100]
	},
	"Two for Twos": {
		"Desc": "Gain $200 whenever years left is a multiple of two.",
		"Cost": 2,
		"Type": "birch",
		"Function": proc_timer_multiple, "Parameters": [fmod,2,200]
	},
	"Three for Threes": {
		"Desc": "Gain $300 whenever years left is a multiple of three.",
		"Cost": 3,
		"Type": "birch",
		"Function": proc_timer_multiple, "Parameters": [fmod,3,300]
	},
	"Five for Fives": {
		"Desc": "Gain $500 whenever years left is a multiple of five.",
		"Cost": 5,
		"Type": "birch",
		"Function": proc_timer_multiple, "Parameters": [fmod,5,500]
	},
	"Seven for Sevens": {
		"Desc": "Gain $700 whenever years left is a multiple of seven.",
		"Cost": 7,
		"Type": "birch",
		"Function": proc_timer_multiple, "Parameters": [fmod,7,700]
	},
	"Evens Demons": {
		"Desc": "Gain $500 on even years, lose $250 on odd years.",
		"Cost": 2,
		"Type": "birch",
		"Function": proc_on_even, "Parameters": [500,-250]
	},
	"Odds Gods": {
		"Desc": "Gain $500 on odd years, lose $250 on even years.",
		"Cost": 2,
		"Type": "birch",
		"Function": proc_on_odd, "Parameters": [500,-250]
	},

	"Prime Meridian": {
		"Desc": "Gain the number of years left as money if the years left is prime.",
		"Cost": 4,
		"Type": "willow",
		"Function": proc_is_prime, "Parameters": []
	},

	"Third Eye": {
		"Desc": "Fae offer one more boon.",
		"Cost": 4,
		"Type": "willow",
		"Function": proc_do_nothing, "Parameters": []
	},
	
		"Second Lease on Life": {
		"Desc": "Trade in $1000 for 10 years back.",
		"Cost": -10,
		"Type": "willow",
		"Function": proc_regain_years, "Parameters": [10000]
	},

}

var turns_left = 50
var score = -1000

var owned_cards = {} #title: number

signal game_over

var selected_cards = []
var total_selected_cost = 0

var BASE_HAND = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Bank.card_types = card_types
	$Inventory.card_types = card_types

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	selected_cards = $Bank.report_selected()
	total_selected_cost = 0
	
	for card in selected_cards:
		var card_title = card.get_title()
		total_selected_cost += card_types[card_title]["Cost"]
	
	if selected_cards.is_empty():
		$ScoreSubtractingLabel.set("theme_override_colors/default_color", Color(0.996, 0.0, 0.164, 1.0))
		$ScoreSubtractingLabel.text = "Select at least one boon."
	else:
		var selection_str = ""
		if total_selected_cost >= 0:
			$ScoreSubtractingLabel.set("theme_override_colors/default_color", Color(0.996, 0.0, 0.164, 1.0))
			selection_str += "-"
		else:
			$ScoreSubtractingLabel.set("theme_override_colors/default_color", Color(0.064, 0.632, 0.422, 1.0))
			selection_str += "+"
		selection_str += str(abs(total_selected_cost)) + " year"
		
		if total_selected_cost not in [-1,1]:
			selection_str += "s"
		
		$ScoreSubtractingLabel.text = selection_str
	
func start():
	self.visible = true
	update_score(-200000, true)
	$Bank.new_hand(BASE_HAND)
	turns_left = 50
	owned_cards = {}
	$Inventory.display_inventory(owned_cards)
	update_turns(0)
	
func stop():
	self.visible = false
	
func update_turns(turns_lost):
	turns_left -= turns_lost
	$"TurnsLeft".text = "Years Remaining\n" + str(turns_left)
	if turns_left <= 0:
		game_over.emit(score)
		
	#Run Card functions
	for card in owned_cards:
		for i in range(owned_cards[card]):
			card_types[card]["Function"].call(card_types[card]["Parameters"])

func update_score(amount, setting=false):
	var valiance = ""
	if setting:
		score = amount
	else:
		score += amount
	if score >= 0:
		valiance = "Profit"
		$Score.set("theme_override_colors/default_color", Color(0.064, 0.632, 0.422, 1.0))
	else:
		valiance = "Debt"
		$Score.set("theme_override_colors/default_color", Color(0.996, 0.0, 0.164, 1.0))
		
	$Score.text = valiance + "\n$" + str(score)
	
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
	else:
		$BuyAudio.play()
		update_turns(total_cost)
		
		var cards_to_draw = BASE_HAND
		
		if "Third Eye" in owned_cards:
			cards_to_draw += owned_cards["Third Eye"]
		$Bank.new_hand(cards_to_draw)
		
		$Inventory.display_inventory(owned_cards)
		
		print("Ok, ", turns_left, " years left...")
	
func proc_is_prime(parameters):
	var number = turns_left
	var is_prime = true
	
	if number in [0,1]:
		is_prime = false
	elif number == 2:
		is_prime = true
	else:
		for i in range(2,floor(number/2)):
			if fmod(number, i) == 0:
				is_prime = false
	
	print(number, " is prime? ", is_prime)
	if is_prime:
		update_score(turns_left)

func proc_timer_multiple(parameters):
	var proc_condition = parameters[0]
	var proc_compare_to = parameters[1]
	var reward = parameters[2]
	
	print("Is ", turns_left, " a multiple of ", proc_compare_to, "?")
	
	if proc_condition.call(turns_left, proc_compare_to) == 0:
		update_score(int(reward))
		print("Yes!")
	else:
		print("No :(")

func proc_do_nothing(parameters):
	pass

func proc_on_even(parameters):
	if fmod(turns_left, 2) == 0:
		update_score(parameters[0])
	else:
		update_score(parameters[1])

func proc_on_odd(parameters):
	if fmod(turns_left, 2) != 0:
		update_score(parameters[0])
	else:
		update_score(parameters[1])
		
func proc_regain_years(parameters):
	update_score(-parameters[0])
	owned_cards.erase("Second Lease on Life")
