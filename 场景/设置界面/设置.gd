extends Control

@onready var 循环播放: TextureButton = $循环播放
@onready var 随机播放: TextureButton = $随机播放
@onready var 翻页按钮_右: TextureButton = get_node_or_null("专辑右翻页")
@onready var 翻页按钮_左: TextureButton = get_node_or_null("专辑左翻页")
@onready var 难度行: Control = get_node_or_null("难度行")
@onready var 难度值: Label = get_node_or_null("难度行/值")
@onready var 难度成就: Label = get_node_or_null("难度行/成就")
@onready var 自动保存值: Label = get_node_or_null("自动保存行/值")
@onready var 保存槽位值: Label = get_node_or_null("保存槽位行/值")

## 显示名逐字对齐原作 DiffScript.cs / Need_save.cs 的字符串（含原空格）。
const DIFF_NAMES := [" 牛 棚 小 酌", " 上 山 下 乡", " 斗 私 批 修", " 造 反 有 理", " 浩 荡 文 革"]
const AUTOSAVE_NAMES := [" 不 自 动 保 存", " 每 月 自 动 保 存", " 半 年 自 动 保 存"]
const SAVEPLACE_NAMES := {
	5: " 成 就 激 活 档 位",
	1: " 无 成 就 壹 档",
	2: " 无 成 就 贰 档",
	3: " 无 成 就 叁 档",
	4: " 无 成 就 肆 档",
}

var 专辑页码: int = 0   # 当前显示第几页专辑（每页 = 「专辑」组里的槽位数）


func _ready() -> void:
	循环播放.pressed.connect(_on_循环播放_pressed)
	随机播放.pressed.connect(_on_随机播放_pressed)
	if 翻页按钮_右:
		翻页按钮_右.pressed.connect(_on_专辑右翻页_pressed)
	if 翻页按钮_左:
		翻页按钮_左.pressed.connect(_on_专辑左翻页_pressed)
	音频总管.专辑变更.connect(_on_专辑变更)
	_连接槽位信号()
	_连接专辑槽位信号()
	_连接设置选择器()
	_刷新槽位显示()
	_刷新按钮外观()
	_初始化专辑页码()
	_refresh_settings_rows()


## 难度/自动保存/存档槽三行的左右箭头（对应原作 DiffScript / Need_save OnMouseDown）。
func _连接设置选择器() -> void:
	for 行 in ["难度行", "自动保存行", "保存槽位行"]:
		var 左 := get_node_or_null(行 + "/左") as BaseButton
		var 右 := get_node_or_null(行 + "/右") as BaseButton
		if 左:
			左.pressed.connect(_on_选择器左_pressed.bind(行))
		if 右:
			右.pressed.connect(_on_选择器右_pressed.bind(行))


func _on_选择器左_pressed(行: String) -> void:
	音频总管.play_button_click_sound()
	match 行:
		"难度行":
			_change_difficulty(-1)
		"自动保存行":
			_change_autosave(-1)
		"保存槽位行":
			_change_saveplace(-1)


func _on_选择器右_pressed(行: String) -> void:
	音频总管.play_button_click_sound()
	match 行:
		"难度行":
			_change_difficulty(1)
		"自动保存行":
			_change_autosave(1)
		"保存槽位行":
			_change_saveplace(1)


## 原作 DiffScript.OnMouseDown：右 +1 越界回 0，左 -1 越界回 4。
func _change_difficulty(delta: int) -> void:
	if GameManager == null or GameManager.world == null:
		return
	var d: int = GameManager.world.difficulty
	if delta > 0:
		d = 0 if d >= 4 else d + 1
	else:
		d = 4 if d <= 0 else d - 1
	GameManager.set_difficulty(d)
	_refresh_settings_rows()


## 原作 Need_save.DownToAutoSave：右 +1 越界回 0，左 -1 越界回 2。
func _change_autosave(delta: int) -> void:
	var v: int = GameManager.autosave_mode
	if delta > 0:
		v = 0 if v >= 2 else v + 1
	else:
		v = 2 if v <= 0 else v - 1
	GameManager.set_autosave_mode(v)
	_refresh_settings_rows()


## 原作 Need_save.DownToSaveSlot：savePlace 1..5 循环，持久化 SavePlaceNum。
func _change_saveplace(delta: int) -> void:
	var v: int = GameManager.save_place
	if delta > 0:
		v = 1 if v >= 5 else v + 1
	else:
		v = 5 if v <= 1 else v - 1
	GameManager.set_save_place(v)
	_refresh_settings_rows()


## 原作 SettingInGameScript：无活动局时销毁难度选择器（Godot 用隐藏），其余两行常驻。
func _refresh_settings_rows() -> void:
	if GameManager == null:
		return
	if 难度行:
		难度行.visible = GameManager.world != null
	if 难度值 and GameManager.world != null:
		var d := clampi(GameManager.world.difficulty, 0, 4)
		难度值.text = DIFF_NAMES[d]
		# 原作 DiffScript.Textotext：diff 0/1 → 成就 X，2-4 → 成就 V。
		if 难度成就:
			难度成就.text = " 成 就 ： X" if d < 2 else " 成 就 ： V"
	if 自动保存值:
		自动保存值.text = AUTOSAVE_NAMES[clampi(GameManager.autosave_mode, 0, 2)]
	if 保存槽位值:
		保存槽位值.text = SAVEPLACE_NAMES.get(GameManager.save_place, str(GameManager.save_place))


# ============ 单曲列表（左/右共 40 槽位，显示当前播放专辑的曲目） ============

func _获取槽位() -> Array:
	var 槽位: Array = []
	for 子节点 in get_children():
		if 子节点.has_node("播放按钮"):
			槽位.append(子节点)
	return 槽位


func _连接槽位信号() -> void:
	var 槽位 := _获取槽位()
	for i in 槽位.size():
		槽位[i].get_node("播放按钮").pressed.connect(_on_播放单曲.bind(i))


func _刷新槽位显示() -> void:
	var 曲名列表: Array = 音频总管.获取当前曲目名列表()
	var 槽位 := _获取槽位()
	for i in 槽位.size():
		var 槽: Control = 槽位[i]
		if i < 曲名列表.size():
			槽.get_node("歌名").text = str(曲名列表[i])
			槽.visible = true
		else:
			槽.visible = false


func _on_播放单曲(索引: int) -> void:
	音频总管.play_button_click_sound()
	音频总管.播放曲目(索引)


# ============ 专辑按钮（分页浏览，点击播放） ============

# 专辑槽位 = 加入「专辑」组的节点（专辑.tscn 实例，根为 Control，内含「专辑按钮」TextureButton）
# 每次实时取组，保证增删槽位后无需改代码
func _获取专辑槽位() -> Array:
	return get_tree().get_nodes_in_group("专辑")


func _连接专辑槽位信号() -> void:
	var 槽位 := _获取专辑槽位()
	for i in 槽位.size():
		var 按钮 := 槽位[i].get_node_or_null("专辑按钮") as TextureButton
		if 按钮 != null:
			按钮.pressed.connect(_on_专辑槽位_按下.bind(i))


# 进入设置时，翻到正在播放的专辑所在的那一页
func _初始化专辑页码() -> void:
	var 每页 := _获取专辑槽位().size()
	if 每页 > 0 and 音频总管.当前专辑索引 >= 0:
		专辑页码 = floori(float(音频总管.当前专辑索引) / float(每页))
	_刷新专辑槽位()


# 把当前页的专辑封面填进各槽位；本页没有对应专辑的槽位隐藏
func _刷新专辑槽位() -> void:
	var 槽位 := _获取专辑槽位()
	var 每页 := 槽位.size()
	var 起始 := 专辑页码 * 每页
	var 专辑数: int = 音频总管.专辑总数()
	for i in 每页:
		var 槽: CanvasItem = 槽位[i]
		var 专辑索引 := 起始 + i
		var 按钮 := 槽.get_node_or_null("专辑按钮") as TextureButton
		if 专辑索引 < 专辑数:
			if 按钮 != null:
				var 封面: Texture2D = 音频总管.获取专辑封面(专辑索引)
				var 按下: Texture2D = 音频总管.获取专辑封面_按下(专辑索引)
				按钮.texture_normal = 封面
				按钮.texture_pressed = 按下 if 按下 != null else 封面
			槽.visible = true
		else:
			槽.visible = false


func _总页数() -> int:
	var 每页 := _获取专辑槽位().size()
	var 专辑数: int = 音频总管.专辑总数()
	if 每页 == 0 or 专辑数 == 0:
		return 1
	return ceili(float(专辑数) / float(每页))


func _on_专辑右翻页_pressed() -> void:
	音频总管.play_button_click_sound()
	专辑页码 = (专辑页码 + 1) % _总页数()
	_刷新专辑槽位()


func _on_专辑左翻页_pressed() -> void:
	音频总管.play_button_click_sound()
	var 页数 := _总页数()
	专辑页码 = (专辑页码 - 1 + 页数) % 页数
	_刷新专辑槽位()


# 点击某个专辑槽位 → 播放该槽位当前对应的专辑
func _on_专辑槽位_按下(槽序号: int) -> void:
	var 专辑索引 := 专辑页码 * _获取专辑槽位().size() + 槽序号
	if 专辑索引 < 音频总管.专辑总数():
		音频总管.play_button_click_sound()
		音频总管.选择专辑(专辑索引)


# ============ 其余按钮 ============

func _on_专辑变更() -> void:
	_刷新槽位显示()


func _on_循环播放_pressed() -> void:
	音频总管.play_button_click_sound()
	音频总管.切换循环()
	_刷新按钮外观()


func _on_随机播放_pressed() -> void:
	音频总管.play_button_click_sound()
	音频总管.切换随机()
	_刷新按钮外观()


func _刷新按钮外观() -> void:
	循环播放.modulate = Color.WHITE if 音频总管.循环 else Color(1, 1, 1, 0.35)
	随机播放.modulate = Color.WHITE if 音频总管.随机 else Color(1, 1, 1, 0.35)


func _on_返回_pressed() -> void:
	var return_scene: String = GameManager.settings_return_scene
	if return_scene == "":
		return_scene = "uid://bydan4iqthbaa"
	get_tree().paused = false
	get_tree().change_scene_to_file(return_scene)
	音频总管.play_button_click_sound()
