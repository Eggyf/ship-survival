extends Area2D

export (int) var speed = 30
var direction := Vector2.ZERO
var id = "bullet"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	hide()
	$bullet_contact.play()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	if direction != Vector2.ZERO:
		
		var velocity = direction * speed
		global_position += velocity

	pass	

func set_direction( direction:Vector2 ):
	
	show()
	self.direction = direction.normalized()
	get_parent().bullet_contact.play()
	pass
