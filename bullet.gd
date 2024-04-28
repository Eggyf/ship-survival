extends Area2D

export (int) var speed = 30
var direction := Vector2.ZERO
var id = "bullet"
var contact = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	hide()
	$explotion.hide()
	$bullet_contact.play()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	if direction != Vector2.ZERO and not contact :
		
		var velocity = direction * speed
		global_position += velocity

	pass	

func set_direction( direction:Vector2 ):
	
	show()
	self.direction = direction.normalized()
	var bullet_contact = get_parent().bullet_contact.instance()
	add_child(bullet_contact) 
	bullet_contact.play()

	pass

func _on_bullet_area_entered(area):
	if area.id == "bullet":
		contact = true
		$explotion.global_position = global_position
		$rocket.hide()
		$explotion.show()
		$explotion_animation.play("explotion")
	
	pass # Replace with function body.

func _on_explotion_animation_animation_finished(anim_name):
	queue_free()
	pass # Replace with function body.
