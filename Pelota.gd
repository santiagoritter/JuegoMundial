extends CharacterBody2D

var friccion = 300.0
var lim_izq = -500
var lim_der = 500
var lim_arr = -700
var lim_abj = 700

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friccion * delta)
	
	var colision = move_and_collide(velocity * delta)
	if colision:
		velocity = velocity.bounce(colision.get_normal())
		
	if global_position.x <= lim_izq or global_position.x >= lim_der:
		velocity.x = -velocity.x
		global_position.x = clamp(global_position.x, lim_izq, lim_der)
		
	if global_position.y <= lim_arr or global_position.y >= lim_abj:
		velocity.y = -velocity.y
		global_position.y = clamp(global_position.y, lim_arr, lim_abj)

func golpear(direccion, fuerza):
	velocity = direccion * fuerza
