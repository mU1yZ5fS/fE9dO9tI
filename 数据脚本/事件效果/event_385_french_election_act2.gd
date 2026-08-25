extends "res://数据脚本/event_script_base.gd"

## 原作 Event385.cs：法国选举-第二幕（两选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - press[4]/res1/res2 为原版实例状态，端口无跨实例持久化：
##    prepare/execute 各自按世界状态重算 press；随机票数用 randi_range 复现；
##  - 原版 TextOfEvents 会改写 new_events_text[958]，端口只在 prepare 动态处理；
##  - 原版 modifies[56].active=false 与 modifies[42-45] 覆盖逐项移植。

const TXT_DESC_FMT := "event.script.event_385_french_election_act2.c0"
const TXT_OPT0_FMT := "event.script.event_385_french_election_act2.c1"
const TXT_OPT1_FMT := "event.script.event_385_french_election_act2.c2"
const TXT_OPT2_FMT := "event.script.event_385_french_election_act2.c3"
const TXT_OPT3_FMT := "event.script.event_385_french_election_act2.c4"
const TXT_OPT_IGNORE := "event.script.event_385_french_election_act2.c5"
const TXT_LABEL_BUDGET := "event.script.event_385_french_election_act2.c6"
const TXT_LABEL_AGENTS := "event.script.event_385_french_election_act2.c7"
const TXT_LABEL_ARMY := "event.script.event_385_french_election_act2.c8"
const TXT_DIS_BUDGET := "event.script.event_385_french_election_act2.c9"
const TXT_DIS_AGENTS := "event.script.event_385_french_election_act2.c10"
const TXT_952 := "event.script.french_election_act2.txt_952"
const TXT_953 := "event.script.french_election_act2.txt_953"
const TXT_954 := "event.script.french_election_act2.txt_954"
const TXT_955 := "event.script.event_385_french_election_act2.c11"
const TXT_956 := "event.script.french_election_act2.txt_956"
const TXT_957 := "event.script.french_election_act2.txt_957"
const TXT_958 := "event.script.french_election_act2.txt_958"
const TXT_959 := "event.script.event_385_french_election_act2.c12"
const TXT_965 := "event.script.french_election_act2.txt_965"
const TXT_966 := "event.script.french_election_act2.txt_966"
const TXT_967 := "event.script.french_election_act2.txt_967"
const TXT_968 := "event.script.event_385_french_election_act2.c13"
const TXT_969 := "event.script.french_election_act2.txt_969"
const TXT_970 := "event.script.french_election_act2.txt_970"
const TXT_971 := "event.script.french_election_act2.txt_971"
const TXT_972 := "event.script.event_385_french_election_act2.c14"
const TXT_973 := "event.script.french_election_act2.txt_973"
const TXT_974 := "event.script.french_election_act2.txt_974"
const TXT_975 := "event.script.french_election_act2.txt_975"
const TXT_976 := "event.script.event_385_french_election_act2.c15"
const TXT_977 := "event.script.french_election_act2.txt_977"
const TXT_978 := "event.script.french_election_act2.txt_978"
const TXT_979 := "event.script.french_election_act2.txt_979"
const TXT_980 := "event.script.event_385_french_election_act2.c16"
const TXT_1039 := "event.script.french_election_act2.txt_1039"
const TXT_1040 := "event.script.french_election_act2.txt_1040"
const TXT_1041 := "event.script.french_election_act2.txt_1041"

const TXT_958_YUG := "event.script.french_election_act2.txt_958_yug"
const TXT_OPT2_YUG := "event.script.event_385_french_election_act2.c17"
const TXT_954_YUG := "event.script.french_election_act2.txt_954_yug"
const TXT_967_YUG := "event.script.french_election_act2.txt_967_yug"
const TXT_971_YUG := "event.script.french_election_act2.txt_971_yug"
const TXT_975_YUG := "event.script.french_election_act2.txt_975_yug"
const TXT_979_YUG := "event.script.french_election_act2.txt_979_yug"
const TXT_1041_YUG := "event.script.french_election_act2.txt_1041_yug"
const TXT_R_FMT := "event.script.event_385_french_election_act2.c18"
const TXT_R_NO_FMT := "event.script.event_385_french_election_act2.c19"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	ws = world
	var press := _compute_press(world)
	var _france := world.get_country_by_legacy_index(21)
	var infl_ch := _infl_ch(world, press)
	if world.get_flag("YugAgree"):
		# 原版改写 new_events_text[958]；端口在 prepare 动态选用文本。
		pass
	event_def.description = _desc_text(world, press, infl_ch)
	var opt := event_def.options
	_prepare_opt385(opt[0], world, press)
	_enable(opt[1], tr(TXT_OPT_IGNORE))


func _prepare_opt385(opt: EventOption, world: WorldState, press: Array) -> void:
	var _france := world.get_country_by_legacy_index(21)
	var infl_ch := _infl_ch(world, press)
	var fmt_text: String
	if infl_ch == 0:
		fmt_text = tr(TXT_OPT0_FMT)
	elif infl_ch == 1:
		fmt_text = tr(TXT_OPT1_FMT)
	elif infl_ch == 2:
		fmt_text = tr(TXT_OPT2_YUG) if world.get_flag("YugAgree") else tr(TXT_OPT2_FMT)
	else:
		fmt_text = tr(TXT_OPT3_FMT)
	if _d(W.I_AGENTS) >= 100 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 50:
		_enable(opt, fmt_text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 50:
		_disable(opt, tr(TXT_DIS_BUDGET).format([10]))
	else:
		_disable(opt, tr(TXT_DIS_AGENTS).format([5]))


func _desc_text(world: WorldState, press: Array, infl_ch: int) -> String:
	var _france := world.get_country_by_legacy_index(21)
	var infl_nato := _infl_nato(world, press)
	var res1: int = randi_range(28, 34)
	var res2: int = randi_range(20, 26)
	var cand_ch := _cand_name(infl_ch)
	var cand_nato := _cand_name(infl_nato)
	return tr(TXT_DESC_FMT).format(["\n", cand_ch, cand_nato, res1, res2])


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	ws.modifiers[56].is_active = false
	var france := ws.get_country_by_legacy_index(21)
	var press := _compute_press(ws)
	var infl_ch := _infl_ch(ws, press)
	var infl_nato := _infl_nato(ws, press)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		# 原版：按 inflNATO 给 press 加 2
		if infl_nato == 0:
			press[1] += 2
		elif infl_nato == 1:
			press[3] += 2
		elif infl_nato == 2:
			press[0] += 2
		else:
			press[2] += 2
		var num := _winner(press)
		_add(W.I_AGENTS, -100)
		_add(W.I_BUDGET, -50)
		# 原版 data.world_political_balance = num
		d.world_political_balance = num  # 原版 data.world_political_balance
		var _cand_ch := _cand_name(infl_ch)
		var _cand_nato := _cand_name(infl_nato)
		var winner_name := _cand_name(num)
		var winner_promise := _promise(num)
		context["result_text"] = tr(TXT_R_FMT).format([
			"\n",
			_black_material(infl_ch), _black_target(infl_ch),
			_black_detail(infl_ch),
			_black_epithet(infl_nato), _black_epithet(infl_ch),
			_black_target2(infl_nato), _black_target2(infl_ch),
			winner_name, winner_promise])
		if num == 0:
			if france != null:
				france.set_tag("亲美", true)
			_add_power(EmpireData.USA, 50)
			d.world_political_balance = 0  # 原版 data.world_political_balance
			Achievements.set_achievement(115)  # 原作 Event385.cs:410-413 iron_and_blood → achievements.Set(115)
			var portugal := ws.get_country_by_legacy_index(87)
			if portugal != null:
				portugal.special += 10
		elif num == 1:
			if france != null:
				france.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			ws.modifiers[42].is_active = false
			ws.modifiers[43].is_active = true
			d.world_political_balance = 1  # 原版 data.world_political_balance
			var portugal2 := ws.get_country_by_legacy_index(87)
			if portugal2 != null:
				portugal2.special += 5
		elif num == 2:
			if france != null:
				if not ws.get_flag("YugAgree"):
					france.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
					france.government = GameConstants.Government.REFORMIST
				else:
					france.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					france.government = GameConstants.Government.REFORMIST
			ws.modifiers[42].is_active = false
			ws.modifiers[44].is_active = true
			d.world_political_balance = 2  # 原版 data.world_political_balance
			var portugal3 := ws.get_country_by_legacy_index(87)
			if portugal3 != null:
				portugal3.special -= 10
		else:
			if france != null:
				france.sub_government = GameConstants.SubGovernment.MODERATE
			ws.modifiers[42].is_active = false
			ws.modifiers[45].is_active = true
			d.world_political_balance = 3  # 原版 data.world_political_balance
			var portugal4 := ws.get_country_by_legacy_index(87)
			if portugal4 != null:
				portugal4.special -= 10
	else:
		var cand_ch := _cand_name(infl_ch)
		context["result_text"] = tr(TXT_R_NO_FMT).format(["\n", cand_ch, _promise(infl_ch)])
		d.world_political_balance = infl_ch  # 原版 data.world_political_balance
		if infl_ch == 0:
			if france != null:
				france.set_tag("亲美", true)
			_add_power(EmpireData.USA, 50)
			Achievements.set_achievement(115)  # 原作 Event385.cs:457-460 achievements.Set(115)
			d.world_political_balance = 0  # 原版 data.world_political_balance
		elif infl_ch == 1:
			if france != null:
				france.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			ws.modifiers[42].is_active = false
			ws.modifiers[43].is_active = true
			d.world_political_balance = 1  # 原版 data.world_political_balance
		elif infl_ch == 2:
			if france != null:
				if not ws.get_flag("YugAgree"):
					france.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
					france.government = GameConstants.Government.REFORMIST
				else:
					france.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					france.government = GameConstants.Government.REFORMIST
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null 					and ws.empires[EmpireData.USSR].leaders.size() > 6:
				ws.empires[EmpireData.USSR].leaders[6].support += 1
			ws.modifiers[42].is_active = false
			ws.modifiers[44].is_active = true
			d.world_political_balance = 2  # 原版 data.world_political_balance
		else:
			if france != null:
				france.sub_government = GameConstants.SubGovernment.MODERATE
			ws.modifiers[42].is_active = false
			ws.modifiers[45].is_active = true
			d.world_political_balance = 3  # 原版 data.world_political_balance


func _compute_press(world: WorldState) -> Array:
	var press: Array = [0, 0, 0, 0]
	var _france := world.get_country_by_legacy_index(21)
	var poland := world.get_country_by_legacy_index(2)
	var hungary := world.get_country_by_legacy_index(4)
	var _ussr := world.get_country_by_legacy_index(7)
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var iran := world.get_country_by_legacy_index(8)
	var afghan := world.get_country_by_legacy_index(12)
	var yemen := world.get_country_by_legacy_index(24)
	var ethiopia := world.get_country_by_legacy_index(41)
	var spain := world.get_country_by_legacy_index(86)
	var portugal := world.get_country_by_legacy_index(87)
	var nkorea := world.get_country_by_legacy_index(10)
	var italy := world.get_country_by_legacy_index(85)
	# press[0]（马歇）
	if int(world.completed_event_ids.get("event_384", 0)) == 1:
		press[0] += 2
	if _d(W.I_AFGHAN_PARCHAM) > _d(W.I_AFGHAN_KHALQ):
		press[0] += 2
	if int(world.completed_event_ids.get("event_049", 0)) == 1:
		press[0] += 1
	if int(world.completed_event_ids.get("event_050", 0)) == 3:
		press[0] -= 1
	if poland != null and poland.puppet_of == 7:
		press[0] -= 1
	if hungary != null and hungary.government == GameConstants.Government.SOCIALIST:
		press[0] += 1
	if ethiopia != null and ethiopia.government == GameConstants.Government.REFORMIST:
		press[0] += 1
	if iran != null and iran.government == GameConstants.Government.SOCIALIST:
		press[0] += 1
	if china != null and china.has_tag("ovd"):
		press[0] += 1
	if china != null and china.has_tag("sev"):
		press[0] += 1
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null 			and world.empires[EmpireData.USSR].power > world.empires[EmpireData.USA].power:
		press[0] += 1
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null 			and world.empires[EmpireData.USSR].power > _d(W.I_INFLUENCE):
		press[0] += 1
	if _mod_active(GameConstants.Modifier.SOVIET_EMBARGO):
		press[0] += 1
	# press[1]（德斯坦）
	if int(world.completed_event_ids.get("event_384", 0)) == 2:
		press[1] += 2
	if _d(132) == 2:  # 原版 data.soviet_eastern_europe_intervention
		press[1] += 1
	if usa != null and usa.development > 0:
		press[1] += 1
	if china != null and china.has_tag("seato"):
		press[1] += 1
	if china != null and china.has_tag("asean"):
		press[1] += 1
	if int(world.completed_event_ids.get("event_050", 0)) == 4 or int(world.completed_event_ids.get("event_052", 0)) == 2:
		press[1] += 1
	if china != null and china.has_tag("okb"):
		press[1] += 1
	if iran != null and iran.government == GameConstants.Government.LIBERAL:
		press[1] += 1
	if afghan != null and not afghan.has_tag("亲中") and afghan.government == GameConstants.Government.AUTHORITARIAN:
		press[1] += 1
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null 			and world.empires[EmpireData.USA].power > world.empires[EmpireData.USSR].power:
		press[1] += 1
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null 			and world.empires[EmpireData.USA].power > _d(W.I_INFLUENCE):
		press[1] += 1
	if _mod_active(GameConstants.Modifier.USA_EMBARGO):
		press[1] += 1
	if int(world.completed_event_ids.get("event_046", 0)) == 2:
		press[1] -= 1
	# press[2]（希拉克）
	if world.influence_prc > world.empires[EmpireData.USA].power and world.influence_prc > world.empires[EmpireData.USSR].power:
		press[2] += 1
	if int(world.completed_event_ids.get("event_384", 0)) == 3:
		press[2] += 2
	if italy != null and italy.内战中:
		press[2] += 1
	if iran != null and iran.has_tag("亲美") and iran.government == GameConstants.Government.AUTHORITARIAN:
		press[2] += 1
	if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
		press[2] += 1
	if portugal != null and portugal.sub_government == GameConstants.SubGovernment.MODERATE:
		press[2] += 1
	if spain != null and spain.government == GameConstants.Government.REFORMIST:
		press[2] += 1
	if nkorea != null and nkorea.has_tag("亲中"):
		press[2] += 1
	if yemen != null and yemen.has_tag("亲中"):
		press[2] += 1
	if world.empires[EmpireData.USA].relations < 500:
		press[2] += 1
	if china != null and (china.has_tag("sev") or china.has_tag("asean")):
		press[2] -= 2
	# press[3]（密特朗）
	if hungary != null and hungary.government == GameConstants.Government.REFORMIST:
		press[3] += 1
	if int(world.completed_event_ids.get("event_384", 0)) == 0 and world.completed_event_ids.has("event_384"):
		press[3] += 2
	if iran != null and iran.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
		press[3] += 1
	if china != null and not china.has_tag("okb") and not china.has_tag("ovd") and not china.has_tag("seato"):
		press[3] += 1
	var war5 := world.wars[5] if world.wars.size() > 5 else null
	if war5 != null and war5.is_going:
		press[3] += 1
	if usa != null and usa.sub_government == GameConstants.SubGovernment.NEOLIBERAL:
		press[3] += 1
	if italy != null and italy.sub_government == GameConstants.SubGovernment.LIBERAL:
		press[3] += 1
	if portugal != null and portugal.sub_government == GameConstants.SubGovernment.LIBERAL:
		press[3] += 1
	if spain != null and spain.sub_government == GameConstants.SubGovernment.LIBERAL:
		press[3] += 1
	if world.is_socialism(china, false) and _d(W.I_PARTY_SYSTEM) >= 30:
		press[3] += 1
	var war3 := world.wars[3] if world.wars.size() > 3 else null
	if war3 != null and war3.is_going:
		press[3] += 1
	if china != null and china.government == GameConstants.Government.REFORMIST:
		press[3] += 1
	return press


func _infl_ch(_world: WorldState, press: Array) -> int:
	if press[0] >= press[1] and press[0] >= press[2] and press[0] >= press[3]:
		return 2
	elif press[1] >= press[0] and press[1] >= press[2] and press[1] >= press[3]:
		return 0
	elif press[2] >= press[0] and press[2] >= press[1] and press[2] >= press[3]:
		return 3
	return 1


func _infl_nato(world: WorldState, press: Array) -> int:
	var infl_ch := _infl_ch(world, press)
	if infl_ch == 0:
		if press[0] >= press[2] and press[0] >= press[3]:
			return 2
		elif press[2] >= press[3] and press[2] >= press[0]:
			return 3
		return 1
	elif infl_ch == 1:
		if press[0] >= press[2] and press[0] >= press[1]:
			return 2
		elif press[2] >= press[1] and press[2] >= press[0]:
			return 3
		return 0
	elif infl_ch == 2:
		if press[2] >= press[1] and press[2] >= press[3]:
			return 3
		elif press[3] >= press[1] and press[3] >= press[2]:
			return 1
		return 0
	if press[0] >= press[1] and press[0] >= press[2]:
		return 2
	elif press[3] >= press[1] and press[3] >= press[0]:
		return 1
	return 0


func _winner(press: Array) -> int:
	if press[0] >= press[1] and press[0] >= press[2] and press[0] >= press[3]:
		return 2
	elif press[1] >= press[0] and press[1] >= press[2] and press[1] >= press[3]:
		return 0
	elif press[2] >= press[0] and press[2] >= press[1] and press[2] >= press[3]:
		return 3
	return 1


func _cand_name(idx: int) -> String:
	if idx == 0: return tr(TXT_956)
	elif idx == 1: return tr(TXT_957)
	elif idx == 2: return tr(TXT_958_YUG) if (ws != null and ws.get_flag("YugAgree")) else tr(TXT_958)
	return tr(TXT_959)


func _promise(idx: int) -> String:
	if idx == 0: return tr(TXT_1039)
	elif idx == 1: return tr(TXT_1040)
	elif idx == 2: return tr(TXT_1041_YUG) if (ws != null and ws.get_flag("YugAgree")) else tr(TXT_1041)
	return tr(TXT_1040)


func _black_material(idx: int) -> String:
	if idx == 0: return tr(TXT_952)
	elif idx == 1: return tr(TXT_953)
	elif idx == 2: return tr(TXT_954_YUG) if (ws != null and ws.get_flag("YugAgree")) else tr(TXT_954)
	return tr(TXT_955)


func _black_target(idx: int) -> String:
	if idx == 0: return tr(TXT_977)
	elif idx == 1: return tr(TXT_978)
	elif idx == 2: return tr(TXT_979_YUG) if (ws != null and ws.get_flag("YugAgree")) else tr(TXT_979)
	return tr(TXT_980)


func _black_detail(idx: int) -> String:
	if idx == 0: return tr(TXT_965)
	elif idx == 1: return tr(TXT_966)
	elif idx == 2: return tr(TXT_967_YUG) if (ws != null and ws.get_flag("YugAgree")) else tr(TXT_967)
	return tr(TXT_968)


func _black_epithet(idx: int) -> String:
	if idx == 0: return tr(TXT_969)
	elif idx == 1: return tr(TXT_970)
	elif idx == 2: return tr(TXT_971_YUG) if (ws != null and ws.get_flag("YugAgree")) else tr(TXT_971)
	return tr(TXT_972)


func _black_target2(idx: int) -> String:
	if idx == 0: return tr(TXT_973)
	elif idx == 1: return tr(TXT_974)
	elif idx == 2: return tr(TXT_975_YUG) if (ws != null and ws.get_flag("YugAgree")) else tr(TXT_975)
	return tr(TXT_976)


func _mod_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_385_french_election_act2.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_385",
	"num": 385,
	"priority": 38500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_385_french_election_act2.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
