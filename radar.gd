extends Area2D

signal enemy
signal enemy_exited

var id = "radar"
var enemy_list = []
var targets = []

func _on_radar_area_entered(area):
	
	for item in targets:
		
		if item == area.id:
			
			enemy_list.append( area )
			emit_signal("enemy")
	
	pass # Replace with function body.

func _on_radar_area_exited(area):

	var i =0
	while i < enemy_list.size():
		
		if area.id == enemy_list[i].id:
			enemy_list.remove(i)
			emit_signal("enemy_exited")
			i -= 1
		
		i += 1
	
	pass # Replace with function body.
