extends Node2D

var selected

var cost = 0
var cost_type = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_card_info(title, card, cost=0):
	$Title.text = title
	$Desc.text = card["Desc"]
	self.set_cost(card["Cost"].call())
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
	
func set_cost(received_cost):
	cost = received_cost
	var label_str = str(cost) + " year"
	if cost not in [1,-1]:
		label_str += "s"
	$CostLabel.text = label_str
		
func show_cost():
	$CostLabel.visible = true

func get_cost():
	return cost
	
func set_count(count):
	$CountLabel.text = str(count)
	$CountLabel.visible = true
	
func play_animation(bad = false):
	$Background/ActivationAnimation.visible = true
	var color = Color(0.0, 1.0, 0.0, 1.0)
	if bad:
		color = Color(1.0, 0.0, 0.0, 1.0)
	$Background/ActivationAnimation.set("modulate", color)
	$AnimationTimer.start()
	print("Start the timer")
	$Background/ActivationAnimation.play()

func play_negate_animation():
	$Background/ActivationAnimation.visible = true
	var color = Color(0.134, 0.123, 1.0, 1.0)
	$Background/ActivationAnimation.set("modulate", color)
	$AnimationTimer.start()
	print("Start the timer")
	$Background/ActivationAnimation.play()

func show_score(score):
	var txt = ""
	if score > 0:
		$ScoreLabel.set("modulate", Color(0.0, 1.0, 0.0, 1.0))
		txt += "+"
	elif score < 0:
		$ScoreLabel.set("modulate", Color(1.0, 0.0, 0.0, 1.0))
		txt += "-"
	else:
		$ScoreLabel.set("modulate", Color(0.134, 0.123, 1.0, 1.0))
		txt = "Negated" # this will never appear bc the score isn't actually passed in if it's deleted
	txt += str(score)
	$ScoreLabel.text = txt
	$ScoreLabel.show()

func _on_animation_timer_timeout() -> void:
	$Background/ActivationAnimation.stop()
	$ScoreLabel.hide()
