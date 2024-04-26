extends Node2D

func is_colliding():
	
	return $down2.is_colliding() and $down3.is_colliding() and $down4.is_colliding()
