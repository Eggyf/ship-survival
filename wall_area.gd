extends Area2D

var id = "wall"
var length_x = 0
var length_y = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$explotion.hide()
	
	scale.x = 30/$Sprite.texture.get_size().x 
	scale.y = 30/$Sprite.texture.get_size().y 
	
	pass # Replace with function body.

func _on_wall_area_area_entered(area):
	print(area.id)
	if area.id == "bullet":
		
		$explotion.global_position = global_position
		$explotion.show()
		$explotion_animation.play("explotion")
		$bullet_contact.play()
		area.queue_free()
		pass
	
	pass # Replace with function body.
	
func _on_explotion_animation_animation_finished(anim_name):
	$explotion.hide()
	pass # Replace with function body.

