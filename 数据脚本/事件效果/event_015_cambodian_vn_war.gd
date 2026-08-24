extends "res://数据脚本/event_script_base.gd"

## 原作 Event15.cs：柬越战争。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10134（!vietnampeace && !event_done[15] && 日期>=1978.12.25）。
##    vietnampeace 由 event_452 成功和解时 set_flag("vietnampeace", true) 表达；
##    .tres 已加 NOT_HAS_FLAG("vietnampeace")，避免和解后仍触发战争。
##  - party_change[2]=1f（派系支持缓冲）：端口无等价 → 跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_start_war1()
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_opt_stand_by(context)
	elif opt == 1:
		_opt_support(context)


# 所有选项共用：启动战争 1（Event15.cs ResultsOfEvents 开头无条件部分）
func _start_war1() -> void:
	if ws.wars.size() <= 1:
		return
	var war := ws.wars[1]
	war.name_war = "柬埔寨－越南战争"
	war.is_going = true
	war.side1 = "柬埔寨"
	war.side2 = "越南"
	war.ussr_side = GameConstants.WarSide.SIDE2


# 选项0：我们无能为力（Event15.cs result 0）
func _opt_stand_by(context: Dictionary) -> void:
	ws.influence_prc -= 10
	if ws.wars.size() > 1:
		ws.wars[1].infl1 = 300
		ws.wars[1].infl2 = 700
	var cambodia := ws.get_country_by_legacy_index(23)
	var stab1: bool = cambodia != null and cambodia.stab == 1
	if not stab1:
		context["result_text"] = tr("event.script.event_015_cambodian_vn_war.i0")
	else:
		context["result_text"] = tr("event.script.event_015_cambodian_vn_war.i1")


# 选项1：支持民主柬埔寨（Event15.cs result 1）
func _opt_support(context: Dictionary) -> void:
	if d.size() > W.I_AGENTS:
		d.agents -= 30
	if ws.wars.size() > 1:
		ws.wars[1].infl1 = 450
		ws.wars[1].infl2 = 550
	context["result_text"] = tr("event.script.event_015_cambodian_vn_war.i2")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_015_cambodian_vn_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "cambodian_vietnam_war",
	"num": 15,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1978.12.25"}, {"t": "NOT_HAS_FLAG", "key": "vietnampeace"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "ANY", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 4}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "stab", "v": 1, "target": "23"}]}, {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 3}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "stab", "v": 1, "target": "23"}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
