extends Node2D

@onready var start: TextureButton = $Background/Start
@onready var game_tittle: Label = $Background/GameTittle

var hover_tween: Tween
var click_tween: Tween
var shade := TextureRect.new()
var level_select: Node2D = preload("res://Scenes/level_select_screen.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.pivot_offset = start.size/2
	start.resized.connect(func():start.pivot_offset = start.size/2)
	start.mouse_entered.connect(_hover.bind(true))
	start.mouse_exited.connect(_hover.bind(false))
	start.button_down.connect(_press.bind(true))
	start.button_up.connect(_press.bind(false))
	start.button_up.connect(_on_start)
	game_tittle.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	shade.texture = preload("res://Images/Shade.png")
	$"Background".add_child(shade)
	add_child(level_select)
	for n in [shade, level_select]:
		n.modulate.a = 0.0
		n.hide()



func _hover(on: bool):
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(start, "self_modulate", Color(0.7, 0.7, 0.7) if on else Color.WHITE, 0.2)

func _press(down: bool):
	if click_tween: click_tween.kill()
	click_tween = create_tween().set_parallel()
	click_tween.tween_property(start, "scale", Vector2.ONE*(0.95 if down else 1.0), 0.08)
	click_tween.tween_property(start, "modulate:a", 0.9 if down else 1.0, 0.08)

func _on_start():
	if not start.is_hovered(): return
	start.disabled = true
	click_tween.kill()
	var fade := create_tween().set_parallel()
	fade.tween_property(start, "modulate:a", 0.0, 0.3)
	fade.tween_property(start, "scale", Vector2.ONE, 0.1)
	for i in range(game_tittle.text.length() - 1, -1, -1):
		await get_tree().create_timer(0.3 / game_tittle.text.length()).timeout
		game_tittle.visible_characters = i
	if fade.is_running(): await fade.finished
	var appear := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for n in [shade, level_select]:
		n.show()
		appear.tween_property(n, "modulate:a", 1.0, 0.2)
