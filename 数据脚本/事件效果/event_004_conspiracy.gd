extends "res://数据脚本/event_script_base.gd"

## 原作 Event4.cs：党内阴谋四选项。政治家清洗循环 + 选项0胜负(惨败进结局2) + 党支持分段。
## 差异：opt0 胜利条件 LeaderProperty[2] OR 支端口无等价 → 丢弃，仅留 party_support>500 && 忠诚>600者>=4。
##       惨败原 data.ending_route=2 → queue_ending_after_event(2)「军事政变」(语义映射)。
##       opt3 原依 modifies[3] 有两段文案/不同扣值 → 取默认(未激活)分支。event_done[444] 移植说明 → 门槛仅 people_support>=700。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))

	if opt == 0:
		_option_debate(context)
	elif opt == 1:
		d.people_support -= 50
		d.agents -= 100
		_party_support_segmented()
		_purge_politicians(-200)
		context["result_text"] = tr("event.script.event_004_conspiracy.i0")
	elif opt == 2:
		d.people_support -= 80
		_party_support_segmented()
		d.army -= 100
		_purge_politicians(-300)
		context["result_text"] = tr("event.script.event_004_conspiracy.i1")
	elif opt == 3:
		_party_support_segmented()
		d.people_support -= 200
		d.living_standard -= 70
		_purge_politicians(-100)
		context["result_text"] = tr("event.script.event_004_conspiracy.i2")


## 选项0：论战胜负（Event4.cs:61-95）
func _option_debate(context: Dictionary) -> void:
	var loyal_count := 0
	for p in ws.politicians:
		if p != null and p.loyalty > 600:
			loyal_count += 1
	# 差异：丢 LeaderProperty[2] OR 支；原 data.party_support>500 && num>=4
	var win: bool = d.party_support > 500 and loyal_count >= 4
	if win:
		d.party_support += 50
		_purge_politicians(-100)
		context["result_text"] = tr("event.script.event_004_conspiracy.i3")
	else:
		d.party_support = 0
		d.people_support = 0
		context["result_text"] = tr("event.script.event_004_conspiracy.i4")
		game.queue_ending_after_event(2)   # 原 data.ending_route=2「军事政变」


## 党支持分段（Event4.cs:102 整数除法逐字）
func _party_support_segmented() -> void:
	@warning_ignore("integer_division")
	var threshold: int = 300 + d.thought_freedom / 5 - (d.people_support - 500) / 5
	if d.party_support <= threshold:
		d.party_support += 400
	else:
		d.party_support += 50


## 政治家清洗循环（Event4.cs:80 复合 trait 判定，逐字端口化）
## 原 traits[3]→背景 traits[1]→性格alignment traits[2]→特殊 is_sledstvie→调查中 sled_slej→调查者
func _purge_politicians(loyalty_delta: int) -> void:
	for p in ws.politicians:
		if p == null:
			continue
		var a := (
			(p.loyalty < 1000 and p.trait_background == GameConstants.PoliticianBackground.AMBITIOUS)
			or (p.loyalty < 800 and p.trait_alignment == GameConstants.PoliticianAlignment.LOCAL_WARLORD)
			or (p.loyalty < 300 and (p.trait_special == GameConstants.PoliticianSpecial.ADVISER or p.trait_special == GameConstants.PoliticianSpecial.OPPORTUNIST))
			or p.you_fall
			or (p.loyalty < 150 and p.trait_special != GameConstants.PoliticianSpecial.PEACE and p.trait_special != GameConstants.PoliticianSpecial.AFFABLE)
			or (p.loyalty < 50 and (p.trait_special == GameConstants.PoliticianSpecial.PEACE or p.trait_special == GameConstants.PoliticianSpecial.AFFABLE))
		)
		var b := (
			p.trait_special != GameConstants.PoliticianSpecial.SHY and p.trait_special != GameConstants.PoliticianSpecial.SICKLY
			and p.trait_alignment != GameConstants.PoliticianAlignment.FENCE_SITTER and not p.is_under_investigation
		)
		if a and b:
			p.power -= 100
			p.loyalty += loyalty_delta
			p.is_under_investigation = true
			p.investigator_index = 1



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_004_conspiracy.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "congress_conspiracy",
	"num": 4,
	"notify": false,
	"once": false,
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 100}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 100}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "people_support", "v": 700}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
