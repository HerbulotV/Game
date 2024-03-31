extends CanvasLayer

func _on_Nouvelle_partie_pressed():
	get_tree().change_scene("res://Scenes/Smasher.tscn")

func _on_Parametres_pressed():
	var settings_scene = load("res://Scenes/Parametres.tscn")
	var settings_instance = settings_scene.instance()
	add_child(settings_instance)

func _on_Sortir_pressed():
	get_tree().quit()


