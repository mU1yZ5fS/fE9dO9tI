extends GameUIBase

## 经济界面逻辑。
## 顶部：工业/农业/服务业/腐败概览
## 左中：11 项预算分配（+/- 按钮调整）
## 右栏：贷款/储蓄金/债务信息
## 文案与数值对齐原版 Economy.unity + Show_diplomacy_data_script.cs + other_text_en.txt

const W = preload("res://数据脚本/world_state.gd")
const BBC = preload("res://数据脚本/bbc_tooltip.gd")

const 预算项 := {
	"工业支出": W.I_BUDGET_INDUSTRY,
	"行政支出": W.I_BUDGET_ADMIN,
	"农业支出": W.I_BUDGET_AGRI,
	"科研经费": W.I_BUDGET_SCIENCE,
	"军费": W.I_BUDGET_ARMY,
	"国安部经费": W.I_BUDGET_MGB,
	"外交支出": W.I_BUDGET_DIPLO,
	"高层福利": W.I_BUDGET_ENVELOPE,
	"服务业支出": W.I_BUDGET_SERVICES,
	"宣传支出": W.I_BUDGET_PROPAGANDA,
	"福利支出": W.I_BUDGET_WELFARE,
}

const STEP := 10

## 预算格悬浮说明：原版 other_text_en.txt 索引 339-349（OkoshkoScript.numString）。
## {0} 为原版换行占位符，运行时替换成换行。
const 预算提示 := {
	W.I_BUDGET_ARMY: "<color=green>提 升 军 事 实 力</color>{0}若 投 资 额 低 于 8.0 ： <color=red>降 低 生 活 水 平</color> 否 则 <color=green>提 升 生 活 水 平</color>{0}<color=green>提 升 国 内 团 结 度</color>{0}<color=green>降 低 思 想 自 由 化</color>{0}<color=green>提 升 工 业</color>{0}<color=red>提 升 腐 败 度</color>",
	W.I_BUDGET_MGB: "<color=green>提 升 特 工 网 络</color>{0}根 据 每 15.0 投 资 额 : <color=green>降 低 腐 败 度</color>{0}<color=green>降 低 思 想 自 由 化</color>{0}<color=red>降 低 人 民 支 持 度</color>{0}<color=red>提 升 党 内 支 持 度</color>{0}<color=green>提 升 生 活 水 平</color>",
	W.I_BUDGET_SCIENCE: "<color=red>提 升 腐 败 度</color>{0}<color=green>提 升 科 学 点 数</color>",
	W.I_BUDGET_ADMIN: "<color=green>降 低 腐 败 度</color>{0}<color=green>提 升 党 内 支 持 度</color>{0}<color=green>提 升 生 活 水 平</color>",
	W.I_BUDGET_ENVELOPE: "<color=red>提 升 腐 败 度</color>{0}<color=green>提 升 党 内 支 持 度</color>",
	W.I_BUDGET_PROPAGANDA: "若 投 资 额 低 于 5.0： <color=red>提 升 腐 败 度</color> 否 则 <color=green>降 低 腐 败 度</color>{0}<color=green>提 升 国 内 团 结 度</color>{0}<color=green>降 低 思 想 自 由 化</color>{0}若 投 资 额 低 于 5.0： <color=red>降 低 人 民 支 持 度</color> 否 则 <color=green>提 升 人 民 支 持 度</color>",
	W.I_BUDGET_AGRI: "<color=red>提 升 腐 败 度</color>{0}<color=green>提 升 农 业</color>{0}<color=green>提 升 生 活 水 平</color>",
	W.I_BUDGET_INDUSTRY: "<color=red>提 升 腐 败 度</color>{0}<color=green>提 升 工 业</color>{0}<color=green>提 升 生 活 水 平</color>",
	W.I_BUDGET_SERVICES: "<color=red>提 升 腐 败 度</color>{0}<color=green>提 升 服 务 业</color>{0}<color=green>提 升 生 活 水 平</color>",
	W.I_BUDGET_WELFARE: "<color=red>提 升 腐 败 度</color>{0}<color=green>提 升 人 民 支 持 度</color>{0}<color=green>提 升 生 活 水 平</color>",
	W.I_BUDGET_DIPLO: "<color=green>提 升 外 交 干 预 点 数</color>{0}<color=green>提 升 与 美 苏 的 关 系</color>{0}若 投 资 额 低 于 6.0： <color=yellow>降 低 外 交 声 誉</color>{0}若 投 资 额 低 于 5.0： <color=red>降 低 中 国 在 非 洲 的 影 响 力</color> 否 则 <color=green>提 升 中 国 在 非 洲 的 影 响 力</color>{0}<color=green>提 升 中 国 对 盟 国 的 影 响 力</color>",
}


func _ready() -> void:
	if not GameManager:
		return
	GameManager.world_state_loaded.connect(_refresh)
	GameManager.date_changed.connect(func(_d): _refresh())
	for item_name in 预算项:
		var idx: int = 预算项[item_name]
		var plus := _find(item_name + "+")
		var minus := _find(item_name + "-")
		if plus is Button:
			plus.pressed.connect(_on_budget_adjust.bind(idx, STEP))
		if minus is Button:
			minus.pressed.connect(_on_budget_adjust.bind(idx, -STEP))
	var loan_plus := _find("贷款+")
	var loan_minus := _find("贷款-")
	if loan_plus is Button:
		loan_plus.pressed.connect(_on_loan_adjust.bind(STEP))
	if loan_minus is Button:
		loan_minus.pressed.connect(_on_loan_adjust.bind(-STEP))
	var reserve_plus := _find("储蓄金+")
	var reserve_minus := _find("储蓄金-")
	if reserve_plus is Button:
		reserve_plus.pressed.connect(_on_reserve_adjust.bind(STEP))
	if reserve_minus is Button:
		reserve_minus.pressed.connect(_on_reserve_adjust.bind(-STEP))
	_attach_tooltips()
	if GameManager.world != null:
		_refresh()


## 预算/储备批量快捷：Shift=±50、Ctrl=±100、否则 ±10（原版 Plusmisnus_script.cs 预算/储备分支）
func _step_magnitude() -> int:
	if Input.is_key_pressed(KEY_SHIFT):
		return 50
	if Input.is_key_pressed(KEY_CTRL):
		return 100
	return STEP


func _on_budget_adjust(idx: int, delta: int) -> void:
	var mag := _step_magnitude()
	var amount := mag if delta > 0 else -mag
	if GameManager.adjust_budget(idx, amount):
		_refresh()


func _on_loan_adjust(delta: int) -> void:
	# 贷款分支原版无 Shift/Ctrl，固定 ±10
	if GameManager.adjust_loan(delta):
		_refresh()


func _on_reserve_adjust(delta: int) -> void:
	var mag := _step_magnitude()
	var amount := mag if delta > 0 else -mag
	if GameManager.adjust_reserve(amount):
		_refresh()


func _refresh() -> void:
	var w: WorldState = GameManager.world
	if w == null:
		return
	var bar := _find("状态栏")
	if bar and bar.has_method("_refresh"):
		bar._refresh()
	_label("工业数值", "%.1f" % (float(w.数值表[W.I_INDUSTRY]) / 10.0))
	_label("农业数值", "%.1f" % (float(w.数值表[W.I_AGRICULTURE]) / 10.0))
	_label("服务业数值", "%.1f" % (float(w.数值表[W.I_SERVICES]) / 10.0))
	_label("腐败数值", "%.1f" % (float(w.数值表[W.I_CORRUPTION]) / 10.0))
	_label("预算数值", "%.1f" % (float(w.数值表[W.I_BUDGET]) / 10.0))
	for item_name in 预算项:
		var idx: int = 预算项[item_name]
		_label(item_name + "数值", "%.1f" % (float(_raw(w, idx)) / 10.0))
	_label("贷款数值", "%.1f" % (float(w.数值表[W.I_LOAN]) / 10.0))
	_label("储蓄金数值", "%.1f" % (float(w.数值表[W.I_RESERVE]) / 10.0))
	# 债务损耗 UI（原版 Show_diplomacy_data_script.Repaint_dolg:290-298）：
	# num=loan/40；零头保底(num<=0 且 loan>0 → 1)；年份互斥加成(1983 +2 / 1980 +1)；定点 num/10.num%10
	var loan: int = w.数值表[W.I_LOAN]
	var year := w.date.year if w.date else 1976
	@warning_ignore("integer_division")
	var debt_num := loan / 40
	if debt_num <= 0 and loan > 0:
		debt_num = 1
	if year >= 1983 and loan > 0:
		debt_num += 2
	elif year >= 1980 and loan > 0:
		debt_num += 1
	_label("债务损耗", " 债 务 损 耗 : \n 预 算 -" + _fixed_point(debt_num))
	# 债务限额：按主人确认使用真实换行（不照抄原版中文分支的字面量 \n）
	_label("债务限额", " 债 务 限 额 : \n" + _fixed_point(_loan_limit(w)))
	# 贪腐损耗 UI（原版 Repaint_corrupt:316-330）：预算 num=corr/10、生活 num2=corr/50，定点显示
	var corruption: int = w.数值表[W.I_CORRUPTION]
	@warning_ignore("integer_division")
	var corr_budget := corruption / 10
	@warning_ignore("integer_division")
	var corr_living := corruption / 50
	_label("贪腐损耗", " 贪 腐 损 耗 : \n 预 算 -%s\n 生 活 水 平 : -%s" % [_fixed_point(corr_budget), _fixed_point(corr_living)])
	# 最大投资 UI（原版 Show_diplomacy_data_script.MakePlankaReady:82-93）：
	# 先 sum/6 再减经济体制惩罚（与点击上限 CheckPlanka 的先减后除顺序不同，整数除法下可差 1，照抄原作）。
	@warning_ignore("integer_division")
	var planka_sum := w.数值表[W.I_BUDGET] + w.数值表[W.I_RESERVE]
	for i in range(W.I_BUDGET_ARMY, W.I_BUDGET_DIPLO + 1):
		planka_sum += w.数值表[i]
	@warning_ignore("integer_division")
	var planka_display := planka_sum / 6
	if w.数值表[W.I_ECON_SYSTEM] > 12:
		@warning_ignore("integer_division")
		planka_display -= (w.数值表[W.I_ECON_SYSTEM] - 12) * (planka_display / 10)
	# 原版 Repaint_planka：整数位是 abs(plankas/10 + 1)，先 +1 再取绝对值。
	@warning_ignore("integer_division")
	_label("最大投资", " 最 大 投 资 :\n%d.%d" % [absi(planka_display / 10 + 1), absi(planka_display % 10)])
	_label("储蓄金影响", _reserve_effect(w))
	var oligarch := w.数值表[W.I_OLIGARCH]
	_label("寡头状态文本", "%s\n 其 影 响 力 为 : %d/100" % [_oligarch_label(oligarch), oligarch])
	_refresh_tooltips(w)


# ── 悬浮提示（对齐原版 OkoshkoScript / Show_diplomacy_data_script.Repaint） ──

func _attach_tooltips() -> void:
	for item_name in 预算项:
		_set_tip_node(item_name + "背景图标")
	for node_name in ["工业数值", "农业数值", "服务业数值", "腐败数值", "贷款数值"]:
		_set_tip_node(node_name)


func _set_tip_node(node_name: String) -> void:
	var n := _find(node_name)
	if n is Control:
		BBC.attach(n)


func _set_tip_text(node_name: String, text: String) -> void:
	var n := _find(node_name)
	if n is Control:
		BBC.attach(n)
		n.tooltip_text = text


## 原版 data_old 显示规则：非负强制 +，负号保留；整数位/十分位分别取绝对值。
func _delta_str(v: int) -> String:
	var 符号 := "-" if v < 0 else "+"
	@warning_ignore("integer_division")
	return "%s%d.%d" % [符号, absi(v / 10), absi(v % 10)]


func _refresh_tooltips(w: WorldState) -> void:
	# 顶部四栏：原版 OkoshkoScript.text_en = "两周内"
	_set_tip_text("工业数值", "%s: %s" % ["两周内", _delta_str(w.两周变化(W.I_INDUSTRY))])
	_set_tip_text("农业数值", "%s: %s" % ["两周内", _delta_str(w.两周变化(W.I_AGRICULTURE))])
	_set_tip_text("服务业数值", "%s: %s" % ["两周内", _delta_str(w.两周变化(W.I_SERVICES))])
	_set_tip_text("腐败数值", "%s: %s" % ["两周内", _delta_str(w.两周变化(W.I_CORRUPTION))])
	# 贷款：原版 OkoshkoScript.text_en = "国家债务 (每两周)"
	_set_tip_text("贷款数值", "%s: %s" % ["国家债务 (每两周)", _delta_str(w.两周变化(W.I_LOAN))])
	for item_name in 预算项:
		var idx: int = 预算项[item_name]
		var tip: String = 预算提示.get(idx, "").replace("{0}", "\n")
		# 原版悬浮框挂在整块 plashka 上：底牌、按钮、数值、名称任一区域悬停都显示
		for suffix in ["背景图标", "+", "-", "数值", ""]:
			_set_tip_text(item_name + suffix, tip)


## 寡头影响力 5 档文案（原版 Show_diplomacy_data_script.cs:229-248，读 data[108]，逐字含空格）
func _oligarch_label(v: int) -> String:
	if v < 18:
		return " 国 内 寡 头 无 立 锥 之 地"
	elif v < 36:
		return " 国 内 寡 头 无 足 轻 重"
	elif v < 54:
		return " 国 内 寡 头 方 兴 未 艾"
	elif v < 72:
		return " 国 内 寡 头 如 日 中 天"
	return " 国 内 寡 头 权 倾 朝 野"


## 原版 Show_diplomacy_data_script.ReserveRepaint（:107-223）中文分支的动态储备金影响
func _reserve_effect(w: WorldState) -> String:
	var d := w.数值表
	var reserve: int = d[W.I_RESERVE]
	var econ: int = d[W.I_ECON_SYSTEM]
	var year: int = w.date.year if w.date else 1976
	var num := 0
	var num2 := 0
	if year < 1980:
		if econ == 13:
			@warning_ignore("integer_division")
			num2 -= reserve / 400
			if reserve < 600:
				@warning_ignore("integer_division")
				num -= 3 - reserve / 150
			else:
				num += 1
		elif econ >= 14:
			@warning_ignore("integer_division")
			num2 -= reserve / 200
			if reserve < 750:
				@warning_ignore("integer_division")
				num -= 4 - reserve / 150
			else:
				num += 1
	elif econ == 13:
		@warning_ignore("integer_division")
		num2 -= reserve / 600
		if reserve < 750:
			@warning_ignore("integer_division")
			num -= 4 - reserve / 150
		else:
			num += 1
	elif econ == 14:
		@warning_ignore("integer_division")
		num2 -= reserve / 400
		if reserve < 1500:
			@warning_ignore("integer_division")
			num -= 7 - reserve / 150
		else:
			num += 3
	elif econ == 15:
		@warning_ignore("integer_division")
		num2 -= reserve / 200
		@warning_ignore("integer_division")
		num -= 13 - reserve / 150
	elif econ == 12:
		@warning_ignore("integer_division")
		num2 -= reserve / 200
		if reserve < 600:
			@warning_ignore("integer_division")
			num -= 3 - reserve / 150
		else:
			num += 1
	var s := " 储 备 金 的 影 响 :\n 第 三 产 业 ，工 业 与 生 活 水 平 : "
	if num >= 10:
		@warning_ignore("integer_division")
		s += "+%d.%d" % [absi(num / 10), absi(num % 10)]
	elif num <= -10:
		@warning_ignore("integer_division")
		s += "-%d.%d" % [absi(num / 10), absi(num % 10)]
	elif num < 0:
		s += "-0.%d" % absi(num)
	else:
		s += "+0.%d" % num
	s += "\n 腐 败 : -0.%d" % absi(num2)
	s += "\n 盟 国 政 权 稳 定 度 : +%s" % _csharp_float_str(float(reserve) / 1500.0)
	return s


func _loan_limit(w: WorldState) -> int:
	var usa_rel := 0
	var ussr_rel := 0
	if w.empires.size() > 0:
		usa_rel = w.empires[0].relations
	if w.empires.size() > 1:
		ussr_rel = w.empires[1].relations
	@warning_ignore("integer_division")
	return (usa_rel + ussr_rel) / 5


## 近似 Unity/Mono float.ToString() 的 7 位有效数字输出（原版 :200 用它显示 reserve/1500）。
func _csharp_float_str(v: float) -> String:
	if absf(v) < 0.0000001:
		return "0"
	var av: float = absf(v)
	# Godot 4.7 文档 gdd_1591：round()/floor() 返回 Variant，需用 roundf()/floorf() 保类型
	var order: float = floorf(log(av) / log(10.0))
	var sig: int = int(pow(10.0, 6.0 - order))
	var rounded: float = roundf(av * sig) / float(sig)
	return ("-" if v < 0.0 else "") + String.num(rounded)


## 整数（×10 存储单位）→ 定点字符串 "x.y"，对齐原版各 Repaint_* 的 num/10 "." num%10 显示。
func _fixed_point(v: int) -> String:
	@warning_ignore("integer_division")
	return "%d.%d" % [absi(v / 10), absi(v % 10)]
