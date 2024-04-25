extends Node2D


func up_is_colliding():
	return $up.is_colliding()

func down_is_colliding():
	return $down.is_colliding()
	
func left_is_colliding():
	return $left.is_colliding()

func right_is_colliding():
	return $right.is_colliding()
