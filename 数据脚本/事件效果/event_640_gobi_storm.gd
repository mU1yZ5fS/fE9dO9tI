extends "res://数据脚本/event_script_base.gd"

## 原作 Event640.cs：打倒社帝马前卒！（中蒙战争，单选项）。
## 触发：DiploButtonScript.cs:12234 —— 外交按钮 1052，selected_country==9，手动触发。
## 差异：ingamewars[69] 已有 war_69 WarDef，仍按 start_war 参数覆盖；
##   usa_place=0（仅 c51.Torg 时）→ WarData.usa_side = GameConstants.WarSide.SIDE1；relres→global_flags。

const TXT_DESC_PRE := "event.script.event_640_gobi_storm.c0"
const TXT_DESC_TAIL := "event.script.event_640_gobi_storm.c1"
const TXT_R_PRE := "event.script.event_640_gobi_storm.c2"
const TXT_R_POST := "event.script.event_640_gobi_storm.c3"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	event_def.description = tr(TXT_DESC_PRE) + _leader_name() + tr(TXT_DESC_TAIL)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = tr(TXT_R_PRE) + _leader_name() + tr(TXT_R_POST)
	# 原版 ingamewars[69]：中蒙战争，中国(650) vs 蒙古(350)，SovietSupportDefender
	game.start_war(69, "中华人民共和国", "蒙古人民共和国", 650, 350, -1, 2)
	if ws.wars.size() > 69 and ws.wars[69] != null:
		ws.wars[69].name_war = "中蒙战争"
	var usa := ws.get_country_by_legacy_index(51)
	if usa != null and usa.has_tag("对华贸易"):
		if ws.wars.size() > 69 and ws.wars[69] != null:
			ws.wars[69].usa_side = GameConstants.WarSide.SIDE1
	var mongolia := ws.get_country_by_legacy_index(9)
	if mongolia != null:
		mongolia.set_tag("对华贸易", false)
		mongolia.set_tag("亲苏", true)
	var ussr := ws.get_country_by_legacy_index(7)
	if ussr != null:
		ussr.set_tag("对华贸易", false)
	ws.set_flag("relres", false)
	_add_relation(EmpireData.USSR, -1000)
	_add_power(EmpireData.USSR, -50)
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_ARMY, -800)
	_add(W.I_BUDGET, -200)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_640_gobi_storm.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_640",
	"nodesc": true,
	"num": 640,
	"priority": 64000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_640_gobi_storm.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
