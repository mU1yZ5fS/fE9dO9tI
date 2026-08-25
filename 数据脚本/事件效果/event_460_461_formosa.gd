extends "res://数据脚本/event_script_base.gd"

## 福尔摩沙之冬 / 福尔摩沙之春（Formosa Winter / Formosa Spring）
## 移植自 Unity 原作：
##   Event460.cs  — 福尔摩沙之冬（ResultsOfEvents :51-75）
##   Event461.cs  — 福尔摩沙之春（ResultsOfEvents :33-101）
## 触发入口：
##   event_460_formosa_winter.tres（ReqEventForDLC02.cs:392-395 的自动触发条件）
##   event_461_formosa_spring.tres（DiploButtonScript.cs:11411-11415 的外交入口手动触发）
##
## 入口契约：EventEngine.apply_event_option 对本脚本生成的 CUSTOM_SCRIPT 效果
## 调用 execute(context)；context.event_id / context.option_index / context.result_text。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	if event_def.event_id != "formosa_winter" or event_def.options.size() < 3:
		return
	var line: int = p_ws.political_line if p_ws.size() > W.I_POLITICAL_LINE else 0
	if line > 1:
		event_def.options[0].disabled_text = "支持左派？我们连自己党里的左派都不放心！"
	else:
		event_def.options[0].disabled_text = "我们有心无力！"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"formosa_winter":
			match option_index:
				0:
					_winter_result_0(context)
				1:
					_winter_result_1(context)
				2:
					_winter_result_2(context)
		"formosa_spring":
			# Event461.cs:36 —— 两个结果分支之前统一执行 LeaveAlliances()。
			_spring_leave_alliances()
			match option_index:
				0:
					_spring_result_0(context)
				1:
					_spring_result_1(context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()
	# 项目惯例：国家面板/概览 仍读 global_flags.event_done_XXX / result_XXX
	# （国家面板.gd 台湾分支、概览.gd:497；同 event_500_african_union.gd:53-54）。
	match str(context.get("event_id", "")):
		"formosa_winter":
			ws.set_flag("event_done_460", true)
			ws.set_flag("result_460", option_index)
		"formosa_spring":
			ws.set_flag("event_done_461", true)
			ws.set_flag("result_461", option_index)


# ============================================================================
# Event460.cs — 福尔摩沙之冬
# ============================================================================

## Event460.cs:51-61（result_num == 0）
func _winter_result_0(context: Dictionary) -> void:
	var taiwan := _taiwan()
	if taiwan != null:
		taiwan.stab = 1                       # Event460.cs:54  allcountries[38].stab = 1
	_add_data(W.I_AGENTS, -50)                # Event460.cs:55  data.agents -= 50
	_add_data(W.I_ARMY, -100)                 # Event460.cs:56  data.army -= 100
	_add_data(W.I_DIPLO, 10)                  # Event460.cs:57  data.diplomatic_reputation += 10
	ws.influence_prc += 20                    # Event460.cs:58  influencePRC += 20
	_add_empire_relation(EmpireData.USA, -50) # Event460.cs:59  empires[0].relations -= 50
	_add_empire_power(EmpireData.USA, -10)    # Event460.cs:60  empires[0].power -= 10
	context["result_text"] = tr("event.script.event_460_461_formosa.i0")


## Event460.cs:63-70（result_num == 1）
func _winter_result_1(context: Dictionary) -> void:
	var taiwan := _taiwan()
	if taiwan != null:
		taiwan.stab = 2                       # Event460.cs:66  allcountries[38].stab = 2
	_add_data(W.I_DIPLO, 5)                   # Event460.cs:67  data.diplomatic_reputation += 5
	_add_empire_relation(EmpireData.USA, -25) # Event460.cs:68  empires[0].relations -= 25
	_add_empire_power(EmpireData.USA, -5)     # Event460.cs:69  empires[0].power -= 5
	context["result_text"] = tr("event.script.event_460_461_formosa.i1")


## Event460.cs:72-76（result_num == 2）
func _winter_result_2(context: Dictionary) -> void:
	_add_empire_power(EmpireData.USA, -5)     # Event460.cs:75  empires[0].power -= 5
	context["result_text"] = tr("event.script.event_460_461_formosa.i2")


# ============================================================================
# Event461.cs — 福尔摩沙之春
# ============================================================================

## Event461.cs:36 + Country.cs:89-115（LeaveAlliances）
## Godot 侧标签集合与 world_factory.gd:112-116 START_CLEAR_TAGS 保持一致；
## 同时按 Country.cs:113 清 puppetOf = -1。
func _spring_leave_alliances() -> void:
	var taiwan := _taiwan()
	if taiwan == null:
		return
	for tag in WorldFactory.START_CLEAR_TAGS:
		taiwan.set_tag(tag, false)
	taiwan.puppet_of = GameConstants.LegacySlot.NONE


## Event461.cs:37-71（result_num == 0）
func _spring_result_0(context: Dictionary) -> void:
	var taiwan := _taiwan()
	var china := _china()
	if taiwan != null:
		taiwan.government = GameConstants.Government.SOCIALIST                 # Event461.cs:40  Gosstroy = 1
		taiwan.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST             # Event461.cs:41  SubGosstroy = 2
		taiwan.set_tag("亲中", true)          # Event461.cs:42  proprc = true
		taiwan.set_tag("对华贸易", true)      # Event461.cs:43  Torg = true
		taiwan.puppet_of = GameConstants.LegacySlot.CHINA                  # Event461.cs:44  puppetOf = 1
		taiwan.chinese_name = "台湾特别行政区"  # Event461.cs:45  name = "台湾特别行政区"
		if china != null:
			if china.has_tag("econ"):          # Event461.cs:46-49
				taiwan.set_tag("econ", true)
			if china.has_tag("okb"):           # Event461.cs:50-53
				taiwan.set_tag("okb", true)
			if china.has_tag("sev"):           # Event461.cs:54-57
				taiwan.set_tag("sev", true)
			if china.has_tag("ovd"):           # Event461.cs:58-61
				taiwan.set_tag("ovd", true)
			if china.has_tag("rim"):           # Event461.cs:62-65
				taiwan.set_tag("rim", true)
	_add_empire_relation(EmpireData.USA, -500) # Event461.cs:66  empires[0].relations -= 500
	_add_data(W.I_PARTY_SUPPORT, 300)          # Event461.cs:67  data.party_support += 300
	_add_data(W.I_PEOPLE_SUPPORT, 300)         # Event461.cs:68  data.people_support += 300
	_add_data(W.I_BUDGET, -100)                # Event461.cs:69  data.budget -= 100
	_add_data(W.I_AGENTS, -100)                # Event461.cs:70  data.agents -= 100
	context["result_text"] = tr("event.script.event_460_461_formosa.i3")


## Event461.cs:72-101（result_num == 1）
func _spring_result_1(context: Dictionary) -> void:
	var taiwan := _taiwan()
	var china := _china()
	if taiwan != null:
		taiwan.government = GameConstants.Government.REFORMIST                 # Event461.cs:75  Gosstroy = 2
		taiwan.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST             # Event461.cs:76  SubGosstroy = 3
		taiwan.set_tag("亲中", true)          # Event461.cs:77  proprc = true
		taiwan.set_tag("对华贸易", true)      # Event461.cs:78  Torg = true
		_add_empire_relation(EmpireData.USA, -300) # Event461.cs:79  empires[0].relations -= 300
		taiwan.chinese_name = "台湾特别行政区"  # Event461.cs:80  name = "台湾特别行政区"
		if china != null:
			if china.has_tag("econ"):          # Event461.cs:81-84
				taiwan.set_tag("econ", true)
			if china.has_tag("okb"):           # Event461.cs:85-88
				taiwan.set_tag("okb", true)
			if china.has_tag("sev"):           # Event461.cs:89-92
				taiwan.set_tag("sev", true)
			if china.has_tag("ovd"):           # Event461.cs:93-96
				taiwan.set_tag("ovd", true)
	_add_data(W.I_PARTY_SUPPORT, 200)          # Event461.cs:97  data.party_support += 200
	_add_data(W.I_PEOPLE_SUPPORT, 100)         # Event461.cs:98  data.people_support += 100
	_add_data(W.I_BUDGET, -50)                 # Event461.cs:99  data.budget -= 50
	_add_data(W.I_AGENTS, -50)                 # Event461.cs:100 data.agents -= 50
	context["result_text"] = tr("event.script.event_460_461_formosa.i4")


# ============================================================================
# 工具方法
# ============================================================================

func _taiwan() -> CountryData:
	return ws.get_country_by_legacy_index(38)


func _china() -> CountryData:
	return ws.get_country_by_legacy_index(1)


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d.add_data_by_index(index, delta)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power
