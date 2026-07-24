extends Node2D

var selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_card_info(title, card):
	$Title.text = title
	$Desc.text = card["Desc"]
	$Background.play(str(card["Type"]))

func get_title():
	return $Title.text

func _on_buy_pressed() -> void:
	selected = !selected
	if $Buy.button_pressed:
		$SelectAudio.play()
		$Background.modulate = "#aaaaaa"
		set_happening("Buying!")
	else:
		$UnselectAudio.play()
		$Background.modulate = "#ffffff"
		$HappeningLabel.visible = false
		
func set_happening(text):
	$HappeningLabel.text = text
	$HappeningLabel.visible = true
	
func set_cost(cost):
	var label_str = str(cost) + " year"
	if cost not in [1,-1]:
		label_str += "s"
	$CostLabel.text = label_str
	$CostLabel.visible = true
	
func set_count(count):
	$CountLabel.text = str(count)
	$CountLabel.visible = true
