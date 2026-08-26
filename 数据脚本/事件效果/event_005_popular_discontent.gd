extends "res://数据脚本/event_script_base.gd"

## 原作 Results_text.cs:733-885，事件5选项1的成功/失败与政党重排分支。


func execute(context: Dictionary) -> void:
	if int(context.get("option_index", -1)) != 0:
		return
	if not _bind_world():
		return
	if d.people_support <= 700 or d.party_support < 500:
		context["result_text"] = tr("event.script.event_005_popular_discontent.i0")
		d.party_support = 0
		d.people_support = 0
		game.queue_ending_after_event(1)
		return

	context["result_text"] = tr("event.script.event_005_popular_discontent.i1")
	d.people_support -= 150
	d.thought_freedom -= 150
	d.party_support -= 100
	if ws.factions.size() > FactionData.CONSERVATIVE:
		ws.factions[FactionData.CONSERVATIVE].is_enabled = true

	if d.party_system >= GameConstants.PartySystem.ONE_PARTY_DICTATORSHIP and d.party_system <= GameConstants.PartySystem.NEW_DEMOCRACY:
		_reorganize_parties()
		if d.size() > 53:
			d.party_ban_count = 0
		ws.set_flag("election_due", true)
	elif d.party_system < GameConstants.PartySystem.CONSOCIATIONALISM:
		d.party_system += 1
	elif d.press_policy < 19:
		d.press_policy += 1


func _reorganize_parties() -> void:
	if ws.factions.size() <= FactionData.CONSERVATIVE:
		return
	var transferred := 0
	for i in ws.factions.size():
		var faction := ws.factions[i]
		faction.ideology = maxi(faction.ideology, 0)
		if i != FactionData.CONSERVATIVE:
			faction.is_ally = false
		if faction.is_enabled and i != FactionData.CONSERVATIVE and faction.support > 0:
			@warning_ignore("integer_division")
			var first_transfer := int(faction.support / 2)
			faction.support -= first_transfer
			faction.ideology -= first_transfer
			transferred += first_transfer
			@warning_ignore("integer_division")
			var second_transfer := int(faction.support / 4)
			faction.support -= second_transfer
			faction.ideology -= second_transfer
			transferred += second_transfer
		elif not faction.is_enabled:
			faction.is_enabled = true
	var ruling := ws.factions[FactionData.CONSERVATIVE]
	ruling.support += transferred
	ruling.ideology += transferred



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_005_popular_discontent.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "popular_discontent",
	"num": 5,
	"trigger": [{"t": "ALL", "c": [{"t": "ANY", "c": [{"t": "RESOURCE_DIFFERENCE_AT_MOST", "key": "people_support", "v": -51, "target": "thought_freedom"}, {"t": "RESOURCE_AT_MOST", "key": "people_support", "v": 99}, {"t": "RESOURCE_AT_LEAST", "key": "thought_freedom", "v": 1200}]}, {"t": "NOT", "c": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_444"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_444"}]}]}, {"t": "NOT", "c": [{"t": "PREV_EVENT_RESULT_IS", "ref": "event_503"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "ANY", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "party_system", "v": 9}, {"t": "RESOURCE_NOT_EQUALS", "key": "press_policy", "v": 19}]}, "fx": [{"t": "ADD_RESOURCE", "key": "party_support", "v": -50}, {"t": "ADD_RESOURCE", "key": "people_support", "v": 100}, {"t": "ADD_RESOURCE", "key": "diplo", "v": -50}, {"t": "SET_RESOURCE", "key": "press_policy", "v": 19, "if": {"t": "RESOURCE_EQUALS", "key": "party_system", "v": 9}}, {"t": "SET_RESOURCE", "key": "party_system", "v": 9, "if": {"t": "RESOURCE_NOT_EQUALS", "key": "party_system", "v": 9}}, {"t": "ADD_ALL_POLITICIAN_LOYALTY", "v": -100}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 100}, "fx": [{"t": "ADD_RESOURCE", "key": "thought_freedom", "v": -150}, {"t": "ADD_RESOURCE", "key": "army", "v": -100}, {"t": "ADD_RESOURCE", "key": "diplo", "v": 50}, {"t": "SET_RESOURCE", "key": "protest_repression", "v": 9}, {"t": "ADD_POLITICIAN_LOYALTY_BY_PERSONALITY", "key": "3", "v": -100}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "people_support", "v": 501}, "fx": [{"t": "ADD_RESOURCE", "key": "thought_freedom", "v": -200}, {"t": "ADD_RESOURCE", "key": "party_support", "v": -50}, {"t": "ADD_RESOURCE", "key": "diplo", "v": 20}, {"t": "ADD_RESOURCE", "key": "people_support", "v": -300}, {"t": "ADD_POLITICIAN_LOYALTY_BY_PERSONALITY", "key": "2,3", "v": -100}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 150}, "fx": [{"t": "ADD_RESOURCE", "key": "agents", "v": -150}, {"t": "ADD_RESOURCE", "key": "thought_freedom", "v": -150}, {"t": "ADD_RESOURCE", "key": "people_support", "v": 100}]}],
}
