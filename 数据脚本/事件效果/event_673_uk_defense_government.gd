extends "res://数据脚本/event_script_base.gd"

## 原作 Event673.cs：乞丐死时不会有彗星出现……（英国国防政府，五选项）。
## 触发：DiploButtonScript.cs:12369 —— 外交按钮 1064，入口扣预算100/特工200后手动触发。
## 差异：Vyshi→亲美、isEU/isNATO→eu/nato、Torg→对华贸易；now_leader→empires[0].current_leader。

const TXT_OPT0_DIS := "event.script.event_673_uk_defense_government.c0"
const TXT_OPT1_DIS := "event.script.event_673_uk_defense_government.c1"
const TXT_OPT2_DIS := "event.script.event_673_uk_defense_government.c2"
const TXT_OPT3_DIS := "event.script.event_673_uk_defense_government.c3"
const TXT_R0 := "event.script.event_673_uk_defense_government.c4"
const TXT_R1 := "event.script.event_673_uk_defense_government.c5"
const TXT_R2 := "event.script.event_673_uk_defense_government.c6"
const TXT_R2_STRASSER := "event.script.event_673_uk_defense_government.c7"
const TXT_R2_FASCIST := "event.script.event_673_uk_defense_government.c8"
const TXT_R3 := "event.script.event_673_uk_defense_government.c9"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	var usa_leader := ws.empires[EmpireData.USA].current_leader if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	var usa_rel := ws.empires[EmpireData.USA].relations if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	var france := ws.get_country_by_legacy_index(21)
	var spain := ws.get_country_by_legacy_index(85)
	if _res(W.I_POLITICAL_LINE) >= 3 and usa_rel >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if usa_leader == 3 or (usa_leader == 1 and france != null and france.government == GameConstants.Government.LIBERAL \
			and spain != null and spain.government == GameConstants.Government.LIBERAL):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if _auth_count() >= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if _res(W.I_POLITICAL_LINE) < 2:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	if uk == null:
		return
	var usa_leader := ws.empires[EmpireData.USA].current_leader if ws.empires.size() > EmpireData.USA \
		and ws.empires[EmpireData.USA] != null else 0
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			uk.government = GameConstants.Government.AUTHORITARIAN
			uk.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			uk.set_tag("亲美", true)
			uk.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 20)
		1:
			context["result_text"] = tr(TXT_R1)
			uk.government = GameConstants.Government.AUTHORITARIAN
			uk.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			uk.set_tag("亲美", true)
			uk.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 20)
		2:
			var num := _sub22_count()
			if num >= 1:
				context["result_text"] = tr(TXT_R2) + tr(TXT_R2_STRASSER)
				uk.government = GameConstants.Government.AUTHORITARIAN
				uk.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
			else:
				context["result_text"] = tr(TXT_R2) + tr(TXT_R2_FASCIST)
				uk.government = GameConstants.Government.AUTHORITARIAN
				uk.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			uk.set_tag("亲美", false)
			uk.set_tag("eu", false)
			uk.set_tag("nato", false)
			uk.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -20)
		3:
			context["result_text"] = tr(TXT_R3)
			uk.government = GameConstants.Government.AUTHORITARIAN
			uk.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			uk.set_tag("亲美", true)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 20)
		4:
			var france := ws.get_country_by_legacy_index(21)
			var spain := ws.get_country_by_legacy_index(85)
			if (usa_leader == 3 or usa_leader == 1) and france != null and france.government == GameConstants.Government.LIBERAL \
					and spain != null and spain.government == GameConstants.Government.LIBERAL:
				context["result_text"] = tr(TXT_R1)
				uk.government = GameConstants.Government.AUTHORITARIAN
				uk.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				uk.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)
			elif _auth_count() >= 2:
				var num3 := _sub22_count()
				if num3 >= 2:
					context["result_text"] = tr(TXT_R2) + tr(TXT_R2_STRASSER)
					uk.government = GameConstants.Government.AUTHORITARIAN
					uk.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
				else:
					context["result_text"] = tr(TXT_R2) + tr(TXT_R2_FASCIST)
					uk.government = GameConstants.Government.AUTHORITARIAN
					uk.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				uk.set_tag("亲美", false)
				uk.set_tag("eu", false)
				uk.set_tag("nato", false)
				_add_power(EmpireData.USA, -20)
			else:
				context["result_text"] = tr(TXT_R0)
				uk.government = GameConstants.Government.AUTHORITARIAN
				uk.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				uk.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)


func _auth_count() -> int:
	var count := 0
	for idx in [21, 85, 86]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and ws.is_authoritarian(c) and c.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST and c.sub_government != GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
			count += 1
	return count


func _sub22_count() -> int:
	var count := 0
	for idx in [21, 85, 86]:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and c.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST:
			count += 1
	return count



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_673_uk_defense_government.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_673",
	"num": 673,
	"priority": 67300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_673_uk_defense_government.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
