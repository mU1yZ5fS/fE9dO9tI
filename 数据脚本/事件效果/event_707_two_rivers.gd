extends "res://数据脚本/event_script_base.gd"

## 原作 Event707.cs：两河的新娘子（叙伊民族联合行动宪章，1978.11）。
## 触发：TimeScript.cs:10260-10266 ——
##   (月>=11 且 年>=1978 或 年>=1979) 且 event_done[36] 且 resultOfEvents[36]==0
##   且 叙利亚(35).SubGosstroy==15 且 叙利亚.prosov。
## 差异：
##  - 共同效果：伊拉克(14).prosov=false、叙利亚(35).prosov=false
##    → Godot set_tag("亲苏", false)（country_data.gd TAG_ALIASES: is_prosov→亲苏）。
##  - 埃及(30) 的 SubGosstroy==20 / Gosstroy==2 分支逐字保留；原版 option1
##    SubGosstroy==20 命中后 return，故不再检查 Gosstroy==2，逐字保留该结构。

const TXT_BASE := "event.script.event_707_two_rivers.c0"

const TXT_EGYPT_20 := "event.script.event_707_two_rivers.c1"

const TXT_EGYPT_2 := "event.script.event_707_two_rivers.c2"

const TXT_R1_BASE := "event.script.event_707_two_rivers.c3"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# Event707.cs ResultsOfEvents 共同效果（先于 result_num 分支）
	_set_prosov(14, false)
	_set_prosov(35, false)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		var text := tr(TXT_BASE)
		var egypt := ws.get_country_by_legacy_index(30)
		if egypt != null:
			if egypt.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
				text += "\n" + tr(TXT_EGYPT_20)
			elif egypt.government == GameConstants.Government.REFORMIST:
				text += "\n" + tr(TXT_EGYPT_2)
		if d.size() > W.I_BUDGET:
			d.budget += 50
		context["result_text"] = text
	elif opt == 1:
		var text := tr(TXT_R1_BASE)
		var egypt := ws.get_country_by_legacy_index(30)
		if egypt != null:
			if egypt.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
				text += "\n" + tr(TXT_EGYPT_20)
			elif egypt.government == GameConstants.Government.REFORMIST:
				text += "\n" + tr(TXT_EGYPT_2)
		context["result_text"] = text


func _set_prosov(legacy_index: int, value: bool) -> void:
	var c := ws.get_country_by_legacy_index(legacy_index)
	if c != null:
		c.set_tag("亲苏", value)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_707_two_rivers.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_707",
	"num": 707,
	"priority": 7070,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1978.11.1"}, {"t": "PREV_EVENT_DONE", "ref": "iraqi_coalition"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "iraqi_coalition"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 15, "target": "35"}, {"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "35"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
