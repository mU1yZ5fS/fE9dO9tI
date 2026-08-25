extends "res://数据脚本/event_script_base.gd"

const T_664_0 := "event.script.event_664_burma_brother_shuangshi.c0"
const T_664_1 := "event.script.event_664_burma_brother_shuangshi.c1"
const T_664_2 := "event.script.event_664_burma_brother_shuangshi.c2"
const T_664_3 := "event.script.event_664_burma_brother_shuangshi.c3"
const T_664_4 := "event.script.event_664_burma_brother_shuangshi.c4"
const T_664_5 := "event.script.event_664_burma_brother_shuangshi.c5"
const T_664_7 := "event.script.event_664_burma_brother_shuangshi.c6"
const T_664_8 := "event.script.event_664_burma_brother_shuangshi.c7"
const T_664_9 := "event.script.event_664_burma_brother_shuangshi.c8"
const T_664_10 := "event.script.event_664_burma_brother_shuangshi.c9"
const T_664_11 := "event.script.event_664_burma_brother_shuangshi.c10"
const T_664_12 := "event.script.event_664_burma_brother_shuangshi.c11"
const T_664_13 := "event.script.event_664_burma_brother_shuangshi.c12"
const T_664_14 := "event.script.event_664_burma_brother_shuangshi.c13"
const T_664_15 := "event.script.event_664_burma_brother_shuangshi.c14"
const T_664_16 := "event.script.event_664_burma_brother_shuangshi.c15"


## 原作 Event664.cs：我的哥哥叫双狮牌，我的妈妈是死去的孔雀（缅甸，三选项）。 ## 触发：TimeScript.cs:11121-11126 —— (日>=1 且 月>=6 且 年>=1985) (月>=6 且 年>=1985) 年>=1986 ##   && 缅甸 SubGosstroy==11。 ## 差异： ##  - 死代码 result_num==5 跳过。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = tr(T_664_0)
	event_def.description = tr(T_664_1)
	var opt := event_def.options
	_enable(opt[0], tr(T_664_2))
	_enable(opt[1], tr(T_664_3))
	if line > 0 and line < 4:
		_enable(opt[2], tr(T_664_4))
	else:
		_disable(opt[2], tr(T_664_5))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var burma := ws.get_country_by_legacy_index(33)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set_part(burma, 0, true)
			_set_part(burma, 1, true)
			_start_war(83, tr(T_664_10), tr(T_664_11), 400, 600, 0, 0, tr(T_664_9))
			context["result_text"] = tr(T_664_8)
		1:
			if burma != null:
				burma.sub_government = GameConstants.SubGovernment.TITOIST
			_set_part(burma, 1, true)
			if burma != null:
				burma.set_tag("亲中", true)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(T_664_12)
		2:
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 30)
			_set_part(burma, 0, true)
			_set_part(burma, 1, true)
			_start_war(83, tr(T_664_14), tr(T_664_15), 700, 300, 0, 0, tr(T_664_13))
			context["result_text"] = tr(T_664_16)




func _set_part(country: CountryData, index: int, value: bool) -> void:
	if country == null:
		return
	while country.parts.size() <= index:
		country.parts.append(false)
	country.parts[index] = value


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_664_burma_brother_shuangshi.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_664",
	"num": 664,
	"priority": 66400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_664_burma_brother_shuangshi.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.6.1"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 11, "target": "33"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
