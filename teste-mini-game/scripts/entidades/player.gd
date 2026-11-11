extends "res://scripts/personagem.gd"
##
## ===== JOGADOR =====
## Anda, pula, ataca, leva dano e morre.
## A vida e o dano vêm da classe Personagem (scripts/personagem.gd).
##

# ---------- AJUSTES (mude os números e teste) ----------
const VELOCIDADE := 130.0      # velocidade de corrida
const PULO := -450.0           # impulso do pulo (negativo = para cima)
const DANO := 20              # dano da espada
const ALCANCE := 40.0          # distância máxima do ataque
const TEMPO_ATAQUE := 0.25     # tempo até a espada acertar
const LIMITE_QUEDA := 400.0    # cair abaixo disto = morte

var atacando := false
var levando_dano := false

@onready var sprite: Sprite2D = $Texture
@onready var anim: AnimationPlayer = $Animation


func _ready() -> void:
	super._ready()             # a classe base define vida = vida_maxima
	add_to_group("jogador")    # o inimigo e o HUD procuram por este grupo
	anim.play("parado")


func _physics_process(delta: float) -> void:
	if morto:
		return

	# PASSO 1 — gravidade
	if not is_on_floor():
		velocity.y += 980.0 * delta

	# Durante a animação de dano o jogador não obedece ao teclado.
	if not levando_dano:
		# PASSO 2 — andar
		var direcao := Input.get_axis("mover_esquerda", "mover_direita")
		velocity.x = direcao * VELOCIDADE
		if direcao != 0.0 and not atacando:
			sprite.flip_h = direcao < 0.0   # durante o ataque ele continua virado

		# PASSO 3 — pular
		if Input.is_action_just_pressed("pular") and is_on_floor():
			velocity.y = PULO

		# PASSO 4 — atacar
		if Input.is_action_just_pressed("atacar") and not atacando:
			atacar()

		# PASSO 5 — escolher a animação certa
		animar()
	else:
		velocity.x = move_toward(velocity.x, 0.0, VELOCIDADE)

	# PASSO 6 — aplicar o movimento
	move_and_slide()

	# PASSO 7 — caiu no buraco do cenário? morre
	if global_position.y > LIMITE_QUEDA:
		levar_dano(vida_maxima)


# ===== PASSO 5: animações =====
func animar() -> void:
	if atacando:
		return   # a animação de ataque precisa terminar
	if not is_on_floor():
		trocar_animacao("pular")
	elif velocity.x != 0.0:
		trocar_animacao("correr")
	else:
		trocar_animacao("parado")


func trocar_animacao(nome: String) -> void:
	if anim.current_animation != nome:
		anim.play(nome)


# ===== PASSO 4: ataque =====
func atacar() -> void:
	atacando = true
	var lado := -1.0 if sprite.flip_h else 1.0   # para onde ele está olhando
	anim.play("atacar")

	# espera a espada chegar no meio do golpe
	await get_tree().create_timer(TEMPO_ATAQUE).timeout
	if morto or not atacando:
		return   # morreu ou levou dano: o golpe não sai

	# procura inimigos NA FRENTE dele e machuca todos que estiverem no alcance
	for inimigo in get_tree().get_nodes_in_group("inimigo"):
		var dx: float = inimigo.global_position.x - global_position.x
		var dy: float = absf(inimigo.global_position.y - global_position.y)
		if absf(dx) <= ALCANCE and dx * lado >= -8.0 and dy <= 28.0:
			inimigo.levar_dano(DANO, global_position.x)

	await get_tree().create_timer(0.2).timeout
	atacando = false


# ===== PASSO 8: levar dano e morrer =====
func levar_dano(quantidade: int, de_quem := 0.0) -> void:
	if morto or levando_dano:
		return

	super.levar_dano(quantidade, de_quem)   # tira a vida e avisa o HUD
	if morto:
		return

	levando_dano = true
	atacando = false

	# empurrão para o lado contrário de quem bateu
	var lado := 1.0 if global_position.x >= de_quem else -1.0
	velocity = Vector2(120.0 * lado, -160.0)

	sprite.modulate = Color(1.0, 0.6, 0.6)   # fica avermelhado
	anim.play("levar_dano")

	await get_tree().create_timer(0.3).timeout
	if morto:
		return
	levando_dano = false
	sprite.modulate = Color.WHITE


func morrer() -> void:
	super.morrer()   # morto = true e avisa o HUD (GAME OVER)
	atacando = false
	velocity = Vector2.ZERO
	anim.play("morrer")
	$Hitbox.set_deferred("disabled", true)
