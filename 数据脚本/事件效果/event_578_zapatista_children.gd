extends "res://数据脚本/event_script_base.gd"

## 原作 Event578.cs：萨帕塔的孩子们……（墨西哥恰帕斯，四选项）。 ## 触发：ReqEventForDLC02.cs:799-802 —— (日>=17 且 月>=11 且 年>=1983) (月>=12 且 年>=1983) 年>=1984 ##   → DATE_AFTER 1983.11.17。 ## 差异： ##  - 选项显隐 prepare 动态改写；proprc/prosov → 亲中/亲苏；influencePRC → ws.influence_prc； ##  - resultOfEvents[577] 缺省按原版 int 默认 0；cw → 内战中；stab → country.stab； ##  - parts[1] 写前 resize；AmericanSupportAttacker.SovietSupportDefender → usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.SIDE2； ##  - TickTime(24) → fortnight_max=24。



const TXT_OPT0_DIS := "event.script.event_578_zapatista_children.c0"
const TXT_OPT1_DIS_WHY := "event.script.event_578_zapatista_children.c1"
const TXT_OPT1_DIS_INDIAN := "event.script.event_578_zapatista_children.c2"
const TXT_OPT2_DIS := "event.script.event_578_zapatista_children.c3"

const TXT_R0 := "event.script.event_578_zapatista_children.c4"
const TXT_R1_A := "event.script.event_578_zapatista_children.c5"
const TXT_R1_B := "event.script.event_578_zapatista_children.c6"
const TXT_R2 := "event.script.event_578_zapatista_children.c7"
const TXT_R3 := "event.script.event_578_zapatista_children.c8"

const WAR45_NAME := "event.script.event_578_zapatista_children.c9"
const WAR45_SIDE1 := "event.script.event_578_zapatista_children.c10"
const WAR45_SIDE2 := "event.script.event_578_zapatista_children.c11"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c149 := world.get_country_by_legacy_index(149)
	var r577 := int(world.completed_event_ids.get("event_577", 0))
	var opt := event_def.options
	if line == 0 and c149 != null and (c149.has_tag("亲中") or c149.has_tag("亲苏")) \
			and r577 == 0 and world.influence_prc >= 800:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 1 and line <= 3 and world.influence_prc >= 500:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_WHY))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_INDIAN))
	if data.size() > W.I_WAR_SUPPORT and data.war_support >= 700:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c140 := ws.get_country_by_legacy_index(140)
	if c140 != null:
		c140.government = GameConstants.Government.LIBERAL
		c140.sub_government = GameConstants.SubGovernment.NEOLIBERAL
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var num := 0
			if c140 != null and c140.stab == 1:
				num = 100
			game.start_war(45, tr(WAR45_SIDE1), tr(WAR45_SIDE2), 800 - num, 200 + num, 0, 1)
			if ws.wars.size() > 45 and ws.wars[45] != null:
				ws.wars[45].name_war = tr(WAR45_NAME)
				ws.wars[45].fortnight_max = 24
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -80)
			_add(W.I_ARMY, -80)
			_add_relation(EmpireData.USA, -200)
			if c140 != null:
				c140.government = GameConstants.Government.AUTHORITARIAN
				c140.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_set_part(c140, 1, true)
			context["result_text"] = tr(TXT_R0)
		1:
			var r577 := int(ws.completed_event_ids.get("event_577", 0))
			if r577 == 1 and c140 != null and c140.内战中 and c140.stab == 1:
				context["result_text"] = tr(TXT_R1_A)
			else:
				if c140 != null:
					c140.内战中 = false
				context["result_text"] = tr(TXT_R1_B)
			_add(W.I_BUDGET, -50)
		2:
			_add(W.I_AGENTS, -30)
			if c140 != null:
				c140.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)


func _set_part(c: CountryData, i: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= i:
		c.parts.append(false)
	c.parts[i] = value



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_578_zapatista_children.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_578",
	"num": 578,
	"priority": 57800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_578_zapatista_children.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.11.17"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
