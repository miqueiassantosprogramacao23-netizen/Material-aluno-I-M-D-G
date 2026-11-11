extends "res://scripts/personagem.gd"
class_name Player

const VELOCIDADE := 130.0
const PULO := -450.0
const DANO := 20
const ALCANCE := 40.0
const TEMPO_ATAQUE := 0.25
const LIMITE_QUEDA := 400.0

var atacando := false
var levando_dano := false

@onready var sprite: Sprite2D = $Texture
@onready var anim: AnimationPlayer = $Animation

func _ready() -> void:
	super._ready()
	add_to_group("jogador")
	anim.play("parado")

func _physics_process(delta: float) -> void:
	if morto:
		return
	if not is_on_floor():
		velocity.y += 980.0 * delta
	if not levando_dano:
		var direcao := Input.get_axis("mover_esquerda", "mover_direita")
		velocity.x = direcao * VELOCIDADE
		if direcao != 0.0 and not atacando:
			sprite.flip_h = direcao < 0.0
		if Input.is_action_just_pressed("pular") and is_on_floor():
			velocity.y = PULO
		if Input.is_action_just_pressed("atacar") and not atacando:
			atacar()
		animar()
	else:
		velocity.x = move_toward(velocity.x, 0.0, VELOCIDADE)
	move_and_slide()
	if global_position.y > LIMITE_QUEDA:
		levar_dano(vida_maxima)

func animar() -> void:
	if atacando:
		return
	if not is_on_floor():
		trocar_animacao("pular")
	elif velocity.x != 0.0:
		trocar_animacao("correr")
	else:
		trocar_animacao("parado")

func trocar_animacao(nome: String) -> void:
	if anim.current_animation != nome:
		anim.play(nome)

func atacar() -> void:
	atacando = true
	var lado := -1.0 if sprite.flip_h else 1.0
	anim.play("atacar")
	await get_tree().create_timer(TEMPO_ATAQUE).timeout
	if morto or not atacando:
		return
	for inimigo in get_tree().get_nodes_in_group("inimigo"):
		var dx: float = inimigo.global_position.x - global_position.x
		var dy: float = absf(inimigo.global_position.y - global_position.y)
		if absf(dx) <= ALCANCE and dx * lado >= -8.0 and dy <= 28.0:
			inimigo.levar_dano(DANO, global_position.x)
	await get_tree().create_timer(0.2).timeout
	atacando = false

func levar_dano(quantidade: int, de_quem := 0.0) -> void:
	super.levar_dano(quantidade, de_quem)
	levando_dano = true
	sprite.play("levar_dano")
	await get_tree().create_timer(0.3).timeout
	levando_dano = false
	if not morto:
		sprite.play("parado")

func morrer() -> void:
	super.morrer()
	atacando = false
	sprite.play("morrer")
