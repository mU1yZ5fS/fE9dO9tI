extends "res://数据脚本/event_script_base.gd"

## 原作事件 53–62：农业/外资改革、缅甸、越南、日本、伊朗终局、
## 中国主导的经济与军事集团、国歌和内蒙古政策。
## 来源：TimeScript.cs:3858-3947，doneventscript.cs:1307-1488，
##       Results_text.cs:4649-5479。

## 原版 Event54 result0 动态文案。
const TXT_54_R0_A := "event.script.event_053_062_reform_and_alliances.c0"
const TXT_54_R0_B := "event.script.event_053_062_reform_and_alliances.c1"

## 原版 Event55 动态文案。
const TXT_55_R1 := "event.script.event_053_062_reform_and_alliances.c2"
const TXT_55_R2_BASE := "event.script.event_053_062_reform_and_alliances.c3"
const TXT_55_R2_SAN_YU := "event.script.event_053_062_reform_and_alliances.c4"
const TXT_55_R2_KHIN_NYUNT := "event.script.event_053_062_reform_and_alliances.c5"

## 原版 Event58 result0 两分支文案。
const TXT_58_R_LEFT := "event.script.event_053_062_reform_and_alliances.c6"
const TXT_58_R_SHAH := "event.script.event_053_062_reform_and_alliances.c7"

## 原版 Event59/60 动态成员名单文案。
const TXT_59_R1_BASE := "event.script.event_053_062_reform_and_alliances.c8"
const TXT_60_R0_BASE := "event.script.event_053_062_reform_and_alliances.c9"
## 原版 Event59 option3 第二禁用文案：我们已经加入了
const TXT_60_R0_TAIL := "event.script.event_053_062_reform_and_alliances.c10"



## 事件 61（国歌问题）与 62（内蒙古问题）逐字中文文案。
## 来源：Event61.cs / Event62.cs（TextOfEvents / VariantsOfEvents / ResultsOfEvents）。
## 说明：{0}{1} 为原版领袖姓名字段占位，显示前由 _fmt_leader() 替换为 name_display。

const TXT_61_TITLE := "event.script.event_053_062_reform_and_alliances.c11"

const TXT_61_DESC := "event.script.event_053_062_reform_and_alliances.c12"

const TXT_61_DESC_AGAIN := "event.script.event_053_062_reform_and_alliances.c13"

const TXT_61_OPT0 := "event.script.event_053_062_reform_and_alliances.c14"
const TXT_61_OPT0_KEEP := "event.script.event_053_062_reform_and_alliances.c15"
const TXT_61_OPT0_DIS := "event.script.event_053_062_reform_and_alliances.c16"
const TXT_61_OPT1 := "event.script.event_053_062_reform_and_alliances.c17"
const TXT_61_OPT1_KEEP := "event.script.event_053_062_reform_and_alliances.c18"
const TXT_61_OPT1_DIS := "event.script.event_053_062_reform_and_alliances.c19"
const TXT_61_OPT2 := "event.script.event_053_062_reform_and_alliances.c20"
const TXT_61_OPT2_KEEP := "event.script.event_053_062_reform_and_alliances.c21"
const TXT_61_OPT2_DIS := "event.script.event_053_062_reform_and_alliances.c22"
const TXT_61_OPT3 := "event.script.event_053_062_reform_and_alliances.c23"
const TXT_61_OPT3_KEEP := "event.script.event_053_062_reform_and_alliances.c24"
const TXT_61_OPT3_DIS := "event.script.event_053_062_reform_and_alliances.c25"
const TXT_61_OPT4 := "event.script.event_053_062_reform_and_alliances.c26"
const TXT_61_OPT4_KEEP := "event.script.event_053_062_reform_and_alliances.c27"
const TXT_61_OPT5 := "event.script.event_053_062_reform_and_alliances.c28"
const TXT_61_OPT5_KEEP := "event.script.event_053_062_reform_and_alliances.c29"

const TXT_61_R_INTRO := "event.script.event_053_062_reform_and_alliances.c30"
const TXT_61_R0 := "event.script.event_053_062_reform_and_alliances.c31"
const TXT_61_R1 := "event.script.event_053_062_reform_and_alliances.c32"
const TXT_61_R2 := "event.script.event_053_062_reform_and_alliances.c33"
const TXT_61_R3 := "event.script.event_053_062_reform_and_alliances.c34"
const TXT_61_R3_ROCK := "event.script.event_053_062_reform_and_alliances.c35"
const TXT_61_R4_A := "event.script.event_053_062_reform_and_alliances.c36"
const TXT_61_R4_B := "event.script.event_053_062_reform_and_alliances.c37"
const TXT_61_R4_C := "event.script.event_053_062_reform_and_alliances.c38"
const TXT_61_R5 := "event.script.event_053_062_reform_and_alliances.c39"
const TXT_61_R5_HUA := "event.script.event_053_062_reform_and_alliances.c40"
const TXT_61_R_KEEP := "event.script.event_053_062_reform_and_alliances.c41"

## 原版 ResultsOfEvents 末尾同步 old_modify_desc[61] 的文案（本版 ModifierCatalog 动态生成，故仅留存溯源）。
const TXT_61_MOD_TITLE := "event.script.event_053_062_reform_and_alliances.c42"
const TXT_61_MOD0 := "event.script.event_053_062_reform_and_alliances.c43"
const TXT_61_MOD1 := "event.script.event_053_062_reform_and_alliances.c44"
const TXT_61_MOD1_B := "event.script.event_053_062_reform_and_alliances.c45"
const TXT_61_MOD2 := "event.script.event_053_062_reform_and_alliances.c46"
const TXT_61_MOD3 := "event.script.event_053_062_reform_and_alliances.c47"
const TXT_61_MOD3_B := "event.script.event_053_062_reform_and_alliances.c48"
const TXT_61_MOD4 := "event.script.event_053_062_reform_and_alliances.c49"
const TXT_61_MOD5 := "event.script.event_053_062_reform_and_alliances.c50"
const TXT_61_MOD6 := "event.script.event_053_062_reform_and_alliances.c51"

const TXT_62_TITLE := "event.script.event_053_062_reform_and_alliances.c52"

const TXT_62_DESC := "event.script.event_053_062_reform_and_alliances.c53"

const TXT_62_OPT0 := "event.script.event_053_062_reform_and_alliances.c54"
const TXT_62_OPT0_DIS := "event.script.event_053_062_reform_and_alliances.c55"
const TXT_62_OPT1 := "event.script.event_053_062_reform_and_alliances.c56"
const TXT_62_OPT1_DIS1 := "event.script.event_053_062_reform_and_alliances.c57"
const TXT_62_OPT1_DIS2 := "event.script.event_053_062_reform_and_alliances.c58"
const TXT_62_OPT2 := "event.script.event_053_062_reform_and_alliances.c59"
const TXT_62_OPT2_DIS := "event.script.event_053_062_reform_and_alliances.c60"
const TXT_62_OPT3 := "event.script.event_053_062_reform_and_alliances.c61"
const TXT_62_OPT3_DIS1 := "event.script.event_053_062_reform_and_alliances.c62"
const TXT_62_OPT3_DIS2 := "event.script.event_053_062_reform_and_alliances.c63"
const TXT_62_OPT4 := "event.script.event_053_062_reform_and_alliances.c64"
const TXT_62_OPT4_DIS := "event.script.event_053_062_reform_and_alliances.c65"
const TXT_62_OPT5 := "event.script.event_053_062_reform_and_alliances.c66"
const TXT_62_R5 := "event.script.event_053_062_reform_and_alliances.c67"

const TXT_62_R0 := "event.script.event_053_062_reform_and_alliances.c68"
const TXT_62_R1 := "event.script.event_053_062_reform_and_alliances.c69"
const TXT_62_R2 := "event.script.event_053_062_reform_and_alliances.c70"
const TXT_62_R3 := "event.script.event_053_062_reform_and_alliances.c71"
const TXT_62_R4 := "event.script.event_053_062_reform_and_alliances.c72"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	d = p_ws
	match event_def.event_id:
		"anthem_problem":
			_prepare_61(event_def)
		"inner_mongolia_problem":
			_prepare_62(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"agricultural_reform": _event_53(option_index)
		"reform_investment": _event_54(option_index, context)
		"burmese_socialism": _event_55(option_index, context)
		"teach_vietnam_lesson": _event_56(option_index)
		"red_rising_sun": _event_57(option_index)
		"iranian_revolution_endgame": _event_58(context)
		"economic_union": _event_59(option_index, context)
		"military_alliance": _event_60(option_index, context)
		"anthem_problem": _event_61(option_index, context)
		"inner_mongolia_problem": _event_62(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_53(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 30,
				W.I_PEOPLE_SUPPORT: -30})
			_change_politicians_above(1, -100, 0)
		1:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_AGRICULTURE: 30,
				W.I_REFORM_MOMENTUM: 10, W.I_THOUGHT_FREEDOM: 30,
				W.I_DIPLO: -10, W.I_LIVING: 30, W.I_CORRUPTION: 20})
			_change_politicians({1: [100, 120], 2: [100, 120]})
		2:
			_add_data({W.I_PARTY_SUPPORT: -70, W.I_REFORM_MOMENTUM: 30,
				W.I_THOUGHT_FREEDOM: 50, W.I_PEOPLE_SUPPORT: 70, W.I_DIPLO: -20,
				W.I_BUDGET: 40, W.I_MANPOWER: -30, W.I_CORRUPTION: 30})
			_add_empire_relation(EmpireData.USA, 30)
			_change_politicians({
				0: [-250, -100], 2: [100, 150], 3: [200, 150],
			})
		3:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_BUDGET: -50,
				W.I_PEOPLE_SUPPORT: 70, W.I_LIVING: 30,
				W.I_AGRICULTURE: 50})
			_add_empire_relation(EmpireData.USSR, 50)
			_unlock_first_agri_tech()
			_subtract_faction_fraction(FactionData.MODERATE, 0.09)
			_subtract_faction_fraction(FactionData.REFORMIST, 0.50)
			_subtract_faction_fraction(FactionData.LIBERAL, 0.24)
			_change_politicians({
				0: [150, 120], 1: [-100, -80], 2: [-150, -100], 3: [-200, -150],
			})
	# 原版 Event53 末尾 old_modify_desc[15] 按农业路线/科技动态拼接，
	# 本端口建模说明（modifier_catalog 静态描述），仅保留原文备查，见文件底部注释。


func _event_54(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_DIPLO: 20,
				W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 80})
			_change_politicians({1: [-200, 0], 2: [-200, 0], 3: [-200, 0]})
			context["result_text"] = tr(TXT_54_R0_A) + _leader_name() + tr(TXT_54_R0_B)
		1:
			_add_data({W.I_BUDGET: 30, W.I_REFORM_MOMENTUM: 10,
				W.I_THOUGHT_FREEDOM: 70, W.I_DIPLO: -20, W.I_MANPOWER: -30})
			ws.reform_stage = 3
			_add_empire_relation(EmpireData.USA, 100)
			ws.set_flag("sez", true)
			_change_politicians({1: [100, 120], 2: [150, 120]})
		2:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_REFORM_MOMENTUM: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_PEOPLE_SUPPORT: 30, W.I_DIPLO: -30,
				W.I_BUDGET: 50, W.I_MANPOWER: -70})
			ws.reform_stage = 3
			_add_empire_relation(EmpireData.USA, 150)
			_subtract_faction_fraction(FactionData.MODERATE, 0.09)
			ws.set_flag("sez", true)
			_change_politicians({
				0: [-250, -100], 1: [-80, -50], 2: [50, 100], 3: [200, 150],
			})


func _event_55(option_index: int, context: Dictionary) -> void:
	var burma := ws.get_country_by_legacy_index(33)
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_BUDGET: -30, W.I_DIPLO: 10})
			_add_empire_relation(EmpireData.USA, -50)
			if burma != null:
				burma.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_55_R1).replace("{0}{1}", _leader_name())
		2:
			_add_data({W.I_AGENTS: -50, W.I_DIPLO: 20})
			_add_empire_relation(EmpireData.USA, -80)
			if burma != null:
				# 原版 allcountries[33].parts[0]=false、prcpower=1000 建模说明，跳过。
				if ws.econ_system <= 12:
					burma.government = GameConstants.Government.REFORMIST
					burma.sub_government = GameConstants.SubGovernment.PRAGMATIST
					context["result_text"] = tr(TXT_55_R2_BASE) + tr(TXT_55_R2_SAN_YU)
				else:
					burma.government = GameConstants.Government.AUTHORITARIAN
					burma.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					context["result_text"] = tr(TXT_55_R2_BASE) + tr(TXT_55_R2_KHIN_NYUNT)
				burma.set_tag("对华贸易", true)
				burma.set_tag("亲中", true)


func _event_56(option_index: int) -> void:
	var vietnam := ws.get_country_by_legacy_index(11)
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_INFLUENCE: -20})
			ws.set_flag("vietnampeace", true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_WAR_PRESSURE: 200, W.I_DIPLO: 20})
			_add_empire_relation(EmpireData.USSR, -200)
			ws.war_state = GameConstants.WarState.SINO_SOVIET
			var war := _war(1)
			if war != null:
				war.name_war = "中国柬埔寨－越南战争"
				war.side1 = "中国-柬埔寨"
			if vietnam != null:
				vietnam.set_tag("对华贸易", true)
		# 原版 Event56 只有 2 个选项；旧 Godot 自造的“峰会”选项（result 2）已删除。


func _event_57(option_index: int) -> void:
	if option_index != 1:
		return
	_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 20,
		W.I_BUDGET: -40, W.I_AGENTS: -60})
	_add_empire_relation(EmpireData.USA, -150)
	var japan := ws.get_country_by_legacy_index(44)
	if japan != null:
		japan.government = GameConstants.Government.REFORMIST
		japan.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
		japan.set_tag("亲美", false)
		japan.set_tag("对华贸易", true)


func _event_58(context: Dictionary) -> void:
	# 原版 Event58.cs:43-103 只有一个结果选项，且只按 data.iran_left_support>data.iran_shah_support 两分支。
	var left := ws.iran_left_support
	var shah := ws.iran_shah_support
	var iran := ws.get_country_by_legacy_index(8)
	if left > shah:
		_add_empire_power(EmpireData.USA, -10)
		if iran != null:
			iran.government = GameConstants.Government.REFORMIST       # 原版 Gosstroy=2（Event58.cs:47）
			iran.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE   # 原版 SubGosstroy=8（Event58.cs:48）
			iran.set_tag("亲美", false)   # 原版 Vyshi=false
			iran.set_tag("sento", false)  # 原版 isSENTO=false
			iran.set_tag("asean", false)  # 原版 isASEAN=false
			if iran.development == 1:
				iran.set_tag("对华贸易", true)  # 原版 dev==1 → Torg=true
		if ws.size() > W.I_IRAN_ISLAMIST_SUPPORT:
			ws.iran_islamist_support = 500  # 原版 data.iran_islamist_support=500
		if ws.size() > 143:
			ws.oil_price += 10
		# 原版 event_done[36] && resultOfEvents[36]==3 → allcountries[14].prcpower+=20；
		# 事件 36 移植说明，跳过。
		context["result_text"] = tr(TXT_58_R_LEFT)
	else:
		_add_empire_power(EmpireData.USA, 10)
		if iran != null and iran.development == 0:
			iran.set_tag("对华贸易", true)  # 原版 dev==0 → Torg=true
		if ws.size() > 143:
			ws.oil_price -= 7
		context["result_text"] = tr(TXT_58_R_SHAH)
	ws.set_flag("iran_revolution_started", false)
	ws.set_flag("iranrev", false)


func _event_59(option_index: int, context: Dictionary) -> void:
	var china := ws.get_country_by_legacy_index(1)
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 30,
				W.I_PEOPLE_SUPPORT: 80, W.I_THOUGHT_FREEDOM: 50, W.I_BUDGET: -80})
			_add_empire_relation(EmpireData.USSR, -100)
			_add_empire_relation(EmpireData.USA, -100)
			ws.iran_democrat_support = 1  # 原版 data.iran_democrat_support=1（ECO 计时标记）
			_set_modifier_active(8, true)
			if china != null:
				china.set_tag("econ", true)
				china.social_stability = 1000
			var names: Array[String] = []
			for country in ws.countries:
				if country == null or not _in_original_econ_range(country):
					continue
				if country.has_tag("亲中") and not country.has_tag("亲美") and not country.has_tag("亲苏"):
					country.set_tag("econ", true)
					country.social_stability = 1000
					names.append(country.chinese_name if country.chinese_name.strip_edges() != "" else country.name)
			_change_all_politicians(100, 0)
			context["result_text"] = tr(TXT_59_R1_BASE) + _join_names(names)
		2:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_INFLUENCE: -30,
				W.I_THOUGHT_FREEDOM: 100})
			_add_empire_relation(EmpireData.USSR, 200)
			_add_empire_relation(EmpireData.USA, -200)
			_add_empire_power(EmpireData.USSR, 30)
			if china != null:
				china.stability = 1
				china.set_tag("sev", true)
			if ws.albania_break == 0:
				var albania := ws.get_country_by_legacy_index(20)
				if albania != null:
					albania.set_tag("亲中", false)
					albania.set_tag("econ", false)
					albania.set_tag("对华贸易", false)
					albania.set_tag("okb", false)
			for country in ws.countries:
				if country == null:
					continue
				var had_econ := country.has_tag("econ")
				country.set_tag("econ", false)
				if had_econ and (country.has_tag("亲苏") or country.has_tag("苏联盟友")
						or country.has_tag("亲中") or country.government == GameConstants.Government.SOCIALIST
						or (country.government == GameConstants.Government.REFORMIST and not country.has_tag("美国盟友")
							and not country.has_tag("亲美"))):
					country.set_tag("sev", true)
			_change_politicians({2: [-200, 0], 3: [-200, 0]})
		3:
			_add_data({W.I_PARTY_SUPPORT: -300, W.I_BUDGET: -20, W.I_INFLUENCE: -20})
			var country15 := ws.get_country_by_legacy_index(15)
			if country15 != null:
				country15.内战中 = true


func _event_60(option_index: int, context: Dictionary) -> void:
	if option_index != 0:
		return
	_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 20,
		W.I_PEOPLE_SUPPORT: 80, W.I_BUDGET: -50, W.I_AGENTS: -100,
		W.I_ARMY: -300})
	_add_empire_relation(EmpireData.USA, -200)
	_add_empire_relation(EmpireData.USSR, -200)
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china.set_tag("okb", true)
	var country15 := ws.get_country_by_legacy_index(15)
	if country15 != null:
		country15.内战中 = false
	_set_modifier_active(59, true)
	var names: Array[String] = []
	for country in ws.countries:
		if country == null:
			continue
		if not _in_original_military_range(country):
			continue
		if country.has_tag("亲中") and country.has_tag("econ") \
				and not country.has_tag("亲美") and not country.has_tag("亲苏"):
			if country.social_stability <= 0:
				country.social_stability = 1000
			country.set_tag("okb", true)
			if country.has_tag("sev"):
				country.set_tag("sev", false)
				country.set_tag("econ", true)
			names.append(country.chinese_name if country.chinese_name.strip_edges() != "" else country.name)
	_change_all_politicians(100, 0)
	context["result_text"] = tr(TXT_60_R0_BASE) + _join_names(names) + tr(TXT_60_R0_TAIL)
	# 原版 Event60 的 old_modify_desc[59] 动态描述（按联盟成员统计）建模说明，
	# 原文备查见文件底部注释。


func _event_61(option_index: int, context: Dictionary) -> void:
	var anthem := int(ws.anthem_choice)
	var num := option_index + 1
	if num == anthem:
		context["result_text"] = tr(TXT_61_R_KEEP)
		return
	match option_index:
		0:
			_add_data({W.I_PEOPLE_SUPPORT: 10, W.I_PARTY_SUPPORT: 10})
		1:
			pass
		2:
			_add_data({W.I_PARTY_SUPPORT: -20, W.I_PEOPLE_SUPPORT: 20})
		3:
			_add_data({W.I_DIPLO: 50})
			ws.influence_prc += 5
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, -100)
		4:
			pass
		5:
			pass
	ws.anthem_choice = num
	_add_data({W.I_MANPOWER: 30, W.I_PEOPLE_SUPPORT: 100,
		W.I_PARTY_SUPPORT: 50, W.I_BUDGET: -30})
	# 原版 AnthemCooldownTime = 4（四年一次国策冷却）；本版无该字段，跳过。
	match option_index:
		0:
			context["result_text"] = tr(TXT_61_R_INTRO) + _fmt_leader(tr(TXT_61_R0))
		1:
			context["result_text"] = tr(TXT_61_R_INTRO) + tr(TXT_61_R1)
		2:
			context["result_text"] = tr(TXT_61_R_INTRO) + tr(TXT_61_R2)
		3:
			var r3 := _fmt_leader(tr(TXT_61_R3))
			if int(ws.completed_event_ids.get("event_668", -1)) == 0:
				r3 = r3.replace("{2}", tr(TXT_61_R3_ROCK))
			else:
				r3 = r3.replace("{2}", "")
			context["result_text"] = tr(TXT_61_R_INTRO) + r3
		4:
			if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
				context["result_text"] = tr(TXT_61_R_INTRO) + tr(TXT_61_R4_A)
			elif not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
				context["result_text"] = tr(TXT_61_R_INTRO) + tr(TXT_61_R4_B)
			else:
				context["result_text"] = tr(TXT_61_R_INTRO) + tr(TXT_61_R4_C)
		5:
			var r5 := tr(TXT_61_R5)
			if ws.leader != null and ws.leader.name_display.begins_with("华"):
				r5 += tr(TXT_61_R5_HUA)
			context["result_text"] = tr(TXT_61_R_INTRO) + r5


func _event_62(option_index: int, context: Dictionary) -> void:
	var inner_mongolia := ws.get_country_by_legacy_index(9)
	match option_index:
		0:
			_add_data({W.I_BUDGET: -30, W.I_PARTY_SUPPORT: 50,
				W.I_THOUGHT_FREEDOM: 50, W.I_PEOPLE_SUPPORT: -30,
				W.I_WAR_SUPPORT: 20, W.I_DIPLO: 30})
			_add_empire_relation(EmpireData.USSR, -30)
			_change_politicians({0: [0, 100], 20: [0, 100]})
			context["result_text"] = tr(TXT_62_R0)
		1:
			_add_data({W.I_BUDGET: -50, W.I_PARTY_SUPPORT: -70,
				W.I_PEOPLE_SUPPORT: 50, W.I_WAR_SUPPORT: -30,
				W.I_REFORM_MOMENTUM: 20})
			_add_empire_relation(EmpireData.USSR, 30)
			context["result_text"] = tr(TXT_62_R1)
		2:
			_add_data({W.I_ARMY: -50, W.I_PEOPLE_SUPPORT: -100,
				W.I_WAR_SUPPORT: 100, W.I_DIPLO: 100,
				W.I_REFORM_MOMENTUM: -10})
			_add_empire_relation(EmpireData.USSR, -100)
			if inner_mongolia != null:
				inner_mongolia.set_tag("对华贸易", false)
			context["result_text"] = _fmt_leader(tr(TXT_62_R2))
		3:
			_add_data({W.I_PARTY_SUPPORT: 30, W.I_THOUGHT_FREEDOM: 30})
			_add_empire_relation(EmpireData.USSR, 20)
			_change_politicians({1: [0, 100], 2: [0, 100], 20: [0, 100]})
			context["result_text"] = tr(TXT_62_R3)
		4:
			_add_data({W.I_BUDGET: -80, W.I_PARTY_SUPPORT: -50,
				W.I_PEOPLE_SUPPORT: 50, W.I_WAR_SUPPORT: -50,
				W.I_REFORM_MOMENTUM: 30})
			_add_empire_relation(EmpireData.USSR, 50)
			if int(ws.territory_policy) < 23:
				ws.territory_policy += 1
			context["result_text"] = tr(TXT_62_R4)
		5:
			context["result_text"] = tr(TXT_62_R5)
	# 原版 NumberOfPolitician(58,85)（乌兰夫）在 Godot 政治家表无 name_1/name_2 索引，相关忠诚/权力/死亡效果移植说明。


func _in_original_econ_range(country: CountryData) -> bool:
	if country == null:
		return false
	var id := country.原版序号
	if id < 7 or id > 52:
		return false
	return id != 52 and id != 35 and id != 24 and id != 25 and id != 40 \
			and id != 30 and id != 14 and id != 13 and id != 36 and id != 44


func _in_original_military_range(country: CountryData) -> bool:
	if country == null:
		return false
	var id := country.原版序号
	if id < 8 or id > 51:
		return false
	return id != 41 and id != 42 and id != 45 and id != 35 and id != 40 \
			and id != 30 and id != 14 and id != 13 and id != 36 and id != 18 and id != 21


func _join_names(names: Array[String]) -> String:
	var result := ""
	for n in names:
		result += "，" + n
	return result


func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _war(index: int) -> WarData:
	return ws.wars[index] if index >= 0 and index < ws.wars.size() else null


func _unlock_first_agri_tech() -> void:
	for i in [0, 1, 2]:
		if ws.techs != null and i < ws.techs.unlocked.size() and not ws.techs.unlocked[i]:
			ws.techs.unlocked[i] = true
			return


func _set_modifier_active(modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.size():
			ws.add_data_by_index(index, int(changes[raw_index]))


func _change_politicians(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			var pair: Array = changes[politician.trait_personality]
			politician.loyalty += int(pair[0])
			politician.power += int(pair[1])


func _change_politicians_above(min_personality: int, loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and politician.trait_personality > min_personality:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


func _change_all_politicians(loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power


## 原版 Event53 old_modify_desc[15] 备查（去空格/剥 color/→\n 后逐字）：
## 根据农业发展情况获得效果
## |“上山下乡”政策及其后果|农业+0.1，科技点-1，思想自由化+0.4
## |社会转型阵痛|生活水平-0.1，思想自由化+0.2
## |社会主义新农村|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4
## |“牛棚”群岛|预算+0.1，农业+0.1，特勤网络-0.2，思想自由化-0.2，外交声誉+0.4，科技点-1，与美国关系-1，与苏联关系-1
## |人心思变|农业-0.1，思想自由化+0.3
## |乡村建设理论|预算-0.6，农业+0.2，生活水平+0.2，思想自由化-0.4
## |长期乡建合同|预算+0.2，农业+0.3，工业+0.1，服务业+0.1，生活水平+0.1，思想自由化+1.2，外交声誉-0.2，与美关系+0.2，美国国际影响力+0.1，中国国际影响力-0.1
## |“新”新村运动|预算-0.4，农业+0.3，服务业+0.1，生活水平+0.1，特勤网络+0.1，思想自由化-0.1
## |新乔治主义社会|预算+0.3，农业+0.5，工业-0.4，服务业-0.2，生活水平-0.1，思想自由化+0.2
## |社会主义新农村|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4
## |水稻共和国|预算+1，农业+0.3，工业+0.2，生活水平-0.6，人民支持度-1.0，思想自由化+1.0，与美关系+0.2，与苏关系+0.2，国际影响力-0.1
## |缓慢推进集体化的公社：|农业+0.1，工业+0.1，生活水平+0.2，预算+0.1
## |家庭联产承包责任制：|预算+0.4，腐败+0.3|若福利投资低于20，则农业-0.2，生活水平-0.2，服务业-0.2|若福利投资高于20，则农业+0.2，生活水平+0.2，服务业+0.2
## |私人农场：|农业-0.4，生活水平-0.4，预算+1.0，服务业+0.2，腐败+0.4，寡头+4
## |快速推进集体化的公社：|农业+0.4，工业+0.4，生活水平+0.4，预算+0.2
## |农业机械化：|农业+0.6，工业+0.4
## |普及化肥与杀虫剂：|农业+0.3，生活水平+0.4
## |转基因技术：|农业+0.2，工业+0.2，生活水平+0.5，预算+0.3
##
## 原版 Event60 old_modify_desc[59] 备查（动态数值用 {0}{1}{2}{3} 表示）：
## 集体安全联盟：|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |非洲联盟:|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |阿拉伯革命同盟:|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |阿拉伯联合共和国:|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |革命国际主义运动：|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}

func _prepare_61(event_def: EventDef) -> void:
	if event_def.options.size() < 6:
		return
	var opts := event_def.options
	event_def.title = tr(TXT_61_TITLE)
	if ws.completed_event_ids.has("anthem_problem"):
		event_def.description = _fmt_leader(tr(TXT_61_DESC_AGAIN))
	else:
		event_def.description = _fmt_leader(tr(TXT_61_DESC))
	var anthem := int(ws.anthem_choice)
	var m3 := _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION)
	var m6 := _mod_active(GameConstants.Modifier.MAOIST_BULWARK)
	var china := ws.get_country_by_legacy_index(1)
	var rim := china != null and china.has_tag("rim")
	var socialism := china != null and china.government == GameConstants.Government.SOCIALIST
	if m6 and int(ws.political_line) <= 2 and anthem != 1:
		_enable(opts[0], tr(TXT_61_OPT0))
	elif anthem == 1:
		_enable(opts[0], tr(TXT_61_OPT0_KEEP))
	else:
		_disable(opts[0], tr(TXT_61_OPT0_DIS))
	if not m3 and anthem != 2:
		_enable(opts[1], tr(TXT_61_OPT1))
	elif anthem == 2:
		_enable(opts[1], tr(TXT_61_OPT1_KEEP))
	else:
		_disable(opts[1], tr(TXT_61_OPT1_DIS))
	if m3 and m6 and anthem != 3:
		_enable(opts[2], tr(TXT_61_OPT2))
	elif anthem == 3:
		_enable(opts[2], tr(TXT_61_OPT2_KEEP))
	else:
		_disable(opts[2], tr(TXT_61_OPT2_DIS))
	if rim and m3 and m6 and socialism and anthem != 4:
		_enable(opts[3], tr(TXT_61_OPT3))
	elif anthem == 4:
		_enable(opts[3], tr(TXT_61_OPT3_KEEP))
	else:
		_disable(opts[3], tr(TXT_61_OPT3_DIS))
	if anthem != 5:
		_enable(opts[4], tr(TXT_61_OPT4))
	else:
		_enable(opts[4], tr(TXT_61_OPT4_KEEP))
	if anthem != 6:
		_enable(opts[5], tr(TXT_61_OPT5))
	else:
		_enable(opts[5], tr(TXT_61_OPT5_KEEP))


func _prepare_62(event_def: EventDef) -> void:
	if event_def.options.size() < 5:
		return
	var opts := event_def.options
	event_def.title = tr(TXT_62_TITLE)
	event_def.description = _fmt_leader(tr(TXT_62_DESC))
	var line := int(ws.political_line)
	var ps := int(ws.party_system)
	var summa := _summa_3_2()
	if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) or (line < 3 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[0], tr(TXT_62_OPT0))
	else:
		_disable(opts[0], tr(TXT_62_OPT0_DIS))
	if not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and (line == 4 or ws.global_flags.get("relres", false) or _empire_relation(EmpireData.USSR) >= 500) and ((line > 0 and ps < 8) or (summa > 66 and ps > 7)):
		_enable(opts[1], tr(TXT_62_OPT1))
	elif not ws.global_flags.get("relres", false) and _empire_relation(EmpireData.USSR) < 500:
		_disable(opts[1], tr(TXT_62_OPT1_DIS1))
	else:
		_disable(opts[1], tr(TXT_62_OPT1_DIS2))
	if (line < 4 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[2], tr(TXT_62_OPT2))
	else:
		_disable(opts[2], tr(TXT_62_OPT2_DIS))
	if (line < 4 and line > 0 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[3], tr(TXT_62_OPT3))
	elif line == 0:
		_disable(opts[3], tr(TXT_62_OPT3_DIS1))
	else:
		_disable(opts[3], tr(TXT_62_OPT3_DIS2))
	if not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and (line == 4 or ws.global_flags.get("relres", false) or _empire_relation(EmpireData.USSR) >= 500) and ((line > 0 and ps < 8) or (summa > 66 and ps > 7)):
		_enable(opts[4], tr(TXT_62_OPT4))
	else:
		_disable(opts[4], tr(TXT_62_OPT4_DIS))

	# 保底：若上述条件全部不满足（例如自由派+多党制+联盟席位不足），
	# 提供“维持现状/暂时搁置”选项，避免事件出现零可选按钮的软锁。
	var any_enabled := false
	for i in range(5):
		if i < opts.size() and opts[i] != null and opts[i].enable_condition == null:
			any_enabled = true
			break
	if opts.size() > 5:
		_disable(opts[5], tr(TXT_62_OPT5))
		if not any_enabled:
			_enable(opts[5], tr(TXT_62_OPT5))


func _summa_3_2() -> int:
	if ws.party_system <= 7:
		return 0
	var num := 0
	var den := 0
	for i in range(5):
		if i >= ws.factions.size() or ws.factions[i] == null:
			continue
		den += int(ws.factions[i].support)
		if i == FactionData.CONSERVATIVE:
			num += int(ws.factions[i].support)
		elif ws.factions[i].is_ally and ws.factions[i].is_enabled:
			num += int(ws.factions[i].support)
	if den == 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / den


func _legacy_cond(max_line_exclusive: int) -> bool:
	var line := int(ws.political_line)
	var ps := int(ws.party_system)
	return (line < max_line_exclusive and ps < 8) or (_summa_3_2() > 66 and ps > 7)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _empire_relation(empire_index: int) -> int:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		return int(ws.empires[empire_index].relations)
	return 0


func _fmt_leader(text: String) -> String:
	var n := _leader_name()
	return text.replace("{0}{1}", n).replace("{0}", n).replace("{1}", n)
