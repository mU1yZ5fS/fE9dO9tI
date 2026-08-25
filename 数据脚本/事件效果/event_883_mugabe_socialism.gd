extends "res://数据脚本/event_script_base.gd"

## 原作 Event883.cs：潮水如此涨涨落落（穆加贝社会主义建设，两选项）。
## 触发：全目录 grep 仅见 DiploButtonScript.cs:10806 外交界面 selected_country==127
##   手动 number_event=883，原版无自动条件（外交按钮手动触发），故 trigger_conditions=[]。
## 差异：
##  - 结果0 插入领袖姓名用 name_display（names1/names2 组合）；
##  - JoinAllOurAlliances(true)→_join_our_alliances；soc_stab→social_stability；
##  - 原版 event_done[883]=false（允许再触发）在 Godot 中 _mark_done 于 execute 后写回，
##    无法以同样方式复位，仅注释保留差异。

const TXT_R0_PRE := "event.script.event_883_mugabe_socialism.c0"
const TXT_R0_POST := "event.script.event_883_mugabe_socialism.c1"
const TXT_R1 := "event.script.event_883_mugabe_socialism.c2"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var zimbabwe := ws.get_country_by_legacy_index(127)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var leader_name := _leader_name()
			context["result_text"] = tr(TXT_R0_PRE) + leader_name + tr(TXT_R0_POST)
			if zimbabwe != null:
				zimbabwe.government = GameConstants.Government.AUTHORITARIAN
				zimbabwe.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				zimbabwe.social_stability = 1000
				_join_our_alliances(zimbabwe)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
		1:
			context["result_text"] = tr(TXT_R1)
			# 原版 event_done[883]=false；本系统 fire_only_once=true 且完成后写标记，
			# 此分支无法真正复位，保留注释。


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## JoinAllOurAlliances(true) 核心联盟跟随逻辑（同 Event713 约定）。
func _join_our_alliances(c: CountryData) -> void:
	if c == null:
		return
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)







# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_883_mugabe_socialism.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_883",
	"num": 883,
	"priority": 88300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_883_mugabe_socialism.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
