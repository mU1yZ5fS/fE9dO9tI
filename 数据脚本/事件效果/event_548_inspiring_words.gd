extends "res://数据脚本/event_script_base.gd"

## 原作 Event548.cs：指点江山，激扬文字！（革命国际，3选项）。
## 触发：无自动触发（GlobalScript.cs:30 决议 StartEvent(548)）。
## 差异：描述/结果由 prepare/execute 动态拼领袖姓名；is_gkchp→ws.get_flag；
##   isRIM→has_tag("rim")；ingamewars[23] 若未建则仅改 data.italy_hot_autumn_route。

const TXT_DESC := "event.script.event_548_inspiring_words.c0"
const TXT_R0 := "event.script.event_548_inspiring_words.c1"
const TXT_R0_TAIL := "event.script.event_548_inspiring_words.c2"
const TXT_R1 := "event.script.event_548_inspiring_words.c3"
const TXT_R1_TAIL := "event.script.event_548_inspiring_words.c4"
const TXT_R2 := "event.script.event_548_inspiring_words.c5"
const TXT_R2_TAIL := "event.script.event_548_inspiring_words.c6"
const TXT_R2_MID := "event.script.inspiring_words.txt_r2_mid"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _leader_name() + tr(TXT_DESC)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var _c1 := ws.get_country_by_legacy_index(1)
	if ws.get_flag("is_gkchp"):
		for c in ws.countries:
			var i := c.原版序号
			if i != 46 and (i < 71 or i > 83 or i == 80) and i != 94 and i != 167 					and (c.sub_government == GameConstants.SubGovernment.MAOIST or c.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL or c.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST) 					and not c.has_tag("sev") and not c.has_tag("ovd") and c.has_tag("亲中") 					and (c.puppet_of < 0 or i == 38):
				c.set_tag("rim", true)
	else:
		for c in ws.countries:
			var i := c.原版序号
			if i != 46 and (i < 71 or i > 83 or i == 80) and i != 94 and i != 167 					and world_is_socialism(c) and c.sub_government != GameConstants.SubGovernment.SOVIET_STYLE and c.sub_government != GameConstants.SubGovernment.TROTSKYIST 					and not c.has_tag("sev") and not c.has_tag("ovd") and c.has_tag("亲中") 					and (c.puppet_of < 0 or i == 38):
				c.set_tag("rim", true)
	var n := _leader_name()
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			context["result_text"] = tr(TXT_R0) + n + tr(TXT_R0_TAIL)
		1:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			context["result_text"] = tr(TXT_R1) + n + tr(TXT_R1_TAIL)
		2:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			context["result_text"] = tr(TXT_R2) + n + tr(TXT_R2_TAIL) + n + tr(TXT_R2_MID)


func world_is_socialism(c: CountryData) -> bool:
	if c == null:
		return false
	return c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_548_inspiring_words.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_548",
	"nodesc": true,
	"num": 548,
	"priority": 54800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_548_inspiring_words.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
