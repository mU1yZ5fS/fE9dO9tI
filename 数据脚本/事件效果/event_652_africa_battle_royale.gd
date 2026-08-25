extends "res://数据脚本/event_script_base.gd"

## 原作 Event652.cs：非洲大逃杀（塞拉利昂莫莫改革，四选项）。
## 触发：TimeScript.cs 11035-11039 —— (月>=4 且 年>=1985 或 年>=1986) && c107.sub_government != GameConstants.SubGovernment.NEOLIBERAL。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 / c107 对华贸易 / c107 内战 / c13 利比亚对华贸易 / c51 美国发展度与美领导人）。
##  - War 78：game.start_war(78,...) + fortnight_max=40（TickTime(40)）；
##    AmericanSupportDefender.SovietSupportAttacker → usa_side = GameConstants.WarSide.SIDE2 / ussr_side = GameConstants.WarSide.SIDE1；
##    仅 AmericanSupportDefender 的分支 usa_side = GameConstants.WarSide.SIDE2 / ussr_side = GameConstants.WarSide.NONE（原版 War 默认 -1）。
##  - 死代码 result 5 测试分支跳过；result 3 是实际选项（充耳不闻），效果已复刻。


const TXT_OPT0_DIS := "event.script.event_652_africa_battle_royale.c0"
const TXT_OPT1_DIS_BACKSTAB := "event.script.event_652_africa_battle_royale.c1"
const TXT_OPT1_DIS_NOONE := "event.script.event_652_africa_battle_royale.c2"
const TXT_OPT1_DIS_INTERFERE := "event.script.event_652_africa_battle_royale.c3"
const TXT_OPT2_DIS_BACKSTAB := "event.script.event_652_africa_battle_royale.c4"
const TXT_OPT2_DIS_BUSY := "event.script.event_652_africa_battle_royale.c5"
const TXT_OPT2_DIS_IMPERIAL := "event.script.event_652_africa_battle_royale.c6"

const TXT_R0 := "event.script.event_652_africa_battle_royale.c7"
const TXT_R1_INTRO := "event.script.event_652_africa_battle_royale.c8"
const TXT_R1_CW := "event.script.event_652_africa_battle_royale.c9"
const TXT_WAR78_NAME := "event.script.event_652_africa_battle_royale.c10"
const TXT_WAR78_CW_ATTACKER := "event.script.event_652_africa_battle_royale.c11"
const TXT_WAR78_CW_DEFENDER := "event.script.event_652_africa_battle_royale.c12"
const TXT_R1_NO_CW := "event.script.event_652_africa_battle_royale.c13"
const TXT_WAR78_NO_CW_ATTACKER := "event.script.event_652_africa_battle_royale.c14"
const TXT_WAR78_NO_CW_DEFENDER := "event.script.event_652_africa_battle_royale.c15"
const TXT_R2 := "event.script.event_652_africa_battle_royale.c16"
const TXT_R3 := "event.script.event_652_africa_battle_royale.c17"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var sierra := world.get_country_by_legacy_index(107)
	var libya := world.get_country_by_legacy_index(13)
	var usa_country := world.get_country_by_legacy_index(51)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var opt := event_def.options
	var sierra_torg := sierra != null and sierra.has_tag("对华贸易")
	if sierra_torg:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	var sierra_cw := sierra != null and sierra.内战中
	var libya_torg := libya != null and libya.has_tag("对华贸易")
	if line <= 2 and (sierra_cw or libya_torg) and not sierra_torg:
		_enable(opt[1], event_def.options[1].text)
	elif sierra_torg:
		_disable(opt[1], tr(TXT_OPT1_DIS_BACKSTAB))
	elif not sierra_cw and not libya_torg:
		_disable(opt[1], tr(TXT_OPT1_DIS_NOONE))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_INTERFERE))
	var usa_dev_ok := usa_country != null and usa_country.development == 1
	var usa_leader := 0
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null:
		usa_leader = world.empires[EmpireData.USA].current_leader
	var usa_leader_ok := usa_leader == 0 or usa_leader == 2
	if line >= 3 and usa_dev_ok and usa_leader_ok and not sierra_torg:
		_enable(opt[2], event_def.options[2].text)
	elif sierra_torg:
		_disable(opt[2], tr(TXT_OPT2_DIS_BACKSTAB))
	elif not usa_dev_ok or not usa_leader_ok:
		_disable(opt[2], tr(TXT_OPT2_DIS_BUSY))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_IMPERIAL))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var sierra := ws.get_country_by_legacy_index(107)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if sierra != null:
				_leave_alliances(sierra)
				sierra.set_tag("对华贸易", true)
				sierra.government = GameConstants.Government.REFORMIST
				sierra.sub_government = GameConstants.SubGovernment.PRAGMATIST
				sierra.set_tag("亲中", true)
			_add(W.I_BUDGET, -80)
			ws.influence_prc += 10
			context["result_text"] = tr(TXT_R0)
		1:
			if sierra != null:
				sierra.government = GameConstants.Government.AUTHORITARIAN
				sierra.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(sierra)
				sierra.set_tag("亲美", true)
				_set_parts(sierra, 0, true)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			_add_relation(EmpireData.USA, -50)
			var text := tr(TXT_R1_INTRO)
			if sierra != null and sierra.内战中:
				game.start_war(78, tr(TXT_WAR78_CW_ATTACKER), tr(TXT_WAR78_CW_DEFENDER), 200, 800, 1, 0)
				text += tr(TXT_R1_CW)
			else:
				game.start_war(78, tr(TXT_WAR78_NO_CW_ATTACKER), tr(TXT_WAR78_NO_CW_DEFENDER), 200, 800, 1, -1)
				if ws.wars.size() > 78 and ws.wars[78] != null:
					ws.wars[78].ussr_side = GameConstants.WarSide.NONE
				text += tr(TXT_R1_NO_CW)
			if ws.wars.size() > 78 and ws.wars[78] != null:
				ws.wars[78].name_war = tr(TXT_WAR78_NAME)
				ws.wars[78].fortnight_max = 40
			context["result_text"] = text
		2:
			if sierra != null:
				_leave_alliances(sierra)
				sierra.government = GameConstants.Government.AUTHORITARIAN
				sierra.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				sierra.set_tag("亲美", true)
				sierra.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R2)
		3:
			if sierra != null:
				sierra.government = GameConstants.Government.REFORMIST
				sierra.sub_government = GameConstants.SubGovernment.PRAGMATIST
			context["result_text"] = tr(TXT_R3)





func _set_parts(c: CountryData, index: int, value: bool) -> void:
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value







# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_652_africa_battle_royale.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_652",
	"num": 652,
	"priority": 65200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_652_africa_battle_royale.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1985.4.1"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 12, "target": "107"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
