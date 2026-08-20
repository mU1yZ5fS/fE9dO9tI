extends "res://数据脚本/event_script_base.gd"

## 原作 Event625.cs：莫桑比克，光明到来？（莫桑比克内战结算，单选项）。
## 触发：TimeScript.cs:7160 —— (c126.level_of_unstab>=1000 || c126.level_of_unstab<=0) && !event_done[625] && c126.parts[0]；
##  parts/level_of_unstab ExprNode 不支持 → trigger_script。
## 差异：描述与结果按 level_of_instability 分支；TextOfEvents 的 parts[0]=false 在 prepare 中复刻。

const TXT_DESC_A := "随着莫桑比克全国抵抗运动的最后一个据点被拔除，莫桑比克解放阵线党终于控制了全国。抵运的残军狼狈撤往了南非。"
const TXT_DESC_B := "随着莫桑比克解放阵线党的最后一个据点被拔除，莫桑比克抵抗运动终于控制了全国。解阵的残军撤往了坦桑尼亚和赞比亚。"
const TXT_R0_A := "莫解阵在莫桑比克首都马普托举行了盛大的阅兵仪式，庆祝着属于莫桑比克人民的胜利。在内战中犯下重大罪行的抵运成员被公审处决。为了报复南非和支持南部的同志，莫桑比克加大了对阿扎尼亚泛非主义大会、非洲人国民大会和南非共产党的支持。没有了内部的大敌，莫解阵终于能够更加专注于人民民主革命和国家建设，并借鉴"
const TXT_R0_MID := "中国和"
const TXT_R0_B := "苏联的经验开展工业化和进行反部落主义的文化革命。"
const TXT_R0_FAIL := "在南非的支持下，莫桑比克全国抵抗运动终于赢得内战，莫解阵党被查禁，新政权开始对前政权的国有资产和集体资产的劫收式私有化——在城市，国有企业直接成为了抵运高官的私有物，而在乡村，部落酋长的权力也再度膨胀，他们开始霸占公社村，将其据为己有，合作社也被解散。这个组织似乎并不像他们自己所宣扬的那样，是反共的民主斗士——从该国传来了抵运犯下各类暴行的消息。在电视上，被俘的莫解阵的高官被脱光衣服，割去身体的各种部位后被绑在海滩的柱子上暴晒；幸存的莫解阵成员撤入了坦桑尼亚，在坦桑尼亚的支持下进行着最后的游击抵抗。这个被CIA称为“非洲红色高棉”的组织的胜利让国际观察者感到非常不安，新的政府几乎只得到了南非和联邦德国的承认，甚至在美国，也只有最强硬的保守派才愿意承认这个政权……与此同时，在莫桑比克，由于抵运支持基督教，事实上的对于宗教自由的剥夺开始了，这无疑激起了海岸线一带穆斯林人口的不满，让我们看看接下来局势会如何发展……"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null:
		return
	_bind_world()
	var mozambique := world.get_country_by_legacy_index(126)
	if mozambique == null:
		return
	if mozambique.level_of_instability >= 1000:
		event_def.description = TXT_DESC_A
	else:
		event_def.description = TXT_DESC_B
	_set_part(mozambique, 0, false)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var mozambique := _country(126)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if mozambique != null and mozambique.level_of_instability >= 1000:
				var text := TXT_R0_A
				if ws.is_socialism(china, true) and _res_ev("event_623") != 1:
					text += TXT_R0_MID
				text += TXT_R0_B
				context["result_text"] = text
				if mozambique != null:
					mozambique.government = GameConstants.Government.SOCIALIST
					mozambique.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				if ws.is_socialism(china, true) and _res_ev("event_623") != 1:
					if mozambique != null:
						_leave_alliances(mozambique)
						mozambique.set_tag("对华贸易", true)
						mozambique.set_tag("亲中", true)
					ws.influence_prc += 30
					_add_relation(EmpireData.USA, -50)
				_add_relation(EmpireData.USA, -50)
				_add_power(EmpireData.USA, -30)
			else:
				context["result_text"] = TXT_R0_FAIL
				if mozambique != null:
					mozambique.government = GameConstants.Government.AUTHORITARIAN
					mozambique.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					_leave_alliances(mozambique)
					mozambique.puppet_of = 131
				if _res_ev("event_623") == 1:
					if mozambique != null:
						mozambique.set_tag("对华贸易", true)
					_add_relation(EmpireData.USA, 100)
				_add_power(EmpireData.USA, 30)



func evaluate(world: WorldState) -> bool:

	if world == null:
		return false
	var mozambique := world.get_country_by_legacy_index(126)
	if mozambique == null or not (mozambique.parts.size() > 0 and mozambique.parts[0]):
		return false
	return mozambique.level_of_instability >= 1000 or mozambique.level_of_instability <= 0






func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = -1


