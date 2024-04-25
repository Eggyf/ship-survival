extends Area2D


var id ="left"

func set_( pos , length , width ):
	
	
	global_position = pos
	
	$collisionShape.shape.extents.x = width
	$collisionShape.shape.extents.y = length/2
	
	print($collisionShape.scale.x)
	print($collisionShape.scale.y)
	
	pass

func _on_left_frontier_area_entered(area):
	
	if area.id == "bullet":
		area.queue_free()
		
	pass # Replace with function body.
