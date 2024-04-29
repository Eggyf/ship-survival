extends Node2D

class_name Brain

var Soldiers = []

func SetInstructions(soldier,instructions: Array):
	soldier.InstructionsStack = instructions
	pass

func SetSoldiers(soldiers: Array):
	Soldiers = soldiers
	pass

func TranslatePathToInstrucions(path):
	var instructions = []
	for i in range(path.size() - 1):
		var node0_array = path[i].split(',')
		var node1_array = path[i + 1].split(',')
		var node0 = [int(node0_array[0]),int(node0_array[1])]
		var node1 = [int(node1_array[0]),int(node1_array[1])]
		if node1[0] > node0[0]:
			instructions.append('right')
			pass
		elif node1[0] < node0[0]:
			instructions.append('left')
			pass
		elif node1[1] > node0[1]:
			instructions.append('down')
			pass
		else:
			instructions.append('up')
			pass
		pass
	return instructions

func GetPathTo(from: Vector2, to: Vector2):
	pass
