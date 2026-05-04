extends CharacterBody2D

var velocidad = 200.0
var fuerza_pateo = 500.0
var fuerza_pase = 300.0
var esta_pateando = false
var tiene_pelota = false
var pelota = null
var pos_inicial = Vector2(-200, 100)
var celebrando = false

func _ready():
	global_position = pos_inicial

func _physics_process(delta):
	if celebrando:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var vy = 0
	var vx = 0
	
	if Input.is_physical_key_pressed(KEY_W):
		vy = vy - 1
		$AnimatedSprite2D.flip_v = false
	if Input.is_physical_key_pressed(KEY_S):
		vy = vy + 1
		$AnimatedSprite2D.flip_v = true
	if Input.is_physical_key_pressed(KEY_A):
		if esta_pateando == false:
			$AnimatedSprite2D.flip_h = true
		vx = vx - 1
	if Input.is_physical_key_pressed(KEY_D):
		if esta_pateando == false:
			$AnimatedSprite2D.flip_h = false
		vx = vx + 1

	if tiene_pelota and pelota != null:
		var offset_x = -20 if $AnimatedSprite2D.flip_h else 20
		var offset_y = 20 if $AnimatedSprite2D.flip_v else 0
		if vy < 0: offset_y = -20
		velocidad = 150
		
		pelota.global_position = global_position + Vector2(offset_x, offset_y)
		
		if (Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_E)) and esta_pateando == false:
			var direccion_mouse = (get_global_mouse_position() - global_position).normalized()
			var fuerza = fuerza_pateo if Input.is_physical_key_pressed(KEY_SPACE) else fuerza_pase
			
			pelota.get_node("CollisionShape2D").set_deferred("disabled", false)
			pelota.global_position = global_position + direccion_mouse * 40
			pelota.golpear(direccion_mouse, fuerza)
			
			tiene_pelota = false
			pelota = null
			esta_pateando = true
			$AnimatedSprite2D.play("Patear")
			await $AnimatedSprite2D.animation_finished
			esta_pateando = false

	elif Input.is_physical_key_pressed(KEY_SPACE) and esta_pateando == false:
		esta_pateando = true
		$AnimatedSprite2D.play("Patear")
		await $AnimatedSprite2D.animation_finished
		esta_pateando = false
		
	if esta_pateando == false:
		if vy == 0 and vx == 0:
			$AnimatedSprite2D.stop()
		else:
			if tiene_pelota:
				$AnimatedSprite2D.play("Run-conPelota")
			else:
				$AnimatedSprite2D.play("Run-sinPelota")
		
	velocity.y = vy * velocidad
	velocity.x = vx * velocidad
	
	move_and_slide()
	
	if tiene_pelota == false:
		for i in get_slide_collision_count():
			var colision = get_slide_collision(i)
			var objeto = colision.get_collider()
			
			if objeto.has_method("golpear"):
				tiene_pelota = true
				pelota = objeto
				pelota.get_node("CollisionShape2D").set_deferred("disabled", true)

func celebrar_gol():
	celebrando = true
	tiene_pelota = false
	$AnimatedSprite2D.play("Gol")
	await get_tree().create_timer(3.0).timeout
	celebrando = false
	global_position = pos_inicial
