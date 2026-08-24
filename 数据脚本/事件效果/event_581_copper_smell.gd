extends "res://数据脚本/event_script_base.gd"

## 原作 Event581.cs：铜臭味（赞比亚，四选项）。 ## 触发：ReqEventForDLC02.cs:814-817 —— (日>=24 且 月>=10 且 年>=1983) (月>=11 且 年>=1983) 年>=1984 ##   → DATE_AFTER 1983.10.24。 ## 差异： ##  - 选项显隐 prepare 动态改写；resultOfEvents[352]/[361]/[500] 缺省按原版 int 默认 0； ##  - names1+names2 → _leader_name()（同 Event650 约定）；data.industry → W.I_INDUSTRY； ##  - JoinECON → 仅 econ 标签 + social_stability=1000；name → chinese_name； ##  - load_scene_after_click + data.ending_route=13 → game.queue_ending_after_event(13)。



const TXT_OPT0_DIS := "event.script.event_581_copper_smell.c0"
const TXT_OPT1_DIS := "event.script.event_581_copper_smell.c1"
const TXT_OPT2_DIS := "event.script.event_581_copper_smell.c2"

const TXT_R0_A := "event.script.event_581_copper_smell.c3"
const TXT_R0_B := "event.script.event_581_copper_smell.c4"
const TXT_R0_C := "event.script.event_581_copper_smell.c5"
const TXT_R0_D := "event.script.event_581_copper_smell.c6"
const TXT_R1 := "event.script.event_581_copper_smell.c7"
const TXT_R2 := "event.script.event_581_copper_smell.c8"
const TXT_R3_A := "event.script.event_581_copper_smell.c9"
const TXT_R3_AU := "event.script.event_581_copper_smell.c10"
const TXT_R3_HARD := "event.script.event_581_copper_smell.c11"
const TXT_R3_SA := "event.script.event_581_copper_smell.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var c131 := world.get_country_by_legacy_index(131)
	var r352 := int(world.completed_event_ids.get("event_352", 0))
	var r361 := int(world.completed_event_ids.get("event_361", 0))
	var opt := event_def.options
	if line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 2 and c131 != null and (c131.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or c131.sub_government == GameConstants.SubGovernment.NEO_FASCIST):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if data.size() > W.I_INDUSTRY and data.industry >= 1200 and r352 == 2 and r361 >= 0 and r361 <= 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c124 := ws.get_country_by_legacy_index(124)
	var china := ws.get_country_by_legacy_index(1)
	var c131 := ws.get_country_by_legacy_index(131)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var tname := _leader_name()
			var text := tr(TXT_R0_A) + tname + tr(TXT_R0_B) + tname + tr(TXT_R0_C) + tname + tr(TXT_R0_D)
			_add(W.I_BUDGET, -50)
			if c124 != null:
				c124.government = GameConstants.Government.SOCIALIST
				c124.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c124)
				c124.set_tag("亲中", true)
				c124.set_tag("对华贸易", true)
			if china != null and china.has_tag("econ") and c124 != null:
				c124.set_tag("econ", true)
				c124.social_stability = 1000
			ws.influence_prc += 20
			_add(W.I_DIPLO, 20)
			context["result_text"] = text
		1:
			if c124 != null:
				c124.government = GameConstants.Government.AUTHORITARIAN
				c124.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c124)
				c124.set_tag("对华贸易", true)
				c124.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
			_add(W.I_BUDGET, 100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(TXT_R1)
		2:
			if c124 != null:
				c124.government = GameConstants.Government.AUTHORITARIAN
				c124.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				_leave_alliances(c124)
				c124.set_tag("对华贸易", true)
			game.queue_ending_after_event(13)
			_add(W.I_BUDGET, 100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(TXT_R2)
		3:
			var text := tr(TXT_R3_A)
			var r500 := int(ws.completed_event_ids.get("event_500", 0))
			if r500 == 0:
				text += tr(TXT_R3_AU)
				if c124 != null:
					c124.government = GameConstants.Government.REFORMIST
					c124.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					_leave_alliances(c124)
					c124.set_tag("对华贸易", true)
					c124.set_tag("okb", true)
				context["result_text"] = text
			else:
				text += tr(TXT_R3_HARD)
				if c131 != null and c131.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
					text += tr(TXT_R3_SA)
					if c124 != null:
						c124.government = GameConstants.Government.AUTHORITARIAN
						c124.sub_government = GameConstants.SubGovernment.NEO_FASCIST
						_leave_alliances(c124)
						c124.chinese_name = "北罗得西亚"
						c124.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
				context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_581_copper_smell.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_581",
	"num": 581,
	"priority": 58100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_581_copper_smell.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.10.24"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
