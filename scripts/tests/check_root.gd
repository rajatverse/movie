extends SceneTree

func _init() -> void:
	print("Root children count: %d" % root.get_child_count())
	for c in root.get_children():
		print(" - Node name: ", c.name)
	quit()
