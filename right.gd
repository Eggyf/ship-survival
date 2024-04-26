extends Node2D

func is_colliding():
	
	return  $right2.is_colliding() and $right3.is_colliding() and $right4.is_colliding()
