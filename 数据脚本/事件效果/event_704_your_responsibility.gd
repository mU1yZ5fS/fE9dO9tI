extends "res://数据脚本/event_script_base.gd"

## 原作 Event704.cs：你要负全部责任（加拿大紧急选举，五选项）。
## 触发：DiploButtonScript.cs:12554 type1077 → 外交互动_批5.gd _def_1077 start_event_num(w,704)。
## 差异：Torg→对华贸易、proprc→亲中、Vyshi→亲美；c137=加拿大、c167=魁北克。

const TXT_DESC_A := "event.script.your_responsibility.txt_desc_a"
const TXT_DESC_B := "event.script.your_responsibility.txt_desc_b"
const TXT_OPT0_DIS := "event.script.event_704_your_responsibility.c0"
const TXT_OPT1_DIS := "event.script.event_704_your_responsibility.c1"
const TXT_OPT2_DIS_A := "event.script.event_704_your_responsibility.c2"
const TXT_OPT2_DIS_B := "event.script.event_704_your_responsibility.c3"
const TXT_OPT3_DIS := "event.script.event_704_your_responsibility.c4"
const TXT_R0 := "event.script.event_704_your_responsibility.c5"
const TXT_R1_LEFT := "event.script.event_704_your_responsibility.c6"
const TXT_R1_PLAIN := "event.script.event_704_your_responsibility.c7"
const TXT_R2 := "event.script.event_704_your_responsibility.c8"
const TXT_R3 := "event.script.event_704_your_responsibility.c9"
const TXT_R4_A := "event.script.event_704_your_responsibility.c10"
const TXT_R4_B := "event.script.event_704_your_responsibility.c11"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	var quebec := ws.get_country_by_legacy_index(167)
	event_def.description = tr(TXT_DESC_B) if quebec != null and quebec.parts.size() > 0 and quebec.parts[0] else tr(TXT_DESC_A)
	if event_def.options.size() < 5:
		return
	var china := ws.get_country_by_legacy_index(1)
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line >= 2 and quebec != null and quebec.parts.size() > 0 and quebec.parts[0]:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if not ws.is_authoritarian(china):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if ws.is_socialism(china, false) and china != null and china.government != GameConstants.Government.LIBERAL \
			and (quebec == null or quebec.parts.size() == 0 or not quebec.parts[0]):
		_enable(opt[2], event_def.options[2].text)
	elif ws.is_socialism(china, true) or (china != null and china.government == GameConstants.Government.LIBERAL):
		_disable(opt[2], tr(TXT_OPT2_DIS_A))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_B))
	var albania := ws.get_country_by_legacy_index(20)
	if line == 0 and ws.result_of_event_num(701) == 3 and albania != null and albania.has_tag("亲中"):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var canada := ws.get_country_by_legacy_index(137)
	var quebec := ws.get_country_by_legacy_index(167)
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			if canada != null:
				_leave_alliances(canada)
				canada.government = GameConstants.Government.AUTHORITARIAN
				canada.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				canada.set_tag("对华贸易", true)
				canada.set_tag("亲中", true)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -100)
		1:
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			if canada != null:
				_leave_alliances(canada)
				canada.set_tag("对华贸易", true)
			if ws.result_of_event_num(701) == 2:
				context["result_text"] = tr(TXT_R1_LEFT)
				if canada != null:
					canada.government = GameConstants.Government.REFORMIST
					canada.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				ws.influence_prc += 30
				_add_relation(EmpireData.USA, -250)
			else:
				context["result_text"] = tr(TXT_R1_PLAIN)
				if canada != null:
					canada.government = GameConstants.Government.LIBERAL
					canada.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				ws.influence_prc += 20
				_add_relation(EmpireData.USA, -150)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			if canada != null:
				_leave_alliances(canada)
				canada.government = GameConstants.Government.REFORMIST
				canada.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				canada.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -100)
		3:
			context["result_text"] = tr(TXT_R3)
			_add(W.I_BUDGET, -500)
			_add(W.I_AGENTS, -500)
			_add(W.I_ARMY, -250)
			_add(W.I_PARTY_SUPPORT, -100)
			if canada != null:
				_leave_alliances(canada)
				canada.government = GameConstants.Government.AUTHORITARIAN
				canada.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				canada.set_tag("亲美", true)
				canada.set_tag("对华贸易", false)
			ws.influence_prc -= 10
			_add_relation(EmpireData.USA, -400)
		4:
			if quebec == null or quebec.parts.size() == 0 or not quebec.parts[0]:
				context["result_text"] = tr(TXT_R4_A)
			else:
				context["result_text"] = tr(TXT_R4_B)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_704_your_responsibility.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_704",
	"nodesc": true,
	"num": 704,
	"priority": 70400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_704_your_responsibility.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
