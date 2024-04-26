extends Node2D

# Called when the node enters the scene tree for the first time.

onready var visible_char = $RichTextLabel.text.length()
var killed= false
func set_game_over(pos):
	
	self.position = pos
	print("game over:",pos)
	$Camera2D.current = true
	pass

func _on_Timer_timeout():
	
	pass # Replace with function body.
