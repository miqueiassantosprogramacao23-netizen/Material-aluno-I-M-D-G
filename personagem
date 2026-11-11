extends CharacterBody2D
##
## ===== PERSONAGEM (classe base) =====
##
## Jogador e inimigo têm coisas IGUAIS: vida, tomar dano e morrer.
## Para não escrever isso duas vezes, escrevemos aqui uma única vez.
##
## O player.gd e o inimigo.gd começam com:
##     extends "res://scripts/personagem.gd"
## e assim HERDAM tudo o que está neste arquivo (orientação a objetos).
##

# PASSO 1 — avisos (sinais) que o HUD pode escutar
signal vida_alterada(vida_atual: int, vida_maxima: int)
signal morreu

# PASSO 2 — cada cena escolhe a vida no Inspetor (jogador 100, inimigo 70)
@export var vida_maxima := 100

var vida := 0
var morto := false


func _ready() -> void:
	vida = vida_maxima


# PASSO 3 — todo dano passa por aqui (o HUD é avisado sozinho)
# O "de_quem" é a posição de quem bateu, usada para o empurrão.
func levar_dano(quantidade: int, de_quem := 0.0) -> void:
	if morto:
		return

	vida = maxi(vida - quantidade, 0)
	vida_alterada.emit(vida, vida_maxima)

	if vida == 0:
		morrer()


# PASSO 4 — morte básica. Jogador e inimigo completam com animação,
# chamando "super.morrer()" no começo do morrer deles.
func morrer() -> void:
	morto = true
	morreu.emit()
