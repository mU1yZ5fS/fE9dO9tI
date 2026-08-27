extends "res://数据脚本/event_script_base.gd"

## 原作 Event99.cs：黄蝎（阿尔及利亚布迈丁继承危机，四选项）。 ## 触发：TimeScript.cs:10843-10849 —— ##   ((日>=10 且 月>=12 且 年>=1978) 年>=1979)。 ## 差异：选项显隐 prepare 动态改写；r1 的 data.oil_price++ 为局部指针死代码，跳过。

const TXT_R0 := "event.script.event_099_yellow_scorpion.c0"

const TXT_R1 := "event.script.event_099_yellow_scorpion.c1"

const TXT_R2 := "event.script.event_099_yellow_scorpion.c2"

const TXT_R3 := "event.script.event_099_yellow_scorpion.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else GameConstants.PartySystem.PEOPLE_DEMOCRACY
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var coal := _coalition_percent(world)
	var left_party := party < GameConstants.PartySystem.PEOPLE_DEMOCRACY
	var opt := event_def.options
	if (line < 3 and left_party) or (coal > 66 and party > GameConstants.PartySystem.NEW_DEMOCRACY):
		_enable(opt[0], "我们将帮助正统派反对修正主义")
	else:
		_disable(opt[0], "我看布迈丁的遗产也应该扬弃了")
	if (line > 1 and line < 4 and left_party) or (coal > 66 and party > GameConstants.PartySystem.NEW_DEMOCRACY):
		_enable(opt[1], "帮助乌季达帮的“自由派”崛起")
	else:
		_disable(opt[1], "布特弗利卡？祝他好运")
	if agents >= 60 and ((line >= 3 and left_party) or (coal > 66 and party > GameConstants.PartySystem.NEW_DEMOCRACY)):
		_enable(opt[2], "支持军队推出的改革者进行去布迈丁化")
	else:
		_disable(opt[2], "乌季达帮坐的时间有点太长了")
	_enable(opt[3], "袖手旁观")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var algeria := ws.get_country_by_legacy_index(40)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -60)
			_add(W.I_DIPLO, 10)
			ws.influence_prc += 10
			_add_power(EmpireData.USSR, -30)
			_add_relation(EmpireData.USSR, -100)
			if algeria != null:
				algeria.set_tag("亲苏", false)
				algeria.set_tag("亲中", true)
				algeria.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R0)
		1:
			_add_power(EmpireData.USSR, 10)
			_add(W.I_AGENTS, -40)
			_add_relation(EmpireData.USA, -30)
			_add_relation(EmpireData.USSR, 50)
			if algeria != null:
				algeria.set_tag("对华贸易", true)
				algeria.set_tag("亲苏", false)
			# data.oil_price++ 局部指针死代码，跳过
			context["result_text"] = tr(TXT_R1)
		2:
			_add_power(EmpireData.USSR, -30)
			_add(W.I_AGENTS, -60)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -300)
			_add_power(EmpireData.USA, 30)
			if algeria != null:
				algeria.set_tag("对华贸易", true)
				algeria.government = GameConstants.Government.AUTHORITARIAN
				algeria.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				algeria.set_tag("亲苏", false)
				algeria.set_tag("亲美", true)
			if d.size() > 143:
				d.oil_price -= 3
			context["result_text"] = tr(TXT_R2)
		3:
			if algeria != null:
				algeria.government = GameConstants.Government.AUTHORITARIAN
				algeria.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			context["result_text"] = tr(TXT_R3)


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






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_099_yellow_scorpion.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_099",
	"num": 99,
	"priority": 9900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_099_yellow_scorpion.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.12.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
