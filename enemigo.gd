extends CharacterBody2D

var velocidad = 170.0
var tiene_pelota = false
var pelota = null
var direccion_mirada = Vector2(1, 0)

var factor_reaccion = 3.0

func _ready():
	pelota = get_tree().current_scene.find_child("Pelota", true, false)
	if pelota == null:
		pelota = get_tree().current_scene.find_child("pelota", true, false)

func _physics_process(delta):
	var ideal_vx = 0.0
	var ideal_vy = 0.0
	
	if tiene_pelota == false and pelota != null:
		var direccion = (pelota.global_position - global_position).normalized()
		ideal_vx = direccion.x
		ideal_vy = direccion.y
	elif tiene_pelota == true:
		var objetivo_arco = Vector2(0, 780)
		var direccion = (objetivo_arco - global_position).normalized()
		ideal_vx = direccion.x
		ideal_vy = direccion.y

	var vel_actual = 130.0 if tiene_pelota else velocidad
	var velocidad_ideal = Vector2(ideal_vx, ideal_vy) * vel_actual
	
	velocity = velocity.lerp(velocidad_ideal, factor_reaccion * delta)

	if velocity.x < -1.0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 1.0:
		$AnimatedSprite2D.flip_h = false
		
	if velocity.y < -1.0:
		$AnimatedSprite2D.flip_v = false
	elif velocity.y > 1.0:
		$AnimatedSprite2D.flip_v = true

	if velocity.length() > 1.0:
		direccion_mirada = velocity.normalized()

	if tiene_pelota and pelota != null:
		pelota.global_position = global_position + (direccion_mirada * 25)

	if velocity.length() < 5.0:
		$AnimatedSprite2D.stop()
	else:
		if tiene_pelota:
			$AnimatedSprite2D.play("Run-conPelota")
		else:
			$AnimatedSprite2D.play("Run-sinPelota")
			
	move_and_slide()
	
	if tiene_pelota == false:
		for i in get_slide_collision_count():
			var colision = get_slide_collision(i)
			var objeto = colision.get_collider()
			
			if objeto == pelota and pelota != null:
				tiene_pelota = true
				pelota.get_node("CollisionShape2D").set_deferred("disabled", true)
			
			elif "tiene_pelota" in objeto and objeto.tiene_pelota == true:
				tiene_pelota = true
				pelota = objeto.pelota
				objeto.tiene_pelota = false
				objeto.pelota = null
