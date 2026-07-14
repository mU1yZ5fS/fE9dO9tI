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


func _on_budget_adjust(idx: int, delta: int) -> void:
	if GameManager.adjust_budget(idx, delta):
		_refresh()
		音频总管.play_button_click_sound()


func _on_loan_adjust(delta: int) -> void:
	if GameManager.adjust_loan(delta):
		_refresh()
		音频总管.play_button_click_sound()


func _on_reserve_adjust(delta: int) -> void:
	if GameManager.adjust_reserve(delta):
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
	var debt_loss := float(w.数值表[W.I_LOAN]) / 40.0
	var year := w.date.year if w.date else 1976
	if year >= 1980:
		debt_loss += 1.0
	if year >= 1983:
		debt_loss += 2.0
	_label("债务损耗", "债务损耗：\n预算-%.1f" % debt_loss)
	_label("债务限额", "债务限额：\n%.1f" % (float(_loan_limit(w)) / 10.0))
	var corruption := w.数值表[W.I_CORRUPTION]
	_label("贪腐损耗", "贪腐损耗:\n预算-%.1f\n生活水平-%.1f" % [float(corruption) / 10.0, float(corruption) / 50.0])
	var planka := GameManager.calc_budget_planka()
	_label("最大投资", "每类上限：\n%.1f" % (float(planka) / 6.0 / 10.0))
	_label("储蓄金影响", "储蓄金影响：\n工业,服务,生活水平\n腐败随储备增加")
	var oligarch := w.数值表[W.I_OLIGARCH]
	_label("寡头状态文本", "国内寡头无立锥之地\n其影响力为:%d/100" % oligarch if oligarch < 10 else "寡头势力渗透经济\n其影响力为:%d/100" % oligarch)


func _loan_limit(w: WorldState) -> int:
	var usa_rel := 0
	var ussr_rel := 0
	if w.empires.size() > 0:
		usa_rel = w.empires[0].relations
	if w.empires.size() > 1:
		ussr_rel = w.empires[1].relations
	@warning_ignore("integer_division")
	return (usa_rel + ussr_rel) / 5
