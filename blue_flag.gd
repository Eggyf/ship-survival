extends Area2D

signal captured(winner)
var id = "blue_flag"
var coordenate

func set_position(pos):
	global_position = pos
	coordenate = Vector2(pos.x / 30 , pos.y / 30) 
	pass
	
func _on_Area2D_area_entered(area):

	emit_signal("captured",area.id)

	pass # Replace with function body.
