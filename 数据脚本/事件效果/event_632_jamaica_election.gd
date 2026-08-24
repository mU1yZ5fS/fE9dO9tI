extends "res://数据脚本/event_script_base.gd"

## 原作 Event632.cs：牙买加，我们热爱的家乡（牙买加1980大选，三选项）。 ## 触发：ReqEventsDLC02.cs:971-974 —— c152.SubGosstroy!=13 且 DATE_AFTER 1980.10.30 ##   （原 (1980&&m>=10&&d>=30) (1980&&m>=11) y>=1981）。 ## 差异：原版按 data.political_line/resultOfEvents[631] Destroy(button[i])；Godot _disable 同义。 ##   Vyshi→亲美、Torg/proprc→标签、now_leader→empires[0].current_leader。

const TXT_OPT0_DIS := "event.script.event_632_jamaica_election.c0"
const TXT_OPT1_DIS := "event.script.event_632_jamaica_election.c1"
const TXT_R0_OK := "event.script.event_632_jamaica_election.c2"
const TXT_R0_FAIL := "event.script.event_632_jamaica_election.c3"
const TXT_R1 := "event.script.event_632_jamaica_election.c4"
const TXT_R2_A := "event.script.jamaica_election.txt_r2_a"
const TXT_R2_REAGAN := "event.script.jamaica_election.txt_r2_reagan"
const TXT_R2_CARTER := "event.script.jamaica_election.txt_r2_carter"
const TXT_R2_TAIL := "event.script.jamaica_election.txt_r2_tail"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var r631 := int(ws.completed_event_ids.get("event_631", 0))
	var opt := event_def.options
	if line < 3 and r631 == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 1 and r631 == 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var jamaica := ws.get_country_by_legacy_index(152)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var usa_power := ws.empires[0].power if ws.empires.size() > 0 and ws.empires[0] != null else 0
			var usa_rel := ws.empires[0].relations if ws.empires.size() > 0 and ws.empires[0] != null else 0
			if ws.influence_prc > usa_power or usa_rel >= 500:
				context["result_text"] = tr(TXT_R0_OK)
				if jamaica != null:
					jamaica.government = GameConstants.Government.REFORMIST
					jamaica.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					_leave_alliances(jamaica)
					jamaica.set_tag("对华贸易", true)
					jamaica.set_tag("亲中", true)
				ws.influence_prc += 10
				_add_power(EmpireData.USA, -20)
				_add_relation(EmpireData.USA, -50)
			else:
				context["result_text"] = tr(TXT_R0_FAIL)
				if jamaica != null:
					jamaica.government = GameConstants.Government.AUTHORITARIAN
					jamaica.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(jamaica)
					jamaica.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)
				_add_relation(EmpireData.USA, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if jamaica != null:
				jamaica.government = GameConstants.Government.LIBERAL
				jamaica.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				_leave_alliances(jamaica)
				jamaica.set_tag("亲美", true)
				jamaica.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, 20)
			_add_relation(EmpireData.USA, 50)
		2:
			var leader := ws.empires[0].current_leader if ws.empires.size() > 0 and ws.empires[0] != null else 0
			context["result_text"] = tr(TXT_R2_A) + (tr(TXT_R2_REAGAN) if leader == 0 else tr(TXT_R2_CARTER)) + tr(TXT_R2_TAIL)
			_add(W.I_BUDGET, -20)
			if jamaica != null:
				jamaica.government = GameConstants.Government.LIBERAL
				jamaica.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				_leave_alliances(jamaica)
				jamaica.set_tag("亲美", true)
			_add_power(EmpireData.USA, 20)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_632_jamaica_election.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_632",
	"num": 632,
	"priority": 63200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_632_jamaica_election.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1980.10.30"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 13, "target": "152"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
