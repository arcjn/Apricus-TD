@tool
extends ColorRect

const CELL := 80.0
const SHADOW_SHADER := preload("res://Shaders/path_shader.gdshader")
var _rect := ColorRect.new()
var _signature := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.z_index = 1
	var mat := ShaderMaterial.new()
	mat.shader = SHADOW_SHADER
	_rect.material = mat
	add_child(_rect)
	set_process(Engine.is_editor_hint())
	rebuild.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rebuild()

func rebuild():
	var tiles := get_tree().get_nodes_in_group("Building") + get_tree().get_nodes_in_group("Path")
	var sig := ""
	for t in tiles:
		sig += str(t.is_in_group("Building"), t.global_position)
	if sig == _signature:
		return
	_signature = sig
	if tiles.is_empty():
		_rect.hide()
		return
	_rect.material.set_shader_parameter("cell", CELL)
	var origin: Vector2 = tiles[0].global_position.posmod(CELL)
	var cells := {}
	var lo := Vector2i(1<<30, 1<<30)
	var hi := -lo
	for t in tiles:
		var c := Vector2i(((t.global_position - origin) / CELL).round())
		cells[c] = 1 if t.is_in_group("Building") else 2
		lo = lo.min(c)
		hi = hi.max(c)
	lo -= Vector2i.ONE
	hi += Vector2i.ONE
	var dim := hi - lo + Vector2i.ONE
	var img := Image.create(dim.x, dim.y, false, Image.FORMAT_RG8)
	for c in cells:
		img.set_pixelv(c - lo, Color(1,0,0) if cells [c] == 1 else Color(0,1,0))
	_rect.global_position = origin + Vector2(lo)*CELL
	_rect.size = Vector2(dim)*CELL
	_rect.material.set_shader_parameter("cell_map", ImageTexture.create_from_image(img))
	_rect.material.set_shader_parameter("map_size", dim)
	_rect.show()
