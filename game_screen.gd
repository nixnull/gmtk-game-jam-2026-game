extends Node

var card_types = {
	"One for Ones": {
		"Desc": "Gain $100 whenever years left is a multiple of one.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_timer_multiple.bind(1),
		"Boon": effect_flat_score_change.bind(100)
	},
	"Two for Twos": {
		"Desc": "Gain $200 whenever years left is a multiple of two.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_timer_multiple.bind(2),
		"Boon": effect_flat_score_change.bind(200)
	},
	"Three for Threes": {
		"Desc": "Gain $300 whenever years left is a multiple of three.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_on_timer_multiple.bind(3),
		"Boon": effect_flat_score_change.bind(300)
	},
	"Five for Fives": {
		"Desc": "Gain $500 whenever years left is a multiple of five.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_on_timer_multiple.bind(5),
		"Boon": effect_flat_score_change.bind(500)
	},
	"Seven for Sevens": {
		"Desc": "Gain $700 whenever years left is a multiple of seven.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_on_timer_multiple.bind(7),
		"Boon": effect_flat_score_change.bind(700)
	},
	"Evens Demons": {
		"Desc": "Gain $500 on even years, lose $400 on odd years.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_even,
		"Boon": effect_flat_score_change.bind(500),
		"Bad Proc": proc_on_odd,
		"Penalty": effect_flat_score_change.bind(-400)
	},
	"Odds Gods": {
		"Desc": "Gain $500 on odd years, lose $400 on even years.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_odd,
		"Boon": effect_flat_score_change.bind(500),
		"Bad Proc": proc_on_even,
		"Penalty": effect_flat_score_change.bind(-400)
	},
	"Prime Meridian": {
		"Desc": "Gain the number of years left as money if the years left is prime.",
		"Type": "birch",
		"Cost": calcost_birch.bind(3),
		"Proc": proc_is_prime,
		"Boon": effect_prime_meridian
	},
	"Perfect Squares": {
		"Desc": "Gain the number of years left as money if the years left is a perfect square.",
		"Type": "birch",
		"Cost": calcost_birch.bind(3),
		"Proc": proc_on_perfect_square,
		"Boon": effect_square_root_score
	},
	"Joker": {
		"Desc": "Gain $500 on funny numbered years.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_funny_number,
		"Boon": effect_flat_score_change.bind(500)
	},

	"Third Eye": {
		"Desc": "Fae offer one more boon.",
		"Type": "willow",
		"Cost": calcost_thirdeye.bind(),
		"Max": 4,
		"Tags": ["Organ"]
	},
	"Second Lease on Life": {
		"Desc": "Buy some years, and pay for it every year after.",
		"Type": "edelwood",
		"Cost": calcost_birch.bind(-10),
		"Bad Proc": proc_always,
		"Penalty": effect_edelwood,
		"Max": 10
	},
	"Refreshing Potion": {
		"Desc": "Refreshes your palate, and your store.",
		"Type": "willow",
		"Cost": calcost_birch.bind(3),
		"Max": 3
	},
	"Live Fast, Die Young": {
		"Desc": "Trade half your remaining lives for $1000 each",
		"Type": "birch",
		"Cost": calcost_tradehalf,
		"Proc": on_buy.bind("Live Fast, Die Young"),
		"Boon": effect_tradehalf
	},
	"Cryptid Currency": {
		"Desc": "Double all your winnings, but triple all your losses",
		"Type": "willow",
		"Cost": calcost_birch.bind(10),
		"Max": 1,
		"PostProc": proc_always,
		"PostEffect": effect_crypto
	},
	"Vestigial Wings": {
		"Desc": "You ignore the lowest penalty applied each turn.",
		"Type": "willow",
		"Cost": calcost_birch.bind(5),
		"Max": 1,
		"PostProc": proc_always,
		"PostEffect": effect_wings,
		"Tags": ["Organ"]
	},
	"Monkey's Paw": {
		"Desc": "Each turn, if less than 2 types of cards would score, they score twice.",
		"Type": "willow",
		"Cost": calcost_birch.bind(8),
		"Max": 1,
		"PostProc": proc_always,
		"PostEffect": effect_monkey_paw,
		"Tags": ["Organ"]
		},
	"Organ Donation": {
		"Desc": "Sell all of your fae organs and body parts for $1000 each.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"PreProc": proc_always,
		"PreEffect": effect_organ_donation
	}
}

var card_scene = load("res://card.tscn")

var turns_left = 50
var score = -1000

var owned_cards = {} #title: number

signal game_over

var selected_cards = []
var total_selected_cost = 0
var turns_left_before_procs = 0

var BASE_HAND = 3

var drawn_cards = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlacementControl/Bank.card_types = card_types
	$PlacementControl/Inventory.card_types = card_types
	#var test = proc_on_timer_multiple.bind(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	selected_cards = $PlacementControl/Bank.report_selected()
	total_selected_cost = 0
	
	for card in selected_cards:
		total_selected_cost += card.get_cost()
	
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
	turns_left = 50
	owned_cards = {}
	$PlacementControl/Bank.draw_cards(BASE_HAND, owned_cards)
	$PlacementControl/Inventory.display_inventory(owned_cards)
	update_turns(0)
	$PlacementControl/Refresh.hide()
	
func stop():
	self.visible = false
	
func update_turns(turns_lost):
	var pending_scores = []
	var turn_net_score = 0
	var end_of_scoring_queue = []
	
	turns_left_before_procs = turns_left
	turns_left -= turns_lost
	$"TurnsLeft".text = "Years Remaining\n" + str(turns_left)
		
	print("Ok, ", turns_left, " years left...")
	
	#Run Card functions
	var card_score_changes = {}
	#PreEffects
	for card in owned_cards:
		for i in range(owned_cards[card]):
			if "PreProc" in card_types[card]:
				print("Check for preproc of " + card + "#" + str(i) + "...")
				if card_types[card]["PreProc"].call():
					print("It preprocs!")
					$PlacementControl/Inventory.animate_card(card, false)
					card_score_changes[card] = card_types[card]["PreEffect"].call()["Score"]
	
	#Boons and Penalties	
	for card in owned_cards:
		for i in range(owned_cards[card]):
			if "Proc" in card_types[card]:
				print("Check for proc of " + card + "#" + str(i) + "...")
				if card_types[card]["Proc"].call():
					print("It procs!")
					$PlacementControl/Inventory.animate_card(card, false)
					var effects = card_types[card]["Boon"].call()
					print(effects)
					if card in card_score_changes:
						card_score_changes[card] += effects["Score"]
					else:
						card_score_changes[card] = effects["Score"]
			if "Bad Proc" in card_types[card]:
				print("Check for bad proc of " + card + "#" + str(i) + "...")
				if card_types[card]["Bad Proc"].call():
					print("It bad procs!")
					$PlacementControl/Inventory.animate_card(card, true)
					var effects = card_types[card]["Penalty"].call()
					
					if card in card_score_changes:
						card_score_changes[card] += effects["Score"]
					else:
						card_score_changes[card] = effects["Score"]
	
	#Post Effects
	for card in owned_cards:
		for i in range(owned_cards[card]):
			if "PostProc" in card_types[card]:
				print("Check for postproc of " + card + "#" + str(i) + "...")
				if card_types[card]["PostProc"].call():
					print("It postprocs!")
					$PlacementControl/Inventory.animate_card(card, false)
					print(card)
					card_score_changes = card_types[card]["PostEffect"].call(card_score_changes)
			
	#Apply scores
	#print(card_score_changes)
	for card in card_score_changes:
		if card in owned_cards: #Handle cards that were erased
			$PlacementControl/Inventory.show_card_score(card, card_score_changes[card])
		turn_net_score += card_score_changes[card]
		
	#print(card_score_changes)
	update_score(turn_net_score)
	
	if turns_left <= 0:
		game_over.emit(score)

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
	if amount >= 0:
		$ScoreChange.set("theme_override_colors/default_color", Color(0.064, 0.632, 0.422, 1.0))
		$ScoreChange.text = "+" + str(amount)
	else:
		$ScoreChange.set("theme_override_colors/default_color", Color(0.996, 0.0, 0.164, 1.0))
		$ScoreChange.text = str(amount)
	if not setting:
		$ScoreChange.show()
		$ScoreChangeShowTimer.start()
	
func _on_buy_pressed() -> void:
	selected_cards = $PlacementControl/Bank.report_selected()
	
	var total_cost = 0
	
	for card in selected_cards:
		var card_title = card.get_title()
		total_cost += card.get_cost()
		
		if card_title in owned_cards:
			owned_cards[card_title] += 1
		else:
			owned_cards[card_title] = 1
			if card_title == "Refreshing Potion":
				$PlacementControl/Refresh.show()
	
	if selected_cards.is_empty():
		print("empty")
	else:
		$BuyAudio.play()
		$PlacementControl/Inventory.display_inventory(owned_cards)
		update_turns(total_cost)
		var to_draw = BASE_HAND + owned_cards.get("Third Eye",0)
		$PlacementControl/Bank.draw_cards(to_draw, owned_cards)
	
func proc_is_prime():
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
	
	return is_prime

func proc_on_timer_multiple(number):
	return fmod(turns_left, number) == 0
	
func proc_funny_number():
	return turns_left in [7, 13, 21, 67, 69, 420]
	
func calcost_birch(cost):
	return cost

func calcost_thirdeye():
	if "Third Eye" in owned_cards:
		return owned_cards["Third Eye"] * 2
	else:
		return 1

func calcost_edelwood():
	if "Third Eye" in owned_cards:
		return -10 + owned_cards["Third Eye"]
	else:
		return -10

func proc_always():
	return true

func proc_on_even():
	return fmod(turns_left, 2) == 0

func proc_on_odd():
	return not proc_on_even()
	
func effect_prime_meridian():
	return {"Score": turns_left * 100}

func effect_edelwood():
	return {"Score": -100}
	
func effect_potion():
	var to_draw = BASE_HAND + owned_cards.get("Third Eye",0)
	$PlacementControl/Bank.draw_cards(to_draw, owned_cards)
	return {"Score": 0}

func _on_refresh_pressed() -> void:
	effect_potion()
	if owned_cards.get("Refreshing Potion",0) > 1:
		owned_cards["Refreshing Potion"] -= 1
	else:
		owned_cards.erase("Refreshing Potion")
		$PlacementControl/Refresh.hide()
	$PlacementControl/Inventory.display_inventory(owned_cards)

func effect_tradehalf():
	var half_turns_left = int(round(turns_left_before_procs * 0.5))
	var tradehalf_big_money = half_turns_left * 1000
	return {"Score": tradehalf_big_money}
	
func calcost_tradehalf():
	return int(round(turns_left * 0.5))
	
func on_buy(proc_card_name):
	var bought_card_titles = []
	for bought_card in selected_cards:
		bought_card_titles.append([bought_card.get_title(),bought_card])
	for bought_card_packed in bought_card_titles:
		if proc_card_name == bought_card_packed[0]:
			var bought_card_index = selected_cards.find(bought_card_packed[1])
			selected_cards.pop_at(bought_card_index)
			return true

func effect_crypto(crypto_score_changes):
	for card in crypto_score_changes:
		var value = crypto_score_changes[card]
		if value > 0:
			crypto_score_changes[card] = value * 2
		else:
			crypto_score_changes[card] = value * 3
	return crypto_score_changes
	
func effect_flat_score_change(score_change):
	return {"Score": score_change}
	
func proc_on_perfect_square():
	return fmod(sqrt(turns_left), 2) == 0

func effect_square_root_score():
	return {"Score": turns_left * 100}
	
func effect_wings(wings_card_scores):
	var lowest_penalty = 0
	for card in wings_card_scores:
		var value = wings_card_scores[card]
		if value < 0 and (lowest_penalty == 0 or lowest_penalty < value):
			lowest_penalty = value
	for card in wings_card_scores:
		if wings_card_scores[card] == lowest_penalty:
			wings_card_scores.erase(card)
			$PlacementControl/Inventory.animate_negated_card(card)
			break
	return wings_card_scores
		
func effect_monkey_paw(paw_card_scores):
	var positive_triggers = 0
	for card in paw_card_scores:
		if paw_card_scores[card] > 0:
			positive_triggers += 1
	if positive_triggers < 3:
		for card in paw_card_scores:
			if paw_card_scores[card] > 0:
				paw_card_scores[card] *= 2
	else:
		$PlacementControl/Inventory.animate_negated_card("Monkey\'s Paw")
	return paw_card_scores

func effect_organ_donation():
	var organs = []
	var sold_organ_count = 0
	for card_type in card_types:
		if "Organ" in card_types[card_type].get("Tags",[]):
			organs.append(card_type)
	for card in $PlacementControl/Inventory.inventory:
		if card in organs:
			sold_organ_count += owned_cards[card]
			owned_cards.erase(card)
	owned_cards.erase("Organ Donation")
	$PlacementControl/Inventory.display_inventory(owned_cards)	
	var organ_sale_value: int = sold_organ_count * 2000 
	return {"Score": organ_sale_value}
	


func _on_score_change_show_timer_timeout() -> void:
	$ScoreChange.hide()
