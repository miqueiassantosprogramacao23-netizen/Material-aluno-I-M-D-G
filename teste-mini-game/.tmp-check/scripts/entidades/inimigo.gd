extends "res://scripts/personagem.gd"
class_name Inimigo

const VELOCIDADE := 55.0
const DANO := 15
const ALCANCE := 40.0
const PERSEGUIR := 160.0
const TEMPO_ATAQUE := 0.25
const RECARGA := 0.6

var atacando := false
var levando_dano := false
var jogador = null

@onready var sprite: Sprite2D = $Texture
@onready var anim: AnimationPlayer = $Animation
@onready var barra: TextureProgressBar = $BarraVida/Preenchimento

func _ready() -> void:
	super._ready()
	add_to_group("inimigo")
	
	anim.play("parado")
	barra.max = vida_maxima
	barra.value = vida
	anim.play("parado")

func _physics_process(delta: float) -> void:
	if morto:
		return
	if jogador == null:
		jogador = get_tree().get_first_node_in_group("jogador")
		if jogador == null:
			return
	var dx: float = jogador.global_position.x - global_position.x
	var dy: float = absf(jogador.global_position.y - global_position.y)
	if absf(dx) <= PERSEGUIR and dy < 60.0:
		sprite.flip_h = dx < 0.0
		if not atacando:
			velocity.x = signf(dx) * VELOCIDADE
			if absf(dx) <= ALCANCE + 10.0:
				atacar()
	else:
		velocity.x = move_toward(velocity.x, 0.0, VELOCIDADE)
	if not atacando and not levando_dano:
		animar()
	move_and_slide()

func animar() -> void:
	if not is_on_floor():
		trocar_animacao("correr")
	elif velocity.x != 0.0:
		trocar_animacao("correr")
	else:
		trocar_animacao("parado")

func trocar_animacao(nome: String) -> void:
	if anim.current_animation != nome:
		anim.play(nome)

func atacar() -> void:
	atacando = true
	anim.play("atacar")
	await get_tree().create_timer(TEMPO_ATAQUE).timeout
	if morto or not atacando:
		return
	if jogador != null and not jogador.morto:
		var dx: float = absf(jogador.global_position.x - global_position.x)
		var dy: float = absf(jogador.global_position.y - global_position.y)
		if dx <= ALCANCE + 10.0 and dy < 30.0:
			jogador.levar_dano(DANO, global_position.x)
	await get_tree().create_timer(RECARGA).timeout
	atacando = false

func levar_dano(quantidade: int, de_quem := 0.0) -> void:
	super.levar_dano(quantidade, de_quem)
	sprite.play("atingido")
	var lado := 1.0 if global_position.x >= de_quem else -1.0
	velocity = Vector2(60.0 * lado, -40.0)
	await get_tree().create_timer(0.3).timeout
	if not morto:
		sprite.play("parado")

func morrer() -> void:
	super.morrer()
	atacando = false
	sprite.play("morrer")
	await get_tree().create_timer(0.5).timeout
	queue_free()
