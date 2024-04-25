extends RigidBody2D

var length_x = 0
var length_y = 0
var id = "wall"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Sprite.scale.x = 30/$Sprite.texture.get_size().x 
	$Sprite.scale.y = 30/$Sprite.texture.get_size().y 
	
	$CollisionShape2D.scale.x = 1.2
	$CollisionShape2D.scale.y = 1.2
	
	pass # Replace with function body.

func set_position(pos):
	
	global_position = pos
	
	pass
