extends "res://数据脚本/event_script_base.gd"

## 原作 Event653.cs：西非巨人——第一幕（尼日利亚第二共和国大选，五选项）。
## 触发：TimeScript.cs 11042-11046 —— (月>=7 且 年>=1979 或 年>=1980)。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 / modifies[3] / data31 / modifies[6] / c1 严格社会主义）。
##  - OilProd += 100f 已建模（ws.oil_prod）。
##  - 死代码 result 5 测试分支跳过；result 0-4 均为实际选项。


const TXT_OPT0_DIS := "event.script.event_653_west_african_giant_act1.c0"
const TXT_OPT1_DIS := "event.script.event_653_west_african_giant_act1.c1"
const TXT_OPT2_DIS := "event.script.event_653_west_african_giant_act1.c2"
const TXT_OPT3_DIS := "event.script.event_653_west_african_giant_act1.c3"
const TXT_OPT4_ALT := "event.script.event_653_west_african_giant_act1.c4"

const TXT_R0 := "event.script.event_653_west_african_giant_act1.c5"
const TXT_R1 := "event.script.event_653_west_african_giant_act1.c6"
const TXT_R2 := "event.script.event_653_west_african_giant_act1.c7"
const TXT_R3 := "event.script.event_653_west_african_giant_act1.c8"
const TXT_R4 := "event.script.event_653_west_african_giant_act1.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var war_support := data.war_support if data.size() > W.I_WAR_SUPPORT else 0
	var opt := event_def.options
	if line >= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 2 and line >= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 3 and line >= 1 and not _modifier_active(world, 3) and war_support >= 600:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	var china := world.get_country_by_legacy_index(1)
	if line <= 1 and _modifier_active(world, 6) and world.is_socialism(china, true):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	if line != 0:
		_enable(opt[4], event_def.options[4].text)
	else:
		_enable(opt[4], tr(TXT_OPT4_ALT))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -40)
			_add(W.I_AGENTS, -40)
			ws.oil_prod += 100.0  # Event653.cs OilProd
			context["result_text"] = tr(TXT_R0)
		1:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -160)
			_add(W.I_AGENTS, -160)
			ws.oil_prod += 100.0  # Event653.cs OilProd
			context["result_text"] = tr(TXT_R1)
		2:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if nigeria != null:
				nigeria.prc_power = 20
				nigeria.内战中 = true
			context["result_text"] = tr(TXT_R2)
		3:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			_add_relation(EmpireData.USA, -100)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if nigeria != null:
				nigeria.prc_power = 20
			context["result_text"] = tr(TXT_R3)
		4:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			context["result_text"] = tr(TXT_R4)




func _modifier_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null 			and world.modifiers[index].is_active





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_653_west_african_giant_act1.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_653",
	"num": 653,
	"priority": 65300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_653_west_african_giant_act1.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.7.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
