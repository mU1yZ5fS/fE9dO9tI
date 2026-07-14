extends Node

# =====================================================================
# 音频总管（autoload 单例）
# 移植自 Unity《毛的遗产》GlobalScript 的音乐点唱机 + Total 音效。
#
# 专辑 = 文件夹：res://资产/音频/专辑/<专辑名>/ 下放若干 .ogg/.wav/.mp3 即一张专辑。
#   - 专辑名 = 文件夹名；曲目名 = 音频文件名（去扩展名）。
#   - 文件夹里的 icon.png / icon_h.png 作为专辑按钮的封面（普通 / 按下）。
#   - 增删曲目或专辑只需在文件系统里增删文件，无需改代码或维护 .tres。
#   - 曲目按需加载（播放时才 load），切专辑/切曲目时旧资源自动释放，省内存。
#
# 给设置场景用的接口：
#   选择专辑(索引) / 专辑总数() / 获取专辑名列表()
#   获取专辑封面(索引) / 获取专辑封面_按下(索引)
#   获取当前曲目名列表() / 当前歌名() / 当前专辑索引
# =====================================================================

signal 曲目变更(歌名: String)   # 当前播放的曲目改变时发出
signal 专辑变更                 # 当前播放的专辑切换时发出（设置场景据此刷新单曲列表）

const 专辑根目录 := "res://资产/音频/专辑/"
const _音频扩展名 := [".ogg", ".wav", ".mp3"]

var 背景音乐播放器: AudioStreamPlayer
@onready var 按钮按下: AudioStreamPlayer = $按钮按下

var 专辑目录列表: Array[String] = []      # 每张专辑的文件夹路径
var 专辑名列表: Array[String] = []        # 文件夹名

var 当前专辑目录: String = ""
var 当前曲目路径列表: Array[String] = []   # 当前专辑的曲目路径（仅记录，按需 load）
var 当前曲目名列表: Array[String] = []     # 取自文件名
var 当前专辑索引: int = -1
var 当前曲目: int = -1                    # 当前专辑内的曲目索引

var 循环: bool = false
var 随机: bool = true


func _ready() -> void:
	# 创建背景音乐播放器并路由到「背景音乐」总线
	背景音乐播放器 = AudioStreamPlayer.new()
	背景音乐播放器.name = "背景音乐播放器"
	背景音乐播放器.bus = "背景音乐"
	add_child(背景音乐播放器)
	背景音乐播放器.finished.connect(_on_背景音乐播放器_finished)

	# 音效路由到「音效」总线
	if 按钮按下:
		按钮按下.bus = "音效"
	var 音效节点 := get_node_or_null("音效")
	if 音效节点 is AudioStreamPlayer:
		(音效节点 as AudioStreamPlayer).bus = "音效"

	_扫描专辑()
	if not 专辑目录列表.is_empty():
		选择专辑(0)   # 默认选第一张专辑并开始播放


# 扫描专辑根目录下的所有子文件夹，每个子文件夹 = 一张专辑
func _扫描专辑() -> void:
	# DirAccess.open() 支持 res:// 路径，而 dir_exists_absolute() 仅支持 OS 绝对路径
	var 目录 := DirAccess.open(专辑根目录)
	if 目录 == null:
		push_warning("音频总管：无法打开专辑根目录 " + 专辑根目录)
		return
	var 目录们: Array[String] = []
	目录.list_dir_begin()
	var 名称 := 目录.get_next()
	while 名称 != "":
		if 目录.current_is_dir() and not 名称.begins_with("."):
			目录们.append(专辑根目录 + 名称 + "/")
		名称 = 目录.get_next()
	目录们.sort()   # 按文件夹名排序，专辑顺序稳定
	for d in 目录们:
		专辑目录列表.append(d)
		专辑名列表.append(d.trim_suffix("/").get_file())


func 专辑总数() -> int:
	return 专辑目录列表.size()


func 获取专辑名列表() -> Array:
	return 专辑名列表.duplicate()


# 专辑按钮的普通封面（icon.png）
func 获取专辑封面(索引: int) -> Texture2D:
	if 索引 < 0 or 索引 >= 专辑目录列表.size():
		return null
	return load(专辑目录列表[索引] + "icon.png") as Texture2D


# 专辑按钮的按下封面（icon_h.png）；缺失时调用方回退到普通封面
func 获取专辑封面_按下(索引: int) -> Texture2D:
	if 索引 < 0 or 索引 >= 专辑目录列表.size():
		return null
	return load(专辑目录列表[索引] + "icon_h.png") as Texture2D


# 选择某张专辑（对应原版 VoiceChangeScript 的专辑按钮）：加载曲目并随机播放一首
func 选择专辑(索引: int) -> void:
	if 索引 < 0 or 索引 >= 专辑目录列表.size():
		return
	当前专辑索引 = 索引
	当前专辑目录 = 专辑目录列表[索引]
	_扫描当前专辑曲目()
	当前曲目 = -1
	专辑变更.emit()
	var 下一首 := _随机曲目索引()
	if 下一首 >= 0:
		播放曲目(下一首)


# 扫描当前专辑文件夹里的音频文件，构成曲目列表
func _扫描当前专辑曲目() -> void:
	当前曲目路径列表.clear()
	当前曲目名列表.clear()
	if 当前专辑目录 == "":
		return
	var 目录 := DirAccess.open(当前专辑目录)
	if 目录 == null:
		return
	var 路径们: Array[String] = []
	目录.list_dir_begin()
	var 名称 := 目录.get_next()
	while 名称 != "":
		if not 目录.current_is_dir():
			var 小写名 := 名称.to_lower()
			for 后缀 in _音频扩展名:
				if 小写名.ends_with(后缀):
					路径们.append(当前专辑目录 + 名称)
					break
		名称 = 目录.get_next()
	路径们.sort()
	for p in 路径们:
		当前曲目路径列表.append(p)
		当前曲目名列表.append(p.get_file().get_basename())


func 获取当前曲目名列表() -> Array:
	return 当前曲目名列表.duplicate()


# 播放当前专辑内的指定曲目（对应原版 zadan_music 指定曲目）
func 播放曲目(索引: int) -> void:
	if 索引 < 0 or 索引 >= 当前曲目路径列表.size():
		return
	var 流 := load(当前曲目路径列表[索引])
	if 流 == null or not (流 is AudioStream):
		push_warning("无法加载曲目：" + 当前曲目路径列表[索引])
		return
	当前曲目 = 索引
	背景音乐播放器.stream = 流
	背景音乐播放器.play()
	曲目变更.emit(当前曲目名列表[索引])


# 一首播完后的自动推进（对应原版 MusicReset）
func _on_背景音乐播放器_finished() -> void:
	if 当前曲目 < 0:
		return
	if 循环:
		背景音乐播放器.play()   # 循环当前曲目
		return
	var 下一首: int
	if 随机:
		下一首 = _随机曲目索引(当前曲目)   # 随机且不重复当前
	else:
		下一首 = _顺序下一首(当前曲目)     # 顺序播放下一首
	if 下一首 >= 0:
		播放曲目(下一首)


func _当前专辑曲目数() -> int:
	return 当前曲目路径列表.size()


# 当前专辑内的随机曲目索引，可排除指定索引避免连续重复
func _随机曲目索引(排除 := -1) -> int:
	var 总数 := _当前专辑曲目数()
	if 总数 == 0:
		return -1
	if 总数 == 1:
		return 0
	var 索引 := randi() % 总数
	while 索引 == 排除:
		索引 = randi() % 总数
	return 索引


func _顺序下一首(当前: int) -> int:
	var 总数 := _当前专辑曲目数()
	if 总数 == 0:
		return -1
	return (当前 + 1) % 总数


func 当前歌名() -> String:
	if 当前曲目 < 0 or 当前曲目 >= 当前曲目名列表.size():
		return ""
	return 当前曲目名列表[当前曲目]


func 切换循环() -> void:
	循环 = not 循环


func 切换随机() -> void:
	随机 = not 随机


# =====================================================================
# 音效（移植自原版 Total / PlayOnTouch 的按钮点击音效）
# =====================================================================
func play_button_click_sound() -> void:
	if 按钮按下:
		按钮按下.play()
