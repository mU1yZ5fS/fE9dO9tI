extends "res://数据脚本/event_script_base.gd"

## 原作 Event463.cs：卡萨布兰卡一夜（摩洛哥干预四选项）。
## 触发：ReqEventForDLC02.cs:402-404 —— DATE_AFTER 1981.6.1；fire_only_once 承担 !event_done[463]。
## 差异：level_of_dev→level_of_development；开战按项目约定 game.start_war(39,...)
##   后覆盖 name_war/fortnight_max（TickTime 20）；AmericanSupportAttacker→usa_side = GameConstants.WarSide.SIDE1，
##   relres→ussr_side = GameConstants.WarSide.SIDE2。

const TXT_OPT0_DIS := "event.script.event_463_casablanca_night.c0"
const TXT_OPT1_DIS := "event.script.event_463_casablanca_night.c1"
const TXT_OPT2_DIS := "event.script.event_463_casablanca_night.c2"
const TXT_R0 := "event.script.event_463_casablanca_night.c3"
const TXT_NAME_FED := "event.script.event_463_casablanca_night.c4"
const TXT_R1 := "event.script.event_463_casablanca_night.c5"
const TXT_WAR_NAME := "event.script.event_463_casablanca_night.c6"
const TXT_WAR_SIDE1 := "event.script.event_463_casablanca_night.c7"
const TXT_WAR_SIDE2 := "event.script.event_463_casablanca_night.c8"
const TXT_R2 := "event.script.event_463_casablanca_night.c9"
const TXT_R2_A := "event.script.event_463_casablanca_night.c10"
const TXT_R2_B := "event.script.event_463_casablanca_night.c11"
const TXT_R2_C := "event.script.event_463_casablanca_night.c12"
const TXT_R3 := "event.script.event_463_casablanca_night.c13"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var morocco := world.get_country_by_legacy_index(54)
	var opt := event_def.options
	if morocco != null and morocco.内战中 and line56 < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line56 <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line56 != 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var morocco := _country(54)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if morocco != null:
				morocco.government = GameConstants.Government.REFORMIST
				morocco.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				morocco.set_tag("亲美", false)
				morocco.set_tag("对华贸易", true)
				morocco.set_tag("亲中", true)
				morocco.chinese_name = tr(TXT_NAME_FED)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -30)
			_add(W.I_ARMY, -80)
			_add_relation(EmpireData.USA, -80)
			_add(W.I_DIPLO, -50)
			var num := 0
			for idx in [40, 55, 13, 14, 35, 42, 104, 93]:
				var c := _country(idx)
				if c != null and (c.has_tag("亲中") or c.government == GameConstants.Government.SOCIALIST):
					num += 20
			var c25 := _country(25)
			var c24 := _country(24)
			if (c25 != null and (c25.has_tag("亲中") or c25.government == GameConstants.Government.SOCIALIST)) or (c24 != null and (c24.has_tag("亲中") or c24.government == GameConstants.Government.SOCIALIST)):
				num += 20
			var c18 := _country(18)
			if c18 != null and c18.内战中:
				num += 50
			var c86 := _country(86)
			if c86 != null and c86.sub_government != GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
				num += 30
			_ensure_western_sahara()
			game.start_war(39, tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 700 - num, 300 + num, 0)
			var war := _get_war(39)
			if war != null:
				war.name_war = tr(TXT_WAR_NAME)
				war.fortnight_max = 20
				if ws.get_flag("relres"):
					war.ussr_side = GameConstants.WarSide.SIDE2
		2:
			var line56 := _res(W.I_POLITICAL_LINE)
			if line56 <= 1:
				context["result_text"] = tr(TXT_R2) + tr(TXT_R2_A) + tr(TXT_R2_C)
				if morocco != null:
					morocco.level_of_development = 1
			else:
				context["result_text"] = tr(TXT_R2) + tr(TXT_R2_B) + tr(TXT_R2_C)
				if morocco != null:
					morocco.level_of_development = 3
			_add_relation(EmpireData.USA, -80)
			_add(W.I_DIPLO, -50)
		3:
			context["result_text"] = tr(TXT_R3)
			_add_power(EmpireData.USA, -20)




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


func _ensure_western_sahara() -> void:
	## 沿用原版 18 号“西撒哈拉”实体（gwcode 9018）；地图归属留给战争结算，
	## 不在开战时提前把 55 号地块从毛里塔尼亚划走。
	var c18 := _country(18)
	if c18 != null and c18.chinese_name.is_empty():
		c18.chinese_name = "西撒哈拉"
		c18.name = "Western Sahara"

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





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_463_casablanca_night.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_463",
	"num": 463,
	"priority": 46300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_463_casablanca_night.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.6.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
