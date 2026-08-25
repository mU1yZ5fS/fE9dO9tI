extends "res://数据脚本/event_script_base.gd"

## 原作 Event590.cs：红色的所罗门雄狮（埃塞门格斯图世袭，二选项）。
## 触发：DiploButtonScript.cs:10794 —— number_event = 590（外交按钮手动触发），无自动触发。
## 差异：
##  - <color> 标签去除（既有约定）；name → chinese_name（含 \n 保留）；
##  - EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；Torg → 对华贸易；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances；
##  - event_done[590]=false → completed_event_ids.erase("event_590")（同 Event440 约定）。




const TXT_R0_A := "event.script.event_590_red_solomon_lion.c0"
const TXT_R0_B := "event.script.event_590_red_solomon_lion.c1"
const TXT_R0_C := "event.script.event_590_red_solomon_lion.c2"
const TXT_R1 := "event.script.event_590_red_solomon_lion.c3"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c41 := ws.get_country_by_legacy_index(41)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0_A) + _leader_name() + tr(TXT_R0_B) + _leader_name() + tr(TXT_R0_C)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if c41 != null:
				c41.chinese_name = "埃塞俄比亚\n民主主义人民共和国"
				c41.government = GameConstants.Government.AUTHORITARIAN
				c41.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				_establish_prochina(c41)
				c41.set_tag("对华贸易", true)
				_join_alliances(c41)
			context["result_text"] = text
		1:
			ws.completed_event_ids.erase("event_590")
			context["result_text"] = tr(TXT_R1)


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_590_red_solomon_lion.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_590",
	"num": 590,
	"priority": 59000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_590_red_solomon_lion.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
