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
		context["result_text"] = "你在全国直播的情况下亲自与北京的抗议者进行了交谈，并承诺尽一切努力改变政策，考虑到所有公民的利益，最后建立真正的民主机制（不过，你并不急于执行）。不过看来人民已经对你的承诺感到了厌倦，他们对你态度冷漠并要求你直接辞职。对你失去了信心的党最后决定罢免你并将你逮捕，之后他们重新组织了一个新的政府领导全国并开始筹划全国选举，而你只能在监狱里蹲着。"
		d[W.I_PARTY_SUPPORT] = 0
		d[W.I_PEOPLE_SUPPORT] = 0
		GameManager.queue_ending_after_event(1)
		return

	context["result_text"] = "你亲自与全国各地的抗议者进行了交谈。你承诺将尽一切努力改变政策，考虑到所有公民的利益，并建立真正的民主机制。（不过，你并不急于执行）。看来你已经成功地说服了人民，抗议活动正在慢慢地减少。"
	d[W.I_PEOPLE_SUPPORT] -= 150
	d[W.I_THOUGHT_FREEDOM] -= 150
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
