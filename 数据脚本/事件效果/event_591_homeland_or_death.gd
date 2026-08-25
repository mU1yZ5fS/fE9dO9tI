extends "res://数据脚本/event_script_base.gd"

## 原作 Event591.cs：祖国或死亡（古巴，三选项）。
## 触发：DiploButtonScript.cs:11793 —— number_event = 591（外交按钮手动触发），无自动触发。
## 差异：
##  - 选项2 显隐 prepare 动态改写（now_leader → current_leader）；Torg → 对华贸易；
##  - modifies[3]/[6].active → ws.modifiers[3]/[6].is_active；
##  - EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances；
##  - c141.SubGosstroy==20 分支文本拼接。



const TXT_OPT2_DIS := "event.script.event_591_homeland_or_death.c0"

const TXT_R0_A := "event.script.event_591_homeland_or_death.c1"
const TXT_R0_B := "event.script.event_591_homeland_or_death.c2"
const TXT_R0_C := "event.script.event_591_homeland_or_death.c3"
const TXT_R0_D := "event.script.event_591_homeland_or_death.c4"
const TXT_R0_E := "event.script.event_591_homeland_or_death.c5"
const TXT_R1_A := "event.script.event_591_homeland_or_death.c6"
const TXT_R1_NORIEGA := "event.script.event_591_homeland_or_death.c7"
const TXT_R1_B := "event.script.event_591_homeland_or_death.c8"
const TXT_R2 := "event.script.event_591_homeland_or_death.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c7 := world.get_country_by_legacy_index(7)
	var ussr := world.empires[EmpireData.USSR] if world.empires.size() > EmpireData.USSR else null
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	if ussr != null and ussr.current_leader == 6 and c7 != null and c7.has_tag("对华贸易") and line >= 3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c138 := ws.get_country_by_legacy_index(138)
	var c141 := ws.get_country_by_legacy_index(141)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var tname := _leader_name()
			var text := tr(TXT_R0_A) + tname + tr(TXT_R0_B) + tname + tr(TXT_R0_C) + tname + tr(TXT_R0_D) + tname + tr(TXT_R0_E)
			_add(W.I_BUDGET, -150)
			if c138 != null:
				if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
					c138.government = GameConstants.Government.SOCIALIST
					c138.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				else:
					c138.government = GameConstants.Government.REFORMIST
					c138.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				_establish_prochina(c138)
				c138.set_tag("对华贸易", true)
				_join_alliances(c138)
			context["result_text"] = text
		1:
			var text := tr(TXT_R1_A)
			if c141 != null and c141.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
				text += tr(TXT_R1_NORIEGA)
			text += tr(TXT_R1_B)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if c138 != null:
				c138.government = GameConstants.Government.AUTHORITARIAN
				c138.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_establish_prochina(c138)
				c138.set_tag("对华贸易", true)
				_join_alliances(c138)
			context["result_text"] = text
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if c138 != null:
				c138.government = GameConstants.Government.REFORMIST
				c138.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				_establish_prochina(c138)
				c138.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R2)


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _mod_active(id: int) -> bool:
	return ws.modifiers.size() > id and ws.modifiers[id] != null and ws.modifiers[id].is_active


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_591_homeland_or_death.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_591",
	"num": 591,
	"priority": 59100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_591_homeland_or_death.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
