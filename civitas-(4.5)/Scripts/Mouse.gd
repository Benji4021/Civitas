extends CanvasLayer

var cursor_normal = preload("res://Assets/WenrexaAssetsMagicCursorsPack/Assets Magic Cursors Pack/24x24px/Cursor Default Enemy.png")
var cursor_click  = preload("res://Assets/WenrexaAssetsMagicCursorsPack/Assets Magic Cursors Pack/24x24px/Cursor Attack Enemy.png")

func _ready():
	Input.set_custom_mouse_cursor(cursor_normal)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Input.set_custom_mouse_cursor(cursor_click)
			else:
				Input.set_custom_mouse_cursor(cursor_normal)
