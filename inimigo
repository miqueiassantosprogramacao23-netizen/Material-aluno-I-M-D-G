extends "res://scripts/personagem.gd"
##
## ===== INIMIGO (caranguejo) =====
## Persegue o jogador, ataca, leva dano e morre.
## A vida e o dano vêm da classe Personagem (scripts/personagem.gd).
##

# ---------- AJUSTES (mude os números e teste) ----------
const VELOCIDADE := 55.0       # velocidade para perseguir
const DANO := 15               # dano da garra
const ALCANCE := 40.0          # distância para atacar
const PERSEGUIR := 160.0       # distância para começar a perseguir

var atacando := false
var levando_dano := false
var jogador = null

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var barra: TextureProgressBar = $BarraVida/Preenchimento


func _ready() -> void:
	super._ready()             # vida = vida_maxima (70, definida na cena)
	add_to_group("inimigo")    # o ataque do jogador procura por este grupo
	jogador = get_tree().get_first_node_in_group("jogador")

	barra.max_value = vida_maxima
	barra.value = vida
	sprite.play("parado")


func _physics_process(delta: float) -> void:
	if morto:
		return

	# PASSO 1 — gravidade
	if not is_on_floor():
		velocity.y += 980.0 * delta

	if jogador == null:
		jogador = get_tree().get_first_node_in_group("jogador")

	# PASSO 2 — decidir o que fazer
	if jogador == null or jogador.morto:
		velocity.x = 0.0
		trocar_animacao("parado")
	elif not atacando and not levando_dano:
		pensar()

	# PASSO 3 — aplicar o movimento
	move_and_slide()

	# caiu no buraco do cenário? morre
	if global_position.y > 500.0:
		morrer()


# ===== PASSO 2: perseguir ou atacar =====
func pensar() -> void:
	var dx: float = jogador.global_position.x - global_position.x
	var dy: float = absf(jogador.global_position.y - global_position.y)

	if absf(dx) <= ALCANCE and dy < 28.0:
		atacar()                       # perto: ataca
	elif absf(dx) <= PERSEGUIR:
		velocity.x = signf(dx) * VELOCIDADE   # longe: persegue
		sprite.flip_h = dx < 0.0
		trocar_animacao("correr")
	else:
		velocity.x = 0.0               # muito longe: fica parado
		trocar_animacao("parado")


# ===== PASSO 2: ataque =====
func atacar() -> void:
	atacando = true
	velocity.x = 0.0
	sprite.flip_h = jogador.global_position.x < global_position.x
	sprite.play("atacar")

	# espera a garra esticar
	await get_tree().create_timer(0.25).timeout
	if morto:
		return
	if not atacando:
		return   # levou dano no meio do ataque: a garra não acerta

	# só machuca se o jogador ainda estiver perto e vivo
	if jogador != null and not jogador.morto:
		var dx: float = absf(jogador.global_position.x - global_position.x)
		var dy: float = absf(jogador.global_position.y - global_position.y)
		if dx <= ALCANCE + 10.0 and dy < 30.0:
			jogador.levar_dano(DANO, global_position.x)

	# espera antes de atacar de novo
	await get_tree().create_timer(0.6).timeout
	atacando = false


# ===== PASSO 4: levar dano e morrer =====
func levar_dano(quantidade: int, de_quem := 0.0) -> void:
	if morto:
		return

	super.levar_dano(quantidade, de_quem)
	barra.value = vida
	if morto:
		return

	levando_dano = true
	atacando = false

	# empurrão curto: se for longe, o próximo golpe do jogador erra o alvo
	var lado := 1.0 if global_position.x >= de_quem else -1.0
	velocity = Vector2(60.0 * lado, -40.0)
	sprite.play("atingido")

	await get_tree().create_timer(0.3).timeout
	levando_dano = false


func morrer() -> void:
	super.morrer()   # morto = true (não persegue nem ataca mais)
	atacando = false
	levando_dano = false
	velocity = Vector2.ZERO
	$BarraVida.visible = false
	sprite.play("morrer")
	$Hitbox.set_deferred("disabled", true)

	# quando a animação de morte termina, o inimigo sai da cena
	await sprite.animation_finished
	queue_free()


# ===== ajudante =====
func trocar_animacao(nome: String) -> void:
	if sprite.animation != nome or not sprite.is_playing():
		sprite.play(nome)
