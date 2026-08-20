extends "res://数据脚本/event_script_base.gd"

## 原作 Event461.cs：福尔摩沙之春（台湾统一/合作二选项）。
## 触发：DiploButtonScript.cs:11411-11415 —— this_type==1005 外交按钮手动触发；
##   按项目约定 trigger_conditions=[]（仅定义，待外交入口接入）。
## 差异：LeaveAlliances() 按 Country.cs:89-115 清标签+puppet_of = GameConstants.LegacySlot.NONE；
##   name→chinese_name；isOVD/isSEV/isRIM/econ/okb→set_tag。

const TXT_OPT0_DIS := "台湾左派的力量太弱了！"
const TXT_R0 := "随着我们对台湾当局施加了巨大的压力，制裁和禁运迅速压垮了这个本就没有什么自给能力的小岛。在一次对抗政府的示威中。我们的特务借机煽风点火，在“你可听见人民的呼声”的歌声中，军警拒绝了接受蒋经国总统关于对人民开枪的指令，事实上发生了哗变。感到自己时日无多的蒋经国收拾了细软，逃往美国檀香山。\n我们的努力得到了回报，由吴荣元组建的“红统”派台湾劳动党事实上夺取了台湾的政治权利。作为推翻蒋氏暴政的英雄，以及对大陆美好生活的向往，台湾迅速决定了接受中华人民共和国管理的决定。外企被悉数收回，美国军队也悉数撤回。而和大陆之间的隔阂也被消除。尽管名义上台湾组建了自己的，独立于北京的政府，但是谁都知道，台湾和大陆再也不会分开了。"
const TXT_NAME_SAR := "台湾特别行政区"
const TXT_R1 := "随着我们对台湾当局施加了巨大的压力，制裁和禁运迅速压垮了这个本就没有什么自给能力的小岛。在一次对抗政府的示威中。我们的特务借机煽风点火，在“你可听见人民的呼声”的歌声中，军警拒绝了接受蒋经国总统关于对人民开枪的指令，事实上发生了哗变。感到自己时日无多的蒋经国收拾了细软，逃往美国檀香山。\n由倒蒋集团组成的大帐篷式政党“民主进步党”在大选中击溃了国民党。新他们立刻宣布将和“中华人民共和国展开深入的合作”。新政府立即着手驱赶美军士兵，并放弃了对于大陆的宣称。我们决定在和平对等的基础上吸纳台湾。他们会和祖国母亲团结在一起，直到永远。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 2:
		return
	var res460 := int(world.completed_event_ids.get("event_460", 0))
	var opt := event_def.options
	if res460 == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var taiwan := _country(38)
	var china := _country(1)
	if taiwan != null:
		_leave_alliances(taiwan)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if taiwan != null:
				taiwan.government = GameConstants.Government.SOCIALIST
				taiwan.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				taiwan.set_tag("亲中", true)
				taiwan.set_tag("对华贸易", true)
				taiwan.puppet_of = GameConstants.LegacySlot.CHINA
				taiwan.chinese_name = TXT_NAME_SAR
			if china != null:
				_follow_alliance(taiwan, china, "econ")
				_follow_alliance(taiwan, china, "okb")
				_follow_alliance(taiwan, china, "sev")
				_follow_alliance(taiwan, china, "ovd")
				_follow_alliance(taiwan, china, "rim")
			_add_relation(EmpireData.USA, -500)
			_add(W.I_PARTY_SUPPORT, 300)
			_add(W.I_PEOPLE_SUPPORT, 300)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
		1:
			context["result_text"] = TXT_R1
			if taiwan != null:
				taiwan.government = GameConstants.Government.REFORMIST
				taiwan.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				taiwan.set_tag("亲中", true)
				taiwan.set_tag("对华贸易", true)
				taiwan.chinese_name = TXT_NAME_SAR
			if china != null:
				_follow_alliance(taiwan, china, "econ")
				_follow_alliance(taiwan, china, "okb")
				_follow_alliance(taiwan, china, "sev")
				_follow_alliance(taiwan, china, "ovd")
			_add_relation(EmpireData.USA, -300)
			_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)




func _follow_alliance(c: CountryData, china: CountryData, tag: String) -> void:
	if c == null or china == null:
		return
	if china.has_tag(tag):
		c.set_tag(tag, true)



func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

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


