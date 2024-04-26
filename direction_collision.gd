extends Node2D

var last_avaliable_pos = Vector2.ZERO

signal restart_position

func up_is_colliding():
	return $up.is_colliding()

func down_is_colliding():
	return $down.is_colliding()
	
func left_is_colliding():
	return $left.is_colliding()

func right_is_colliding():
	return $right.is_colliding()

func _on_Timer_timeout():
	
	if not up_is_colliding() or not down_is_colliding() or not left_is_colliding() or not right_is_colliding():
		last_avaliable_pos = global_position
	else:
		emit_signal("restart_position")
	pass # Replace with function body.
