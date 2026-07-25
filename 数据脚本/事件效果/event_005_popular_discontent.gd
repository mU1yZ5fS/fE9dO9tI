extends RefCounted

## 原作 Results_text.cs:733-885，事件5选项1的成功/失败与政党重排分支。
const W = preload("res://数据脚本/world_state.gd")


func execute(context: Dictionary) -> void:
	if int(context.get("option_index", -1)) != 0:
		return
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	var d := ws.数值表
	if d[W.I_PEOPLE_SUPPORT] <= 700 or d[W.I_PARTY_SUPPORT] < 500:
		context["result_text"] = ("You personally spoke to the protesters in Beijing, but people tired of promises "
				+ "demanded your resignation. The party organized your dismissal and arrest and formed a "
				+ "transitional government pending general elections.")
		GameManager.queue_ending_after_event(1)
		return

	context["result_text"] = ("You personally addressed the protesters in Beijing in a speech broadcast "
			+ "throughout the country. You promised to change policy, take the interests of all citizens "
			+ "into account and create real democratic mechanisms. The protests are gradually subsiding.")
	d[W.I_PEOPLE_SUPPORT] += 100
	d[W.I_THOUGHT_FREEDOM] -= 50
	d[W.I_PARTY_SUPPORT] -= 100
	if ws.factions.size() > FactionData.CONSERVATIVE:
		ws.factions[FactionData.CONSERVATIVE].is_enabled = true

	if d[W.I_PARTY_SYSTEM] >= 6 and d[W.I_PARTY_SYSTEM] <= 7:
		_reorganize_parties(ws)
		if d.size() > 53:
			d[53] = 0
		ws.set_flag("election_due", true)
	elif d[W.I_PARTY_SYSTEM] < 9:
		d[W.I_PARTY_SYSTEM] += 1
	elif d[W.I_PRESS_POLICY] < 19:
		d[W.I_PRESS_POLICY] += 1


func _reorganize_parties(ws: WorldState) -> void:
	if ws.factions.size() <= FactionData.CONSERVATIVE:
		return
	var transferred := 0
	for i in ws.factions.size():
		var faction := ws.factions[i]
		faction.ideology = maxi(faction.ideology, 0)
		if i != FactionData.CONSERVATIVE:
			faction.is_ally = false
		if faction.is_enabled and i != FactionData.CONSERVATIVE and faction.support > 0:
			var first_transfer := int(faction.support / 2)
			faction.support -= first_transfer
			faction.ideology -= first_transfer
			transferred += first_transfer
			var second_transfer := int(faction.support / 4)
			faction.support -= second_transfer
			faction.ideology -= second_transfer
			transferred += second_transfer
		elif not faction.is_enabled:
			faction.is_enabled = true
	var ruling := ws.factions[FactionData.CONSERVATIVE]
	ruling.support += transferred
	ruling.ideology += transferred
