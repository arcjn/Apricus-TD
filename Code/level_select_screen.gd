extends Node2D

@onready var b_1: TextureButton = $Backgroung/B1
@onready var b_2: TextureButton = $Backgroung/B2
@onready var b_3: TextureButton = $Backgroung/B3
@onready var b_4: TextureButton = $Backgroung/B4
@onready var b_5: TextureButton = $Backgroung/B5
@onready var b_6: TextureButton = $Backgroung/B6
@onready var b_7: TextureButton = $Backgroung/B7
@onready var b_8: TextureButton = $Backgroung/B8
@onready var b_9: TextureButton = $Backgroung/B9
@onready var b_10: TextureButton = $Backgroung/B10

@onready var level_1: TextureRect = $Backgroung/B1/Level1
@onready var level_2: TextureRect = $Backgroung/B2/Level2
@onready var level_3: TextureRect = $Backgroung/B3/Level3
@onready var level_4: TextureRect = $Backgroung/B4/Level4
@onready var level_5: TextureRect = $Backgroung/B5/Level5
@onready var level_6: TextureRect = $Backgroung/B6/Level6
@onready var level_7: TextureRect = $Backgroung/B7/Level7
@onready var level_8: TextureRect = $Backgroung/B8/Level8
@onready var level_9: TextureRect = $Backgroung/B9/Level9
@onready var level_10: TextureRect = $Backgroung/B10/Level10

var hover_tween: Tween
var click_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	b_1.pivot_offset = b_1.size/2
	b_1.mouse_entered.connect(_hover.bind(true))
	b_1.mouse_exited.connect(_hover.bind(false))
	b_1.button_down.connect(_press.bind(true))
	b_1.button_up.connect(_press.bind(false))
	b_1.button_up.connect(_on_level_1)


func _hover(on: bool):
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween()
	hover_tween.tween_property(b_1, "self_modulate", Color(0.7,0.7,0.7) if on else Color.WHITE, 0.2)

func _press(down: bool):
	if click_tween: click_tween.kill()
	click_tween = create_tween().set_parallel()
	click_tween.tween_property(b_1, "scale", Vector2.ONE*(0.95 if down else 1.0), 0.08)
	click_tween.tween_property(b_1, "modulate:a", 0.9 if down else 1.0, 0.08)

func _on_level_1():
	if not b_1.is_hovered():return
	b_1.disabled = true
	click_tween.kill()
	var fade := create_tween().set_parallel()
	fade.tween_property(b_1, "modulate:a", 0.0, 0.5)
	fade.tween_property(b_1, "scale", Vector2.ONE, 0.1)
	await fade.finished
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
