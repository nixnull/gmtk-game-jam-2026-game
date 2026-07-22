extends Node

var turns_left = 10
var score = 10

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start():
	self.visible = true
	$Bank.draw_cards(3)
	turns_left = 10
	update_turns(0)
	
func stop():
	self.visible = false
	
func update_turns(turns_lost):
	turns_left -= turns_lost
	$"TurnsLeft".text = "Turns Remaining\n" + str(turns_left)
	if turns_left <= 0:
		game_over.emit(score)

func _on_buy_pressed() -> void:
	var selected_cards = []
	selected_cards = $Bank.report_selected()
	
	var total_cost = 0
	
	for card in selected_cards:
		total_cost += card.cost
	
	if selected_cards.is_empty():
		print("empty")
		pass
	
	update_turns(total_cost)
