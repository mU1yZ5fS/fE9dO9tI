extends "res://数据脚本/event_script_base.gd"

## 原作 Event130.cs：玻利维亚，我的祖国，你已坠入火海（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "event.script.event_130_bolivia_my_homeland.c0"
const TXT_PROPRC_NO := "event.script.event_130_bolivia_my_homeland.c1"
const TXT_R0 := "event.script.event_130_bolivia_my_homeland.c2"
const TXT_R1 := "event.script.event_130_bolivia_my_homeland.c3"




func _proprc_suffix(c: CountryData) -> String:
	return tr(TXT_PROPRC_YES) if c.has_tag("亲中") else tr(TXT_PROPRC_NO)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bolivia := ws.get_country_by_legacy_index(72)
	if bolivia == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			bolivia.level_of_instability -= 5
			bolivia.level_of_development -= 10
			bolivia.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R0) + _proprc_suffix(bolivia)
		1:
			bolivia.set_tag("对华贸易", true)
			bolivia.level_of_instability -= 15
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			context["result_text"] = tr(TXT_R1) + _proprc_suffix(bolivia)
		_:
			bolivia.level_of_instability -= 5
			bolivia.level_of_development -= 5
			# 用户需求：玻利维亚事件1选择2（保持距离）也能与玻利维亚建立贸易。
			bolivia.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R0) + _proprc_suffix(bolivia)
	bolivia.government = GameConstants.Government.LIBERAL
	bolivia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
	bolivia.next_election_year = 1979
	bolivia.next_election_month = 7
	bolivia.next_election_day = 1




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_130_bolivia_my_homeland.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_130",
	"num": 130,
	"priority": 13000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_130_bolivia_my_homeland.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
