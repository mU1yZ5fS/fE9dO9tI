extends "res://数据脚本/event_script_base.gd"

## 原作 Event672.cs：穷人战争（马里-布基纳法索边境战争，四选项）。
## 触发：ReqEventsDLC02.cs:339-341 —— c58.SubGosstroy==7 && IsSocialism(true,61) && DATE_AFTER 1985.9.1
##   复合条件 → trigger_script evaluate。
## 差异：ingamewars[85] 已有 war_85 WarDef，仍按 start_war 参数覆盖；
##   AmericanSupportAttacker → usa_side = GameConstants.WarSide.SIDE2、SovietSupportDefender → ussr_side=2。

const TXT_OPT0_DIS := "event.script.event_672_poor_war.c0"
const TXT_OPT1_DIS := "event.script.event_672_poor_war.c1"
const TXT_R0 := "event.script.event_672_poor_war.c2"
const TXT_R1 := "event.script.event_672_poor_war.c3"
const TXT_R2 := "event.script.event_672_poor_war.c4"
const TXT_R3 := "event.script.event_672_poor_war.c5"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var mali := ws.get_country_by_legacy_index(58)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if mali != null:
				_set_part(mali, 0, true)
			_start_war(500, 500)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			if mali != null:
				_set_part(mali, 0, true)
			_start_war(600, 400)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add_relation(EmpireData.USA, 50)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
		3:
			context["result_text"] = tr(TXT_R3)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19850901:
		return false
	var mali := world.get_country_by_legacy_index(58)
	var upper_volta := world.get_country_by_legacy_index(61)
	return mali != null and mali.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN \
		and upper_volta != null and world.is_socialism(upper_volta, true)


func _start_war(infl1: int, infl2: int) -> void:
	game.start_war(85, "马里", "布基纳法索", infl1, infl2, 1, 2)
	if ws.wars.size() > 85 and ws.wars[85] != null:
		ws.wars[85].name_war = "马里-布基纳法索战争"


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_672_poor_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_672",
	"num": 672,
	"priority": 67200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_672_poor_war.gd",
	"trigger_script": "res://数据脚本/事件效果/event_672_poor_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
