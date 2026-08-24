extends "res://数据脚本/event_script_base.gd"

## 原作 Event656.cs：红色普罗米修斯（尼日利亚人民军战略反攻，一选项）。
## 触发：TimeScript.cs 11071-11077 —— event_done[655] && c60.prc_power>=100
##   && c60.government != GameConstants.Government.REFORMIST && IsSocialism(true) 计数>=5 && !c60.内战。
## 差异：
##  - 触发条件用 ExprNode（PREV_EVENT_DONE / COUNTRY_FIELD_AT_LEAST / COUNTRY_FIELD_NOT_EQUALS / SOCIALIST_COUNT_AT_LEAST / COUNTRY_FIELD_EQUALS）。
##  - War 79：AmericanSupportDefender.SovietSupportDefender → usa_side = GameConstants.WarSide.SIDE2 / ussr_side = GameConstants.WarSide.SIDE2；
##    无 TickTime → 原版 fortnight_max 默认 999，Godot 覆盖为 999。
##  - 死代码 result 5 测试分支跳过。


const TXT_R0 := "event.script.event_656_red_prometheus.c0"
const TXT_WAR_NAME := "event.script.event_656_red_prometheus.c1"
const TXT_WAR_ATTACKER := "event.script.event_656_red_prometheus.c2"
const TXT_WAR_DEFENDER := "event.script.event_656_red_prometheus.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.is_empty():
		return
	_enable(event_def.options[0], event_def.options[0].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	if nigeria != null:
		while nigeria.parts.size() <= 0:
			nigeria.parts.append(false)
		nigeria.parts[0] = true
		nigeria.set_tag("对华贸易", false)
	game.start_war(79, tr(TXT_WAR_ATTACKER), tr(TXT_WAR_DEFENDER), 400, 600, 1, 1)
	if ws.wars.size() > 79 and ws.wars[79] != null:
		ws.wars[79].name_war = tr(TXT_WAR_NAME)
		ws.wars[79].fortnight_max = 999
	context["result_text"] = tr(TXT_R0)





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_656_red_prometheus.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_656",
	"num": 656,
	"priority": 65600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_656_red_prometheus.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_655"}, {"t": "COUNTRY_FIELD_AT_LEAST", "key": "prc_power", "v": 100, "target": "60"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "v": 2, "target": "60"}, {"t": "SOCIALIST_COUNT_AT_LEAST", "v": 5, "keys": ["59", "112", "113", "114", "68", "107", "67", "64", "63", "62", "108", "61", "56", "58"]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "target": "60"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
