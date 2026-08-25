extends "res://数据脚本/event_script_base.gd"

## 原作 Event443.cs：收复藏南！（1选项）。
## 触发：无自动触发点（trigger_conditions=[]）。TimeScript.cs:2866-2875 中印战争（war==2）胜利分支手动 number_event=443。
## 差异：CBIndia→ws.set_flag("cb_india", false)。




const TXT_R0 := "event.script.event_443_recover_arunachal.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(EmpireData.USSR, -150)
			_add_power(EmpireData.USSR, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, 100)
			ws.influence_prc += 10
			ws.set_flag("cb_india", false)
			# 藏南/阿鲁纳恰尔地块（map_regions.json region 43）归中国 710：
			# 对应原版 ILoveSuckCocks() 的 parts 重绘（data.arunachal_status>=2 分支），
			# 战争胜利已由月度结算转移过一次，此处幂等补执行（读档后覆盖仍在）。
			if GameManager != null:
				game.set_map_region_owner([43], 710)
			context["result_text"] = tr(TXT_R0)




func _disable_blank(opt: EventOption) -> void:
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_443_recover_arunachal.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_443",
	"num": 443,
	"priority": 44300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_443_recover_arunachal.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
