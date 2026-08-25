extends "res://数据脚本/event_script_base.gd"

## 原作 Event584.cs：班达斯坦的终结（马拉维，单选项）。
## 触发：DiploButtonScript.cs:11708 —— number_event = 584（外交按钮手动触发），无自动触发。
## 差异：
##  - Gosstroy → government；completedDecisions[7] → ws.decisions.completed[7]；
##  - Torg → 对华贸易；proprc → 亲中。




const TXT_R0_A := "event.script.event_584_bantustan_end.c0"
const TXT_R0_SA := "event.script.event_584_bantustan_end.c1"
const TXT_R0_OTHER := "event.script.event_584_bantustan_end.c2"
const TXT_R0_MID_A := "event.script.event_584_bantustan_end.c3"
const TXT_R0_BREAK := "event.script.event_584_bantustan_end.c4"
const TXT_R0_MID_B := "event.script.event_584_bantustan_end.c5"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c131 := ws.get_country_by_legacy_index(131)
	var c38 := ws.get_country_by_legacy_index(38)
	var c125 := ws.get_country_by_legacy_index(125)
	var text := tr(TXT_R0_A)
	if c131 != null and c131.government == GameConstants.Government.AUTHORITARIAN:
		text += tr(TXT_R0_SA)
	else:
		text += tr(TXT_R0_OTHER)
	text += tr(TXT_R0_MID_A)
	var break_cond := c38 != null and c38.government == GameConstants.Government.AUTHORITARIAN and ws.decisions != null \
			and ws.decisions.completed.size() > 7 and not ws.decisions.completed[7]
	if break_cond:
		text += tr(TXT_R0_BREAK)
	text += tr(TXT_R0_MID_B)
	_add(W.I_BUDGET, -50)
	if c125 != null:
		c125.government = GameConstants.Government.SOCIALIST
		c125.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		_leave_alliances(c125)
		c125.set_tag("亲中", true)
		c125.set_tag("对华贸易", true)
	ws.influence_prc += 20
	_add(W.I_DIPLO, 15)
	context["result_text"] = text



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_584_bantustan_end.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_584",
	"num": 584,
	"priority": 58400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_584_bantustan_end.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
