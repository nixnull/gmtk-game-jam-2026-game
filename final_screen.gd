extends CanvasLayer

var final_score = 0

signal restart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_screen()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_screen(score):
	$FinalScore.text = "Final Score\n" + str(score)
	if score >= 0:
		$WinMessage.show()
	else:
		$LoseMessage.show()
	self.visible = true
	
func hide_screen():
	self.visible = false

func _on_button_pressed() -> void:
	$RestartSFX.play()
	$WinMessage.hide()
	$LoseMessage.hide()
	restart.emit()
