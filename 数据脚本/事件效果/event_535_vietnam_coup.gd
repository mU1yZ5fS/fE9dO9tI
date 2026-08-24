extends "res://数据脚本/event_script_base.gd"

## 原作 Event535.cs：君子报仇，十年不晚（越南亲华派政变，2选项）。
## 触发：无自动触发（DiploButtonScript.cs:11380 外交按钮 number_event=535）。

const TXT_R0 := "event.script.event_535_vietnam_coup.c0"
const TXT_R1 := "event.script.event_535_vietnam_coup.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c11 := ws.get_country_by_legacy_index(11)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add_power(EmpireData.USSR, -30)
			_add_relation(EmpireData.USSR, -200)
			_set_data(171, 0)  # 原 data.vietnam_pro_china_coup_available
			if c11 != null:
				_leave_alliances(c11)
				c11.set_tag("亲中", true)
				c11.set_tag("对华贸易", true)
				_join_alliances(c11)
				if c1 != null:
					c11.sub_government = c1.sub_government
					c11.government = c1.government
				c11.prc_power = 1000
				c11.social_stability = 1000
			for c in ws.countries:
				if c.puppet_of == 11:
					c.puppet_of = GameConstants.LegacySlot.NONE
			_add(W.I_BUDGET, -40)
			_add(W.I_AGENTS, -40)
			_add(W.I_INFLUENCE, 50)
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_535_vietnam_coup.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_535",
	"num": 535,
	"priority": 53500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_535_vietnam_coup.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
