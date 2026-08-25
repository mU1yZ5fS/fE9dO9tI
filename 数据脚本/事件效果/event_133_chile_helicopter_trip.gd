extends "res://数据脚本/event_script_base.gd"

## 原作 Event133.cs：直升机之旅（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "event.script.event_133_chile_helicopter_trip.c0"
const TXT_PROPRC_NO := "event.script.event_133_chile_helicopter_trip.c1"
const TXT_R0 := "event.script.event_133_chile_helicopter_trip.c2"
const TXT_R1 := "event.script.event_133_chile_helicopter_trip.c3"
const TXT_R2 := "event.script.event_133_chile_helicopter_trip.c4"




func _proprc_suffix(c: CountryData) -> String:
	return tr(TXT_PROPRC_YES) if c.has_tag("亲中") else tr(TXT_PROPRC_NO)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var chile := ws.get_country_by_legacy_index(74)
	if chile == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 15
			chile.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R0) + _proprc_suffix(chile)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 15
			chile.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			chile.set_tag("对华贸易", false)
			chile.set_tag("亲中", false)
			context["result_text"] = tr(TXT_R1) + _proprc_suffix(chile)
		_:
			chile.level_of_instability -= 15
			context["result_text"] = tr(TXT_R2) + _proprc_suffix(chile)
	chile.next_election_year = 1980
	chile.next_election_month = 9
	chile.next_election_day = 11




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_133_chile_helicopter_trip.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_133",
	"num": 133,
	"priority": 13300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_133_chile_helicopter_trip.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
