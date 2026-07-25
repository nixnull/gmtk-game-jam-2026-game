extends Node

var card_types = {
	"One for Ones": {
		"Desc": "Gain $100 whenever years left is a multiple of one.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_timer_multiple.bind(1),
		"Effect": update_score.bind(100)
	},
	"Two for Twos": {
		"Desc": "Gain $200 whenever years left is a multiple of two.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_timer_multiple.bind(1),
		"Effect": update_score.bind(200)
	},
	"Three for Threes": {
		"Desc": "Gain $300 whenever years left is a multiple of three.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_on_timer_multiple.bind(1),
		"Effect": update_score.bind(300)
	},
	"Five for Fives": {
		"Desc": "Gain $500 whenever years left is a multiple of five.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_on_timer_multiple.bind(1),
		"Effect": update_score.bind(500)
	},
	"Seven for Sevens": {
		"Desc": "Gain $700 whenever years left is a multiple of seven.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_on_timer_multiple.bind(1),
		"Effect": update_score.bind(700)
	},
	"Evens Demons": {
		"Desc": "Gain $500 on even years, lose $400 on odd years.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_even,
		"Effect": update_score.bind(500),
		"Bad Proc": proc_on_odd,
		"Bad Effect": update_score.bind(-400)
	},
	"Odds Gods": {
		"Desc": "Gain $500 on odd years, lose $400 on even years.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_on_odd,
		"Effect": update_score.bind(500),
		"Bad Proc": proc_on_even,
		"Bad Effect": update_score.bind(-400)
	},
	"Prime Meridian": {
		"Desc": "Gain the number of years left as money if the years left is prime.",
		"Type": "birch",
		"Cost": calcost_birch.bind(2),
		"Proc": proc_is_prime,
		"Effect": effect_prime_meridian
	},
	"Joker": {
		"Desc": "Gain $500 on funny numbered years.",
		"Type": "birch",
		"Cost": calcost_birch.bind(1),
		"Proc": proc_funny_number,
		"Effect": update_score.bind(500)
	},

	"Third Eye": {
		"Desc": "Fae offer one more boon.",
		"Type": "willow",
		"Cost": calcost_thirdeye.bind(),
		"Max": 4
	},
	"Second Lease on Life": {
		"Desc": "Buy some years, and pay for it every year after.",
		"Type": "edelwood",
		"Cost": calcost_birch.bind(10),
		"Bad Proc": proc_always,
		"Bad Effect": effect_edelwood,
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
		"Effect": effect_tradehalf
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
	$Bank.card_types = card_types
	$Inventory.card_types = card_types
	var test = proc_on_timer_multiple.bind(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	selected_cards = $Bank.report_selected()
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
	$Bank.draw_cards(BASE_HAND, owned_cards)
	$Inventory.display_inventory(owned_cards)
	update_turns(0)
	
func stop():
	self.visible = false
	
func update_turns(turns_lost):
	turns_left_before_procs = turns_left
	turns_left -= turns_lost
	$"TurnsLeft".text = "Years Remaining\n" + str(turns_left)
		
	print("Ok, ", turns_left, " years left...")
		
	#Run Card functions
	for card in owned_cards:
		for i in range(owned_cards[card]):
			if "Proc" in card_types[card]:
				print("Check for proc of " + card + "#" + str(i) + "...")
				if card_types[card]["Proc"].call():
					print("It procs!")
					$Inventory.animate_card(card, false)
					card_types[card]["Effect"].call()
			if "Bad Proc" in card_types[card]:
				print("Check for bad proc of " + card + "#" + str(i) + "...")
				if card_types[card]["Bad Proc"].call():
					print("It bad procs!")
					$Inventory.animate_card(card, true)
					card_types[card]["Bad Effect"].call()
					
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
	
func _on_buy_pressed() -> void:
	var selected_cards = []
	selected_cards = $Bank.report_selected()
	
	var total_cost = 0
	
	for card in selected_cards:
		var card_title = card.get_title()
		total_cost += card.get_cost()
		
		if card_title in owned_cards:
			owned_cards[card_title] += 1
		else:
			owned_cards[card_title] = 1
			if card_title == "Refreshing Potion":
				$Refresh.show()
	
	if selected_cards.is_empty():
		print("empty")
	else:
		$BuyAudio.play()
		$Inventory.display_inventory(owned_cards)
		update_turns(total_cost)
		var to_draw = BASE_HAND + owned_cards.get("Third Eye",0)
		$Bank.draw_cards(to_draw, owned_cards)
	
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
	return turns_left in [7, 13, 69, 420]
	
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
	return turns_left

func effect_edelwood():
	update_score(-100)
	
func effect_potion():
	var to_draw = BASE_HAND + owned_cards.get("Third Eye",0)
	$Bank.draw_cards(to_draw, owned_cards)

func _on_refresh_pressed() -> void:
	effect_potion()
	if owned_cards.get("Refreshing Potion",0) > 1:
		owned_cards["Refreshing Potion"] -= 1
	else:
		owned_cards.erase("Refreshing Potion")
		
		$Refresh.hide()
		$Inventory.display_inventory(owned_cards)

func effect_tradehalf():
	var half_turns_left = int(round(turns_left_before_procs * 0.5))
	var tradehalf_big_money = half_turns_left * 1000
	update_score(tradehalf_big_money)
	
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
