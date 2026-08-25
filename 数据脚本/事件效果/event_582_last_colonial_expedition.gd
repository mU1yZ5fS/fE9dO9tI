extends "res://数据脚本/event_script_base.gd"

## 原作 Event582.cs：最后的殖民地远征（中非博卡萨，六选项）。 ## 触发：ReqEventForDLC02.cs:819-822 —— (日>=20 且 月>=9 且 年>=1979) (月>=10 且 年>=1979) 年>=1980 ##   → DATE_AFTER 1979.9.20。 ## 差异： ##  - 选项显隐 prepare 动态改写；science[23] → ws.techs.unlocked[23]； ##  - modifies[3]/[6].active → ws.modifiers[3]/[6].is_active； ##  - Torg → 对华贸易；proprc → 亲中；name → chinese_name；puppetOf → puppet_of。



const TXT_OPT0_DIS := "event.script.event_582_last_colonial_expedition.c0"
const TXT_OPT1_DIS := "event.script.event_582_last_colonial_expedition.c1"
const TXT_OPT2_DIS := "event.script.event_582_last_colonial_expedition.c2"
const TXT_OPT3_DIS := "event.script.event_582_last_colonial_expedition.c3"
const TXT_OPT4_DIS := "event.script.event_582_last_colonial_expedition.c4"

const TXT_R0_A := "event.script.event_582_last_colonial_expedition.c5"
const TXT_R0_CONGO := "event.script.event_582_last_colonial_expedition.c6"
const TXT_R0_FAIL := "event.script.event_582_last_colonial_expedition.c7"
const TXT_R1 := "event.script.event_582_last_colonial_expedition.c8"
const TXT_R2 := "event.script.event_582_last_colonial_expedition.c9"
const TXT_R3 := "event.script.event_582_last_colonial_expedition.c10"
const TXT_R4 := "event.script.event_582_last_colonial_expedition.c11"
const TXT_R5 := "event.script.event_582_last_colonial_expedition.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c21 := world.get_country_by_legacy_index(21)
	var opt := event_def.options
	if line <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line != 0 and line != 4 and (not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) or not _mod_active(GameConstants.Modifier.MAOIST_BULWARK)) \
			and c21 != null and c21.has_tag("对华贸易") and _tech(23):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if line <= 1:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	if line >= 2:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c65 := ws.get_country_by_legacy_index(65)
	var c52 := ws.get_country_by_legacy_index(52)
	var c21 := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			if c52 != null and c52.has_tag("亲中") and _tech(23):
				var text := tr(TXT_R0_A) + tr(TXT_R0_CONGO)
				if c65 != null:
					c65.government = GameConstants.Government.SOCIALIST
					c65.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					_leave_alliances(c65)
					c65.set_tag("对华贸易", true)
					c65.set_tag("亲中", true)
				_add(W.I_DIPLO, 20)
				ws.influence_prc += 50
				if c65 != null:
					c65.chinese_name = "中非人民共和国"
				_add_relation(EmpireData.USA, -100)
				context["result_text"] = text
			else:
				var text := tr(TXT_R0_A) + tr(TXT_R0_FAIL)
				if c65 != null:
					c65.government = GameConstants.Government.AUTHORITARIAN
					c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					_leave_alliances(c65)
					c65.chinese_name = "中非共和国"
				_add_relation(EmpireData.USA, -100)
				if c65 != null:
					c65.puppet_of = GameConstants.LegacySlot.FRANCE
				context["result_text"] = text
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				c65.chinese_name = "中非共和国"
				_leave_alliances(c65)
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_DIPLO, 20)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_leave_alliances(c65)
				c65.set_tag("亲中", true)
				c65.set_tag("对华贸易", true)
			if c21 != null:
				c21.set_tag("对华贸易", false)
			if c65 != null:
				c65.chinese_name = "中非人民帝国"
			ws.influence_prc += 20
			_add(W.I_DIPLO, 20)
			context["result_text"] = tr(TXT_R2)
		3:
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				_leave_alliances(c65)
				c65.chinese_name = "中非共和国"
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_DIPLO, -20)
			_add(W.I_DIPLO, 20)
			context["result_text"] = tr(TXT_R3)
		4:
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				_leave_alliances(c65)
				c65.chinese_name = "中非共和国"
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_DIPLO, -20)
			if c65 != null:
				c65.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R4)
		5:
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				_leave_alliances(c65)
				c65.chinese_name = "中非共和国"
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			context["result_text"] = tr(TXT_R5)


func _mod_active(id: int) -> bool:
	return ws.modifiers.size() > id and ws.modifiers[id] != null and ws.modifiers[id].is_active


func _tech(idx: int) -> bool:
	return ws.techs != null and ws.techs.unlocked.size() > idx and ws.techs.unlocked[idx]



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_582_last_colonial_expedition.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_582",
	"num": 582,
	"priority": 58200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_582_last_colonial_expedition.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.9.20"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
