extends Node2D

var title = "Five for Fives"
var desc = "Gain 5 points when the countdown timer is a multiple of 5."
var cost = 1

var selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Title.text = title
	$Desc.text = desc
	cost = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_buy_pressed() -> void:
	selected = !selected
