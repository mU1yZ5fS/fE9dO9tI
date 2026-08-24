extends "res://数据脚本/event_script_base.gd"

## 原作 Event706.cs：第三次“新进程”（多哥第三次革命，单选项）。
## 触发：DiploButtonScript.cs:10866（type70, c108）→ 外交互动_批2.gd 已接通（入口扣预算/特工各50）。
## 差异：proprc→亲中、Torg→对华贸易、soc_stab→social_stability、JoinAllOurAlliances→_join_alliances。

const TXT_R0 := "event.script.event_706_third_new_process.c0"
const TXT_R0_APPEND := "event.script.event_706_third_new_process.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var text := tr(TXT_R0)
	var mali := ws.get_country_by_legacy_index(58)
	if mali != null and mali.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		text += tr(TXT_R0_APPEND)
	context["result_text"] = text
	var togo := ws.get_country_by_legacy_index(108)
	if togo != null:
		_leave_alliances(togo)
		togo.government = GameConstants.Government.AUTHORITARIAN
		togo.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
		togo.set_tag("亲中", true)
		togo.set_tag("对华贸易", true)
		_join_alliances(togo)
	var haiti := ws.get_country_by_legacy_index(139)
	if haiti != null:
		haiti.social_stability = 1000
	ws.influence_prc += 30



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_706_third_new_process.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_706",
	"num": 706,
	"priority": 70600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_706_third_new_process.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
