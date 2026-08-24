extends "res://数据脚本/event_script_base.gd"

## 原作 Event671.cs：朋友来了有美酒（中欧823计划，四选项）。
## 触发：DiploButtonScript.cs:12361 —— 外交按钮 1063，手动触发。
## 差异：prcinfl→prc_influence；science[12]→techs.unlocked[12]；选项3 event_done[671]=false→skip_mark_done。

const TXT_OPT0_DIS_DONE := "event.script.event_671_friend_wine.c0"
const TXT_OPT0_DIS_NO := "event.script.event_671_friend_wine.c1"
const TXT_OPT1_DIS_DONE := "event.script.event_671_friend_wine.c2"
const TXT_OPT1_DIS_NO := "event.script.event_671_friend_wine.c3"
const TXT_OPT2_DIS := "event.script.event_671_friend_wine.c4"
const TXT_R0_FMT := "event.script.event_671_friend_wine.c5"
const TXT_R1_FMT := "event.script.event_671_friend_wine.c6"
const TXT_R2_FMT := "event.script.event_671_friend_wine.c7"
const TXT_R3 := "event.script.event_671_friend_wine.c8"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var france := ws.get_country_by_legacy_index(21)
	var west_germany := ws.get_country_by_legacy_index(16)
	var east_germany := ws.get_country_by_legacy_index(17)
	var luxemburg := ws.get_country_by_legacy_index(0)
	if _tech(12) and _res(W.I_INDUSTRY) >= 800 and france != null and france.prc_influence == 0:
		_enable(opt[0], event_def.options[0].text)
	elif france != null and france.prc_influence != 0:
		_disable(opt[0], tr(TXT_OPT0_DIS_DONE))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_NO))
	var germany_unified := (west_germany != null and west_germany.parts.size() > 0 and west_germany.parts[0]) \
		or (east_germany != null and east_germany.parts.size() > 0 and east_germany.parts[0])
	if germany_unified and west_germany != null and west_germany.prc_influence == 0:
		_enable(opt[1], event_def.options[1].text)
	elif west_germany != null and west_germany.prc_influence != 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_DONE))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_NO))
	if luxemburg == null or luxemburg.prc_influence == 0:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var france := ws.get_country_by_legacy_index(21)
	var west_germany := ws.get_country_by_legacy_index(16)
	var luxemburg := ws.get_country_by_legacy_index(0)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = _fmt(tr(TXT_R0_FMT))
			_add(W.I_BUDGET, -150)
			if france != null:
				france.prc_influence = 1
		1:
			context["result_text"] = _fmt(tr(TXT_R1_FMT))
			_add(W.I_BUDGET, -300)
			_add(W.I_INDUSTRY, -400)
			if west_germany != null:
				west_germany.prc_influence = 1
		2:
			context["result_text"] = _fmt(tr(TXT_R2_FMT))
			_add(W.I_BUDGET, -150)
			if luxemburg != null:
				luxemburg.prc_influence = 12
		3:
			context["result_text"] = tr(TXT_R3)
			# 原版 :101 event_done[671]=false → 跳过完成标记
			context["skip_mark_done"] = true


func _fmt(s: String) -> String:
	return s.replace("{0}{1}", _leader_name())


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _tech(idx: int) -> bool:
	return ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_671_friend_wine.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_671",
	"num": 671,
	"priority": 67100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_671_friend_wine.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
