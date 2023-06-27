extends Camera2D

@export var cell_w = 160
@export var cell_h = 104
@export var tilemap:TileMap 
@export var player:Node2D

var org = Vector2(0,0)
var cell = Vector2(0,0)

func _process(delta):
	org = tilemap.position - Vector2(8,32)
	cell = ((player.position - org - Vector2( cell_w/2, cell_h/2 )) / Vector2(cell_w, cell_h)).floor() + Vector2(1,1)
#	print_debug(cell)
