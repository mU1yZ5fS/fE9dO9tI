extends "res://数据脚本/event_script_base.gd"

## 原作 Event588.cs：欧加登战火重燃（索马里-埃塞俄比亚边境冲突，三选项）。 ## 触发：TimeScript.cs:10901-10906 —— ##   日期>=1982.6.1 && c42.SubGosstroy==10 ##   && ((!c42.亲苏 && c41.亲苏) (!c42.亲苏 && c41.亲中) (c42.亲苏 && c41.亲中))。 ## 差异： ##  - 原版 !c42.parts[0] && !c42.parts[2] 由 CountryData.parts 建模； ##  - Attacker/Defender 用 new_events_text[794]/[795] = 索马里/埃塞俄比亚； ##  - SovietSupportAttacker/Defender → ussr_side 0/1，美国不介入 → usa_side = GameConstants.WarSide.NONE； ##  - TickTime(16/4) → fortnight_max=16/4。



const TXT_R0 := "event.script.event_588_ogaden_war_rekindled.c0"
const TXT_R1 := "event.script.event_588_ogaden_war_rekindled.c1"
const TXT_R2 := "event.script.event_588_ogaden_war_rekindled.c2"

const WAR15_NAME := "event.script.event_588_ogaden_war_rekindled.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)
	_enable(event_def.options[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var somalia := ws.get_country_by_legacy_index(42)
	var num := 100 if int(ws.completed_event_ids.get("event_587", 0)) == 2 else 0
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_ARMY, -100)
			_start_war_15(somalia, num, 500, 500, 16)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_ARMY, -100)
			_start_war_15(somalia, num, 300, 700, 16)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_ARMY, -50)
			# 原版 TickTime(4)，但 TimeScript.WorldWarsDone 对 war15 另有 fortnight_go>=16 门槛， # 有效超时 = max(4,16)=16。 _start_war_15(somalia, num, 400, 600, 16) context["result_text"] = tr(TXT_R2)


func _start_war_15(somalia: CountryData, num: int, infl1: int, infl2: int, tick: int) -> void:
	var ussr_side := 0 if somalia != null and somalia.has_tag("亲苏") else 1
	game.start_war(15, "索马里", "埃塞俄比亚", infl1 + num, infl2 - num, -1, ussr_side)
	if ws.wars.size() > 15 and ws.wars[15] != null:
		ws.wars[15].name_war = tr(WAR15_NAME)
		ws.wars[15].fortnight_max = tick






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_588_ogaden_war_rekindled.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_588",
	"num": 588,
	"priority": 58800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_588_ogaden_war_rekindled.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1982.6.1"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "42"}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "42"}]}, {"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "41"}]}, {"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "42"}]}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "41"}]}, {"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "42"}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "41"}]}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
