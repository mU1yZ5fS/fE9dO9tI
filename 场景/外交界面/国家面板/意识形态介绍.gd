extends Control

const DATA = preload("res://数据脚本/core/意识形态介绍数据.gd")

# ── 子意识形态图标映射（与国家面板.gd 保持一致） ──
const SUB_ICONS := {
	0: preload("res://资产/UI/外交/子意识形态图标/sub_00.png"),
	1: preload("res://资产/UI/外交/子意识形态图标/sub_01.png"),
	2: preload("res://资产/UI/外交/子意识形态图标/sub_02.png"),
	3: preload("res://资产/UI/外交/子意识形态图标/sub_03.png"),
	4: preload("res://资产/UI/外交/子意识形态图标/sub_04.png"),
	5: preload("res://资产/UI/外交/子意识形态图标/sub_05.png"),
	6: preload("res://资产/UI/外交/子意识形态图标/sub_06.png"),
	7: preload("res://资产/UI/外交/子意识形态图标/sub_07.png"),
	8: preload("res://资产/UI/外交/子意识形态图标/sub_08.png"),
	9: preload("res://资产/UI/外交/子意识形态图标/sub_09.png"),
	10: preload("res://资产/UI/外交/子意识形态图标/sub_10.png"),
	11: preload("res://资产/UI/外交/子意识形态图标/sub_11.png"),
	12: preload("res://资产/UI/外交/子意识形态图标/sub_12.png"),
	13: preload("res://资产/UI/外交/子意识形态图标/sub_13.png"),
	14: preload("res://资产/UI/外交/子意识形态图标/sub_14.png"),
	15: preload("res://资产/UI/外交/子意识形态图标/sub_15.png"),
	16: preload("res://资产/UI/外交/子意识形态图标/sub_16.png"),
	17: preload("res://资产/UI/外交/子意识形态图标/sub_17.png"),
	18: preload("res://资产/UI/外交/子意识形态图标/sub_18.png"),
	19: preload("res://资产/UI/外交/子意识形态图标/sub_19.png"),
	20: preload("res://资产/UI/外交/子意识形态图标/sub_20.png"),
	21: preload("res://资产/UI/外交/子意识形态图标/sub_21.png"),
	22: preload("res://资产/UI/外交/子意识形态图标/sub_22.png"),
}

var current_sub: int = -1
var _icon_node: TextureRect

@onready var _text: RichTextLabel = $介绍
@onready var _close: Button = $关闭


func _ready() -> void:
	_text.bbcode_enabled = true
	_close.pressed.connect(_on_close_pressed)
	_icon_node = $图标  # 场景中已有 TextureRect 节点
	hide()


func open(sub_idx: int, _country_name: String = "") -> void:
	current_sub = sub_idx
	_text.text = _load_text(sub_idx)

	# 设置子意识形态图标
	if _icon_node:
		var tex: Texture2D = SUB_ICONS.get(sub_idx)
		if tex:
			_icon_node.texture = tex
			_icon_node.visible = true
		else:
			_icon_node.visible = false  # 无对应图标时隐藏

	show()
	move_to_front()


func _load_text(idx: int) -> String:
	var text: String = DATA.TEXTS.get(idx, "")
	if text != "":
		return text
	return _default_text(idx)


func _default_text(idx: int) -> String:
	var name_zh: String = CountryData.IDEOLOGY.get(idx, "未知意识形态")
	return "【%s】\n\n该意识形态的硬编码文案尚未写入。" % name_zh


func _on_close_pressed() -> void:
	hide()
