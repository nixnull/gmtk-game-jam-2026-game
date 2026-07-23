extends Node2D

var selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_card_type(title, desc):
	$Title.text = title
	$Desc.text = desc

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
