class_name MemoryCard
extends Button

# 絵柄の一覧。画像を使わず、色つき丸＋文字で表現
const SYMBOLS := [
	{"letter": "A", "color": Color("e74c3c")},
	{"letter": "B", "color": Color("e67e22")},
	{"letter": "C", "color": Color("f1c40f")},
	{"letter": "D", "color": Color("27ae60")},
	{"letter": "E", "color": Color("16a085")},
	{"letter": "F", "color": Color("2980b9")},
	{"letter": "G", "color": Color("9b59b6")},
	{"letter": "H", "color": Color("e84393")},
]

var symbol_index := 0
var face_up := false
var matched := false


func flip_up() -> void:
	face_up = true
	queue_redraw()


func flip_down() -> void:
	face_up = false
	queue_redraw()


# ペア成立：これ以降は押せなくして、少し薄くする
func set_matched() -> void:
	matched = true
	disabled = true
	modulate = Color(1, 1, 1, 0.5)


func _draw() -> void:
	if face_up or matched:
		_draw_face()
	else:
		_draw_back()


# 裏向き：はっきり見える色つきのカード裏面を描く（Godot標準ボタンの薄い見た目に頼らない）
func _draw_back() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color(0.22, 0.24, 0.34), true)
	draw_rect(rect, Color(0.45, 0.5, 0.62), false, 4.0)
	var c := size * 0.5
	var half := Vector2(size.x * 0.22, size.y * 0.22)
	var diamond := PackedVector2Array([
		c + Vector2(0, -half.y), c + Vector2(half.x, 0),
		c + Vector2(0, half.y), c + Vector2(-half.x, 0),
	])
	draw_colored_polygon(diamond, Color(0.45, 0.5, 0.62, 0.6))


# 表向き/成立時：絵柄を描く
func _draw_face() -> void:
	var sym: Dictionary = SYMBOLS[symbol_index]
	var center := size * 0.5
	var r := minf(size.x, size.y) * 0.5 - 10.0
	draw_set_transform(center, 0.0, Vector2.ONE)
	draw_circle(Vector2.ZERO, r, Color(0.16, 0.16, 0.2))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, sym.color, 3.0, true)

	var font := ThemeDB.fallback_font
	var font_size := 44
	var text: String = sym.letter
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(font, Vector2(-text_size.x * 0.5, text_size.y * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, sym.color)
