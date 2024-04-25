extends Node2D


func is_colliding():
	
	if $right1.is_colliding(): return true
	if $right2.is_colliding(): return true
	if $right3.is_colliding(): return true
	
	return false

func self_rotation(rot):
	self.rotate(rot)
