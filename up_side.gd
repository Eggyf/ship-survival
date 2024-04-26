extends Node2D


func is_colliding():
	
	return $up2.is_colliding() and $up3.is_colliding() and $up4.is_colliding() 

