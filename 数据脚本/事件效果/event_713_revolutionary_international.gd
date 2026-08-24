extends "res://数据脚本/event_script_base.gd"

## 原作 Event713.cs：青出于蓝，而胜于蓝（国际毛派反华集团事件，1978.10 触发条件见 event_713_trigger.gd）。
## 触发：EventDef.trigger_script = event_713_trigger.gd（TimeScript.cs:9979-10040 的
## flag/num 循环统计 + 国家政体/修正/决策条件，ExprNode 无法表达，走尾追加钩子）。
## 差异：
##  - <color> 标签去除（UI 未开 bbcode）；字符间空格排版不保留。
##  - 原版 numberOfSpecialEnding=0 → Godot CountryData.special_ending=0。
##  - resultOfEvents[686]/[125]/[437]/[503]/[521]/[540]/[545] 用 completed_event_ids，
##    对应事件后续移植统一使用 "event_NNN" 作为 event_id（见 事件对齐台账.md）。
##  - LeaveAlliances / JoinAllOurAlliances 按 Country.cs:89-112 / 42-86 分支逐项映射
##    到 Godot tags（包含 puppetOf=-1）。
##  - ChineseSubGosstroy()（GameState.cs:4934-5028）本脚本完整移植为
##    _chinese_sub_government()，分支顺序与返回值逐字对齐。

const ARRAY_LOYALISTS := [9, 10, 11, 22, 23, 31, 32, 33, 34, 43, 47, 49, 50, 96, 97, 128]

const TXT_OPT1_A := "event.script.event_713_revolutionary_international.c0"
const TXT_OPT1_B := "event.script.event_713_revolutionary_international.c1"
const TXT_OPT1_C := "event.script.event_713_revolutionary_international.c2"

const TXT_DESC_PRE := "event.script.event_713_revolutionary_international.c3"
const TXT_DESC_POST := "event.script.event_713_revolutionary_international.c4"

const TXT_R0 := "event.script.event_713_revolutionary_international.c5"

const TXT_R1_PRE := "event.script.event_713_revolutionary_international.c6"
const TXT_R1_MID := "event.script.event_713_revolutionary_international.c7"


## 显示前动态钩子：插入领导人姓名；按原版 VariantsOfEvents 三段条件设选项1文案与门槛。
## 注意 resultOfEvents[] 未触发时原版为 int 默认 0；Godot completed_event_ids 缺省 -1，
## 故 540 用 get("event_540", 0) 对齐原版缺省语义，545/521 需真值 2 不受影响。
func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var leader_name := _leader_name(world)
	event_def.description = tr(TXT_DESC_PRE) + leader_name + tr(TXT_DESC_POST)
	if event_def.options.size() > 1:
		var opt: EventOption = event_def.options[1]
		var available := _option1_available(world)
		if available:
			opt.text = tr(TXT_OPT1_A)
			opt.disabled_text = ""
			opt.enable_condition = null
		elif world.completed_event_ids.has("event_503") \
				and world.completed_event_ids.get("event_503", -1) == 0:
			opt.text = tr(TXT_OPT1_B)
			opt.disabled_text = tr(TXT_OPT1_B)
			opt.enable_condition = _never_node()
		else:
			opt.text = tr(TXT_OPT1_C)
			opt.disabled_text = tr(TXT_OPT1_C)
			opt.enable_condition = _never_node()


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_common_effects()
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_PARTY_SUPPORT, -250)
		_add(W.I_PEOPLE_SUPPORT, -250)
		context["result_text"] = tr(TXT_R0)
	elif opt == 1:
		_add(W.I_BUDGET, -1000)
		_add(W.I_AGENTS, -1000)
		_add(W.I_ARMY, -1000)
		_add(W.I_PARTY_SUPPORT, -50)
		_add(W.I_PEOPLE_SUPPORT, -100)
		_add_relation(EmpireData.USSR, -800)
		_add_relation(EmpireData.USA, -400)
		_subdue_country(19, "印度")
		_subdue_country(44, "日本")
		for legacy_index in ARRAY_LOYALISTS:
			var c := ws.get_country_by_legacy_index(legacy_index)
			if c == null or not ws.is_socialism(c, true):
				continue
			if c.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or c.sub_government == GameConstants.SubGovernment.TROTSKYIST:
				continue
			_leave_alliances(c)
			var china := ws.get_country_by_legacy_index(1)
			if china != null:
				c.government = china.government
				c.sub_government = _chinese_sub_government()
			c.puppet_of = GameConstants.LegacySlot.CHINA
			c.set_tag("亲中", true)
			c.set_tag("对华贸易", true)
			_join_our_alliances(c)
		context["result_text"] = tr(TXT_R1_PRE) + _leader_name(ws) + tr(TXT_R1_MID)


## Event713.cs ResultsOfEvents 开头共同效果（result_num 分支之前）。
func _common_effects() -> void:
	# event_done[686] = false（重置，允许 686 再触发）
	ws.completed_event_ids.erase("event_686")
	# 秘鲁(62)：SubGosstroy==17 或 proprc → Gosstroy=2, SubGosstroy=15
	var peru := ws.get_country_by_legacy_index(62)
	if peru != null and (peru.sub_government == GameConstants.SubGovernment.MAOIST or peru.has_tag("亲中")):
		peru.government = GameConstants.Government.REFORMIST
		peru.sub_government = GameConstants.SubGovernment.PRAGMATIST
	# 全国家循环：i!=1、非中国附庸、IsSocialism(true)、SubGosstroy!=16/18、
	# 非亲苏/亲美、不在经互会/华约 → 影响-20、断亲中/对华贸易/econ/okb；
	# 符合条件者转 rim。
	for c in ws.countries:
		if c == null or c.原版序号 == GameConstants.LegacySlot.CHINA:
			continue
		if c.puppet_of == GameConstants.LegacySlot.CHINA:
			continue
		if not ws.is_socialism(c, true):
			continue
		if c.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or c.sub_government == GameConstants.SubGovernment.TROTSKYIST:
			continue
		if c.has_tag("亲苏") or c.has_tag("亲美") or c.has_tag("sev") or c.has_tag("ovd"):
			continue
		ws.influence_prc -= 20
		c.set_tag("亲中", false)
		c.set_tag("对华贸易", false)
		c.set_tag("econ", false)
		c.set_tag("okb", false)
		if c.sub_government == GameConstants.SubGovernment.MAOIST or c.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST \
				or (c.原版序号 == 24 and ws.completed_event_ids.get("event_437", 0) == 0 \
				and not _parts_0(25)):
			c.set_tag("rim", true)
	# 印度(19)：Gosstroy=0, SubGosstroy=0, numberOfSpecialEnding=0, 非亲美
	var india := ws.get_country_by_legacy_index(19)
	if india != null:
		india.government = GameConstants.Government.AUTHORITARIAN
		india.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
		india.special_ending = 0
		india.set_tag("亲美", false)
		india.set_tag("rim", true)
	# resultOfEvents[125] = 0（后续移植约定 event_id="event_125"）
	ws.completed_event_ids["event_125"] = 0
	var c80 := ws.get_country_by_legacy_index(80)
	if c80 != null:
		c80.set_tag("rim", true)
	var c44 := ws.get_country_by_legacy_index(44)
	if c44 != null:
		c44.set_tag("rim", true)


## 印度(19)/日本(44)：LeaveAlliances → 改名、Gosstroy=2、SubGosstroy=15、
## puppetOf=1、亲中+对华贸易、JoinAllOurAlliances。
func _subdue_country(legacy_index: int, new_name: String) -> void:
	var c := ws.get_country_by_legacy_index(legacy_index)
	if c == null:
		return
	_leave_alliances(c)
	c.name = new_name
	c.chinese_name = new_name
	c.government = GameConstants.Government.REFORMIST
	c.sub_government = GameConstants.SubGovernment.PRAGMATIST
	c.puppet_of = GameConstants.LegacySlot.CHINA
	c.set_tag("亲中", true)
	c.set_tag("对华贸易", true)
	_join_our_alliances(c)


## Country.cs:89-112 LeaveAlliances（联盟/倾向清空 + puppetOf=-1）。

func _join_our_alliances(c: CountryData) -> void:
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)






func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"


## Event713.cs VariantsOfEvents 选项1 三态判定（原版条件逐字）。
func _option1_available(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= W.I_ARMY:
		return false
	var d503_done: bool = world.completed_event_ids.has("event_503")
	var d503_result: int = world.completed_event_ids.get("event_503", -1)
	return world.influence_prc >= 1000 \
		and data.diplomatic_reputation > 900 \
		and data.budget + data.reserve >= 1000 \
		and data.agents >= 1000 \
		and data.army >= 1000 \
		and world.completed_event_ids.get("event_540", 0) == 0 \
		and world.completed_event_ids.get("event_545", -1) == 2 \
		and world.completed_event_ids.get("event_521", -1) == 2 \
		and (not d503_done or d503_result != 0)


## 不可达 ExprNode（prepare 动态禁用选项时使用，与原版 SetActive(false) 等价）。
func _never_node() -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	return n


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _parts_0(legacy_index: int) -> bool:
	var c := ws.get_country_by_legacy_index(legacy_index)
	return c != null and c.parts.size() > 0 and c.parts[0]


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（分支顺序逐字）。
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
		elif data.party_system == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data.ideology <= 2 and data.econ_system < 13 \
				and data.diplomatic_reputation >= 700 and data.party_system < 8 \
				and _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
			result = 0
		elif (data.econ_system >= 13 and data.war_support >= 700 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK)) \
				or _mod_active(GameConstants.Modifier.PRESIDENT_FOR_LIFE):
			result = 9
		elif data.econ_system <= 13 and data.war_support >= 700 \
				and data.diplomatic_reputation >= 700 and (_mod_active(GameConstants.Modifier.MAOIST_BULWARK) or _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION)):
			result = 10
		elif data.econ_system >= 13 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(GameConstants.Modifier.FOURTH_INTERNATIONAL):
			result = 18
		elif _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and data.party_system <= 7 \
				and data.econ_system <= 12 and data.religion_policy <= 25:
			result = 17
		elif data.ideology == 1 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and data.religion_policy <= 26:
			result = 16
		elif data.econ_system < 13 and data.press_policy >= 17 \
				and data.ideology == 1 and data.religion_policy <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(GameConstants.Modifier.RETURN_TO_AGRARIAN_CIVILIZATION):
			result = 8
		elif data.ideology >= 2 and data.econ_system >= 13 \
				and data.diplomatic_reputation <= 700 and data.party_system >= 8 \
				and data.press_policy >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data.ideology <= 3 and data.econ_system >= 12 \
				and data.econ_system <= 13 and data.diplomatic_reputation >= 300 \
				and data.territory_policy > 21 and data.war_support >= 700:
			result = 11
		elif data.ideology <= 3 and data.econ_system <= 14 \
				and data.diplomatic_reputation >= 500 and data.econ_system > 11 \
				and data.war_support >= 400:
			result = 8
		elif data.ideology <= 3 and data.econ_system <= 13 \
				and data.press_policy > 17:
			result = 3
		elif data.party_system <= 8 \
				and (data.econ_system == 13 or data.econ_system == 12) \
				and data.war_support < 700 and not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) \
				and data.press_policy >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data.econ_system <= 13 and data.diplomatic_reputation >= 500:
		result = 4
	elif (data.party_system <= 8 and data.press_policy <= 18) \
			or data.war_support >= 700:
		result = 12
	elif data.econ_system > 13 and data.diplomatic_reputation < 700:
		result = 6
	else:
		result = 5
	return result


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active
