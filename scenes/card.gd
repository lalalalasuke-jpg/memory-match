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


# 裏向きの間はボタンの見た目（裏面）そのまま。表向き/成立時だけ絵柄を描く
func _draw() -> void:
	if not (face_up or matched):
		return
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
