extends Area2D

signal captured(winner)
var id = "red_flag"

func set_position(pos):
	global_position = pos
	pass
	
func _on_Area2D_area_entered(area):

	emit_signal("captured",area.id)

	pass # Replace with function body.
