extends "res://数据脚本/event_script_base.gd"

## 原作 Event595.cs：国土与自由（肯尼亚左翼政变，两选项）。
## 触发：TimeScript.cs:10922-10926 —— 日期>=1982.7.15。
## 差异：
##  - 描述由 prepare 按 c42.parts[1/2]、event_594 结果、c119.cw 动态拼接；
##  - c119.parts[1]=true（写前 resize）；TickTime(24) → fortnight_max=24；
##  - SovietSupportDefender.AmericanSupportAttacker → ussr_side = GameConstants.WarSide.SIDE2/usa_side = GameConstants.WarSide.SIDE1。

const TXT_DESC_A := "event.script.event_595_land_and_freedom.c0"
const TXT_DESC_FAIL := "event.script.event_595_land_and_freedom.c1"
const TXT_DESC_WIN := "event.script.event_595_land_and_freedom.c2"
const TXT_DESC_C := "event.script.event_595_land_and_freedom.c3"
const TXT_DESC_SUPP := "event.script.event_595_land_and_freedom.c4"
const TXT_DESC_E := "event.script.event_595_land_and_freedom.c5"

const TXT_OPT0_DIS := "event.script.event_595_land_and_freedom.c6"

const TXT_R0 := "event.script.event_595_land_and_freedom.c7"
const TXT_R1 := "event.script.event_595_land_and_freedom.c8"

const WAR51_NAME := "event.script.event_595_land_and_freedom.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.description = _make_desc(world)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var kenya := world.get_country_by_legacy_index(119)
	if line < 2 and kenya != null and kenya.内战中:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], tr(TXT_OPT0_DIS))
	_enable(event_def.options[1], event_def.options[1].text)


func _make_desc(world: WorldState) -> String:
	var somalia := world.get_country_by_legacy_index(42)
	var kenya := world.get_country_by_legacy_index(119)
	var text := tr(TXT_DESC_A)
	var somalia_fail := _part(somalia, 1) or _part(somalia, 2)
	if somalia_fail:
		text += tr(TXT_DESC_FAIL)
	elif int(world.completed_event_ids.get("event_594", 0)) != 2 and not somalia_fail:
		text += tr(TXT_DESC_WIN)
	text += tr(TXT_DESC_C)
	if kenya == null or not kenya.内战中:
		text += tr(TXT_DESC_SUPP)
	text += tr(TXT_DESC_E)
	return text


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var kenya := ws.get_country_by_legacy_index(119)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			game.start_war(51, "肯尼亚军队", "人民救赎委员会", 750, 250, 0, 1)
			if ws.wars.size() > 51 and ws.wars[51] != null:
				ws.wars[51].name_war = tr(WAR51_NAME)
				ws.wars[51].fortnight_max = 24
			if kenya != null:
				while kenya.parts.size() <= 1:
					kenya.parts.append(false)
				kenya.parts[1] = true
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -80)
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)


func _part(c: CountryData, idx: int) -> bool:
	if c == null:
		return false
	while c.parts.size() <= idx:
		c.parts.append(false)
	return c.parts[idx]






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_595_land_and_freedom.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_595",
	"num": 595,
	"priority": 59500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_595_land_and_freedom.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1982.7.15"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
