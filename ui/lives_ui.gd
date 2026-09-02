extends RichTextLabel

func _init():
	Events.on_life_change.connect(update_life)

func update_life(gold: int):
	text = Fmt.bold(gold)
