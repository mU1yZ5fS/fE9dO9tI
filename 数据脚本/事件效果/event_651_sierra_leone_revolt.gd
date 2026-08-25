extends "res://数据脚本/event_script_base.gd"

## 原作 Event651.cs：树丛恶魔（塞拉利昂暴乱，三选项）。
## 触发：TimeScript.cs:11027-11033 —— (月>=5 且 年>=1982 或 年>=1983)。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线）。
##  - War 77：game.start_war(77,...) + fortnight_max=40（TickTime(40)），
##    SovietSupportDefender/AmericanSupportAttacker → ussr_side = GameConstants.WarSide.SIDE2 / usa_side = GameConstants.WarSide.SIDE1。
##  - c107=塞拉利昂；c107.parts[0]=true 保留。



const TXT_OPT0_DIS := "event.script.event_651_sierra_leone_revolt.c0"
const TXT_OPT1_DIS := "event.script.event_651_sierra_leone_revolt.c1"

const TXT_R0 := "event.script.event_651_sierra_leone_revolt.c2"

const TXT_R1 := "event.script.event_651_sierra_leone_revolt.c3"

const TXT_R2 := "event.script.event_651_sierra_leone_revolt.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var opt := event_def.options
	if line != 0 and line != 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var sierra := ws.get_country_by_legacy_index(107)
	if sierra != null:
		sierra.government = GameConstants.Government.AUTHORITARIAN
		sierra.sub_government = GameConstants.SubGovernment.NEOPATRIARCHAL
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if sierra != null:
				sierra.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -20)
			ws.influence_prc += 15
			_add(W.I_DIPLO, 15)
			_add_relation(EmpireData.USA, -100)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -40)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, -10)
			if sierra != null:
				while sierra.parts.size() <= 0:
					sierra.parts.append(false)
				sierra.parts[0] = true
			game.start_war(77, "人民党", "政府军", 200, 800, 0, 1)
			if ws.wars.size() > 77 and ws.wars[77] != null:
				ws.wars[77].name_war = "塞拉利昂内战"
				ws.wars[77].fortnight_max = 40
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_651_sierra_leone_revolt.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_651",
	"num": 651,
	"priority": 65100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_651_sierra_leone_revolt.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1982.5.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
