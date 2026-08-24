extends "res://数据脚本/event_script_base.gd"

## 原作 Event576.cs：我们将会获得胜利，并且我们赢得过胜利（澳大利亚风暴，三选项）。
## 触发：Event575.cs:111 —— 结果1 非欧社联分支 number_event = 576；
##   Godot 由 event_575 的 execute 调 EventEngine.enqueue_chain(["event_576"])，本事件无自动触发。
## 差异：
##  - 描述按 resultOfEvents[573] 拼接（缺省按原版 int 默认 0）；
##  - Gosstroy → government；Vyshi → 亲美；Torg → 对华贸易；puppetOf → puppet_of；
##  - LeaveAlliances 用基类 _leave_alliances。


const TXT_DESC_BASE := "event.script.event_576_australia_revolution.c0"
const TXT_DESC_R2 := "event.script.event_576_australia_revolution.c1"
const TXT_DESC_R1 := "event.script.event_576_australia_revolution.c2"
const TXT_DESC_TAIL := "event.script.event_576_australia_revolution.c3"

const TXT_OPT0_DIS_NO := "event.script.event_576_australia_revolution.c4"
const TXT_OPT0_DIS_RIOT := "event.script.event_576_australia_revolution.c5"
const TXT_OPT1_DIS := "event.script.event_576_australia_revolution.c6"

const TXT_R0_INTRO := "event.script.event_576_australia_revolution.c7"
const TXT_R0_TROT := "event.script.event_576_australia_revolution.c8"
const TXT_R0_HILL := "event.script.event_576_australia_revolution.c9"
const TXT_R0_CLANCY := "event.script.event_576_australia_revolution.c10"
const TXT_R0_TAIL := "event.script.event_576_australia_revolution.c11"
const TXT_R1 := "event.script.event_576_australia_revolution.c12"
const TXT_R2_A := "event.script.event_576_australia_revolution.c13"
const TXT_R2_B := "event.script.event_576_australia_revolution.c14"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var r573 := int(world.completed_event_ids.get("event_573", 0))
	var c50 := world.get_country_by_legacy_index(50)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 0
	var desc := tr(TXT_DESC_BASE)
	if r573 == 2:
		desc += tr(TXT_DESC_R2)
	elif r573 == 1:
		desc += tr(TXT_DESC_R1)
	desc += tr(TXT_DESC_TAIL)
	event_def.description = desc
	var opt := event_def.options
	if line < 2 and (r573 == 1 or r573 == 2) and c50 != null and c50.government == GameConstants.Government.SOCIALIST:
		_enable(opt[0], event_def.options[0].text)
	elif c50 == null or c50.government != GameConstants.Government.SOCIALIST:
		_disable(opt[0], tr(TXT_OPT0_DIS_NO))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_RIOT))
	if line > 1 and r573 == 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var c134 := ws.get_country_by_legacy_index(134)
	var c159 := ws.get_country_by_legacy_index(159)
	var c92 := ws.get_country_by_legacy_index(92)
	var r573 := int(ws.completed_event_ids.get("event_573", 0))
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -200)
			var text := tr(TXT_R0_INTRO)
			if c92 != null and c92.sub_government == GameConstants.SubGovernment.TROTSKYIST:
				text += tr(TXT_R0_TROT)
				if c135 != null:
					c135.government = GameConstants.Government.SOCIALIST
					c135.sub_government = GameConstants.SubGovernment.TROTSKYIST
					_leave_alliances(c135)
					c135.set_tag("对华贸易", true)
				if c134 != null:
					c134.puppet_of = GameConstants.LegacySlot.NONE
			elif r573 == 2:
				text += tr(TXT_R0_HILL)
				if c135 != null:
					c135.government = GameConstants.Government.SOCIALIST
					c135.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					_leave_alliances(c135)
					c135.set_tag("对华贸易", true)
					c135.set_tag("亲中", true)
				if c134 != null:
					c134.puppet_of = GameConstants.LegacySlot.NONE
				ws.influence_prc += 50
			elif r573 == 1:
				text += tr(TXT_R0_CLANCY)
				if c135 != null:
					c135.government = GameConstants.Government.SOCIALIST
					c135.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
					_leave_alliances(c135)
					c135.set_tag("对华贸易", true)
					c135.set_tag("亲苏", true)
				if c134 != null:
					c134.puppet_of = GameConstants.LegacySlot.NONE
				_add_power(EmpireData.USSR, 100)
			text += tr(TXT_R0_TAIL)
			_add_relation(EmpireData.USA, -300)
			_add_power(EmpireData.USA, -100)
			context["result_text"] = text
		1:
			_add(W.I_BUDGET, -180)
			_add(W.I_AGENTS, -150)
			if c135 != null:
				c135.government = GameConstants.Government.REFORMIST
				c135.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				_leave_alliances(c135)
				c135.set_tag("对华贸易", true)
				c135.set_tag("亲中", true)
			context["result_text"] = tr(TXT_R1)
		2:
			var text := tr(TXT_R2_A)
			if c135 != null:
				c135.government = GameConstants.Government.AUTHORITARIAN
				c135.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c135)
				c135.set_tag("亲美", true)
			text += tr(TXT_R2_B)
			if c159 != null:
				c159.government = GameConstants.Government.AUTHORITARIAN
				c159.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(c159)
				c159.puppet_of = GameConstants.LegacySlot.AUSTRALIA
			context["result_text"] = text



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_576_australia_revolution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_576",
	"num": 576,
	"priority": 57600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_576_australia_revolution.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
