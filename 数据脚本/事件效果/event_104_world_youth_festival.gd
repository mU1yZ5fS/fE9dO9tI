extends "res://数据脚本/event_script_base.gd"

## 原作 Event104.cs：第十二届世界青年学生节（单选项，动态长文案）。
## 触发：TimeScript.cs:10868-10874 ——
##   (月>=7 且 年>=1985 或 年>=1986) && event_done[541] && resultOfEvents[541]==0
##   && IsSocialism(true,1)（c1 社会主义用 ANY(gov==1, sub==0) 表达）。
## 差异：
##  - 原版 kolvo_variant=1，result1/2 不可达（死分支），仅移植 result0。
##  - 文案按 USSR now_leader(6戈尔巴乔夫/3谢尔比茨基/5格里申/4罗曼诺夫/8利加乔夫)、
##    dolshnost[0]（politics_positions[0]）、modifies[6] 逐段拼接。

const TXT_OPEN := "event.script.event_104_world_youth_festival.c0"

const TXT_LEADERS := "event.script.event_104_world_youth_festival.c1"

const TXT_PREMIER := "event.script.event_104_world_youth_festival.c2"

const TXT_PROTEST_MID := "event.script.event_104_world_youth_festival.c3"

const TXT_PROTEST_TAIL := "event.script.event_104_world_youth_festival.c4"

const TXT_CLOSING := "event.script.event_104_world_youth_festival.c5"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		var leader_name := _leader_name()
		var text := tr(TXT_OPEN) + leader_name
		var ussr_leader := _empire_leader(1)
		var ussr_name := ""
		match ussr_leader:
			6:
				ussr_name = "戈尔巴乔夫"
			3:
				ussr_name = "谢尔比茨基"
			5:
				ussr_name = "格里申"
			4:
				ussr_name = "罗曼诺夫"
			8:
				ussr_name = "利加乔夫"
		if ussr_name != "":
			text += tr(TXT_LEADERS) + ussr_name + "。我国的学生代表向他们献上了鲜花和拥抱。国务院总理"
		var premier := _premier_name()
		text += premier + tr(TXT_PREMIER)
		if not _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
			text += tr(TXT_PROTEST_MID) + leader_name + tr(TXT_PROTEST_TAIL)
		text += tr(TXT_CLOSING)
		_add(W.I_THOUGHT_FREEDOM, 20)
		_add(W.I_PEOPLE_SUPPORT, 80)
		ws.influence_prc += 10
		_add(W.I_PARTY_SUPPORT, 50)
		_add_relation(EmpireData.USSR, 100)
		_add_relation(EmpireData.USA, 50)
		context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## 原版 dolshnost[0]（总理槽）!=150/200 时用槽内政治家姓名，否则用领袖姓名。
func _premier_name() -> String:
	if ws.politics_positions.size() > 0:
		var idx := ws.politics_positions[0]
		if idx != 150 and idx != 200 and idx >= 0 and idx < ws.politicians.size():
			var p: PoliticianData = ws.politicians[idx]
			if p != null and p.name_display != "":
				return p.name_display
	return _leader_name()


func _empire_leader(empire_index: int) -> int:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		return ws.empires[empire_index].current_leader
	return -1


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active







# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_104_world_youth_festival.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_104",
	"num": 104,
	"priority": 10400,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.7.1"}, {"t": "PREV_EVENT_DONE", "ref": "event_541"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_541"}, {"t": "ANY", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 1, "target": "1"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "target": "1"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
