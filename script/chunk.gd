extends Node2D

var chunk_index: int
var chunk_height := 600


func setup(index:int):
	chunk_index = index
	position.y = index * chunk_height
