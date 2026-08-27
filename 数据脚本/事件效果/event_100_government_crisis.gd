extends "res://数据脚本/event_script_base.gd"

## 原作 Event100.cs：政府危机（孟加拉国艾尔沙德，三选项）。 ## 触发：TimeScript.cs:10850-10856 —— ##   ((日>=10 且 月>=12 且 年>=1983) 年>=1984) && c32.puppetOf<0。 ## 差异：选项显隐 prepare 动态改写。

const TXT_R0 := "event.script.event_100_government_crisis.c0"

const TXT_R1 := "event.script.event_100_government_crisis.c1"

const TXT_R2 := "event.script.event_100_government_crisis.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else GameConstants.PartySystem.PEOPLE_DEMOCRACY
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var coal := _coalition_percent(world)
	var left_party := party < GameConstants.PartySystem.PEOPLE_DEMOCRACY
	var opt := event_def.options
	if world.influence_prc >= 50 and agents >= 100 \
			and ((line < 3 and left_party) or (coal > 66 and party > GameConstants.PartySystem.NEW_DEMOCRACY)):
		_enable(opt[0], "通过支持反对派来煽动反政府集会")
	else:
		_disable(opt[0], "我们没有足够的力量")
	_enable(opt[1], "我们在国内有自己的问题")
	if (line > 0 and left_party) or (coal > 66 and party > GameConstants.PartySystem.NEW_DEMOCRACY):
		_enable(opt[2], "拨款支持政府")
	else:
		_disable(opt[2], "我们不能支持他们")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bangladesh := ws.get_country_by_legacy_index(32)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, 10)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -70)
			if bangladesh != null:
				bangladesh.set_tag("亲中", true)
				bangladesh.set_tag("亲美", false)
				bangladesh.set_tag("对华贸易", true)
				bangladesh.government = GameConstants.Government.REFORMIST
				bangladesh.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -80)
			if bangladesh != null:
				bangladesh.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -70)
			context["result_text"] = tr(TXT_R2)


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






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_100_government_crisis.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_100",
	"num": 100,
	"priority": 10000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_100_government_crisis.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1983.12.10"}, {"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "32"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
