extends "res://数据脚本/event_script_base.gd"

## 原作 Event560.cs：我们想要大饼与自由（摩洛哥面包骚乱，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:407-409 ——
##   c54.SubGosstroy==7 && (1984.1.22 或 1984.2 或 1985+)。
## 差异：描述由 prepare 动态拼领袖姓名；level_of_dev→level_of_development；spec→special。

const TXT_DESC_A := "event.script.event_560_bread_and_freedom.c0"
const TXT_DESC_B := "event.script.event_560_bread_and_freedom.c1"
const TXT_OPT0_DIS := "event.script.event_560_bread_and_freedom.c2"
const TXT_OPT1_DIS := "event.script.event_560_bread_and_freedom.c3"
const TXT_R0_INTRO := "event.script.event_560_bread_and_freedom.c4"
const TXT_R0_REV := "event.script.bread_and_freedom.txt_r0_rev"
const TXT_R0_REV_WEST := "event.script.bread_and_freedom.txt_r0_rev_west"
const TXT_R0_REV_WEST_PRO := "event.script.bread_and_freedom.txt_r0_rev_west_pro"
const TXT_R0_LIB := "event.script.bread_and_freedom.txt_r0_lib"
const TXT_R1 := "event.script.bread_and_freedom.txt_r1"
const TXT_R1_WEST := "event.script.event_560_bread_and_freedom.c5"
const TXT_R1_TAIL := "event.script.event_560_bread_and_freedom.c6"
const TXT_R2 := "event.script.event_560_bread_and_freedom.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var n := _leader_name()
	event_def.description = tr(TXT_DESC_A) + n + tr(TXT_DESC_B)
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	var r463 := int(ws.completed_event_ids.get("event_463", 0))
	var c40 := world.get_country_by_legacy_index(40)
	var c86 := world.get_country_by_legacy_index(86)
	if r463 == 2 and ws.completed_event_ids.has("event_463") 			and (c40 == null or not c40.has_tag("亲美") or (c86 != null and c86.has_tag("对华贸易"))):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	var line := d.political_line
	if line > 1 and line < 4 and c86 != null and c86.sub_government == GameConstants.SubGovernment.TITOIST:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c18 := ws.get_country_by_legacy_index(18)
	var c54 := ws.get_country_by_legacy_index(54)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0_INTRO)
			if c54 != null and c54.level_of_development == 1:
				text += tr(TXT_R0_REV)
				if c18 != null and not c18.内战中:
					text += tr(TXT_R0_REV_WEST)
					if c54 != null:
						c54.parts.resize(maxi(c54.parts.size(), 1))
						c54.parts[0] = false
					if c18 != null:
						c18.special = 0
						c18.government = GameConstants.Government.REFORMIST
						c18.sub_government = GameConstants.SubGovernment.PRAGMATIST
						c18.set_tag("对华贸易", true)
					ws.influence_prc += 5
				else:
					text += tr(TXT_R0_REV_WEST_PRO)
					if c54 != null:
						c54.parts.resize(maxi(c54.parts.size(), 1))
						c54.parts[0] = false
					if c18 != null:
						c18.special = 0
						c18.government = GameConstants.Government.SOCIALIST
						c18.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
						c18.set_tag("对华贸易", true)
						c18.set_tag("亲中", true)
					ws.influence_prc += 20
				if c18 != null:
					game.set_map_region_owner([54, 55, 56, 57], c18.gwcode)
				if c54 != null:
					c54.government = GameConstants.Government.SOCIALIST
					c54.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
					_leave_alliances(c54)
					c54.set_tag("亲中", true)
					c54.name = "摩洛哥人民共和国"
					c54.chinese_name = "摩洛哥人民共和国"
					c54.set_tag("对华贸易", true)
				_add_relation(EmpireData.USSR, 50)
				_add_relation(EmpireData.USA, -100)
				_add(W.I_BUDGET, -80)
				_add(W.I_AGENTS, -100)
				_add(W.I_ARMY, -100)
			else:
				text += tr(TXT_R0_LIB)
				if c54 != null:
					c54.government = GameConstants.Government.LIBERAL
					c54.sub_government = GameConstants.SubGovernment.LIBERAL
					_leave_alliances(c54)
					c54.set_tag("亲中", true)
					c54.name = "摩洛哥王国"
					c54.chinese_name = "摩洛哥王国"
					c54.set_tag("对华贸易", true)
				_add_relation(EmpireData.USSR, -50)
				_add_relation(EmpireData.USA, -150)
				_add(W.I_BUDGET, -80)
				_add(W.I_AGENTS, -100)
				_add(W.I_ARMY, -100)
			context["result_text"] = text
		1:
			var text := tr(TXT_R1)
			if c18 != null and c54 != null and ((not c18.内战中 and (c54.parts.size() == 0 or not c54.parts[0])) or (c54.parts.size() > 0 and c54.parts[0])):
				text += tr(TXT_R1_WEST)
				if c54 != null:
					c54.parts.resize(maxi(c54.parts.size(), 1))
					c54.parts[0] = true
					game.set_map_region_owner([54, 55, 56, 57], c54.gwcode)
				if c18 != null:
					_leave_alliances(c18)
			text += tr(TXT_R1_TAIL)
			_add(W.I_BUDGET, -100)
			if c54 != null:
				c54.government = GameConstants.Government.REFORMIST
				c54.sub_government = GameConstants.SubGovernment.TITOIST
				_leave_alliances(c54)
				c54.set_tag("亲中", true)
				c54.name = "摩洛哥人民联邦王国"
				c54.chinese_name = "摩洛哥人民联邦王国"
				c54.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 50)
			context["result_text"] = text
		2:
			context["result_text"] = tr(TXT_R2)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_560_bread_and_freedom.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_560",
	"nodesc": true,
	"num": 560,
	"priority": 56000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_560_bread_and_freedom.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 7, "target": "54"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1984.1.22"}, {"t": "DATE_AFTER", "key": "1984.2.1"}, {"t": "DATE_AFTER", "key": "1985.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
