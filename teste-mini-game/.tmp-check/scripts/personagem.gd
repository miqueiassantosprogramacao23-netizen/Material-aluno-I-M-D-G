extends CharacterBody2D
class_name Personagem

## PERSONAGEM (classe base)
## Jogador e inimigo têm vida, tomam dano e morrem.
## player.gd e inimigo.gd herdam tudo deste arquivo.

signal vida_alterada(vida_atual: int, vida_maxima: int)
signal morreu

@export var vida_maxima :=0
var vida := 0
var morto := false

func _ready() -> void:
	vida = vida_maxima

func levar_dano(quantidade: int, de_quem := 0.0) -> void:
	if morto:
		return
	vida = maxi(vida - quantidade, 0)
	vida_alterada.emit(vida, vida_maxima)
	if vida == 0:
		morrer()

func morrer() -> void:
	morto = true
	morreu.emit()
