extends Control

const ENDINGS: Dictionary = {
	0: {&"title": "时间的尽头", &"text": "游戏时间已到尽头。\n\n历史的车轮滚滚向前，这个时代的篇章已经翻过。无论功过是非，一切都将交由后人评说。"},
	1: {&"title": "人民的选择", &"text": "党失去了人民的信任，一场革命推翻了政权。\n\n当权力脱离了群众，当承诺沦为空谈，人民终将做出自己的选择。历史证明，任何政权都无法长久地违背民意。"},
	2: {&"title": "军事政变", &"text": "不满的军官们发动了政变。\n\n军队本是国家的柱石，但当政治的裂痕延伸到军营之中，枪杆子便不再听从笔杆子的指挥。一夜之间，天翻地覆。"},
	3: {&"title": "经济崩溃", &"text": "国家经济彻底崩溃，社会陷入动荡。\n\n工厂停工，商店空空，货币沦为废纸。饥饿的人群涌上街头，曾经的大国沦为一片废墟。经济规律不会因为意识形态而改变。"},
	4: {&"title": "人口危机", &"text": "人口锐减至危险水平。\n\n战争、饥荒与政策的失误，使得这片土地上的人口急剧减少。没有了人民，国家便失去了存在的根基。"},
	5: {&"title": "冷战胜利", &"text": "中国成为了新的超级大国。\n\n通过巧妙的外交斡旋与坚定的国防建设，中国在冷战的棋局中脱颖而出。世界的权力天平发生了根本性的倾斜。"},
	6: {&"title": "改革开放", &"text": "中国走上了改革开放的道路。\n\n实践是检验真理的唯一标准。当教条让位于务实，当封闭转向开放，古老的国度焕发出新的生机。经济腾飞的奇迹由此拉开序幕。"},
	7: {&"title": "红色帝国", &"text": "共产主义的旗帜飘扬在全世界。\n\n从亚洲到非洲，从拉丁美洲到欧洲，革命的浪潮席卷全球。一个崭新的世界秩序在红色的旗帜下建立起来。"},
}

@onready var 结局标题: Label = $结局标题
@onready var 结局文案: Label = $结局文案
@onready var 返回主菜单: TextureButton = $返回主菜单
@onready var 翻页: TextureButton = $翻页

var _pages: PackedStringArray
var _current_page: int = 0


func _ready() -> void:
	var ending_id: int = GameManager.current_ending_id
	var ending: Dictionary = ENDINGS.get(ending_id, ENDINGS[0])

	结局标题.text = ending[&"title"]

	_pages = ending[&"text"].split("\n\n")
	_current_page = 0
	_show_current_page()

	返回主菜单.pressed.connect(_on_返回主菜单_pressed)
	翻页.pressed.connect(_on_翻页_pressed)

	翻页.visible = _pages.size() > 1


func _show_current_page() -> void:
	结局文案.text = _pages[_current_page]
	翻页.visible = _pages.size() > 1


func _on_翻页_pressed() -> void:
	_current_page = (_current_page + 1) % _pages.size()
	_show_current_page()


func _on_返回主菜单_pressed() -> void:
	get_tree().change_scene_to_file("uid://bydan4iqthbaa")
