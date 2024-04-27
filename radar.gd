extends Area2D

signal enemy
signal enemy_exited
signal ally_in
signal ally_leave

var id = "radar"
var enemy_list = []
var targets = []
var ally_detection = []
var ally = []

func set_enemy(list):
	targets = list
func set_ally(list):
	ally_detection = list

func _on_radar_area_entered(area):
	
	for item in targets:
		
		if item == area.id:
			enemy_list.append( area )
			emit_signal("enemy")
	
	for item in ally_detection:
		
		if item == area.id:
			var area_id = area.id
			var parent = get_parent().id
			ally.append( area )
			emit_signal("ally_in")
			
	pass # Replace with function body.

func _on_radar_area_exited(area):

	var i =0
	while i < enemy_list.size():
		
		if area.id == enemy_list[i].id:
			enemy_list.remove(i)
			emit_signal("enemy_exited")
			i -= 1
		i += 1
	
	i = 0
	while i < ally.size():
		
		if area.id == ally[i].id:
			ally.remove(i)
			emit_signal("ally_leave")
			i -= 1
		i += 1
	
	pass # Replace with function body.
