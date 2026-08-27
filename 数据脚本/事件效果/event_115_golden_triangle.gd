extends "res://数据脚本/event_script_base.gd"

## 原作 Event115.cs：金三角（三选项）。
## 触发：TimeScript.cs:10943-10947 ——
##   年>=1982 && c33.对华贸易 && !c33.亲中 && c34.对华贸易 && c22.对华贸易。
## 差异：
##  - result 5 为死代码（button_text[5]=""）→ 跳过；
##  - traits[0]==0 → trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT；loyality→loyalty。


const TXT_OPT1_DIS := "event.script.event_115_golden_triangle.c0"

const TXT_R0 := "event.script.event_115_golden_triangle.c1"
const TXT_R1 := "event.script.event_115_golden_triangle.c2"
const TXT_R2 := "event.script.event_115_golden_triangle.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else GameConstants.PartySystem.PEOPLE_DEMOCRACY
	var coal := _coalition_percent(world)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if (line >= 2 and party < GameConstants.PartySystem.PEOPLE_DEMOCRACY) or (coal > 66 and party > GameConstants.PartySystem.NEW_DEMOCRACY):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var burma := ws.get_country_by_legacy_index(33)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, 70)
			_add(W.I_AGENTS, -10)
			_add(W.I_CORRUPTION, 40)
			_add(W.I_PARTY_SUPPORT, -150)
			_add_power(EmpireData.USSR, -10)
			if burma != null:
				burma.set_tag("对华贸易", true)
			for p in ws.politicians:
				if p != null and p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 100
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -20)
			_add(W.I_ARMY, -20)
			_add(W.I_CORRUPTION, -20)
			if burma != null:
				burma.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R2)


## 原版 summa_3_2 复算：仅 party_system>7 时计算执政党(1)+盟友席位数 ×100 / 五党总席位数。
func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= GameConstants.PartySystem.NEW_DEMOCRACY:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_115_golden_triangle.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_115",
	"num": 115,
	"priority": 11500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_115_golden_triangle.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1982.1.1"}, {"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "33"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "33"}]}, {"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "34"}, {"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "22"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
