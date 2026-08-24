extends "res://数据脚本/event_script_base.gd"

## 原作 Event573.cs：地球那边的土地（澳大利亚审视，四选项）。 ## 触发：ReqEventForDLC02.cs:779-782 —— (月>=8 且 年>=1982) 年>=1983 → DATE_AFTER 1982.8.1。 ## 差异： ##  - 选项按 data.political_line（政治路线）动态显隐； ##  - Torg → 对华贸易；modifies[6].active → ws.modifiers[6].is_active； ##  - resultOfEvents[573] 缺省按原版 int 默认 0 处理。



const TXT_OPT0_DIS := "event.script.event_573_land_beyond_earth.c0"
const TXT_OPT1_DIS := "event.script.event_573_land_beyond_earth.c1"
const TXT_OPT2_DIS := "event.script.event_573_land_beyond_earth.c2"

const TXT_R0 := "event.script.event_573_land_beyond_earth.c3"
const TXT_R1 := "event.script.event_573_land_beyond_earth.c4"
const TXT_R2_A := "event.script.event_573_land_beyond_earth.c5"
const TXT_R2_B := "event.script.event_573_land_beyond_earth.c6"
const TXT_R2_C := "event.script.event_573_land_beyond_earth.c7"
const TXT_R3 := "event.script.event_573_land_beyond_earth.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line > 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line != 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if c135 != null:
				c135.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 100)
			_add_power(EmpireData.USA, 10)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -80)
			if c135 != null:
				c135.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			context["result_text"] = tr(TXT_R1)
		2:
			var text := tr(TXT_R2_A)
			if not _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
				text += tr(TXT_R2_B)
			text += tr(TXT_R2_C)
			_add(W.I_AGENTS, -100)
			context["result_text"] = text
		3:
			context["result_text"] = tr(TXT_R3)


func _mod_active(id: int) -> bool:
	return ws.modifiers.size() > id and ws.modifiers[id] != null and ws.modifiers[id].is_active



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_573_land_beyond_earth.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_573",
	"num": 573,
	"priority": 57300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_573_land_beyond_earth.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1982.8.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
