## 原作 Event306.cs：对党的领导路线的抗议（抗议路线，三选项）。
## 触发：全目录搜索无 this_num_event = 306 / Reset(306)；链外 REST 段，原版无自动条件。
## 差异：NumberOfPolitician(15,15)→_find_politician；event_done/resultOfEvents[444]→completed_event_ids；
##  modifies[3/65].active→_set_mod_active；显示字段跳过；文本来自 Events_text_en 索引 69-76（禁用项复用 index 52）。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "对党的领导路线的抗议"
const TXT_DESC := "显然，在我们国家并不是一切都是完美的，许多人对党的政策不满意。当然，人民受到修正主义者和外国代理人的煽动，但也许这是我们改变权力结构的机会？与此同时，镇压抗议活动将导致人们的信任和国际声誉下降。"
const TXT_OPT0 := "驱散民众"
const TXT_OPT1 := "我们显然可以通过开除胡耀邦去安抚党和人民。"
const TXT_OPT2 := "利用抗议，组织党内政变。"
const TXT_OPT2_DIS := "和平解决方案已无可能！"
const TXT_R0 := "军队使各城市的局势稳定下来。我们成功在几乎不流血也不抓人的情况下稳定了局势，尽管人民已不太信任我们，抗议者被坦克轰击的图片也见诸西方媒体报端。"
const TXT_R1 := "耀邦退休了，不久就死于心肌梗塞。人民很高兴，党员们也很高兴，对极左派来说，他是修正主义者，温和派对他激进的思想不满意，而对自由派来说，把他们所有的罪过都推到一个前同事身上是有利的......"
const TXT_R2 := "党支持抗议活动，并开始分裂。执政派系失去了支持，甚至连军队都抛弃了他们。不久，我国便建立了一个新政府，前统治者不是老死就是被判犯有叛国罪。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var p15 := _find_politician(15, 15)
	var ev444_done := world.completed_event_ids.has("event_444")
	var ev444_res := int(world.completed_event_ids.get("event_444", 0))
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	_enable(opt[1], TXT_OPT1)
	if p15 >= 0 and (not ev444_done or ev444_res != 0):
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, -100)
			context["result_text"] = TXT_R0
		1:
			var num := _find_politician(15, 15)
			if num >= 0:
				GameManager.kill_politician(num)
			context["result_text"] = TXT_R1
		2:
			var num2 := _find_politician(15, 15)
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 250)
			_add(W.I_AGENTS, -50)
			_add(W.I_DIPLO, -150)
			_set_mod_active(3, false)
			_add_relation(EmpireData.USA, 100)
			if num2 >= 0 and num2 < ws.politicians.size():
				var p := ws.politicians[num2]
				if p != null:
					_set_leader_from(p)
					GameManager.kill_politician(num2)
					_set_mod_active(65, false)
			# LeaderAsset/MoneyLevel/ServeRMB 为显示字段，跳过
			context["result_text"] = TXT_R2


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _mod_active(idx: int) -> bool:
	var w: WorldState = ws if ws != null else GameManager.world
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
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket

