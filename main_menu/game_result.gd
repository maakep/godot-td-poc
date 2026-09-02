extends Control

@onready var btn_continue = $ContinueBtn

# Called when the node enters the scene tree for the first time.
func _ready():
	btn_continue.pressed.connect(on_continue)

func on_continue():
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
