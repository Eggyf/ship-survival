extends Node2D


func is_colliding():
	
	if $up2.is_colliding(): return true
	
	return false
