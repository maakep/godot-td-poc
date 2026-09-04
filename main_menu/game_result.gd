extends Control

const MAIN_MENU_SCENE := "res://main_menu/main_menu.tscn"
const GAME_SCENE := "res://game.tscn"
const VICTORY_COLOR := Color(1.0, 0.82, 0.35)
const DEFEAT_COLOR := Color(1.0, 0.42, 0.38)

@onready var title: Label = %Title
@onready var subtitle: Label = %Subtitle
@onready var duration_value: Label = %DurationValue
@onready var waves_value: Label = %WavesValue
@onready var towers_value: Label = %TowersValue
@onready var unlocks: RichTextLabel = %Unlocks
@onready var performance: RichTextLabel = %Performance
@onready var continue_button: Button = %ContinueButton
@onready var retry_button: Button = %RetryButton

var unlocked_factions_this_run: Array[String] = []

func _ready() -> void:
	Events.run_win.connect(_show_result.bind(true))
	Events.run_fail.connect(_show_result.bind(false))
	FactionProgress.faction_unlocked.connect(_record_unlock)

func _record_unlock(faction_id: String) -> void:
	if faction_id not in unlocked_factions_this_run:
		unlocked_factions_this_run.append(faction_id)

func _show_result(won: bool) -> void:
	if visible:
		return

	var world := get_tree().current_scene
	var player := world.get_node_or_null("Player")
	var spawner := world.get_node_or_null("Spawner")
	var faction_name := " + ".join(Factions.get_active_faction_names())

	title.text = "VICTORY" if won else "DEFEAT"
	title.add_theme_color_override("font_color", VICTORY_COLOR if won else DEFEAT_COLOR)
	subtitle.text = "%s defended the realm." % faction_name if won else "%s was overrun." % faction_name
	duration_value.text = _format_duration(player.get_run_duration_seconds()) if player else "--:--"
	waves_value.text = "%d / %d" % [spawner.get_completed_wave_count(), Levels.all.size()] if spawner else "--"
	towers_value.text = str(FactionProgress.towers_built_this_run)
	unlocks.text = _format_unlocks()
	performance.text = _format_performance(player)
	retry_button.visible = !won
	visible = true
	continue_button.grab_focus()
	get_tree().paused = true

func _format_unlocks() -> String:
	if unlocked_factions_this_run.is_empty():
		return "[color=#8793a6]No new factions unlocked this run.[/color]"

	var lines: Array[String] = []
	for faction_id in unlocked_factions_this_run:
		var faction: Dictionary = Factions.get_faction(faction_id)
		lines.append("[color=#ffd45f][b]%s unlocked![/b][/color]" % faction.name)
	return "\n".join(lines)

func _format_performance(player: Node) -> String:
	if player == null:
		return "[color=#8793a6]No performance data available.[/color]"

	var ranking: Array = player.get_tower_damage_ranking()
	if ranking.is_empty():
		return "[color=#8793a6]No tower damage was recorded.[/color]"

	var lines: Array[String] = []
	for index in range(ranking.size()):
		var entry: Dictionary = ranking[index]
		lines.append("[b]%d. %s[/b]  —  %d damage  •  %d kills" % [index + 1, entry.name, roundi(entry.damage), entry.kills])
	return "\n".join(lines)

func _format_duration(seconds: int) -> String:
	return "%d:%02d" % [seconds / 60, seconds % 60]

func _on_continue_pressed() -> void:
	_change_scene(MAIN_MENU_SCENE)

func _on_retry_pressed() -> void:
	Levels.reset_run()
	FactionProgress.reset_run()
	_change_scene(GAME_SCENE)

func _change_scene(scene_path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_continue_pressed()
