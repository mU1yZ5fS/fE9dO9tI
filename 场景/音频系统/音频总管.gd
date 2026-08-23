extends Node

# =====================================================================
# 音频总管（autoload 单例）
# 移植自 Unity《毛的遗产》GlobalScript 的音乐点唱机 + Total 音效。
#
# 专辑加载机制：
#   导出 exe 后，优先读取 exe 同级的「专辑」目录：
#     <exe目录>/专辑/<专辑名>/
#       info.json（可选）  —— 可写专辑名、曲目名、封面等
#       icon.png / cover.png 等（可选）—— 专辑按钮封面
#       歌曲.ogg / 歌曲.mp3 / 歌曲.wav —— 曲目
#   编辑器下或没有外置专辑目录时，回退读取
#     res://资产/音频/专辑/<专辑名>/
#
# info.json 支持两种常用写法（文件名为 info.json / 信息.json / metadata.json）：
#   {
#     "name": "专辑名",
#     "icon": "cover.png",
#     "tracks": [
#       {"name": "歌名", "file": "song.ogg"},
#       "another_song.mp3"
#     ]
#   }
#   tracks / songs / music / 曲目 / 歌曲 数组里的元素可以是：
#     字符串（音频文件名）、{"name": "...", "file": "..."}、["歌名", "文件"]
#
# 增删专辑或曲目只需在外部文件夹里增删文件，无需改代码或维护 .tres。
# 曲目按需加载（播放时才 load），切专辑/切曲目时旧资源自动释放，省内存。
#
# 给设置场景用的接口：
#   选择专辑(索引) / 专辑总数() / 获取专辑名列表()
#   获取专辑封面(索引) / 获取专辑封面_按下(索引)
#   获取当前曲目名列表() / 当前歌名() / 当前专辑索引
# =====================================================================

signal 曲目变更(歌名: String)   # 当前播放的曲目改变时发出
signal 专辑变更                 # 当前播放的专辑切换时发出（设置场景据此刷新单曲列表）

const 内置专辑根目录 := "res://资产/音频/专辑/"
const 外置专辑根目录名候选 := ["专辑", "音乐", "Albums", "Music"]
const _音频扩展名 := [".ogg", ".wav", ".mp3"]
const _图片扩展名 := [".png", ".jpg", ".jpeg", ".webp"]
const _信息文件名候选 := ["info.json", "信息.json", "metadata.json"]
const _曲目数组键 := ["tracks", "songs", "music", "曲目", "歌曲", "音乐"]

var 背景音乐播放器: AudioStreamPlayer
@onready var 按钮按下: AudioStreamPlayer = $按钮按下

## 按钮悬停音效播放器（懒创建，见 play_button_hover_sound）
var 按钮悬停: AudioStreamPlayer = null

## 当前实际使用的专辑根目录（外置绝对路径或 res:// 路径），空串表示未找到
var 专辑根目录: String = ""
var 当前使用外置专辑: bool = false

var 专辑目录列表: Array[String] = []      # 每张专辑的文件夹路径
var 专辑名列表: Array[String] = []        # 显示名称（优先 info.json，其次文件夹名）

var 当前专辑目录: String = ""
var 当前曲目路径列表: Array[String] = []   # 当前专辑的曲目路径（仅记录，按需 load）
var 当前曲目名列表: Array[String] = []     # 显示名称（优先 info.json，其次文件名）
var 当前专辑索引: int = -1
var 当前曲目: int = -1                    # 当前专辑内的曲目索引

var 循环: bool = false
var 随机: bool = true


func _ready() -> void:
	# 创建背景音乐播放器并路由到「背景音乐」总线
	背景音乐播放器 = AudioStreamPlayer.new()
	背景音乐播放器.name = "背景音乐播放器"
	背景音乐播放器.bus = "背景音乐"
	# ESC 菜单会 get_tree().paused=true，但背景音乐应继续播放，不随暂停停掉。
	背景音乐播放器.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(背景音乐播放器)
	背景音乐播放器.finished.connect(_on_背景音乐播放器_finished)

	# 音效路由到「音效」总线
	if 按钮按下:
		按钮按下.bus = "音效"
	var 音效节点 := get_node_or_null("音效")
	if 音效节点 is AudioStreamPlayer:
		(音效节点 as AudioStreamPlayer).bus = "音效"

	# 应用持久化音量（原版 voice_china 默认 5 → AudioSource.volume=0.05）
	apply_voice()

	_扫描专辑()
	if not 专辑目录列表.is_empty():
		选择专辑(0)   # 默认选第一张专辑并开始播放


# ============================== 专辑目录扫描 ==============================

## 获取最合适的专辑根目录：
## 1. 导出后 exe 同级的「专辑」/「音乐」等目录
## 2. 编辑器工程根目录的同级目录（便于本地测试外置加载）
## 3. 内置 res://资产/音频/专辑
func _获取专辑根目录() -> String:
	for 根 in _候选外置专辑根目录():
		if _目录存在(根):
			return 根
	if _目录存在(内置专辑根目录):
		return 内置专辑根目录
	return ""


func _候选外置专辑根目录() -> Array[String]:
	var 结果: Array[String] = []
	var exe_dir := OS.get_executable_path().get_base_dir()
	var project_dir := ProjectSettings.globalize_path("res://")
	for 名 in 外置专辑根目录名候选:
		结果.append(exe_dir.path_join(名))
		# 工程根目录仅用于编辑器/开发时测试；导出后若与 exe 同级相同也会被去重
		结果.append(project_dir.path_join(名))
	return 结果


func _目录存在(path: String) -> bool:
	return DirAccess.open(path) != null


# 扫描专辑根目录下的所有子文件夹，每个子文件夹 = 一张专辑
func _扫描专辑() -> void:
	专辑目录列表.clear()
	专辑名列表.clear()
	专辑根目录 = _获取专辑根目录()
	当前使用外置专辑 = 专辑根目录 != "" and 专辑根目录 != 内置专辑根目录
	if 专辑根目录 == "":
		push_warning("音频总管：无法打开专辑根目录，请检查 res://资产/音频/专辑 或 exe 同级「专辑」目录")
		return
	var 目录 := DirAccess.open(专辑根目录)
	if 目录 == null:
		push_warning("音频总管：无法打开专辑根目录 " + 专辑根目录)
		return
	var 目录们: Array[String] = []
	目录.list_dir_begin()
	var 名称 := 目录.get_next()
	while 名称 != "":
		if 目录.current_is_dir() and not 名称.begins_with("."):
			目录们.append(专辑根目录.path_join(名称))
		名称 = 目录.get_next()
	目录.list_dir_end()
	目录们.sort()   # 按文件夹名排序，专辑顺序稳定

	# 如果根目录本身没有子文件夹、却直接放了音频，也把根目录当作一张专辑
	if 目录们.is_empty() and _目录含有音频(专辑根目录):
		目录们.append(专辑根目录)

	for d in 目录们:
		专辑目录列表.append(d)
		专辑名列表.append(_读取专辑名(d))
	print("音频总管：加载 %d 张专辑，来源：%s%s" % [
		专辑目录列表.size(),
		"外置 " if 当前使用外置专辑 else "内置 ",
		专辑根目录,
	])


func _目录含有音频(dir_path: String) -> bool:
	var 后缀数组 := PackedStringArray(_音频扩展名)
	return not ResScan.list_files(dir_path, 后缀数组).is_empty()


func 专辑总数() -> int:
	return 专辑目录列表.size()


func 获取专辑名列表() -> Array:
	return 专辑名列表.duplicate()


# ============================== info.json 解析 ==============================

## 读取专辑目录下的信息 json；找不到或解析失败返回空字典。
## 兼容文件名：info.json / 信息.json / metadata.json。
func _读取信息json(目录: String) -> Dictionary:
	for 名 in _信息文件名候选:
		var path := 目录.path_join(名)
		if not FileAccess.file_exists(path):
			continue
		var text := FileAccess.get_file_as_string(path)
		if text.strip_edges() == "":
			return {}
		var parsed: Variant = JSON.parse_string(text)
		if parsed is Dictionary:
			return parsed
		push_warning("音频总管：%s 不是有效的 JSON 对象" % path)
		return {}
	return {}


## 从字典里按多个候选键取值，返回去除首尾空白的字符串；没有则返回空串。
func _字典取字符串(dict: Dictionary, keys: Array) -> String:
	for key in keys:
		if dict.has(key):
			var v: Variant = dict[key]
			var s := str(v).strip_edges()
			if s != "" and s != "<null>":
				return s
	return ""


func _读取专辑名(目录: String) -> String:
	var info := _读取信息json(目录)
	var 名称 := _字典取字符串(info, ["name", "title", "album", "专辑名", "名称", "专辑"])
	if 名称 != "":
		return 名称
	return 目录.trim_suffix("/").get_file()


## 从 info.json 里提取曲目数组；找不到返回空数组。
func _读取曲目条目(info: Dictionary) -> Array:
	if info.is_empty():
		return []
	for key in _曲目数组键:
		if info.has(key):
			var v: Variant = info[key]
			if v is Array:
				return v
	return []


# ============================== 曲目（单曲列表） ==============================

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

	var info := _读取信息json(当前专辑目录)
	var 条目 := _读取曲目条目(info)
	if 条目.is_empty():
		# 没有 info.json 曲目表时，回退为扫描目录里的音频文件
		var 后缀数组 := PackedStringArray(_音频扩展名)
		var 路径们 := ResScan.list_files(当前专辑目录, 后缀数组)
		for p in 路径们:
			当前曲目路径列表.append(p)
			当前曲目名列表.append(p.get_file().get_basename())
		return

	for 条目元素 in 条目:
		var path := _解析曲目路径(条目元素, 当前专辑目录)
		if path == "":
			continue
		当前曲目路径列表.append(path)
		当前曲目名列表.append(_解析曲目名(条目元素, path))


func 获取当前曲目名列表() -> Array:
	return 当前曲目名列表.duplicate()


## 把 info.json 里的单个曲目条目解析成实际音频路径。
## 支持：字符串文件名、{"name":..., "file":...}、["歌名", "文件"]。
func _解析曲目路径(条目: Variant, 目录: String) -> String:
	if 条目 is String:
		var s := (条目 as String).strip_edges()
		if s == "":
			return ""
		if _是音频文件(s):
			return _解析相对路径(s, 目录)
		return _按歌名找音频(s, 目录)
	if 条目 is Dictionary:
		var dict := 条目 as Dictionary
		var file := _字典取字符串(dict, ["file", "path", "src", "audio", "文件名", "文件", "音频", "路径"])
		if file != "":
			return _解析相对路径(file, 目录)
		var 名称 := _字典取字符串(dict, ["name", "title", "歌名", "曲名", "标题"])
		if 名称 != "":
			return _按歌名找音频(名称, 目录)
		return ""
	if 条目 is Array and (条目 as Array).size() >= 2:
		var arr := 条目 as Array
		var a := str(arr[0]).strip_edges()
		var b := str(arr[1]).strip_edges()
		if _是音频文件(a):
			return _解析相对路径(a, 目录)
		if _是音频文件(b):
			return _解析相对路径(b, 目录)
	return ""


## 把 info.json 里的单个曲目条目解析成显示名。
func _解析曲目名(条目: Variant, path: String) -> String:
	if 条目 is Dictionary:
		var dict := 条目 as Dictionary
		var 名称 := _字典取字符串(dict, ["name", "title", "歌名", "曲名", "标题"])
		if 名称 != "":
			return 名称
	if 条目 is Array and (条目 as Array).size() >= 2:
		var arr := 条目 as Array
		var a := str(arr[0]).strip_edges()
		var b := str(arr[1]).strip_edges()
		if a != "" and not _是音频文件(a):
			return a
		if b != "" and not _是音频文件(b):
			return b
	return path.get_file().get_basename()


func _是音频文件(s: String) -> bool:
	var lower := s.to_lower()
	for ext in _音频扩展名:
		if lower.ends_with(ext):
			return true
	return false


## 把 info.json 里写的相对文件名拼接成真实路径；绝对路径/res:///user:// 原样返回。
func _解析相对路径(文件: String, 目录: String) -> String:
	if 文件.begins_with("res://") or 文件.begins_with("user://"):
		return 文件
	if 文件.begins_with("/") or 文件.contains(":"):
		return 文件
	return 目录.path_join(文件)


## 根据歌名在当前专辑目录里找一个同名音频文件（用于 info.json 只写歌名的情况）。
func _按歌名找音频(歌名: String, 目录: String) -> String:
	var target := 歌名.strip_edges().to_lower()
	if target == "":
		return ""
	var 后缀数组 := PackedStringArray(_音频扩展名)
	var 路径们 := ResScan.list_files(目录, 后缀数组)
	for p in 路径们:
		if p.get_file().get_basename().to_lower() == target:
			return p
	return ""


# ============================== 播放与推进 ==============================

# 播放当前专辑内的指定曲目（对应原版 zadan_music 指定曲目）
func 播放曲目(索引: int) -> void:
	if 索引 < 0 or 索引 >= 当前曲目路径列表.size():
		return
	var 流 := _加载音频流(当前曲目路径列表[索引])
	if 流 == null:
		push_warning("无法加载曲目：" + 当前曲目路径列表[索引])
		return
	当前曲目 = 索引
	背景音乐播放器.stream = 流
	背景音乐播放器.play()
	曲目变更.emit(当前曲目名列表[索引])


## 内部 res:// 走 ResourceLoader（支持导出后的 .remap）；
## 外置绝对路径用各 AudioStream 的 load_from_file 直接读取，不依赖导入缓存。
func _加载音频流(path: String) -> AudioStream:
	if path == "":
		return null
	var lower := path.to_lower()
	if path.begins_with("res://"):
		var res: Variant = load(path)
		return res if res is AudioStream else null
	if lower.ends_with(".ogg"):
		return AudioStreamOggVorbis.load_from_file(path)
	if lower.ends_with(".mp3"):
		return AudioStreamMP3.load_from_file(path)
	if lower.ends_with(".wav"):
		return AudioStreamWAV.load_from_file(path)
	return null


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


# ============================== 专辑封面 ==============================

# 专辑按钮的普通封面（优先 info.json 指定，其次 icon.* / cover.*）
func 获取专辑封面(索引: int) -> Texture2D:
	if 索引 < 0 or 索引 >= 专辑目录列表.size():
		return null
	return _查找专辑图片(专辑目录列表[索引], false)


# 专辑按钮的按下封面（优先 icon_h.*；缺失时调用方回退到普通封面）
func 获取专辑封面_按下(索引: int) -> Texture2D:
	if 索引 < 0 or 索引 >= 专辑目录列表.size():
		return null
	var tex := _查找专辑图片(专辑目录列表[索引], true)
	return tex if tex != null else 获取专辑封面(索引)


func _查找专辑图片(目录: String, pressed: bool) -> Texture2D:
	var info := _读取信息json(目录)
	var info_key: String = ""
	if pressed:
		info_key = _字典取字符串(info, ["icon_pressed", "icon_h", "press_icon", "按下封面", "按下图标"])
	else:
		info_key = _字典取字符串(info, ["icon", "cover", "封面", "图标"])
	if info_key != "":
		var tex := _加载图片(_解析相对路径(info_key, 目录))
		if tex != null:
			return tex

	var 候选: Array[String] = []
	if pressed:
		for ext in _图片扩展名:
			候选.append("icon_h" + ext)
		候选.append("icon_pressed" + _图片扩展名[0])
	else:
		for ext in _图片扩展名:
			候选.append("icon" + ext)
			候选.append("cover" + ext)
	for 文件名 in 候选:
		var tex := _加载图片(目录.path_join(文件名))
		if tex != null:
			return tex
	return null


## 加载图片：res:// 走 ResourceLoader；外置绝对路径用 Image.load_from_file。
func _加载图片(path: String) -> Texture2D:
	if path == "":
		return null
	if path.begins_with("res://"):
		var res: Variant = load(path)
		return res as Texture2D
	if not FileAccess.file_exists(path):
		return null
	var img := Image.load_from_file(path)
	if img == null:
		return null
	return ImageTexture.create_from_image(img)


# ============================== 音量 ==============================

## 音量 0-100（原版 voice 字段，默认 5）应用到「背景音乐」总线。
## 原版 AudioSource.volume = voice/100，即线性音量；Godot 总线用 dB，这里做 linear_to_db 转换。
func apply_voice() -> void:
	var 索引 := AudioServer.get_bus_index("背景音乐")
	if 索引 < 0:
		return
	var 值: int = GameManager.voice if GameManager else 5
	var 线性 := clampf(float(值) / 100.0, 0.0, 1.0)
	AudioServer.set_bus_volume_db(索引, linear_to_db(clampf(线性, 0.001, 1.0)))
	AudioServer.set_bus_mute(索引, 值 == 0)


# =====================================================================
# 音效（移植自原版 Total / PlayOnTouch 的按钮点击音效）
# =====================================================================
func play_button_click_sound() -> void:
	if 按钮按下:
		按钮按下.play()


## 按钮悬停音效（click_mouse_over_01.wav；由 按钮特效 autoload 统一触发）。
## 播放器按需懒创建，路由到「音效」总线。
func play_button_hover_sound() -> void:
	if 按钮悬停 == null:
		按钮悬停 = AudioStreamPlayer.new()
		按钮悬停.name = "按钮悬停"
		按钮悬停.bus = "音效"
		按钮悬停.stream = preload("res://资产/音频/音效/click_mouse_over_01.wav")
		add_child(按钮悬停)
	if 按钮悬停:
		按钮悬停.play()
