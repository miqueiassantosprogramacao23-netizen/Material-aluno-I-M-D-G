extends CanvasLayer

@onready var barra_jogador: TextureProgressBar = $BarraVida/Preenchimento
@onready var gameover: Control = $GameOver

func _ready() -> void:
	gameover.visible = false

func atualizar_vida(vida_atual: int, _vida_maxima: int) -> void:
	barra_jogador.value = vida_atual

func mostrar_game_over() -> void:
	gameover.visible = true
	await get_tree().create_timer(1.2).timeout
	get_tree().reload_current_scene()
