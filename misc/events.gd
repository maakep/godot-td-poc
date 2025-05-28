extends Node

signal on_obstacles_built(obj, cell)
signal on_obstacle_removed(obj, cell)
signal on_enemy_killed()
signal on_enemy_destination_reached()
signal on_wave_done(wave)
signal on_gold_change(g: int)
