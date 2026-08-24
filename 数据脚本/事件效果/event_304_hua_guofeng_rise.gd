## 原作 Event304.cs：华国锋的崛起（逼华国锋下台，两选项）。
## 触发：全目录搜索无 this_num_event = 304 / Reset(304)；链外 REST 段，原版无自动条件。
## 差异：faction_leader[1..3]→factions[i].leader_index；KillPerson→game.kill_politician；
##  LeaderAsset/MoneyLevel/ServeRMB 显示字段跳过；文本来自 Events_text_en 索引 57-62。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0 := "event.script.event_304_hua_guofeng_rise.c0"
const TXT_R1 := "event.script.event_304_hua_guofeng_rise.c1"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			var num := -1
			if ws.factions.size() > 1 and ws.factions[1] != null and ws.factions[1].leader_index < 100:
				num = ws.factions[1].leader_index
			elif ws.factions.size() > 2 and ws.factions[2] != null and ws.factions[2].leader_index < 100:
				num = ws.factions[2].leader_index
			elif ws.factions.size() > 3 and ws.factions[3] != null and ws.factions[3].leader_index < 100:
				num = ws.factions[3].leader_index
			if num >= 0 and num < ws.politicians.size():
				var p := ws.politicians[num]
				if p != null:
					_set_leader_from(p)
					game.kill_politician(num)
					_set_mod_active(65, false)
			# LeaderAsset/MoneyLevel/ServeRMB 为显示字段，跳过
			context["result_text"] = tr(TXT_R1)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_304_hua_guofeng_rise.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_304",
	"num": 304,
	"priority": 30400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_304_hua_guofeng_rise.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
