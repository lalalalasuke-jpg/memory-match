extends Node2D

const CARD := preload("res://scenes/card.tscn")
## ペアの数（カード枚数はこの2倍）
const PAIR_COUNT := 8
## 揃わなかった時、裏返すまでの待ち時間
const MISMATCH_DELAY := 0.8

var moves := 0
var matches := 0
# 今表向きになっていて、まだ判定してないカード（最大2枚）
var flipped: Array[MemoryCard] = []
var busy := false

@onready var grid: GridContainer = $HUD/Grid
@onready var moves_label: Label = $HUD/MovesLabel
@onready var matches_label: Label = $HUD/MatchesLabel
@onready var win_panel: Control = $HUD/WinPanel
@onready var win_moves_label: Label = $HUD/WinPanel/WinMoves


func _ready() -> void:
	_build_grid()
	_update_hud()


# ペアぶんの絵柄を2枚ずつ用意してシャッフルし、カードを並べる
func _build_grid() -> void:
	var symbol_indices: Array[int] = []
	for i in PAIR_COUNT:
		symbol_indices.append(i)
		symbol_indices.append(i)
	symbol_indices.shuffle()

	for idx in symbol_indices:
		var card: MemoryCard = CARD.instantiate()
		card.symbol_index = idx
		card.pressed.connect(_on_card_pressed.bind(card))
		grid.add_child(card)


func _on_card_pressed(card: MemoryCard) -> void:
	if busy or card.face_up or card.matched:
		return
	card.flip_up()
	flipped.append(card)
	if flipped.size() < 2:
		return

	moves += 1
	_update_hud()
	busy = true
	var a := flipped[0]
	var b := flipped[1]
	if a.symbol_index == b.symbol_index:
		a.set_matched()
		b.set_matched()
		matches += 1
		flipped.clear()
		busy = false
		_update_hud()
		if matches == PAIR_COUNT:
			_on_win()
	else:
		await get_tree().create_timer(MISMATCH_DELAY).timeout
		a.flip_down()
		b.flip_down()
		flipped.clear()
		busy = false


func _on_win() -> void:
	win_moves_label.text = "MOVES %d" % moves
	win_panel.visible = true


func _update_hud() -> void:
	moves_label.text = "MOVES %d" % moves
	matches_label.text = "MATCHES %d/%d" % [matches, PAIR_COUNT]


# 勝利画面が出てる間は、タップ/クリックでもう一度遊べる
func _unhandled_input(event: InputEvent) -> void:
	if not win_panel.visible:
		return
	var tapped: bool = (event is InputEventMouseButton and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed)
	if tapped:
		get_tree().reload_current_scene()
