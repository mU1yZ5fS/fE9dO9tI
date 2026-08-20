extends "res://数据脚本/event_script_base.gd"

## 原作 Event503.cs：交城的山水实呀实在美（2选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_R0_A := "很快，一揽子改革计划开始了，你的雕像已经开始修建，对于您的个人崇拜的民谣与民俗故事已经在民间流传开来，你被誉为“黄土高原的天才”，“世界最著名革命家”、“毛泽东思想的永恒火焰”，是“前所未有的最天真、最自然、最有感情也最纯粹的革命者”…而在党内，已经有传言说你会培养你的儿子为唯一接班人。更有甚者认为你死后，会被安葬在一个纪念堂当中。在路线上，我们也开始了基于人民为主体叙事，批判其他社会主义国家党务精英化，强调反对社会帝国主义与美国帝国主义，将自力更生放在第一位的“民族特色社会主义”的建设-不过，我们自然需要花不少资源来平息并且党内对这些变化不满的人，但是在最有可能形成威胁的两翼消失后，党内已经很少有异议能够挑战到你了。"
const TXT_R1_A := "主席同志，那只是个建议，你一向生活民主作风，包容党内各派思想，谦逊而富有智慧，我知道你自然不会选择这条邪路的，这真是个糟糕的笑话。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c1 := ws.get_country_by_legacy_index(1)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(1, 300)
			_add(3, 300)
			_add(4, -(100))
			_set_data(31, 900)
			_add(8, -(40))
			_add(9, -(40))
			_set_data(15, 6)
			_set_data(16, 10)
			_set_data(17, 16)
			_set_data(18, 20)
			_set_data(50, 29)
			if ws.modifiers.size() > 6: ws.modifiers[6].is_active = false
			if _mod(6):
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = "无 产 阶 级 专 政"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 无产阶级专政
				# 原版 GlobalScript.inst.gameState.doctr[8] = "人 民 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 人民民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = "协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = "经 典 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 经典计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = "中 式 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中式计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = "国 家 监 护 资 本 主 义"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 国家监护资本主义
				# 原版 GlobalScript.inst.gameState.doctr[14] = "社 会 主 义 导 向 市 场"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 社会主义导向市场
				# 原版 GlobalScript.inst.gameState.doctr[15] = "左 翼 小 政 府"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 左翼小政府
				# 原版 GlobalScript.inst.gameState.doctr[21] = "改 良 区 域 自 治 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 改良区域自治制度
				# 原版 GlobalScript.inst.gameState.doctr[22] = "联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[24] = "文 化 革 命"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 文化革命
			else:
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = " 一 党 制 共 和 国"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党制共和国
				# 原版 GlobalScript.inst.gameState.doctr[7] = "一 党 独 大 式 民 主"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党独大式民主
				# 原版 GlobalScript.inst.gameState.doctr[8] = " 宪 政 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 宪政民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = " 协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = " 中 央 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中央计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = " 分 权 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 分权计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = " 鸟 笼 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 鸟笼经济
				# 原版 GlobalScript.inst.gameState.doctr[14] = " “ 社 会 ” 市 场 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: “社会”市场经济
				# 原版 GlobalScript.inst.gameState.doctr[15] = " 最 小 干 预"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 最小干预
				# 原版 GlobalScript.inst.gameState.doctr[21] = " 联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[22] = " 联 省 自 治"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联省自治
				# 原版 GlobalScript.inst.gameState.doctr[24] = " 破 除 传 统"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 破除传统
			if ws.modifiers.size() > 3: ws.modifiers[3].is_active = true
			_add_relation(0, -(100))
			_add_relation(1, -(100))
			if c1 != null: c1.government = GameConstants.Government.AUTHORITARIAN
			if c1 != null: c1.sub_government = _chinese_sub_government()
		1:
			context["result_text"] = TXT_R1_A

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data[W.I_PARTY_SYSTEM] == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data[W.I_IDEOLOGY] <= 2 and data[W.I_ECON_SYSTEM] < 13 				and data[W.I_DIPLO] >= 700 and data[W.I_PARTY_SYSTEM] < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data[W.I_ECON_SYSTEM] >= 13 and data[W.I_WAR_SUPPORT] >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_WAR_SUPPORT] >= 700 				and data[W.I_DIPLO] >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data[W.I_ECON_SYSTEM] >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data[W.I_PARTY_SYSTEM] <= 7 				and data[W.I_ECON_SYSTEM] <= 12 and data[W.I_RELIGION] <= 25:
			result = 17
		elif data[W.I_IDEOLOGY] == 1 and not _mod_active(6) and data[W.I_RELIGION] <= 26:
			result = 16
		elif data[W.I_ECON_SYSTEM] < 13 and data[W.I_PRESS_POLICY] >= 17 				and data[W.I_IDEOLOGY] == 1 and data[W.I_RELIGION] <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(40):
			result = 8
		elif data[W.I_IDEOLOGY] >= 2 and data[W.I_ECON_SYSTEM] >= 13 				and data[W.I_DIPLO] <= 700 and data[W.I_PARTY_SYSTEM] >= 8 				and data[W.I_PRESS_POLICY] >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] >= 12 				and data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 300 				and data[W.I_TERRITORY] > 21 and data[W.I_WAR_SUPPORT] >= 700:
			result = 11
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 14 				and data[W.I_DIPLO] >= 500 and data[W.I_ECON_SYSTEM] > 11 				and data[W.I_WAR_SUPPORT] >= 400:
			result = 8
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 13 				and data[W.I_PRESS_POLICY] > 17:
			result = 3
		elif data[W.I_PARTY_SYSTEM] <= 8 				and (data[W.I_ECON_SYSTEM] == 13 or data[W.I_ECON_SYSTEM] == 12) 				and data[W.I_WAR_SUPPORT] < 700 and not _mod_active(3) 				and data[W.I_PRESS_POLICY] >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 500:
		result = 4
	elif (data[W.I_PARTY_SYSTEM] <= 8 and data[W.I_PRESS_POLICY] <= 18) 			or data[W.I_WAR_SUPPORT] >= 700:
		result = 12
	elif data[W.I_ECON_SYSTEM] > 13 and data[W.I_DIPLO] < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)

## 原版 ReqEventForDLC02.cs:72-74 的 num==0 计数。
func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var num := 0
	for politic in world.politicians:
		if politic == null:
			continue
		if politic.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT and ((politic.name_first == 0 and politic.name_last == 0) or (politic.name_first == 3 and politic.name_last == 3) or (politic.name_first == 4 and politic.name_last == 4) or (politic.name_first == 5 and politic.name_last == 5) or (politic.name_first == 1 and politic.name_last == 41)):
			num += 1
		if politic.name_first == 13 and politic.name_last == 13:
			num += 1
		if politic.name_first == 14 and politic.name_last == 14:
			num += 1
		if politic.name_first == 15 and politic.name_last == 15:
			num += 1
		if politic.name_first == 16 and politic.name_last == 16:
			num += 1
	if world.leader == null:
		return false
	return num == 0 and world.leader.name_first == 2 and world.leader.name_last == 2 \
		and (world.modifiers.size() <= 3 or not world.modifiers[3].is_active) \
		and int(world.completed_event_ids.get("event_668", 0)) == 3 \
		and int(world.completed_event_ids.get("event_669", 0)) == 3
