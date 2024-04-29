extends Area2D

var id = "wall"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$explotion.hide()
	
	scale.x = 30/$Sprite.texture.get_size().x 
	scale.y = 30/$Sprite.texture.get_size().y 
	$explotion.scale.x = 70
	$explotion.scale.y = 40
	
	pass # Replace with function body.

func _on_wall_area_area_entered(area):
	
	if area.id == "bullet":
		
		$explotion.global_position = position
		$explotion.show()
		$bullet_contact.play()
		$explotion_animation.play("explotion")
		area.queue_free()
		pass
	
	pass # Replace with function body.

func _on_explotion_animation_animation_finished(anim_name):
	$explotion.hide()
	pass # Replace with function body.
