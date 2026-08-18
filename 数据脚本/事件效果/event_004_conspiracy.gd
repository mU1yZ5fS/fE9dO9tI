extends "res://数据脚本/event_script_base.gd"

## 原作 Event4.cs：党内阴谋四选项。政治家清洗循环 + 选项0胜负(惨败进结局2) + 党支持分段。
## 差异：opt0 胜利条件 LeaderProperty[2] OR 支端口无等价 → 丢弃，仅留 party_support>500 && 忠诚>600者>=4。
##       惨败原 data[35]=2 → queue_ending_after_event(2)「军事政变」(语义映射)。
##       opt3 原依 modifies[3] 有两段文案/不同扣值 → 取默认(未激活)分支。event_done[444] 移植说明 → 门槛仅 people_support>=700。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))

	if opt == 0:
		_option_debate(context)
	elif opt == 1:
		d[W.I_PEOPLE_SUPPORT] -= 50
		d[W.I_AGENTS] -= 100
		_party_support_segmented()
		_purge_politicians(-200)
		context["result_text"] = "忠诚于你的特工在大会开始之前就成功的控制了刚到北京的阴谋者们并将他们送去蹲大牢去了。在大会中，你在他们缺席的情况下批评了他们，获得了大部分与会代表的支持。但是除去党的高阶成员不是那么简单的……"
	elif opt == 2:
		d[W.I_PEOPLE_SUPPORT] -= 80
		_party_support_segmented()
		d[W.I_ARMY] -= 100
		_purge_politicians(-300)
		context["result_text"] = "忠诚于你的军官在大会开始之前就成功的控制了刚到北京的阴谋者们并将他们送去蹲大牢去了。在士兵在场的大会中，你在他们缺席的情况下批评了他们，获得了大部分与会代表的支持。但是除去党的高阶成员不是那么简单的……"
	elif opt == 3:
		_party_support_segmented()
		d[W.I_PEOPLE_SUPPORT] -= 200
		d[W.I_LIVING] -= 70
		_purge_politicians(-100)
		context["result_text"] = "你通过媒体呼吁人民支持你，保护你的权力。在大会开始之前。忠诚于你的群众参加了声援你的示威游行，并开始向你的对手控制的部门发起攻击。认识到了他们处于劣势之后，反对派们决定撤退，最后大会保卫了你的权力，但是人们已经厌倦了类似于文化大革命的运动。"


## 选项0：论战胜负（Event4.cs:61-95）
func _option_debate(context: Dictionary) -> void:
	var loyal_count := 0
	for p in ws.politicians:
		if p != null and p.loyalty > 600:
			loyal_count += 1
	# 差异：丢 LeaderProperty[2] OR 支；原 data[1]>500 && num>=4
	var win: bool = d[W.I_PARTY_SUPPORT] > 500 and loyal_count >= 4
	if win:
		d[W.I_PARTY_SUPPORT] += 50
		_purge_politicians(-100)
		context["result_text"] = "在密谋者讲出他们的控告前你就用批评和反控告批判了他们。大多数出席全会的党员支持你，密谋者只得退却。"
	else:
		d[W.I_PARTY_SUPPORT] = 0
		d[W.I_PEOPLE_SUPPORT] = 0
		context["result_text"] = "在密谋者讲出他们的控告前你就用批评和反控告批判了他们。但是，你的名誉显然不大好，大多数党员受够了你的领导。大多数出席全会的党员支持了密谋者，你被解职并被踢出中央委员会，丢到了一个偏远的清水衙门。"
		GameManager.queue_ending_after_event(2)   # 原 data[35]=2「军事政变」


## 党支持分段（Event4.cs:102 整数除法逐字）
func _party_support_segmented() -> void:
	@warning_ignore("integer_division")
	var threshold: int = 300 + d[W.I_THOUGHT_FREEDOM] / 5 - (d[W.I_PEOPLE_SUPPORT] - 500) / 5
	if d[W.I_PARTY_SUPPORT] <= threshold:
		d[W.I_PARTY_SUPPORT] += 400
	else:
		d[W.I_PARTY_SUPPORT] += 50


## 政治家清洗循环（Event4.cs:80 复合 trait 判定，逐字端口化）
## 原 traits[3]→背景 traits[1]→性格alignment traits[2]→特殊 is_sledstvie→调查中 sled_slej→调查者
func _purge_politicians(loyalty_delta: int) -> void:
	for p in ws.politicians:
		if p == null:
			continue
		var a := (
			(p.loyalty < 1000 and p.trait_background == 28)
			or (p.loyalty < 800 and p.trait_alignment == 41)
			or (p.loyalty < 300 and (p.trait_special == 16 or p.trait_special == 35))
			or p.you_fall
			or (p.loyalty < 150 and p.trait_special != 9 and p.trait_special != 37)
			or (p.loyalty < 50 and (p.trait_special == 9 or p.trait_special == 37))
		)
		var b := (
			p.trait_special != 17 and p.trait_special != 19
			and p.trait_alignment != 40 and not p.is_under_investigation
		)
		if a and b:
			p.power -= 100
			p.loyalty += loyalty_delta
			p.is_under_investigation = true
			p.investigator_index = 1
