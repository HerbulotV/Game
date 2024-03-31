extends KinematicBody2D

var speed = 200
var jump_speed = 700
var gravity = 20
var playerAttack = false
var is_dead = false
var is_falling = false
var is_pushing = false
var is_pushed = false

var push_duration = 0.45  # Durée de l'effet de poussée en secondes
var push_timer = 0.0
var push_direction = Vector2()

var Smasher = load("res://Scenes/Smasher.gd")

var velocity = Vector2()

var heart_full_texture = load("res://assets/Players/double heart pixel art 16x16.png")
var heart_3_quart_texture = load("res://assets/Players/double & demi heart pixel art 16x16.png")
var heart_demi_texture = load("res://assets/Players/double & empty heart pixel art 16x16.png")
var heart_one_quart_texture = load("res://assets/Players/demi & empty heart pixel art 16x16.png")
var heart_empty_texture = load("res://assets/Players/double empty heart pixel art 16x16.png")

func _physics_process(delta):

	handle_movement(delta)

	handle_jump()
	handle_attack()
	handle_slide()
	
	
	if push_timer > 0:
		push_timer -= delta
		is_pushed = true
	else:
		is_pushed = false
	if is_pushed:
		var push_progress = 1 - push_timer / push_duration
		var speed_factor = 1.3
		velocity.y = push_direction.y * (1 - 4 * (push_progress - 0.5) * (push_progress - 0.5))
		velocity.x = push_direction.x * speed_factor * (1 - 4 * (push_progress - 0.5) * (push_progress - 0.5))
	else:
		velocity.y += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	
func handle_movement(_delta):
	if $AnimatedSprite.animation == "Pousser":
		return
		
	velocity.x = (int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))) * speed
	if Input.is_action_pressed("right"):
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("Courir")
	elif Input.is_action_pressed("left"):
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("Courir")
	elif Input.is_action_pressed("dance"):
		$AnimatedSprite.play("Danser")
	else :
		$AnimatedSprite.play("Respirer")
func handle_jump():
	if $AnimatedSprite.animation == "Pousser":
		return
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity.y = -jump_speed
			$AnimatedSprite.play("Sauter")  
		elif Input.is_action_pressed("right") or Input.is_action_pressed("left"):
			$AnimatedSprite.play("Courir") 
	else:
		$AnimatedSprite.play("Sauter")  
			

	
		
func handle_attack():
	if Input.is_action_just_pressed("push") and $AnimatedSprite.animation != "Pousser":
		is_pushing = true
		velocity.x = 0
		$AnimatedSprite.play("Pousser")
		
		if $AnimatedSprite.flip_h == true:
			$Attack_zone_01/CollisionShape2D.set_disabled(true)
			$Attack_zone_02/CollisionShape2D.set_disabled(false)
		elif $AnimatedSprite.flip_h == false:
			$Attack_zone_01/CollisionShape2D.set_disabled(false)
			$Attack_zone_02/CollisionShape2D.set_disabled(true)
	elif Input.is_action_just_released("push"):
		$Attack_zone_01/CollisionShape2D.set_disabled(true)
		$Attack_zone_02/CollisionShape2D.set_disabled(true)
		
func handle_slide():
	if get_slide_count() > 0 :
		for i in range(get_slide_count()):
			if "Player" in get_slide_collision(i).collider.name:
				velocity.y = -300

func _on_pushable_zone_01_area_entered(area):
	if area.is_in_group("coup_right"):

		push_1() # appel de la méthode push() sur le joueur 2

	if area.is_in_group("coup_left"):
		#print("Player 2 touché par la droite")
		push_2()

	if area.is_in_group("vide"):
		print(is_falling)
		if !is_falling:
			# Sauter vers le haut
			velocity.y = -jump_speed*1.6
			var heart = get_parent().get_node("heart_1")
			if heart.texture == heart_full_texture :
				heart.texture = heart_3_quart_texture
			elif heart.texture == heart_3_quart_texture :
				heart.texture = heart_demi_texture
			elif heart.texture == heart_demi_texture :
				heart.texture = heart_one_quart_texture
#			elif heart.texture == heart_one_quart_texture :
#				heart.texture = heart_empty_texture
				is_falling = true

	if area.is_in_group("infinity_vide"):
		
		var heart = get_parent().get_node("heart_1")
		if heart.texture == heart_one_quart_texture :
			heart.texture = heart_empty_texture
		
			yield(get_tree().create_timer(1), "timeout")
			var win_label = get_parent().get_node("CanvasLayer/WinLabel")
			
			if win_label.visible != true :
				win_label.text = "Player 2 wins !"
				win_label.visible = true
				var win_bg = get_parent().get_node("CanvasLayer/WinBG")
				win_bg.visible = true
			print("infinity")
			
			var button_restart = get_parent().get_node("CanvasLayer/Button")
			button_restart.visible = true
			var button_home = get_parent().get_node("CanvasLayer/Button2")
			button_home.visible = true
			get_tree().paused = true
	
		
		
		

func _on_AnimatedSprite_animation_finished():
	
	if $AnimatedSprite.animation == "Pousser":
		is_pushing = false
		$Attack_zone_01/CollisionShape2D.set_disabled(true)
		$Attack_zone_02/CollisionShape2D.set_disabled(true)
		if is_on_floor():
			if velocity.x != 0:
				 $AnimatedSprite.play("Courir")
			else:
				 $AnimatedSprite.play("Respirer")
		else:
			$AnimatedSprite.play("Sauter")


func _on_Attack_zone_01_area_entered(area):
#	#$AnimatedSprite.animation == "die"
	if area.is_in_group("body2"):
		print("Player 1 frappe Player 2")


func push_1():
	push_direction = Vector2(250, -100)
	push_timer = push_duration
	velocity.x = push_direction.x
	velocity.y = push_direction.y
	
func push_2():
	push_direction = Vector2(-250, -100)
	push_timer = push_duration
	velocity.x = push_direction.x
	velocity.y = push_direction.y
