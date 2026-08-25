extends "res://数据脚本/event_script_base.gd"

## 原作 Event497.cs：恩古瓦比的大会？——第二幕（刚果党代会，四选项）。
## 触发：TimeScript.cs:11006-11012 —— (日>=17 且 月>=10 且 年>=1984
##   或 月>=11 年>=1984 / 年>=1985) && c52.Gosstroy==1 && c52.SubGosstroy!=16。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 + relres flag + c1.sev + c52.对华贸易）。
##  - IsSocialism(true, 1) → ws.is_socialism(china, true)（严格社会主义判定）。
##  - LeaveAlliances() 逐项清标签（同 Event587 约定）。



const TXT_OPT0_DIS := "event.script.event_497_congo_congress.c0"
const TXT_OPT1_DIS := "event.script.event_497_congo_congress.c1"
const TXT_OPT2_DIS := "event.script.event_497_congo_congress.c2"

const TXT_R0 := "event.script.event_497_congo_congress.c3"

const TXT_R1 := "event.script.event_497_congo_congress.c4"

const TXT_R2_FR_NEUTRAL := "event.script.event_497_congo_congress.c5"

const TXT_R2_FR_PROSU := "event.script.event_497_congo_congress.c6"

const TXT_R3_FR_NEUTRAL := "event.script.event_497_congo_congress.c7"

const TXT_R3_FR_PROSU := TXT_R1


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var congo := world.get_country_by_legacy_index(52)
	var china := world.get_country_by_legacy_index(1)
	var torg := congo != null and congo.has_tag("对华贸易")
	var sev := china != null and china.has_tag("sev")
	var opt := event_def.options
	if line < 2 and torg:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if world.get_flag("relres") and sev and line < 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line != 0 and line != 4:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var congo := ws.get_country_by_legacy_index(52)
	var france := ws.get_country_by_legacy_index(21)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = GameConstants.Government.SOCIALIST
				congo.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				_leave_alliances(congo)
				congo.set_tag("亲中", true)
				congo.set_tag("对华贸易", true)
			ws.influence_prc += 20
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = GameConstants.Government.SOCIALIST
				congo.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				_leave_alliances(congo)
				congo.set_tag("亲苏", true)
				congo.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			var fr_prosu := france != null and france.has_tag("亲苏")
			if congo != null:
				_leave_alliances(congo)
				congo.set_tag("对华贸易", true)
			if not fr_prosu:
				if congo != null:
					congo.government = GameConstants.Government.REFORMIST
					congo.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				ws.influence_prc += 20
				context["result_text"] = tr(TXT_R2_FR_NEUTRAL)
			else:
				if congo != null:
					if ws.is_socialism(china, true):
						congo.set_tag("亲中", true)
						congo.government = GameConstants.Government.SOCIALIST
						congo.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					elif china != null and china.government == GameConstants.Government.REFORMIST:
						congo.set_tag("亲中", true)
						congo.government = GameConstants.Government.REFORMIST
						congo.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				ws.influence_prc += 20
				context["result_text"] = tr(TXT_R2_FR_PROSU)
		3:
			if france != null and france.has_tag("亲苏"):
				if congo != null:
					_leave_alliances(congo)
					congo.set_tag("亲苏", true)
					congo.government = GameConstants.Government.SOCIALIST
					congo.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				context["result_text"] = TXT_R3_FR_PROSU
			else:
				if congo != null:
					_leave_alliances(congo)
					congo.government = GameConstants.Government.REFORMIST
					congo.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				context["result_text"] = tr(TXT_R3_FR_NEUTRAL)


## Country.LeaveAlliances() 逐项映射（同 Event587 约定）。



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_497_congo_congress.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_497",
	"num": 497,
	"priority": 49700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_497_congo_congress.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1984.10.17"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 1, "target": "52"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 16, "target": "52"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
