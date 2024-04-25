extends Area2D

var id = "wall"

# Called when the node enters the scene tree for the first time.
func _ready():
	$explotion.hide()
	pass # Replace with function body.

func _on_wall_area_area_entered(area):
	
	if area.id == "bullet":
		
		$explotion.global_position = $wall.global_position
		$explotion.show()
		$explotion_animation.play("explotion")
		area.queue_free()
		$bullet_contact.play()
		pass
	
	pass # Replace with function body.
	
func _on_explotion_animation_animation_finished(anim_name):
	$explotion.hide()
	pass # Replace with function body.
