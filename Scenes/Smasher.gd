extends Node2D

onready var player1 = get_node("Player_01")
onready var player2 = get_node("Player_02")

var played_note = false

var hard_mod = 0



# Liste des noms de plateformes
var platform_names = [
	"Plateforme_01",
	"Plateforme_02",
	"Plateforme_03",
	"Plateforme_04",
	"Plateforme_05",
	"Plateforme_06",
	"Plateforme_07",
	"Plateforme_08",
]

# Chemins des textures pour les plateformes
var platform_textures = {
	"normal": preload("res://assets/simple_grass_full.png"),
	"special": preload("res://assets/special_grass_full.png")
}

var platform_to_keep = ""
var new_round = true

signal cycle_completed

func _ready():
#	# Sans cette ligne, Godot ne lira pas le MIDI
#	OS.open_midi_inputs( )
#		# Une boucle qui liste et affiche tous les appareil MIDI connecté à l'ordinateur
#	# "get_connected_midi_inputs" est une fonction de Godot qui appartient à OS (qui est aussi une variable de Godot)
#	for current_midi_input in OS.get_connected_midi_inputs( ):
#		print(current_midi_input)

#	# Créez un Timer pour jouer la note 2 secondes avant que la plateforme ne change de texture
#	var play_note_timer = Timer.new()
#	play_note_timer.set_name("PlayNoteTimer")
#	play_note_timer.set_wait_time(3)  # 3 secondes, car le Timer change_texture_timer a un délai de 5 secondes
#	play_note_timer.connect("timeout", self, "_on_play_note_timer_timeout")
#	play_note_timer.set_autostart(false)
#	play_note_timer.set_one_shot(false)
	
	# Créez un Timer pour appeler la fonction change_texture toutes les 5 secondes
	var change_texture_timer = Timer.new()
	change_texture_timer.set_name("ChangeTextureTimer")
	change_texture_timer.set_wait_time(5)
	change_texture_timer.connect("timeout", self, "change_texture")
	change_texture_timer.set_autostart(false)
	change_texture_timer.set_one_shot(false)


	# Créez un Timer pour appeler la fonction hide_platforms toutes les 10 secondes
	var hide_timer = Timer.new()
	hide_timer.set_name("HideTimer")
	hide_timer.set_wait_time(10)
	hide_timer.connect("timeout", self, "_on_hide_timer_timeout")
	hide_timer.set_autostart(false)
	hide_timer.set_one_shot(false)

	#add_child(play_note_timer)
	add_child(change_texture_timer)
	add_child(hide_timer)

	# Démarrez les Timers dans le bon ordre
	#play_note_timer.start()
	change_texture_timer.start()
	hide_timer.start()
	
	connect("cycle_completed", self, "_on_cycle_completed")

func _on_hide_timer_timeout():
	new_round = true
	hide_platforms()
	var show_timer = get_tree().create_timer(5)
	show_timer.connect("timeout", self, "on_show_timer_timeout")

func on_show_timer_timeout():
	show_platforms()
	emit_signal("cycle_completed")

func _on_cycle_completed():
	# Restart the hide_timer
	$HideTimer.start()
	
func change_texture():
	if new_round:
		# Choisissez une plateforme aléatoire à conserver
		#platform_to_keep = platform_names[randi() % platform_names.size()]
		
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var my_random_number = rng.randi_range(0, platform_names.size()-1)
		platform_to_keep = platform_names[my_random_number]
		
		#platform_to_keep = platform_names[int(rand_range(0, platform_names.size() - 1))]
		
		
		new_round = false
		played_note = false  # Réinitialisez la valeur de played_note pour le nouveau tour
	# Parcourez toutes les plateformes et changez la texture de celle qui va rester
	for platform_name in platform_names:
		var platform = get_node(platform_name)
		var sprite = platform.get_node("Sprite")
		var particles = sprite.get_node("Particles2D")

		# Obtenez le AudioStreamPlayer de la plateforme actuelle
		var note_player = platform.get_node("NotePlayer")
		note_player.stop()
	
		if platform_name == platform_to_keep and !played_note:
			note_player.play()
			played_note = true
			if hard_mod < 10: 
				sprite.texture = platform_textures.special
			if hard_mod < 15:
				particles.visible = true
			hard_mod += 0.5
			print(hard_mod)
		else:
			sprite.texture = platform_textures.normal
			particles.visible = false
	# Réinitialisez la valeur de played_note à false après avoir parcouru toutes les plateformes
	played_note = false
			
func hide_platforms():
	# Parcourez toutes les plateformes et masquez celles qui ne sont pas choisies
	for platform_name in platform_names:
		var platform = get_node(platform_name)

		if platform_name == platform_to_keep:
			platform.visible = true
			platform.get_node("CollisionShape2D").set_disabled(false)
		else:
			platform.visible = false
			platform.get_node("CollisionShape2D").set_disabled(true)

	# Créez un Timer pour appeler la fonction show_platforms après 5 secondes
	var show_timer = Timer.new()
	show_timer.set_wait_time(3)
	show_timer.connect("timeout", self, "show_platforms")
	show_timer.set_autostart(true)
	show_timer.set_one_shot(true)
	add_child(show_timer)

func show_platforms():
	# Parcourez toutes les plateformes et rendez-les visibles, réactivez leur CollisionShape2D et rétablissez leur texture normale
	for platform_name in platform_names:
		var platform = get_node(platform_name)
		var sprite = platform.get_node("Sprite")
		var particles = sprite.get_node("Particles2D")
		platform.visible = true
		platform.get_node("CollisionShape2D").set_disabled(false)
		sprite.texture = platform_textures.normal
		particles.visible = false 
		var note_player = platform.get_node("NotePlayer")
		note_player.stop()
		
#func _on_Button_pressed():
#
#	restart_game()
#
#func _on_Button2_pressed():
#	get_tree().change_scene("res://Scenes/Menu_MusicSmasher.tscn")
#
#func restart_game():
#	get_tree().paused  = false
#	get_tree().reload_current_scene()
#func _on_play_note_timer_timeout():
#	# Jouez la note correspondant à la plateforme choisie
#	if platform_to_keep != "":
#		var platform = get_node(platform_to_keep)
#		var note_player = platform.get_node("NotePlayer")
#		note_player.play()
#yield(get_tree().create_timer(2), "timeout")


## "_input" est appelée automatiquement chaque fois qu'un événement d'entrée (input) est détecté dans la scène de jeu
## "event" est ce que Godot envoie en paramêtre de "_input", une variable contenant toutes les infos de l'événement
## Plus d'infos ici: https://docs.godotengine.org/fr/stable/tutorials/inputs/input_examples.html
#func _input(event):
#	# Si cet événement est du MIDI:
#	if event is InputEventMIDI:
#		# si l'événement est du MIDI, il contiendra toutes les informations classique du MIDI (message, pitch, instrument, etc.)
#		# Pour plus d'info sur le MIDI, voir notre cours "2 - IoT - Musique éléctonique et MIDI" 
#		# Donc si on print event.pitch, on affichera le code de la note MIDI:
#		print(event.pitch)
#
#		# Ici j'appelle ma fonction "traiter_evenement_midi" en lui passant l'event en paramêtre.
#		# Le détail de la fonction se trouve plus bas
#		traiter_evenement_midi(event)
#
#		afficher_note(event.pitch)
#
#func traiter_evenement_midi(event_midi):
#	# Si la varible "message" contenu dans la variable "event" = "MIDI_MESSAGE_NOTE_ON" (voir "NOTE ON" dans notre cours)
#	# En d'autres termes: "si l'événement midi a été déclenchée par une note qui vient d'être pressée"
#	if event_midi.message == MIDI_MESSAGE_NOTE_ON:
#		print("NOTE_ON")
#		# "Si la note de l'événement MIDI est 48"
#		if event_midi.pitch == 48:
#			# Appeler ma fonctionner "activer_objet" en lui passant 48 en paramètres
#			# voir le détail de la fonction plus bas
#			activer_objet(48)
#		# "Sinon si la note de l'événement MIDI est 50"
#		elif event_midi.pitch == 50:
#			# Pareil avec 50 en paramètres
#			activer_objet(50)
#
#
#
#
## Fonction qui active du son, des particules et un effet visuel de l'objet A ou B selon la note jouée (ici 48 ou 50)
#func activer_objet(note):
#	if note == 48:
#		# On va chercher le node enfant "Conteneur_Objet_A" et on active la fonction "effet_objet" qu'il contient
#		# la fonction "effet_objet" se trouve dans le script attaché à "Conteneur_Objet_A"
#		$"Conteneur_Objet_A".effet_objet()
#	if note == 50:
#		# Pareil pour "Conteneur_Objet_B" 
#		$"Conteneur_Objet_B".effet_objet()
#
#
## Fonction qui change le texte du node "Note_Jouée" en affichant le code MIDI de la note
#func afficher_note(note):
#	# On récupère un node de type "Label" et on attribue à sa valeure "text" la note MIDI
#	# Comme la valeure "text" n'accepte que les string et que event.pitch est un int, on utilise "as String" pour changer le type de la varible
#	$"Conteneur_note_jouée/Note_jouée".text = note as String



	
