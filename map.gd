extends Node2D

class_name map

var functions_ = functions.new()

func paint_cell(row,column):
	
	return functions_.stockastic_function(row,column)

func paint_row_true(row_length):
	
	var row102 = []
	for i in range(0,row_length):
		row102.append(true)
		
	return row102

func paint_function( row_length=100 , column_length=100):
	
	var matrix102x102 = []
	
	for i in range(0,row_length):
		
		var row102 = []
		if i == 0:
			row102 = paint_row_true(row_length)
			
		elif i == row_length - 1:
			row102 = paint_row_true(row_length)
			
		else:   
		
			for j in range(0,column_length):
				
				if j == 0:
					row102.append(true)
					continue
				elif j == column_length - 1:
					row102.append(true)
					continue
				
				var cell = paint_cell(i,j)
				row102.append(cell)
				
				pass    
		
		matrix102x102.append(row102)
	
	return matrix102x102

func get_map(row,column,row_sub_matrix_length):
	
	var game_map = []
	row += 1
	column += 1
	
	for i in range(1,row):
		
		var my_row = []
		for j in range(1,column):
			
			var matriz102x102 = paint_function( row_sub_matrix_length , row_sub_matrix_length)

			my_row.append( { "row": i , "column": j , "matrix": matriz102x102 } )
			pass
		
		game_map.append(my_row)
	
	return game_map

func formatting_matrix( map  , row_length , column_length , row_sub_matrix_length ):
	
	var result = []
	for i in range( 0, row_length):
		
		for sub_i in range( 0 , row_sub_matrix_length ):
			
			var row = []
			for j in range(0 , column_length):
				
				var sub_matrix = map[i][j]["matrix"]
				row += sub_matrix[sub_i]
				pass
			
			result.append(row)
			
			pass
	
	return result

func get_map_formatted(row,column , sub_matrix_length):
	
	var map = get_map(row,column,sub_matrix_length)
	var format = formatting_matrix(map,row,column,sub_matrix_length)
	
	return format

