extends Node

var card_types = {
	"One for Ones": {
		"Desc": "Gain $1 whenever years left is a multiple of one.",
		"Cost": 1,
		"Function": proc_timer_multiple, "Parameters": [fmod,1,1]
	},
	"Two for Twos": {
		"Desc": "Gain $2 whenever years left is a multiple of two.",
		"Cost": 1,
		"Function": proc_timer_multiple, "Parameters": [fmod,2,2]
	},
	"Three for Threes": {
		"Desc": "Gain $3 whenever years left is a multiple of three.",
		"Cost": 1,
		"Function": proc_timer_multiple, "Parameters": [fmod,3,3]
	},
	"Five for Fives": {
		"Desc": "Gain $5 whenever years left is a multiple of five.",
		"Cost": 1,
		"Function": proc_timer_multiple, "Parameters": [fmod,5,5]
	},
	"Seven for Sevens": {
		"Desc": "Gain $7 whenever years left is a multiple of seven.",
		"Cost": 1,
		"Function": proc_timer_multiple, "Parameters": [fmod,7,7]
	},

	"Prime Meridian": {
		"Desc": "Gain the number of years left as money if the years left is prime.",
		"Cost": 1,
		"Function": proc_is_prime, "Parameters": []
	},

}

var turns_left = 50
var score = -1000

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
	update_score(-2000, true)
	$Bank.new_hand(3)
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
		
	$Score.text = valiance + "\n" + str(score)
	
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
		update_turns(total_cost)
			
		$Bank.new_hand(3)
		
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
