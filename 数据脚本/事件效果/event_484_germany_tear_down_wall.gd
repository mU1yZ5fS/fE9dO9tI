extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_484_germany_tear_down_wall.c0"
const S_15 := "event.script.event_484_germany_tear_down_wall.c1"
const S_23 := "event.script.event_484_germany_tear_down_wall.c2"
const S_28 := "event.script.event_484_germany_tear_down_wall.c3"
const S_32 := "event.script.event_484_germany_tear_down_wall.c4"
const S_37 := "event.script.event_484_germany_tear_down_wall.c5"
const S_41 := "event.script.event_484_germany_tear_down_wall.c6"
const S_45 := "event.script.event_484_germany_tear_down_wall.c7"
const S_50 := "event.script.event_484_germany_tear_down_wall.c8"
const S_52 := "event.script.event_484_germany_tear_down_wall.c9"
const S_57 := "event.script.event_484_germany_tear_down_wall.c10"
const S_60 := "event.script.event_484_germany_tear_down_wall.c11"
const S_66 := "event.script.event_484_germany_tear_down_wall.c12"
const S_76 := "event.script.event_484_germany_tear_down_wall.c13"
const S_86 := "event.script.event_484_germany_tear_down_wall.c14"
const S_87 := "event.script.event_484_germany_tear_down_wall.c15"
const S_97 := "event.script.event_484_germany_tear_down_wall.c16"
const S_100 := "event.script.event_484_germany_tear_down_wall.c17"
const S_105 := "event.script.event_484_germany_tear_down_wall.c18"
const S_120 := "event.script.event_484_germany_tear_down_wall.c19"
const S_121 := "event.script.event_484_germany_tear_down_wall.c20"
const S_131 := "event.script.event_484_germany_tear_down_wall.c21"
const S_133 := "event.script.event_484_germany_tear_down_wall.c22"
const S_136 := "event.script.event_484_germany_tear_down_wall.c23"
const S_143 := "event.script.event_484_germany_tear_down_wall.c24"


## 原作 Event484.cs：推倒这堵墙！（四选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:10229（this_type==116）手动
##   number_event=484 进入；Godot 侧 trigger_conditions=[]。
## 差异：
##  - iron_and_blood 成就已接 Achievements（Event484.cs:61）；old_modify_texts[53]/desc[53] 为展示文案跳过；
##  - prosov→亲苏、proprc→亲中、Torg→对华贸易；dev→development；JoinAllOurAlliances→_join_our_alliances。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var c16 := world.get_country_by_legacy_index(16)
	var c17 := world.get_country_by_legacy_index(17)
	var c1 := world.get_country_by_legacy_index(1)
	var c21 := world.get_country_by_legacy_index(21)
	var ussr := world.empires[EmpireData.USSR] if world.empires.size() > EmpireData.USSR else null
	if c16 != null and c17 != null:
		var west_ok := ((c17.has_tag("nato") and (c16.government == GameConstants.Government.REFORMIST or not c16.has_tag("亲苏"))) \
				or (c17.government == GameConstants.Government.SOCIALIST and c16.government != GameConstants.Government.REFORMIST and not c16.has_tag("亲苏"))) \
				and c16.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST
		if west_ok:
			_enable(opt[0], tr(S_23))
		else:
			_disable(opt[0], tr(S_28))
		var east_ok := ((c16.has_tag("亲苏") and c16.government == GameConstants.Government.SOCIALIST and c1 != null \
				and c1.has_tag("sev") and c1.has_tag("ovd")) or c16.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST \
				or (c16.government == GameConstants.Government.SOCIALIST and c16.has_tag("亲中"))) \
				and c16.government != GameConstants.Government.REFORMIST and c17.government != GameConstants.Government.SOCIALIST and not c17.has_tag("nato")
		if east_ok:
			_enable(opt[1], tr(S_32))
		else:
			_disable(opt[1], tr(S_37))
		if (c16.government == GameConstants.Government.REFORMIST or (c21 != null and c21.has_tag("soc_eu") and c17.has_tag("soc_eu") \
				and ussr != null and ussr.current_leader == 6)) and c17.government == GameConstants.Government.REFORMIST:
			_enable(opt[2], tr(S_41))
		elif c16.government == GameConstants.Government.SOCIALIST and c17.government == GameConstants.Government.SOCIALIST and not c16.has_tag("亲苏"):
			_enable(opt[2], tr(S_45))
		else:
			_disable(opt[2], tr(S_50))
	_enable(opt[3], tr(S_52))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c16 := ws.get_country_by_legacy_index(16)
	var c17 := ws.get_country_by_legacy_index(17)
	var c21 := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	# 原作 Event484.cs:61-64：result_num != 3 && iron_and_blood → achievements.Set(132)
	if opt != 3:
		Achievements.set_achievement(132)
	if opt == 0:
		if c16 == null or c17 == null:
			return
		if c17.has_tag("nato"):
			_leave_alliances(c16)
			_set_part(c17, 0, true)
			c17.set_tag("对华贸易", true)
			c17.development = 2
			_set_mod_active(53, false)
			context["result_text"] = tr(S_66)
		elif c17.government == GameConstants.Government.SOCIALIST:
			_set_part(c17, 0, true)
			c17.set_tag("对华贸易", true)
			c17.development = 2
			_set_mod_active(53, true)
			_leave_alliances(c16)
			c17.government = GameConstants.Government.SOCIALIST
			c17.sub_government = GameConstants.SubGovernment.MAOIST
			c17.set_tag("亲中", true)
			_join_our_alliances(c17)
			context["result_text"] = tr(S_76)
		else:
			context["result_text"] = tr(S_143)
	elif opt == 1:
		if c16 == null or c17 == null:
			return
		_set_part(c16, 0, true)
		c16.set_tag("对华贸易", true)
		_leave_alliances(c17)
		c17.development = 3
		c16.name = tr(S_97)
		if ws.is_socialism(c16, true):
			context["result_text"] = tr(S_100)
		elif c16.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
			context["result_text"] = tr(S_105)
		else:
			context["result_text"] = tr(S_143)
	elif opt == 2:
		if c16 == null or c17 == null:
			return
		if c16.government == GameConstants.Government.SOCIALIST and c17.government == GameConstants.Government.SOCIALIST:
			_leave_alliances(c16)
			_set_part(c17, 0, true)
			_join_our_alliances(c17)
			c17.development = 1
			c17.set_tag("对华贸易", true)
			c17.government = GameConstants.Government.SOCIALIST
			c17.sub_government = GameConstants.SubGovernment.MAOIST
			c17.name = tr(S_120)
			context["result_text"] = tr(S_121)
		else:
			_leave_alliances(c16)
			_set_part(c17, 0, true)
			_leave_alliances(c17)
			c17.development = 1
			c17.set_tag("对华贸易", true)
			c17.government = GameConstants.Government.REFORMIST
			c17.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			c17.name = tr(S_131)
			_set_mod_active(53, false)
			var text := tr(S_133)
			if c21 != null and c21.has_tag("soc_eu"):
				text += tr(S_136)
				c17.set_tag("soc_eu", true)
			context["result_text"] = text
	else:
		context["result_text"] = tr(S_143)


func _set_mod_active(idx: int, active: bool) -> void:
	if idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = active




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




func _set_part(c: CountryData, i: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= i:
		c.parts.append(false)
	c.parts[i] = value



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_484_germany_tear_down_wall.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_484",
	"num": 484,
	"priority": 48400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_484_germany_tear_down_wall.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
