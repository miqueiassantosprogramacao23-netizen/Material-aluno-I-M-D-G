extends SceneTree

var feito := false

func _process(_delta: float) -> bool:
	if feito:
		return false
	feito = true
	var cena = load("res://cenas/cenario/Level.tscn").instantiate()
	root.add_child(cena)
	var inimigo = cena.get_node("Inimigo")
	var jogador = cena.get_node("Player")
	print("INIMIGO vida_maxima=", inimigo.vida_maxima, " vida=", inimigo.vida)
	print("PLAYER   vida_maxima=", jogador.vida_maxima, " vida=", jogador.vida)
	print("INIMIGO y=", inimigo.global_position.y, " on_floor=", inimigo.is_on_floor())
	inimigo.levar_dano(20, jogador.global_position.x)
	print("INIMIGO apos 20 de dano -> vida=", inimigo.vida, " morto=", inimigo.morto)
	return false
