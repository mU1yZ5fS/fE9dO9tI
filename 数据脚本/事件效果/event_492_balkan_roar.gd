extends "res://数据脚本/event_script_base.gd"

## 原作 Event492.cs：狂风怒吼，巴尔干咆哮（保加利亚变天，四选项）。 ## 触发：ReqEventForDLC02.cs:1524-1526 —— ##   c6.SubGosstroy==16 && !c2.prosov && !c5.prosov && !c4.prosov ##   && !c1.isSEV && !c1.isOVD && !c1.isASEAN && !c1.isSEATO ##   && ((年>=1984 月>=9 日>=9) (年>=1984 月>=10) 年>=1985)。 ## 差异： ##  - Gosstroy/SubGosstroy → government/sub_government；cw → 内战中； ##  - prosov/isSEV/isOVD/isASEAN/isSEATO/Torg/proprc/isBALECON → has_tag/set_tag； ##  - spec → special；relres → ws.get_flag("relres")；IsSocialism(true,1) → ws.is_socialism(c1, true)。



const TXT_OPT0_DIS := "event.script.event_492_balkan_roar.c0"
const TXT_OPT1_DIS := "event.script.event_492_balkan_roar.c1"
const TXT_OPT2_DIS := "event.script.event_492_balkan_roar.c2"

const TXT_R0_WIN := "event.script.event_492_balkan_roar.c3"

const TXT_R0_BALECON := "event.script.event_492_balkan_roar.c4"

const TXT_R0_USSR := "event.script.event_492_balkan_roar.c5"

const TXT_R0_LOSE := "event.script.event_492_balkan_roar.c6"

const TXT_R1 := "event.script.event_492_balkan_roar.c7"

const TXT_R2 := "event.script.event_492_balkan_roar.c8"

const TXT_R3 := "event.script.event_492_balkan_roar.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var bulgaria := world.get_country_by_legacy_index(6)
	var china := world.get_country_by_legacy_index(1)
	var albania := world.get_country_by_legacy_index(20)
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var econ := world.econ_system if world.size() > W.I_ECON_SYSTEM else 11
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var opt := event_def.options
	if bulgaria != null and bulgaria.内战中 and world.is_socialism(china, true) and mod6:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if albania != null and albania.special == 1 and world.influence_prc >= 800:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line >= 2 and econ >= 13 and world.get_flag("relres"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bulgaria := ws.get_country_by_legacy_index(6)
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			if ws.influence_prc >= 600:
				var text := tr(TXT_R0_WIN)
				if bulgaria != null:
					bulgaria.government = GameConstants.Government.SOCIALIST
					bulgaria.sub_government = GameConstants.SubGovernment.MAOIST
					_leave_alliances(bulgaria)
					bulgaria.set_tag("对华贸易", true)
					bulgaria.set_tag("亲中", true)
					_join_alliances(bulgaria)
				_add_relation(EmpireData.USSR, -400)
				_add_power(EmpireData.USSR, -100)
				ws.influence_prc += 100
				if albania != null and albania.special == 1:
					text += tr(TXT_R0_BALECON)
					if bulgaria != null:
						bulgaria.set_tag("balecon", true)
				text += tr(TXT_R0_USSR)
				context["result_text"] = text
			else:
				context["result_text"] = tr(TXT_R0_LOSE)
				if bulgaria != null:
					bulgaria.government = GameConstants.Government.AUTHORITARIAN
					bulgaria.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					_leave_alliances(bulgaria)
				_add_relation(EmpireData.USSR, -200)
				_add_power(EmpireData.USSR, -150)
		1:
			_add(W.I_BUDGET, -150)
			if bulgaria != null:
				_leave_alliances(bulgaria)
				bulgaria.set_tag("对华贸易", true)
				bulgaria.set_tag("balecon", true)
			_add_relation(EmpireData.USSR, -250)
			_add_power(EmpireData.USSR, -100)
			ws.influence_prc += 80
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -100)
			if bulgaria != null:
				bulgaria.government = GameConstants.Government.REFORMIST
				bulgaria.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				bulgaria.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, 300)
			_add_power(EmpireData.USSR, -100)
			ws.influence_prc += 80
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_492_balkan_roar.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_492",
	"num": 492,
	"priority": 49200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_492_balkan_roar.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 16, "target": "6"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "2"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "5"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "4"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "asean", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "seato", "target": "1"}]}, {"t": "DATE_AFTER", "key": "1984.9.9"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
