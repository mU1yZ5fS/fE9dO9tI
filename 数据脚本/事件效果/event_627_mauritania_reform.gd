extends "res://数据脚本/event_script_base.gd"

## 原作 Event627.cs：伊斯兰、民族、宪政和社会主义民主！（毛里塔尼亚社会改造，单选项）。
## 触发：DiploButtonScript.cs:11770 —— 外交按钮 1032，selected_country==59（毛里塔尼亚），
##   入口扣 data.budget-=150、data.agents-=100（在 _def_1032 中已移植），随后 StartEvent(627)。
## 本 .tres trigger_conditions 为空：仅由外交按钮手动触发，不进自动扫描。

const TXT_R0 := "event.script.event_627_mauritania_reform.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(59)  # 毛里塔尼亚
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if c != null:
				c.government = GameConstants.Government.SOCIALIST
				c.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c)
				c.set_tag("对华贸易", true)
				c.set_tag("亲中", true)
				c.chinese_name = "毛里塔尼亚民主共和国"
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -100)  # 原 :38-39 两次 -50
			_add_power(EmpireData.USA, -20)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_627_mauritania_reform.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_627",
	"num": 627,
	"priority": 62700,
	"notify": false,
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
