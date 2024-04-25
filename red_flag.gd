extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready():

	$AnimationPlayer.play("wind_flag")
	pass # Replace with function body.

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play("wind_flag")
	pass # Replace with function body.
