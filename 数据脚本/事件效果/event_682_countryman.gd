extends "res://数据脚本/event_script_base.gd"

## 原作 Event682.cs：我实在是个乡下人……（乡土中国决策触发，六选项）。
## 触发：GlobalScript.cs:58 Decision「乡土中国」→ decision_catalog.gd d38（HasChosenInTheEvent(681,4)
##   + 非毛主义 + 党支持<800 + 预算>=200），d38.effects 里 A.start_event(682) 已就位。
## 差异：doctr[13] 显示文案表建模说明，跳过并留原文；结果后的 old_modify_desc[15] 整段为
##   display-only 文案（按 r681/r682/r53 + 科技 3/6/7 重建），按项目惯例跳过，仅留溯源。

const TXT_OPT0_DIS_A := "event.script.event_682_countryman.c0"
const TXT_OPT0_DIS_B := "event.script.event_682_countryman.c1"
const TXT_OPT1_DIS_A := "event.script.event_682_countryman.c2"
const TXT_OPT1_DIS_B := "event.script.event_682_countryman.c3"
const TXT_OPT2_DIS_A := "event.script.event_682_countryman.c4"
const TXT_OPT2_DIS_B := "event.script.event_682_countryman.c5"
const TXT_OPT4_DIS := "event.script.event_682_countryman.c6"
const TXT_OPT5_DIS_A := "event.script.event_682_countryman.c7"
const TXT_OPT5_DIS_B := "event.script.event_682_countryman.c8"
const TXT_R0_FMT := "event.script.event_682_countryman.c9"
const TXT_R1_FMT := "event.script.event_682_countryman.c10"
const TXT_R2_FMT := "event.script.event_682_countryman.c11"
const TXT_R3_FMT := "event.script.event_682_countryman.c12"
const TXT_R4_FMT := "event.script.event_682_countryman.c13"
const TXT_R5_FMT := "event.script.event_682_countryman.c14"
# 原版结果尾部 old_modify_desc[15] 重建（display-only，本版 ModifierCatalog 静态维护，跳过运行时拼接）：
#   基础文案「根据农业发展情况获得效果」+ 按 r681（0-4）或 r682（0-5）选段
#   + 按 r53（0-3）选段 + 科技 3/6/7 的机械化/化肥/转基因段。详见 Event682.cs 尾部 if/else 链。


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 6:
		return
	var china := ws.get_country_by_legacy_index(1)
	var line := _res(W.I_POLITICAL_LINE)
	var econ := _res(W.I_ECON_SYSTEM)
	var usa_rel := ws.empires[EmpireData.USA].relations if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	var opt := event_def.options
	if _mod_active(GameConstants.Modifier.CONFUCIAN_VICTORY) and line > 2:
		_enable(opt[0], event_def.options[0].text)
	elif line <= 2:
		_disable(opt[0], tr(TXT_OPT0_DIS_A))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_B))
	if line == 4 and usa_rel > 600 and econ > 11:
		_enable(opt[1], event_def.options[1].text)
	elif line < 4:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	if line > 0 and (econ == 12 or econ == 13):
		_enable(opt[2], event_def.options[2].text)
	elif line == 0:
		_disable(opt[2], tr(TXT_OPT2_DIS_A))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_B))
	_enable(opt[3], event_def.options[3].text)
	if ws.is_socialism(china, true) and line <= 2:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))
	if econ >= 14 and line == 4 and (ws.is_authoritarian(china) or (china != null and china.government == GameConstants.Government.LIBERAL)):
		_enable(opt[5], event_def.options[5].text)
	elif econ < 14:
		_disable(opt[5], tr(TXT_OPT5_DIS_A))
	else:
		_disable(opt[5], tr(TXT_OPT5_DIS_B))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader := _leader_name()
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0_FMT).replace("{0}{1}", leader)
			_add(W.I_BUDGET, -150)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_THOUGHT_FREEDOM, -100)
			if _res(W.I_RELIGION) < 28:
				_set_data(W.I_RELIGION, 28)
		1:
			context["result_text"] = tr(TXT_R1_FMT).replace("{0}{1}", leader)
			_add(W.I_BUDGET, -150)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add_relation(EmpireData.USA, 250)
			_add_relation(EmpireData.USSR, -150)
			_add_power(EmpireData.USA, 30)
			ws.influence_prc -= 10
			if _res(W.I_ECON_SYSTEM) < 15:
				_add(W.I_ECON_SYSTEM, 1)
			else:
				_add(W.I_THOUGHT_FREEDOM, 50)
			_set_data(W.I_RELIGION, 29)
		2:
			context["result_text"] = tr(TXT_R2_FMT).replace("{0}{1}", leader)
			_add(W.I_BUDGET, -200)
			_add(W.I_PARTY_SUPPORT, 40)
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_AGRICULTURE, 50)
			_add(W.I_SERVICES, 20)
			_set_data(W.I_RELIGION, 24)
		3:
			context["result_text"] = tr(TXT_R3_FMT).replace("{0}{1}", leader)
			_add(W.I_BUDGET, -100)
			_add(W.I_PARTY_SUPPORT, 10)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 80)
			_set_data(W.I_ECON_SYSTEM, 13)
			# 原版 doctr[13] = "新乔治主义社会"：显示文案表建模说明，跳过。
		4:
			context["result_text"] = tr(TXT_R4_FMT).replace("{0}{1}", leader)
			_add(W.I_BUDGET, -200)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, -100)
			_add(W.I_AGRICULTURE, 50)
		5:
			context["result_text"] = tr(TXT_R5_FMT).replace("{0}{1}", leader)
			_add(W.I_BUDGET, -100)
			_add(W.I_PARTY_SUPPORT, 20)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add(W.I_AGRICULTURE, 50)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, 150)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## 原版 {0}{1} = names1/names2 → Godot name_display。
func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_682_countryman.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_682",
	"num": 682,
	"priority": 68200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_682_countryman.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
