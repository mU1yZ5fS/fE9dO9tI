extends GameUIBase

## 派系界面逻辑。
## 左栏: 6 大政策类别 + 5 个派系支持/禁止
## 中栏: 政体 + 路线 + 饼图 + 生育政策
## 右栏: 政策选项面板 + 条件说明 + 政策介绍

const W = preload("res://数据脚本/world_state.gd")

const 派系颜色 := [
	Color(0.72, 0.0, 0.0),
	Color(0.60, 0.0, 0.72),
	Color(1.0, 0.46, 0.75),
	Color(0.0, 0.54, 0.10),
	Color(0.28, 0.56, 0.89),
	Color(0.55, 0.55, 0.55),
]

const 派系列表 := ["极左派", "保守派", "温和派", "改革派", "自由派"]
const 政体名 := {0: "威权体制", 1: "社会主义", 2: "改良主义", 3: "自由民主"}
const 路线名 := {0: "毛主义路线", 1: "保守路线", 2: "温和路线", 3: "改革路线", 4: "自由路线"}

# num=this_number（原版 Doctrine_script 分支键）；slots=.tscn 面板内按钮节点名（场景顺序，
# 作定位槽用，文案由 _build_options 运行时覆盖）；descriptions 按 id（=data 值）索引。
const 政策类别 := {
	"经济类型": {
		"idx": W.I_ECON_SYSTEM, "num": 16, "panel": "右栏经济类型",
		"slots": ["中央计划经济", "中式计划经济", "国家资本主义", "国控资本主义", "市场经济", "自由市场"],
		"descriptions": {
			10: "苏联式中央计划经济。国家完全控制生产与分配。\n工业+2 农业-1 思想自由-2",
			11: "带有中国特色的计划经济。允许有限的地方自主权。\n工业+1 农业+1",
			12: "国家主导的资本主义体制。国企掌控命脉产业。\n工业+2 预算+1 腐败+1",
			13: "国家监管下的资本运行。鸟笼经济思想。\n工业+1 预算+1 生活水平+1",
			14: "混合所有制经济。市场与计划并存。\n生活水平+2 工业+1 腐败+1",
			15: "最小政府干预。完全自由化的市场经济。\n生活水平+3 腐败+2 党内支持-2",
		},
	},
	"党政": {
		"idx": W.I_PARTY_SYSTEM, "num": 15, "panel": "右栏党政",
		"slots": ["无产阶级专政", "人民民主专政", "联合政府", "西式民主"],
		"descriptions": {
			6: "无产阶级专政。党的绝对领导。\n党内支持+2 思想自由-2",
			7: "人民民主专政。统一战线框架下的多党合作。\n党内支持+1 民众支持+1",
			8: "联合政府。多党制下的有限民主。\n民众支持+2 思想自由+1 党内支持-1",
			9: "西式多党民主。自由选举与权力交替。\n民众支持+3 思想自由+2 党内支持-3",
		},
	},
	"人权": {
		"idx": W.I_PRESS_POLICY, "num": 17, "panel": "右栏人权",
		"slots": ["舆论一律", "纪律约束", "自然限制", "多元自由"],
		"descriptions": {
			16: "严格的新闻与舆论管控。所有媒体服从党的指挥。\n党内支持+1 思想自由-3 特工网络+1",
			17: "党纪约束。维持基本纪律但允许内部讨论。\n党内支持+1 思想自由-1",
			18: "自然过渡。逐步放宽管制。\n思想自由+1 民众支持+1",
			19: "多元自由。允许不同声音。\n思想自由+3 民众支持+2 党内支持-2",
		},
	},
	"国家体制": {
		"idx": W.I_TERRITORY, "num": 18, "panel": "右栏国家体制",
		"slots": ["单一制", "区域自治", "联邦制", "邦联制"],
		"descriptions": {
			20: "中央集权的单一制国家。地方服从中央。\n党内支持+1 民众支持-1",
			21: "联邦制。各省拥有较大自主权。\n民众支持+1 国际声望+1",
			22: "松散邦联。各组成单位高度独立。\n民众支持+2 党内支持-1",
			23: "民族区域高度自治联盟。\n民众支持+2 党内支持-3 军力-1",
		},
	},
	"传统与宗教": {
		"idx": W.I_RELIGION, "num": 50, "panel": "右栏传统与宗教",
		"slots": ["文化革命", "国家无神论", "宗教管制", "世俗化", "尊崇传统", "政教协定"],
		"descriptions": {
			24: "打击传统主义。消灭一切旧文化。\n党内支持+1 民众支持-3 思想自由-3",
			25: "支持无神论。宗教活动受到严格限制。\n党内支持+1 思想自由-1",
			26: "宗教监管。允许宗教存在但受国家监管。\n民众支持+1",
			27: "世俗国家。政教分离。\n思想自由+1 民众支持+1",
			28: "依赖传统。恢复儒学等传统文化。\n民众支持+2 国际声望+1",
			29: "政教协议。与宗教团体达成合作。\n民众支持+2 思想自由+1 党内支持-1",
		},
	},
	"军事力量": {
		"idx": W.I_MIL_DOCTRINE, "num": 51, "panel": "右栏军事力量",
		"slots": ["全民皆兵", "积极建军", "国防建设", "职业化军队"],
		"descriptions": {
			30: "全面军事化。最大化动员人口。\n兵力最多 预算消耗高",
			31: "建设军力。扩大常备军规模。\n兵力较多 预算消耗中",
			32: "防御军。以守为主。\n兵力适中 预算消耗低",
			33: "合同制军队。职业化精兵路线。\n兵力较少 战斗力高",
		},
	},
}

# ── 当前政策名标签（doctr 名表）──
# 原版 Politic_doctr_script 读 doctr[data[idx]]；doctr[42] 基础名来自 Assets/Resources/Doctr_en.txt
# （LoadInScript.cs:64-79），再由 modifies[6].active 覆盖部分项（GameStartScript.cs:1645-1673）。
# 开局 modifies[6] 激活 → 经济11=中式计划经济、党政6=无产阶级专政、宗教24=文化革命…
const DOCTR_BASE := {
	0: "威权主义", 1: "保守社会主义", 2: "民族特色社会主义", 3: "邓式实用主义", 4: "社会民主主义", 5: "自由主义",
	6: "一党制共和国", 7: "新民主主义制度", 8: "管制民主制", 9: "西方范式民主国家",
	10: "中央计划经济", 11: "分权计划经济", 12: "国家垄断资本主义", 13: "鸟笼经济", 14: "\"社会\"市场经济", 15: "最小干预",
	16: "舆论一律", 17: "纪律约束", 18: "自然限制", 19: "多元自由",
	20: "单一制", 21: "联邦制", 22: "联省自治", 23: "自治联盟",
	24: "破除传统", 25: "无神论化", 26: "宗教管制", 27: "世俗主义", 28: "尊崇传统", 29: "政教协定",
	30: "全民皆兵", 31: "积极建军", 32: "建设国防", 33: "合同兵制",
	34: "社会主义", 35: "改良主义", 36: "实用主义", 37: "市场", 38: "威权", 39: "强硬", 40: "柔和", 41: "民主",
}
# modifies[6].active 时覆盖（GameStartScript.cs:1647-1657）
const DOCTR_MOD6 := {
	6: "无产阶级专政", 8: "人民民主制度", 9: "协和民主体制", 10: "经典计划经济", 11: "中式计划经济",
	13: "国家监护资本主义", 14: "社会主义导向市场", 15: "左翼小政府", 21: "改良区域自治制度", 22: "联邦制", 24: "文化革命",
}

const DEDUCT_BUDGET := 50
const DEDUCT_LIVING := 50
const DEDUCT_PARTY := 30


# ── 状态位读取（映射 WorldState；数字事件未移植 → 恒默认）──
func _mod_active(w: WorldState, n: int) -> bool:
	return w != null and w.modifiers.size() > n and w.modifiers[n] != null and w.modifiers[n].is_active

func _dec_done(w: WorldState, n: int) -> bool:
	return w != null and w.decisions != null and w.decisions.completed.size() > n and w.decisions.completed[n]

# 数字键事件（444/502/503/550/551/682…）在本移植中未接入（completed_event_ids 用字符串键）
# → resultOfEvents 恒 -1、event_done 恒 false，与原版 GameStartScript.cs:48-51 初始态一致。
func _evt_result(w: WorldState, n: int) -> int:
	return w.completed_event_ids.get(n, -1) if w != null else -1

func _evt_done(w: WorldState, n: int) -> bool:
	return w != null and w.completed_event_ids.has(n)


## 当前政策值 id → 显示名（doctr[id]，modifies[6] 覆盖）。原版 doctr[data[idx]]。
func doctr_name(w: WorldState, id: int) -> String:
	if _mod_active(w, 6) and DOCTR_MOD6.has(id):
		return DOCTR_MOD6[id]
	return DOCTR_BASE.get(id, "未知")


## 忠实移植 Doctrine_script.cs OnMouseDown()：按 this_number 与真实状态位生成有序选项 [{id,text}]。
## 数字事件（444/503/550/551/682）未移植 → _evt_* 恒 -1/false，与原版开局初始态一致。
## 开局态 modifies[6]=true、completedDecisions/其余 modifies 全 false → 各类满编选项。
func _build_options(w: WorldState, num: int) -> Array[Dictionary]:
	var o: Array[Dictionary] = []
	match num:
		16:  # 经济
			if _mod_active(w, 11):
				o.append({"id": 10, "text": "国家信息自动化系统"})
				o.append({"id": 11, "text": "赛博协同控制工程"})
			elif _dec_done(w, 18):
				o.append({"id": 12, "text": "国家垄断资本主义"})
			elif _evt_result(w, 503) == 0:
				o.append({"id": 10, "text": "中央计划经济"})
			elif _evt_result(w, 682) == 3:
				o.append({"id": 13, "text": "新乔治主义社会"})
			elif _mod_active(w, 6):
				o.append({"id": 10, "text": "经典计划经济"})
				o.append({"id": 11, "text": "中式计划经济"})
				o.append({"id": 12, "text": "国家资本主义"})
				o.append({"id": 13, "text": "国家监护资本主义"})
				if not _dec_done(w, 13):
					o.append({"id": 14, "text": "社会主义导向市场"})
					o.append({"id": 15, "text": "左翼小政府"})
			else:
				o.append({"id": 10, "text": "中央计划经济"})
				o.append({"id": 11, "text": "分权计划经济"})
				o.append({"id": 12, "text": "国家资本主义"})
				o.append({"id": 13, "text": "鸟笼经济"})
				if not _dec_done(w, 13):
					o.append({"id": 14, "text": "混合经济"})
					o.append({"id": 15, "text": "最小干预"})
		15:  # 党政
			if _evt_done(w, 444) and _evt_result(w, 444) == 0:
				o.append({"id": 6, "text": "无产阶级专政"})
			elif _evt_result(w, 503) == 0:
				o.append({"id": 6, "text": "一党专政"})
			elif _dec_done(w, 18):
				o.append({"id": 7, "text": "新民主主义制度" if _mod_active(w, 6) else "一党独大式民主"})
			elif _mod_active(w, 6):
				o.append({"id": 6, "text": "无产阶级专政"})
				o.append({"id": 7, "text": "新民主主义制度"})
				if not _dec_done(w, 13) and not _mod_active(w, 24) and not _dec_done(w, 16):
					o.append({"id": 8, "text": "人民民主制度"})
					o.append({"id": 9, "text": "协和民主体制"})
			else:
				o.append({"id": 6, "text": "一党专政党内民主"})
				o.append({"id": 7, "text": "一党独大式民主"})
				if not _dec_done(w, 13) and not _mod_active(w, 24) and not _dec_done(w, 16):
					o.append({"id": 8, "text": "宪政民主制度"})
					o.append({"id": 9, "text": "协和民主体制"})
		17:  # 人权
			if _evt_done(w, 444) and _evt_result(w, 444) == 0:
				o.append({"id": 19, "text": "自由境界"})
			else:
				o.append({"id": 16, "text": "舆论一律"})
				if not _mod_active(w, 26) and _evt_result(w, 503) != 0:
					o.append({"id": 17, "text": "纪律约束"})
					o.append({"id": 18, "text": "自然限制"})
					o.append({"id": 19, "text": "多元自由"})
		18:  # 国家体制
			if _evt_done(w, 551) and _evt_result(w, 551) == 3:
				o.append({"id": 21, "text": _territory21_text(w)})
				o.append({"id": 22, "text": "联邦制" if _mod_active(w, 6) else "联省自治"})
				o.append({"id": 23, "text": "自治联盟"})
			elif _evt_done(w, 550) and _evt_result(w, 550) == 2:
				o.append({"id": 21, "text": "中国特色联邦制"})
			elif _evt_done(w, 550) and _evt_result(w, 550) == 3:
				o.append({"id": 20, "text": "单一制"})
			else:
				o.append({"id": 20, "text": "单一制"})
				o.append({"id": 21, "text": _territory21_text(w)})
				o.append({"id": 22, "text": "联邦制" if _mod_active(w, 6) else "联省自治"})
				o.append({"id": 23, "text": "自治联盟"})
		50:  # 传统与宗教
			if _evt_done(w, 444) and _evt_result(w, 444) == 0:
				o.append({"id": 24, "text": "文化革命"})
			elif _evt_result(w, 503) == 0 or _evt_result(w, 682) == 1:
				o.append({"id": 29, "text": "政教协定"})
			elif not _mod_active(w, 25) and not _dec_done(w, 16):
				o.append({"id": 24, "text": "文化革命" if _mod_active(w, 6) else "破除传统"})
				o.append({"id": 25, "text": "无神国家"})
				o.append({"id": 26, "text": "民宗管制"})
				o.append({"id": 27, "text": "世俗主义"})
				o.append({"id": 28, "text": "尊崇传统"})
				o.append({"id": 29, "text": "政教协定"})
			else:
				o.append({"id": 28, "text": "尊崇传统"})
				o.append({"id": 29, "text": "政教协定"})
		51:  # 军事（固定）
			o.append({"id": 30, "text": "全民皆兵"})
			o.append({"id": 31, "text": "积极建军"})
			o.append({"id": 32, "text": "建设国防"})
			o.append({"id": 33, "text": "合同兵制"})
	return o


## 国家体制 id21 文案：随 resultOfEvents[550]（原版 :233-244/198-208，均以 modifies[6] 分改良/联邦）。
func _territory21_text(w: WorldState) -> String:
	var r := _evt_result(w, 550)
	if r == 0:
		return "美国模式联邦制"
	elif r == 1:
		return "苏联模式联邦制"
	return "改良区域自治制度" if _mod_active(w, 6) else "联邦制"


const 生育政策名 := ["一胎制", "二胎制", "无限制"]

var _当前类别: String = ""


func _ready() -> void:
	if not GameManager:
		return
	GameManager.world_state_loaded.connect(_refresh)
	GameManager.date_changed.connect(func(_d): _refresh())
	_ensure_pie_chart()
	for cat_name in 政策类别:
		var btn := _find(cat_name + "切换")
		if btn is Button:
			btn.pressed.connect(_on_policy_tab.bind(cat_name))
	# 选项按钮按 slot 位置接线（id/文案运行时由 _build_options 决定，点击/悬停时按位置解析）
	for cat_name in 政策类别:
		var slots: Array = 政策类别[cat_name]["slots"]
		for slot_idx in slots.size():
			var btn := _find(slots[slot_idx])
			if btn is Button:
				btn.pressed.connect(_on_policy_slot.bind(cat_name, slot_idx))
				btn.mouse_entered.connect(_on_policy_slot_hover.bind(cat_name, slot_idx))
	for i in 派系列表.size():
		var sup := _find("支持" + 派系列表[i])
		var ban := _find("禁止" + 派系列表[i])
		if sup is TextureButton:
			sup.toggled.connect(_on_faction_support.bind(i, true))
		if ban is TextureButton:
			ban.toggled.connect(_on_faction_support.bind(i, false))
	for policy_name in 生育政策名:
		var btn := _find(policy_name)
		if btn is Button:
			btn.pressed.connect(_on_birth_policy.bind(生育政策名.find(policy_name)))
	var expand_btn := _find("右栏政策介绍展开")
	var collapse_btn := _find("右栏政策介绍收回")
	if expand_btn is TextureButton:
		expand_btn.pressed.connect(func(): _set_visible("右栏政策介绍", true))
	if collapse_btn is TextureButton:
		collapse_btn.pressed.connect(func(): _set_visible("右栏政策介绍", false))
	if GameManager.world != null:
		_refresh()


func _refresh() -> void:
	var w := GameManager.world
	if w == null:
		return
	_label("军队力量", "%d" % w.数值表[W.I_ARMY])
	var pc := w.get_player_country()
	_label("政体类型", 政体名.get(pc.government, "未知") if pc else "")
	_label("政治路线类型", 路线名.get(w.数值表[W.I_POLITICAL_LINE], "未知"))
	# 满足现状者（I_SATISFIED）仅出现在饼图灰色扇区，不进左侧可互动派系列表
	for cat_name in 政策类别:
		var cat: Dictionary = 政策类别[cat_name]
		var current_val: int = _raw(w, int(cat["idx"]))
		_label(cat_name + "显示", doctr_name(w, current_val))
	for i in mini(派系列表.size(), w.factions.size()):
		var f: FactionData = w.factions[i]
		var sup := _find("支持" + 派系列表[i]) as TextureButton
		var ban := _find("禁止" + 派系列表[i]) as TextureButton
		if sup: sup.set_pressed_no_signal(f.is_ally)
		if ban: ban.set_pressed_no_signal(not f.is_enabled)
		if sup:
			sup.tooltip_text = "%s 支持度 %d｜点击结盟/取消（仅未禁止派系可结盟）" % [
				派系列表[i], f.support
			]
	var birth_val: int = _raw(w, W.I_BIRTH_POLICY)
	for i in 生育政策名.size():
		var btn := _find(生育政策名[i]) as Button
		if btn: btn.set_pressed_no_signal(i == birth_val)
	var pie := _find("派系饼图") as Control
	if pie:
		for child in pie.get_children():
			if child is Control:
				child.queue_redraw()
		pie.queue_redraw()
	if _当前类别 != "":
		_refresh_policy_panel(_当前类别)


# ── 饼图（使用 _draw 避免每帧重建节点） ──

## 场景中的「派系饼图」是空 Control，需挂上可绘制的 PieChart 子节点
func _ensure_pie_chart() -> void:
	var host := _find("派系饼图") as Control
	if host == null:
		return
	for child in host.get_children():
		if child is PieChart:
			return
	var chart := PieChart.new()
	chart.name = "Chart"
	chart.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(chart)


class PieChart extends Control:
	func _draw() -> void:
		var w: WorldState = GameManager.world if GameManager else null
		if w == null:
			return
		var slices: Array[Dictionary] = []
		var 派系颜色_ref := [
			Color(0.72, 0.0, 0.0), Color(0.60, 0.0, 0.72),
			Color(1.0, 0.46, 0.75), Color(0.0, 0.54, 0.10),
			Color(0.28, 0.56, 0.89), Color(0.55, 0.55, 0.55),
		]
		for i in mini(5, w.factions.size()):
			var f: FactionData = w.factions[i]
			if not f.is_enabled:
				continue
			var s: int = maxi(f.support, 0)
			if s > 0:
				slices.append({"value": s, "color": 派系颜色_ref[i]})
		var satisfied: int = 0
		if w.数值表.size() > WorldState.I_SATISFIED:
			satisfied = maxi(w.数值表[WorldState.I_SATISFIED], 0)
		if satisfied > 0:
			slices.append({"value": satisfied, "color": 派系颜色_ref[5]})
		var total := 0
		for s in slices:
			total += s.value
		if total <= 0:
			return
		var center := size / 2.0
		var radius := minf(center.x, center.y) * 0.92
		if radius <= 1.0:
			return
		var start_angle := -PI / 2.0
		for s in slices:
			var sweep := float(s.value) / float(total) * TAU
			var pts := PackedVector2Array()
			pts.append(center)
			for seg in 33:
				var angle := start_angle + sweep * float(seg) / 32.0
				pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
			draw_colored_polygon(pts, s.color)
			start_angle += sweep


# ── 政策面板 ──

func _on_policy_tab(cat_name: String) -> void:
	var toggling_off := (_当前类别 == cat_name)
	_当前类别 = "" if toggling_off else cat_name
	for cn in 政策类别:
		var pn: String = 政策类别[cn]["panel"]
		_set_visible(pn, cn == _当前类别)
	_set_visible("右栏条件显示", _当前类别 != "")
	if _当前类别 != "":
		_refresh_policy_panel(_当前类别)
	音频总管.play_button_click_sound()


func _refresh_policy_panel(cat_name: String) -> void:
	var w := GameManager.world
	if w == null:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	var current_val: int = _raw(w, cat_idx)
	var slots: Array = cat["slots"]
	# 运行时按状态位生成有序选项，填入位置槽；多余槽隐藏（对齐原版 num+1 个可见）
	var options := _build_options(w, int(cat["num"]))
	var first_other: int = -1
	for slot_idx in slots.size():
		var btn := _find(slots[slot_idx]) as Button
		if btn == null:
			continue
		if slot_idx >= options.size():
			btn.visible = false
			continue
		btn.visible = true
		var target_val: int = int(options[slot_idx]["id"])
		btn.text = String(options[slot_idx]["text"]).replace("\n", "")
		# 权威 4 条件检查在 GameManager，UI 只读结果（避免与实际切换判定漂移）
		var chk := GameManager.check_policy_change(cat_idx, target_val)
		var can_select: bool = chk["can"]
		btn.disabled = not can_select
		btn.modulate = Color.WHITE if can_select else Color(0.5, 0.5, 0.5)
		if target_val == current_val:
			btn.modulate = Color(1.0, 1.0, 0.6)
		elif first_other < 0:
			first_other = target_val
	# 常驻条件面板：默认对第一个非当前选项显示 4 条件（hover 具体选项时更新）
	if first_other >= 0:
		_label("右栏条件显示", _build_condition_text(cat_idx, first_other))


## slot 位置 → 当前该槽的政策 id（运行时由 _build_options 决定）。-1 = 槽为空。
func _slot_target(w: WorldState, cat_name: String, slot_idx: int) -> int:
	var options := _build_options(w, int(政策类别[cat_name]["num"]))
	if slot_idx < 0 or slot_idx >= options.size():
		return -1
	return int(options[slot_idx]["id"])


func _on_policy_slot(cat_name: String, slot_idx: int) -> void:
	var w := GameManager.world
	if w == null:
		return
	var target_val := _slot_target(w, cat_name, slot_idx)
	if target_val < 0:
		return
	if GameManager.change_policy(int(政策类别[cat_name]["idx"]), target_val):
		_refresh()
		音频总管.play_button_click_sound()


## 常驻 4 条件文案（原版 uslovie_text[0..3]，各带 [满足]/[未满足]）。
## 显示口径同原作：预算 |Δ|×5、党内团结 |Δ|×30（与判定阈值 ×50/×300 不同）。
func _build_condition_text(cat_idx: int, target_val: int) -> String:
	var w := GameManager.world
	if w == null:
		return ""
	var current_val: int = _raw(w, cat_idx)
	var diff := absi(target_val - current_val)
	if diff == 0:
		return "当前政策"
	var chk := GameManager.check_policy_change(cat_idx, target_val)
	var t := "预算中的资金：%d  [%s]\n\n\n" % [diff * 5, "满足" if chk["budget_ok"] else "未满足"]
	t += "党内团结度高于：%d  [%s]\n\n\n" % [diff * 30, "满足" if chk["party_ok"] else "未满足"]
	t += "%s  [%s]\n\n\n" % [chk["leading_text"], "满足" if chk["leading_ok"] else "未满足"]
	t += "%s  [%s]\n\n" % [_mao_cond_text(w, target_val), "满足" if chk["mao_ok"] else "未满足"]
	t += "切换消耗：预算-%.1f 生活-%.1f 党内-%.1f" % [
		float(diff * DEDUCT_BUDGET) / 10.0,
		float(diff * DEDUCT_LIVING) / 10.0,
		float(diff * DEDUCT_PARTY) / 10.0,
	]
	return t


## 第4条件文案（原版 Doctrine_button_script.cs:446-461）：
## modifies[6]激活且目标∈{9,14,15,22,23,28,29} 或 (19且res[444]≠0) → "毛主席正看着你！"；
## 否则毛已死(data[38]≥100)→"尚未建立"、毛在世→"毛主席已离世，起锚！"。
func _mao_cond_text(w: WorldState, target_val: int) -> String:
	if _mod_active(w, 6) and (target_val in [9, 14, 15, 22, 23, 28, 29] \
			or (target_val == 19 and _evt_result(w, 444) != 0)):
		return "毛主席正看着你！"
	if GameManager.is_mao_dead():
		return "尚未建立"
	return "毛主席已离世，起锚！"


func _on_policy_slot_hover(cat_name: String, slot_idx: int) -> void:
	var w := GameManager.world
	if w == null:
		return
	var target_val := _slot_target(w, cat_name, slot_idx)
	if target_val < 0:
		return
	var cat: Dictionary = 政策类别[cat_name]
	var cat_idx: int = int(cat["idx"])
	_label("右栏条件显示", _build_condition_text(cat_idx, target_val))
	var descs: Dictionary = cat.get("descriptions", {})
	_label("右栏政策介绍文案", descs.get(target_val, ""))


# ── 派系支持/禁止 ──

func _on_faction_support(button_pressed: bool, faction_idx: int, is_support: bool) -> void:
	if is_support:
		# 原版 Party_ally_script 一党制：点击=toggle is_ally，仅启用派系可结盟（无积分/无强化）
		var w := GameManager.world
		var enabled := false
		if w and faction_idx < w.factions.size() and w.factions[faction_idx]:
			enabled = w.factions[faction_idx].is_enabled
		GameManager.set_faction_ally(faction_idx, button_pressed and enabled)
	else:
		GameManager.set_faction_enabled(faction_idx, not button_pressed)
	_refresh()


# ── 生育政策 ──

func _on_birth_policy(policy_idx: int) -> void:
	GameManager.set_birth_policy(policy_idx)
	_refresh()
	音频总管.play_button_click_sound()
