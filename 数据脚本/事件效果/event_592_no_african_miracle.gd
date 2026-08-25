extends "res://数据脚本/event_script_base.gd"

## 原作 Event592.cs：再无“非洲奇迹”（科特迪瓦革命，单选项）。
## 触发：DiploButtonScript.cs:11726 —— number_event = 592（外交按钮手动触发），无自动触发。
## 差异：
##  - EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；Torg → 对华贸易；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances。




const TXT_R0 := "event.script.event_592_no_african_miracle.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c64 := ws.get_country_by_legacy_index(64)
	_add(W.I_BUDGET, -80)
	_add(W.I_AGENTS, -80)
	if c64 != null:
		c64.government = GameConstants.Government.SOCIALIST
		c64.sub_government = GameConstants.SubGovernment.MAOIST
		_leave_alliances(c64)
		_establish_prochina(c64)
		c64.set_tag("对华贸易", true)
		_join_alliances(c64)
	context["result_text"] = tr(TXT_R0)


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_592_no_african_miracle.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_592",
	"num": 592,
	"priority": 59200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_592_no_african_miracle.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
