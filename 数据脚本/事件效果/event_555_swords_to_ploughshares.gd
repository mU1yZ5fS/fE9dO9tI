extends "res://数据脚本/event_script_base.gd"

## 原作 Event555.cs：铸剑为犁（西德和平运动，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1239-1241 —— c17.isNATO && (1983.10.22 或 1984+)。
## 差异：isNATO/isSocEU→has_tag；data.britain_political_route raw index；empires[0].now_leader→current_leader。

const TXT_DESC := "event.script.event_555_swords_to_ploughshares.c0"
const TXT_OPT0_DIS := "event.script.event_555_swords_to_ploughshares.c1"
const TXT_OPT1_DIS_0 := "event.script.event_555_swords_to_ploughshares.c2"
const TXT_OPT1_DIS_1 := "event.script.event_555_swords_to_ploughshares.c3"
const TXT_R0_A := "event.script.swords_to_ploughshares.txt_r0_a"
const TXT_R0_A_SOCEU := "event.script.swords_to_ploughshares.txt_r0_a_soceu"
const TXT_R0_A_UK := "event.script.swords_to_ploughshares.txt_r0_a_uk"
const TXT_R0_B := "event.script.event_555_swords_to_ploughshares.c4"
const TXT_R1 := "event.script.event_555_swords_to_ploughshares.c5"
const TXT_R2 := "event.script.event_555_swords_to_ploughshares.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var usa_name := "罗纳德·里根"
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null 			and world.empires[EmpireData.USA].current_leader != 0:
		usa_name = "吉米·卡特"
	event_def.description = tr(TXT_DESC).replace("{0}", usa_name)
	var opt := event_def.options
	var line := d.political_line
	if line <= 2 and ws.influence_prc >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 0 and line < 4:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_0))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_1))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var _c1 := ws.get_country_by_legacy_index(1)
	var c17 := ws.get_country_by_legacy_index(17)
	var c85 := ws.get_country_by_legacy_index(85)
	var c92 := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var num := 0
			for c in ws.countries:
				if c.has_tag("nato"):
					num += 1
			var num2 := 0
			for c in ws.countries:
				if (c.government == GameConstants.Government.SOCIALIST or c.government == GameConstants.Government.REFORMIST) and c.原版序号 in [92, 21, 85, 86, 87]:
					num2 += 1
			if num < 11 and (num2 >= 3 or (c21_has_soc_eu())):
				var text := tr(TXT_R0_A)
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -200)
				if c17 != null:
					c17.government = GameConstants.Government.REFORMIST
					c17.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					_leave_alliances(c17)
					c17.set_tag("对华贸易", true)
				if c85 != null and c85.has_tag("soc_eu"):
					text += tr(TXT_R0_A_SOCEU)
					if c17 != null:
						c17.set_tag("soc_eu", true)
					if _res(147) == 3 and (c92 == null or not c92.has_tag("soc_eu")):
						text += tr(TXT_R0_A_UK)
						if c92 != null:
							c92.set_tag("soc_eu", true)
							c92.set_tag("nato", false)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 100)
				_add_power(EmpireData.USA, -50)
				_add_relation(EmpireData.USA, -500)
				ws.influence_prc += 50
				_add(W.I_DIPLO, 10)
				context["result_text"] = text
			else:
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -200)
				_add_relation(EmpireData.USA, -200)
				context["result_text"] = tr(TXT_R0_B)
		1:
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, 10)
			_add_power(EmpireData.USA, 50)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_power(EmpireData.USA, 50)
			context["result_text"] = tr(TXT_R2)


func c21_has_soc_eu() -> bool:
	var c21 := ws.get_country_by_legacy_index(21)
	return c21 != null and c21.has_tag("soc_eu")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_555_swords_to_ploughshares.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_555",
	"nodesc": true,
	"num": 555,
	"priority": 55500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_555_swords_to_ploughshares.gd",
	"trigger": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "17"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1983.10.22"}, {"t": "DATE_AFTER", "key": "1983.11.1"}, {"t": "DATE_AFTER", "key": "1984.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
