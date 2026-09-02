extends Node2D

@onready var btn_play = $Play
@onready var btn_settings = $Settings
@onready var btn_quit = $Quit

func _ready():
	btn_play.connect("pressed", on_play_pressed)
	btn_settings.connect("pressed", on_settings_pressed)
	btn_quit.connect("pressed", on_quit_pressed)

func on_play_pressed():
	get_tree().change_scene_to_file("res://main_menu/faction_select.tscn")

func on_settings_pressed():
	get_tree().change_scene_to_file("res://game.tscn")
	
func on_quit_pressed():
	get_tree().quit()
