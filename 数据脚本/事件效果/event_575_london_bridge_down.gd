extends "res://数据脚本/event_script_base.gd"

## 原作 Event575.cs：伦敦桥倒下了（澳大利亚共和，二选项）。 ## 触发：ReqEventForDLC02.cs:789-792 —— c92.Gosstroy==1 (c92.Gosstroy==2 && c92.isSocEU)。 ## 差异： ##  - 描述按 c92 政体/标签与 c135 子政体动态拼接；resultOfEvents[573]==1 追加提问； ##  - Vyshi → 亲美；isSocEU → soc_eu；Torg → 对华贸易；cw → 内战中； ##  - 选项1 非欧社联分支 load_scene_after_click+number_event=576 → EventEngine.enqueue_chain(["event_576"])。


const TXT_DESC_BASE := "event.script.event_575_london_bridge_down.c0"
const TXT_DESC_HARD := "event.script.event_575_london_bridge_down.c1"
const TXT_DESC_SOFT := "event.script.event_575_london_bridge_down.c2"
const TXT_DESC_TROT := "event.script.event_575_london_bridge_down.c3"
const TXT_DESC_HAWKE := "event.script.event_575_london_bridge_down.c4"
const TXT_DESC_FRASER := "event.script.event_575_london_bridge_down.c5"
const TXT_DESC_ASK := "event.script.event_575_london_bridge_down.c6"

const TXT_OPT0_DIS := "event.script.event_575_london_bridge_down.c7"

const TXT_R0 := "event.script.event_575_london_bridge_down.c8"
const TXT_R0_EU := "event.script.event_575_london_bridge_down.c9"
const TXT_R1_NORMAL := "event.script.event_575_london_bridge_down.c10"
const TXT_R1_EU := "event.script.event_575_london_bridge_down.c11"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var c92 := world.get_country_by_legacy_index(92)
	var c135 := world.get_country_by_legacy_index(135)
	var r573 := int(world.completed_event_ids.get("event_573", 0))
	var desc := tr(TXT_DESC_BASE)
	if c92 != null and (c92.government == GameConstants.Government.REFORMIST or c92.government == GameConstants.Government.SOCIALIST) and c92.sub_government != GameConstants.SubGovernment.TROTSKYIST \
			and not c92.has_tag("soc_eu") and not c92.has_tag("nato"):
		desc += tr(TXT_DESC_HARD)
	elif c92 != null and c92.government == GameConstants.Government.REFORMIST and c92.has_tag("soc_eu"):
		desc += tr(TXT_DESC_SOFT)
	else:
		desc += tr(TXT_DESC_TROT)
	if c135 != null and c135.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT:
		desc += tr(TXT_DESC_HAWKE)
	else:
		desc += tr(TXT_DESC_FRASER)
	if r573 == 1:
		desc += tr(TXT_DESC_ASK)
	event_def.description = desc
	var opt := event_def.options
	if r573 == 1 and c135 != null and not c135.has_tag("亲美"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var c136 := ws.get_country_by_legacy_index(136)
	var c85 := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			if c135 != null:
				_leave_alliances(c135)
				c135.government = GameConstants.Government.REFORMIST
				c135.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				c135.set_tag("对华贸易", true)
				c135.set_tag("亲中", true)
			_add_relation(EmpireData.USA, -200)
			_add_power(EmpireData.USA, -50)
			if c85 != null and c85.has_tag("soc_eu"):
				var text := tr(TXT_R0) + tr(TXT_R0_EU)
				if c135 != null:
					c135.set_tag("soc_eu", true)
				if c136 != null:
					_leave_alliances(c136)
					c136.government = GameConstants.Government.REFORMIST
					c136.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					c136.内战中 = true
					c136.set_tag("对华贸易", true)
					c136.set_tag("soc_eu", true)
				context["result_text"] = text
			else:
				context["result_text"] = tr(TXT_R0)
		1:
			if c135 != null:
				c135.set_tag("亲美", false)
				c135.government = GameConstants.Government.REFORMIST
			if c85 != null and c85.has_tag("soc_eu"):
				if c135 != null:
					c135.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
					c135.set_tag("soc_eu", true)
				if c136 != null:
					_leave_alliances(c136)
					c136.government = GameConstants.Government.REFORMIST
					c136.内战中 = true
					c136.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					c136.set_tag("soc_eu", true)
				context["result_text"] = tr(TXT_R1_EU)
			else:
				if c135 != null:
					c135.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				EventEngine.enqueue_chain(["event_576"])
				context["result_text"] = tr(TXT_R1_NORMAL)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_575_london_bridge_down.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_575",
	"num": 575,
	"priority": 57500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_575_london_bridge_down.gd",
	"trigger": [{"t": "ANY", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 1, "target": "92"}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 2, "target": "92"}, {"t": "COUNTRY_HAS_TAG", "key": "soc_eu", "target": "92"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
