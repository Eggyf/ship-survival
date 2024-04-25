extends Node2D

class_name functions

func stockastic_function(row,column):
	
	
	# Get the current time in milliseconds
	var current_time_msec = OS.get_ticks_msec()

	var seed_ = 800
	var offset = 0
	
	if row + column > seed_ or row == 1 or column == 1:
		offset = 1
		pass
	else:
		offset = -1
		pass

	if (current_time_msec % row == 0 and not current_time_msec % column == 0) or \
	   (current_time_msec % (column + offset) == 0 and \
		 not current_time_msec % (row + offset) == 0):
		
		return false

	return true
