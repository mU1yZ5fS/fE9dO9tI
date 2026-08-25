extends "res://数据脚本/event_script_base.gd"

## 原作 Event381.cs：从里斯本到符拉迪沃斯托克/从波恩到符拉迪沃斯托克（一选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 标题按 c87.isNATO 动态改写；c7/c17 政体与 c17.parts[0] 逐项移植；
##  - 原版 iron_and_blood 成就 Set(132) 已接 Achievements。

const TXT_TITLE_NATO := "event.script.event_381_yakovlev_brussels.c0"
const TXT_TITLE_OTHER := "event.script.event_381_yakovlev_brussels.c1"
const TXT_R0 := "event.script.event_381_yakovlev_brussels.c2"
const TXT_NAME_GERMANY := "event.script.event_381_yakovlev_brussels.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var portugal := world.get_country_by_legacy_index(87)
	if portugal != null and portugal.has_tag("nato"):
		event_def.title = tr(TXT_TITLE_NATO)
	else:
		event_def.title = tr(TXT_TITLE_OTHER)
	if event_def.options.size() >= 1:
		_enable(event_def.options[0], event_def.options[0].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var portugal := ws.get_country_by_legacy_index(87)
	if portugal != null and portugal.has_tag("nato"):
		context["result_title"] = tr(TXT_TITLE_NATO)
	else:
		context["result_title"] = tr(TXT_TITLE_OTHER)
	context["result_text"] = tr(TXT_R0)
	for c in ws.countries:
		if c != null and c.has_tag("sev"):
			c.set_tag("sev", false)
			c.set_tag("eu", true)
	var ussr := ws.get_country_by_legacy_index(7)
	if ussr != null:
		ussr.government = GameConstants.Government.REFORMIST
		ussr.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
	# 原作 Event381.cs:56：iron_and_blood → achievements.Set(132)
	Achievements.set_achievement(132)
	var germany := ws.get_country_by_legacy_index(17)
	if germany != null:
		if germany.parts.size() < 1:
			germany.parts.resize(1)
		germany.parts[0] = true
		germany.name = tr(TXT_NAME_GERMANY)
		germany.chinese_name = tr(TXT_NAME_GERMANY)
		germany.set_tag("亲美", false)
		germany.government = GameConstants.Government.REFORMIST
		germany.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_381_yakovlev_brussels.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_381",
	"num": 381,
	"priority": 38100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_381_yakovlev_brussels.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
