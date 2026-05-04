extends CharacterBody2D

var velocidad = 200.0
var fuerza_pateo = 500.0
var fuerza_pase = 300.0
var esta_pateando = false
var tiene_pelota = false
var pelota = null
var pos_inicial = Vector2(-200, 100)
var celebrando = false
var direccion_mirada = Vector2(1, 0)

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

	if vx != 0 or vy != 0:
		direccion_mirada = Vector2(vx, vy).normalized()

	if tiene_pelota and pelota != null:
		pelota.global_position = global_position + (direccion_mirada * 25)
		
		if (Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_E)) and esta_pateando == false:
			var fuerza = fuerza_pateo if Input.is_physical_key_pressed(KEY_SPACE) else fuerza_pase
			
			pelota.get_node("CollisionShape2D").set_deferred("disabled", false)
			pelota.global_position = global_position + (direccion_mirada * 40)
			pelota.golpear(direccion_mirada, fuerza)
			
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
		
	var vel_actual = 150.0 if tiene_pelota else velocidad
	velocity.y = vy * vel_actual
	velocity.x = vx * vel_actual
	
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
