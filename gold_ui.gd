extends RichTextLabel

func _init():
	Events.on_gold_change.connect(update_gold)

func update_gold(gold: int):
	text = bold(gold)

func bold(t): 
	return "[b]{text}[/b]".format({"text": t})
