## 科研界面主控脚本
## 管理27项科技（农业9项 + 工业9项 + 军事9项）的科技树UI。
## 玩家点击科技按钮启动研究，花费科研点和预算；
## 界面通过进度条、状态图标、年份标签展示每项科技的状态。
extends GameUIBase

const W = preload("res://数据脚本/world_state.gd")

# 27项科技的名称，同时也是场景中对应 TextureButton 节点的名称
# 按顺序排列：[0-8]农业、[9-17]工业、[18-26]军事
const TECH_NAMES: Array[String] = [
	"大跃进的遗产", "巩固农业设施", "农业方法革新",
	"发展农业机械化", "新型肥料与杀虫剂", "开垦处女地",
	"选育与基因研究", "新增研究设施", "遗传修饰",
	"改良流水线生产模式", "自研工业科技", "工业设施中国化",
	"电子工业中国化", "自动化生产控制", "中国版的OGAS",
	"现代制造业", "改进国内工业机械", "计算机化",
	"加强军备开发", "更新军队装备", "情报部门新装备",
	"发展海军与空军", "发展核武器与导弹", "指挥链与军事组织改革",
	"新式间谍装备", "现代间谍装备", "迎接信息化战争",
]

const TECH_UI_COUNT := 27

# 每项科技的最早可研究年份（从 TechState.TECH_YEAR 同步）
const UNLOCK_YEARS: Array[int] = [
	1976, 1976, 1978, 1978, 1978, 1978, 1980, 1981, 1980,
	1976, 1976, 1978, 1980, 1978, 1980, 1981, 1981, 1983,
	1976, 1978, 1978, 1981, 1981, 1976, 1978, 1980, 1981,
]

# 鼠标滚轮滚动参数
const SCROLL_STEP := 80.0    # 每次滚动移动的像素距离
const CAMERA_Y_MIN := 540.0  # 摄像机Y轴上限（最上方）
const CAMERA_Y_MAX := 2400.0 # 摄像机Y轴下限（最下方）

var _tex_yes: Texture2D       # "可研究"状态图标
var _tex_no: Texture2D        # "不可研究"状态图标
var _camera: Camera2D          # 用于上下滚动界面的摄像机
var _refresh_counter: int = 0  # 帧计数器，每10帧刷新一次UI


func _ready() -> void:
	_tex_yes = preload("res://资产/UI/科研/是否可科研状态_是.png")
	_tex_no = preload("res://资产/UI/科研/是否可科研状态_否.png")
	_camera = _find("移动视角摄像机") as Camera2D

	# 将所有 Control 节点设为鼠标穿透，避免遮挡按钮点击
	_make_mouse_transparent(self)

	# 为每个科技按钮绑定点击回调，将科技索引作为参数传入
	for i in TECH_UI_COUNT:
		var btn := find_child(TECH_NAMES[i], true, false) as TextureButton
		if btn:
			btn.mouse_filter = Control.MOUSE_FILTER_STOP  # 按钮自身保留鼠标事件
			btn.pressed.connect(_on_tech_pressed.bind(i))

	_refresh()


## 递归地将所有非按钮 Control 设为 MOUSE_FILTER_IGNORE（鼠标穿透），
## 只保留 TextureButton 可点击。CanvasLayer 不是 Control 的子类，跳过。
func _make_mouse_transparent(node: Node) -> void:
	if node is CanvasLayer:
		return
	if node is TextureButton:
		return
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_make_mouse_transparent(child)


## 刷新整个科研界面：顶部预算/科研点数值 + 每项科技的进度条、状态图标、年份标签
func _refresh() -> void:
	var w := GameManager.world
	if w == null:
		return
	var ts := w.techs
	if ts == null:
		return

	var budget := _raw(w, W.I_BUDGET)
	var science := _raw(w, W.I_SCIENCE)

	# 预算内部以×10存储，显示时除以10还原为实际值
	_label("预算数值", "%.1f" % (float(budget) / 10.0))
	_label("科研点数数值", str(science))

	for i in TECH_UI_COUNT:
		var tech_name := TECH_NAMES[i]

		# --- 进度条：显示剩余研究时间 ---
		var bar := _find(tech_name + "_科研进度") as ProgressBar
		if bar:
			if ts.in_progress[i]:
				# 正在研究：显示剩余时间（总时间 - 已用时间）
				bar.visible = true
				var req := maxi(ts.required_time[i], 1)
				bar.max_value = req
				bar.value = req - ts.elapsed_time[i]
			elif ts.unlocked[i]:
				# 已完成：进度条清空（value=0）表示已研究完毕
				bar.visible = true
				bar.max_value = 1
				bar.value = 0
			else:
				# 未开始：进度条填满（value=1）表示尚未开始
				bar.visible = true
				bar.max_value = 1
				bar.value = 1

		# --- 状态图标：显示"可研究/不可研究"标记 ---
		var icon := _find(tech_name + "_是否可科研状态") as TextureRect
		if icon:
			if ts.unlocked[i]:
				icon.visible = false             # 已完成，不显示图标
			elif ts.in_progress[i]:
				icon.visible = true
				icon.texture = _tex_yes          # 研究中，显示绿色图标
			else:
				icon.visible = true
				if ts.can_start(i, w.date.year):
					icon.texture = _tex_yes      # 满足条件，可以开始
				else:
					icon.texture = _tex_no       # 条件不足，不可开始

		# --- 年份标签：显示解锁年份或当前研究状态 ---
		var lbl := _find(tech_name + "_解锁年份") as Label
		if lbl:
			if ts.unlocked[i]:
				lbl.text = "已完成"
			elif ts.in_progress[i]:
				lbl.text = "研究中"
			else:
				lbl.text = str(UNLOCK_YEARS[i])  # 显示最早可研究年份


## 科技按钮点击回调：消耗科研点和预算，启动研究
@warning_ignore("integer_division")
func _on_tech_pressed(tech_index: int) -> void:
	var w := GameManager.world
	if w == null or w.techs == null:
		return
	var ts := w.techs

	# 已解锁或不满足前置条件则忽略点击
	if ts.unlocked[tech_index] or not ts.can_start(tech_index, w.date.year):
		return

	var d := w.数值表
	# start_research 返回花费的预算金额，同时内部将科技标记为 in_progress
	var money_cost: int = ts.start_research(tech_index, d[W.I_SCIENCE], w.date.year, w.date.month)
	if money_cost > 0:
		d[W.I_SCIENCE] = 0            # 科研点全部消耗
		d[W.I_BUDGET] -= money_cost   # 扣除预算
		w.sync_economy()              # 直接写数值表不会置 dirty，强制同步显示视图
		音频总管.play_button_click_sound()
	_refresh()


## "返回"按钮：切换回外交界面
func _on_返回外交_pressed() -> void:
	get_tree().change_scene_to_file("uid://vq6jexkk5tru")
	音频总管.play_button_click_sound()


## 每10帧刷新一次UI，避免每帧都遍历27项科技的开销
func _process(_delta: float) -> void:
	_refresh_counter += 1
	if _refresh_counter >= 10:
		_refresh_counter = 0
		_refresh()


## 鼠标滚轮滚动：上下移动摄像机实现界面纵向滚动
func _unhandled_input(event: InputEvent) -> void:
	if _camera == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_camera.position.y = maxf(_camera.position.y - SCROLL_STEP, CAMERA_Y_MIN)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_camera.position.y = minf(_camera.position.y + SCROLL_STEP, CAMERA_Y_MAX)
			get_viewport().set_input_as_handled()
