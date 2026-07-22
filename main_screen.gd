extends Node

var cards_owned = []
var cards_available = []
var cards_buying = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"StartScreen".visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_screen_start_game() -> void:
	$"StartScreen".visible = false
	$GameScreen.start()
	
func _on_game_screen_game_over(score) -> void:
	$GameScreen.visible = false
	$FinalScreen.display_screen(score)
