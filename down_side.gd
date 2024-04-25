extends Node2D

func is_colliding():
	
	if $down2.is_colliding(): return true
	
	return false
