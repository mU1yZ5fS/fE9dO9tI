extends "res://数据脚本/event_script_base.gd"

## 原作 Event594.cs：加里萨大屠杀（event_594，三选项）。
## 触发：TimeScript.cs:10915-10918 —— 日期>=1980.11.1 && c42.SubGosstroy==10。
## 差异：
##  - 原版 SubGosstroy!=10 分支的空白禁用选项在 .tres 中保留空 text 的 _disable 实现；
##  - AmericanSupportDefender.SovietSupportAttacker → usa_side = GameConstants.WarSide.SIDE2/ussr_side = GameConstants.WarSide.SIDE1；
##  - 仅 AmericanSupportDefender → usa_side = GameConstants.WarSide.SIDE2/ussr_side = GameConstants.WarSide.NONE；
##  - TickTime(24) → fortnight_max=24。

const TXT_DESC_BASE := "event.script.event_594_garissa_massacre.c0"
const TXT_DESC_EXTRA := "event.script.event_594_garissa_massacre.c1"

const TXT_OPT0_DIS := "event.script.event_594_garissa_massacre.c2"
const TXT_OPT1_DIS := "event.script.event_594_garissa_massacre.c3"

const TXT_R0_A := "event.script.event_594_garissa_massacre.c4"
const TXT_R0_B := "event.script.event_594_garissa_massacre.c5"
const TXT_R0_C := "event.script.event_594_garissa_massacre.c6"
const TXT_R1_A := "event.script.event_594_garissa_massacre.c7"
const TXT_R1_B := "event.script.event_594_garissa_massacre.c8"
const TXT_R1_C := "event.script.event_594_garissa_massacre.c9"
const TXT_R1_D := "event.script.event_594_garissa_massacre.c10"
const TXT_R2 := "event.script.event_594_garissa_massacre.c11"

const WAR50_NAME := "event.script.event_594_garissa_massacre.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var somalia := world.get_country_by_legacy_index(42)
	var china := world.get_country_by_legacy_index(1)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var somalia_proprc := somalia != null and somalia.has_tag("亲中")
	var somalia_prosov := somalia != null and somalia.has_tag("亲苏")
	var china_sev := china != null and china.has_tag("sev")
	var opt := event_def.options
	if somalia != null and somalia.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		event_def.description = tr(TXT_DESC_BASE) + tr(TXT_DESC_EXTRA)
		if line <= 2 and (somalia_proprc or (somalia_prosov and china_sev)):
			_enable(opt[0], event_def.options[0].text)
		else:
			_disable(opt[0], tr(TXT_OPT0_DIS))
		if line >= 2 and (not somalia_proprc or (somalia_prosov and not china_sev)):
			_enable(opt[1], event_def.options[1].text)
		else:
			_disable(opt[1], tr(TXT_OPT1_DIS))
		_enable(opt[2], event_def.options[2].text)
	else:
		event_def.description = tr(TXT_DESC_BASE)
		_disable(opt[0], "")
		_disable(opt[1], "")
		_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var somalia := ws.get_country_by_legacy_index(42)
	var kenya := ws.get_country_by_legacy_index(119)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0_A)
			if somalia != null and somalia.has_tag("亲苏"):
				text += tr(TXT_R0_B)
			text += tr(TXT_R0_C)
			_start_war_50(somalia, 0)
			if kenya != null:
				while kenya.parts.size() <= 0:
					kenya.parts.append(false)
				kenya.parts[0] = true
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -80)
			context["result_text"] = text
		1:
			var text := tr(TXT_R1_A)
			if somalia != null and somalia.has_tag("亲苏"):
				text += tr(TXT_R1_B)
			elif somalia == null or not somalia.has_tag("亲中"):
				text += tr(TXT_R1_C)
			text += tr(TXT_R1_D)
			_start_war_50(somalia, 1)
			if kenya != null:
				while kenya.parts.size() <= 0:
					kenya.parts.append(false)
				kenya.parts[0] = true
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -80)
			context["result_text"] = text
		2:
			context["result_text"] = tr(TXT_R2)


func _start_war_50(somalia: CountryData, branch: int) -> void:
	var prosov := somalia != null and somalia.has_tag("亲苏")
	if branch == 0:
		if prosov:
			game.start_war(50, "索马里", "肯尼亚", 750, 250, 1, 0)
		else:
			game.start_war(50, "索马里", "肯尼亚", 700, 300, 1, -1)
	else:
		if prosov:
			game.start_war(50, "索马里", "肯尼亚", 550, 450, 1, 0)
		else:
			game.start_war(50, "索马里", "肯尼亚", 450, 550, 1, -1)
	if ws.wars.size() > 50 and ws.wars[50] != null:
		ws.wars[50].name_war = tr(WAR50_NAME)
		ws.wars[50].fortnight_max = 24






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_594_garissa_massacre.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_594",
	"num": 594,
	"priority": 59400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_594_garissa_massacre.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1980.11.1"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "42"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
