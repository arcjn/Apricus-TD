@tool
extends Node2D
## Draws the start/end stripes on a path tile (child of an 80x80 path Sprite2D).
## The stripes always sit on the OPEN end of the path: the side facing away
## from the one neighbouring path tile, so they turn by themselves.
## @tool = this also runs inside the editor, so you see the stripes while designing.

@export var color := Color8(175, 197, 116): # green = start; red Color8(241, 184, 160) = end
	set(value):
		color = value
		queue_redraw()

const CELL := 80.0
# Stripes measured from the Krita art: [start, end) in px from the open edge
const STRIPES := [[0, 9], [12, 18], [21, 24]]
# Direction to the neighbouring path tile -> how far to turn the stripes
const SIDES := {Vector2.RIGHT: 0.0, Vector2.DOWN: 90.0, Vector2.LEFT: 180.0, Vector2.UP: 270.0}

var _angle := 0.0


func _ready() -> void:
	set_process(Engine.is_editor_hint()) # in the editor, keep re-checking as tiles move
	_update.call_deferred() # in the game, check once after every tile exists


func _process(_delta: float) -> void:
	_update()


func _update() -> void:
	var a := _open_side_angle()
	if a != _angle:
		_angle = a
		queue_redraw() # ask Godot to call _draw() again


func _open_side_angle() -> float:
	var me: Vector2 = get_parent().global_position
	for t in get_tree().get_nodes_in_group("Path"):
		if t == get_parent():
			continue
		var d: Vector2 = (t.global_position - me) / CELL
		if d.round() in SIDES and d.length() < 1.1:
			return SIDES[d.round()]
	return _angle


func _draw() -> void:
	# Drawn as if the neighbour were on the right (stripes on the left edge),
	# then turned about the tile's centre so "right" points at the real neighbour.
	draw_set_transform(Vector2(CELL, CELL) / 2, deg_to_rad(_angle))
	for s in STRIPES:
		draw_rect(Rect2(s[0] - CELL / 2, -CELL / 2, s[1] - s[0], CELL), color)
