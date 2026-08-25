extends "res://数据脚本/event_script_base.gd"

## 原作 Event913.cs：一颗名为太阳的星星（登陆太阳宣传，单选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:82-84 ——
##   !event_done[913] && allcountries[10].SubGosstroy==19 && science[30]。
##   science[30]→TECH_UNLOCKED(30)，fire_only_once 承担 !event_done[913]。

const TXT_R0 := "event.script.event_913_sun_star.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = tr(TXT_R0)
		_add(W.I_PARTY_SUPPORT, 1000)
		_add(W.I_PEOPLE_SUPPORT, 1000)
		_add(W.I_THOUGHT_FREEDOM, -1000)
		_set_data(W.I_WAR_SUPPORT, 1000)
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -100)
		_add_relation(EmpireData.USA, -150)
		_add_relation(EmpireData.USSR, -150)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_913_sun_star.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_913",
	"num": 913,
	"priority": 91300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_913_sun_star.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 19, "target": "10"}, {"t": "TECH_UNLOCKED", "v": 30}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
