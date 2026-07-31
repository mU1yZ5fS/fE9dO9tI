extends GameUIBase

## 经济界面逻辑。
## 顶部：工业/农业/服务业/腐败概览
## 左中：11 项预算分配（+/- 按钮调整）
## 右栏：贷款/储蓄金/债务信息

const W = preload("res://数据脚本/world_state.gd")

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
		音频总管.play_button_click_sound()


func _on_loan_adjust(delta: int) -> void:
	# 贷款分支原版无 Shift/Ctrl，固定 ±10
	if GameManager.adjust_loan(delta):
		_refresh()
		音频总管.play_button_click_sound()


func _on_reserve_adjust(delta: int) -> void:
	var mag := _step_magnitude()
	var amount := mag if delta > 0 else -mag
	if GameManager.adjust_reserve(amount):
		_refresh()
		音频总管.play_button_click_sound()


func _refresh() -> void:
	var w := GameManager.world
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
	# 债务损耗 UI（原版 Show_diplomacy_data_script.Repaint_dolg:280-298）：
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
	_label("债务损耗", "债务损耗：\n预算-" + _fixed_point(debt_num))
	_label("债务限额", "债务限额：\n%.1f" % (float(_loan_limit(w)) / 10.0))
	# 贪腐损耗 UI（原版 Repaint_corrupt:316-330）：预算 num=corr/10、生活 num2=corr/50，定点显示
	var corruption: int = w.数值表[W.I_CORRUPTION]
	@warning_ignore("integer_division")
	var corr_budget := corruption / 10
	@warning_ignore("integer_division")
	var corr_living := corruption / 50
	_label("贪腐损耗", "贪腐损耗:\n预算-%s\n生活水平:-%s" % [_fixed_point(corr_budget), _fixed_point(corr_living)])
	var planka := GameManager.calc_budget_planka()
	_label("最大投资", "每类上限：\n%.1f" % (float(planka) / 6.0 / 10.0))
	_label("储蓄金影响", "储蓄金影响：\n工业,服务,生活水平\n腐败随储备增加")
	var oligarch := w.数值表[W.I_OLIGARCH]
	_label("寡头状态文本", "%s\n其影响力为:%d/100" % [_oligarch_label(oligarch), oligarch])


## 寡头影响力 5 档文案（原版 Show_diplomacy_data_script.cs:229-248，读 data[108]）
func _oligarch_label(v: int) -> String:
	if v < 18:
		return "国内寡头无立锥之地"
	elif v < 36:
		return "国内寡头无足轻重"
	elif v < 54:
		return "国内寡头方兴未艾"
	elif v < 72:
		return "国内寡头如日中天"
	return "国内寡头权倾朝野"


func _loan_limit(w: WorldState) -> int:
	var usa_rel := 0
	var ussr_rel := 0
	if w.empires.size() > 0:
		usa_rel = w.empires[0].relations
	if w.empires.size() > 1:
		ussr_rel = w.empires[1].relations
	@warning_ignore("integer_division")
	return (usa_rel + ussr_rel) / 5


## 整数（×10 存储单位）→ 定点字符串 "x.y"，对齐原版各 Repaint_* 的 num/10 "." num%10 显示。
func _fixed_point(v: int) -> String:
	@warning_ignore("integer_division")
	return "%d.%d" % [absi(v / 10), absi(v % 10)]
