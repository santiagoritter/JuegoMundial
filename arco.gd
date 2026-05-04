extends Area2D

func _on_body_entered(body):
	if body.has_method("golpear"):
		body.velocity = Vector2.ZERO
		body.global_position = Vector2.ZERO
		
		var jugador = get_parent().get_node("Player")
		if jugador != null:
			jugador.celebrar_gol()
