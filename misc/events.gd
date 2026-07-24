extends Node

signal tower_built(obj, cell)
signal on_obstacle_removed(obj, cell)
signal on_enemy_killed()
signal on_enemy_destination_reached()
signal on_wave_done(wave)
signal on_gold_change(g: int)
signal on_live_change(l: int)

signal tower_clicked(tower: Node2D)

# UI
signal on_tower_ui_clicked(faction_id: String, tower_id: String)
