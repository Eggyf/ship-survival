extends Node2D


func is_colliding():
	
	
	return $left2.is_colliding() and $left3.is_colliding() and $left4.is_colliding()
	
