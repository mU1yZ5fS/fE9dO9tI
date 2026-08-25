extends "res://数据脚本/event_script_base.gd"

## 原作 Event577.cs：美国南方邻居的危机（墨西哥，六选项含一个恒禁用）。 ## 触发：ReqEventForDLC02.cs:794-797 —— (日>=30 且 月>=1 且 年>=1982) (月>=2 且 年>=1982) 年>=1983 ##   → DATE_AFTER 1982.1.30。 ## 差异： ##  - 选项显隐 prepare 动态改写；proprc → 亲中；influencePRC → ws.influence_prc； ##  - data.war_support → W.I_WAR_SUPPORT；data.industry? 无（581 用）；cw → 内战中； ##  - 结果前全局 c140.gov=3/sub=12 对所有结果生效。



const TXT_OPT0_DIS := "event.script.event_577_mexico_crisis.c0"
const TXT_OPT1_DIS_68 := "event.script.event_577_mexico_crisis.c1"
const TXT_OPT1_DIS_POP := "event.script.event_577_mexico_crisis.c2"
const TXT_OPT2_DIS_NO := "event.script.event_577_mexico_crisis.c3"
const TXT_OPT2_DIS_CANT := "event.script.event_577_mexico_crisis.c4"
const TXT_OPT3_DIS := "event.script.event_577_mexico_crisis.c5"
const TXT_OPT5 := "event.script.event_577_mexico_crisis.c6"

const TXT_R0 := "event.script.event_577_mexico_crisis.c7"
const TXT_R1_A := "event.script.event_577_mexico_crisis.c8"
const TXT_R1_MANY := "event.script.event_577_mexico_crisis.c9"
const TXT_R1_FEW := "event.script.event_577_mexico_crisis.c10"
const TXT_R2 := "event.script.event_577_mexico_crisis.c11"
const TXT_R3 := "event.script.event_577_mexico_crisis.c12"
const TXT_R4 := "event.script.event_577_mexico_crisis.c13"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var num := _count_proprc(world)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if line == 0 and num > 4 and world.influence_prc >= 800:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 1 and line <= 2 and world.influence_prc >= 500:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_68))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_POP))
	if line == 3 and china != null and china.has_tag("seato") and world.empires.size() > EmpireData.USA \
			and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USA].relations >= 800:
		_enable(opt[2], event_def.options[2].text)
	elif line < 3:
		_disable(opt[2], tr(TXT_OPT2_DIS_NO))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_CANT))
	if data.size() > W.I_WAR_SUPPORT and data.war_support >= 700:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)
	_disable(opt[5], tr(TXT_OPT5))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c140 := ws.get_country_by_legacy_index(140)
	if c140 != null:
		c140.government = GameConstants.Government.LIBERAL
		c140.sub_government = GameConstants.SubGovernment.NEOLIBERAL
	var num := _count_proprc(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -100)
			context["result_text"] = tr(TXT_R0)
		1:
			var text := tr(TXT_R1_A)
			if num > 4:
				text += tr(TXT_R1_MANY)
				if c140 != null:
					c140.内战中 = true
			else:
				text += tr(TXT_R1_FEW)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -100)
			context["result_text"] = text
		2:
			if c140 != null:
				c140.内战中 = true
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(TXT_R3)
		4:
			context["result_text"] = tr(TXT_R4)
		5:
			context["result_text"] = tr(TXT_OPT5)


func _count_proprc(world: WorldState) -> int:
	var num := 0
	for i in range(71, 84):
		var c := world.get_country_by_legacy_index(i)
		if c != null and c.has_tag("亲中"):
			num += 1
	for j in range(138, 150):
		if j == 145:
			continue
		var c := world.get_country_by_legacy_index(j)
		if c != null and c.has_tag("亲中"):
			num += 1
	return num



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_577_mexico_crisis.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_577",
	"num": 577,
	"priority": 57700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_577_mexico_crisis.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1982.1.30"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
