extends "res://数据脚本/event_script_base.gd"

## 原作 Event670.cs：关心群众生活，注意工作方法（群众组织路线，三选项）。
## 触发：ReqEventsDLC02.cs:329-331 —— DATE_AFTER 1977.11.1。
## 差异：traits[1]==41 → trait_alignment == GameConstants.PoliticianAlignment.LOCAL_WARLORD；KillPerson → game.kill_politician；
##   结果尾 old_modify_desc[6] 由 ModifierCatalog._effect_maoist_bulwark 动态生成，
##   fortnight_simulator 同步实装 Event670/Event548 对 6 号修正的实际数值效果。

const TXT_DESC_PRE := "event.script.event_670_mass_work.c0"
const TXT_DESC_A := "event.script.event_670_mass_work.c1"
const TXT_DESC_B := "event.script.event_670_mass_work.c2"
const TXT_DESC_C := "event.script.event_670_mass_work.c3"
const TXT_OPT0_DIS_A := "event.script.event_670_mass_work.c4"
const TXT_OPT0_DIS_B := "event.script.event_670_mass_work.c5"
const TXT_OPT1_DIS := "event.script.event_670_mass_work.c6"
const TXT_OPT2_DIS := "event.script.event_670_mass_work.c7"
# 选项正常文案常量：不用 event_def.options[N].text 回填，
# 避免 prepare 多次调用时文本已被 _disable 覆盖成禁用词。
const TXT_OPT0 := "event.script.event_670_mass_work.c8"
const TXT_OPT1 := "event.script.event_670_mass_work.c9"
const TXT_OPT2 := "event.script.event_670_mass_work.c10"
const TXT_R0 := "event.script.event_670_mass_work.c11"
const TXT_R1 := "event.script.event_670_mass_work.c12"
const TXT_R2 := "event.script.event_670_mass_work.c13"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	# 原版读 resultOfEvents[25/26]，统一走 result_of_event_num，
	# 避免旧档/覆盖表中 completed_event_ids 缺失导致“条件满足却不触发选项”。
	var r25 := ws.result_of_event_num(25)
	var r26 := ws.result_of_event_num(26)
	var line := _res(W.I_POLITICAL_LINE)
	var mod3 := ws.modifiers.size() > 3 and ws.modifiers[3] != null and ws.modifiers[3].is_active
	var desc := tr(TXT_DESC_C)
	if (r25 == 2 or r26 == 2) and line == 0 and mod3:
		desc = tr(TXT_DESC_A).replace("{0}{1}", _leader_name())
	elif r25 == 2 or r26 == 2:
		desc = tr(TXT_DESC_B)
	event_def.description = tr(TXT_DESC_PRE) + desc
	var flag := line == 0 and mod3 and _res(W.I_PARTY_SUPPORT) >= 800 and r25 == 2 and r26 == 2
	var flag2 := line >= 0 and line < 2 and r25 == 2 and r26 == 2
	var opt := event_def.options
	if flag:
		_enable(opt[0], tr(TXT_OPT0))
	elif r25 != 2 or r26 != 2:
		_disable(opt[0], tr(TXT_OPT0_DIS_A))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_B))
	if flag2:
		_enable(opt[1], tr(TXT_OPT1))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 0 or (not flag and not flag2):
		_enable(opt[2], tr(TXT_OPT2))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			for i in ws.politicians.size():
				var p: PoliticianData = ws.politicians[i]
				if p != null and p.trait_alignment == GameConstants.PoliticianAlignment.LOCAL_WARLORD:
					game.kill_politician(i)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
		2:
			context["result_text"] = tr(TXT_R2).replace("{0}{1}", _leader_name())
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 150)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_670_mass_work.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_670",
	"nodesc": true,
	"num": 670,
	"priority": 67000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_670_mass_work.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.11.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
