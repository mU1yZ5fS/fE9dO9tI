extends "res://数据脚本/event_script_base.gd"

## 原作 Event345.cs：肩上的那块牌子。触发：ReqEventForDLC02.cs:607-610 —— 日期>=1984.6.5。
## 差异：
##  - 原版 VariantsOfEvents 动态销毁按钮：按 data.political_line（政治路线）、resultOfEvents[514]、modifies[6].active
##    决定两个按钮文案/可用性，这里在 prepare 动态 _enable/_disable 复刻；
##  - 原版 TextOfEvents 按 vietnampeace / resultOfEvents[378] / allcountries[10].puppetOf 动态拼描述；
##    vietnampeace 端口建模说明 → 用 global_flags 同名键近似（项目既有约定）；
##  - 原版对 old_modify_desc[50] 的拼接是展示文案，Godot 由修正目录统一管理，这里跳过并注释原文。


const TXT_DESC_BASE := "event.script.event_345_shoulder_boards.c0"
const TXT_DESC_VISITS := "event.script.event_345_shoulder_boards.c1"
const TXT_DESC_NO_VISITS := "event.script.event_345_shoulder_boards.c2"
const TXT_DESC_TAIL := "event.script.event_345_shoulder_boards.c3"

const TXT_OPT0_EN := "event.script.event_345_shoulder_boards.c4"
const TXT_OPT0_DIS := "event.script.event_345_shoulder_boards.c5"
const TXT_OPT1_EN := "event.script.event_345_shoulder_boards.c6"
const TXT_OPT1_DIS := "event.script.event_345_shoulder_boards.c7"

const TXT_R0 := "event.script.event_345_shoulder_boards.c8"
const TXT_R1 := "event.script.event_345_shoulder_boards.c9"
const TXT_R1_NORMAL := "event.script.event_345_shoulder_boards.c10"
const TXT_R1_SPECIAL := "event.script.event_345_shoulder_boards.c11"

# 原版 old_modify_desc[50] 展示文案（跳过运行时覆盖，仅保留原文供溯源）：
# |没有军衔的军队：|人民支持度+0.3，军力+0.2，干涉点数+0.2
# |恢复军衔：|军力+0.5，干涉点数+0.2，腐败+0.2，资金-0.1


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var korea := world.get_country_by_legacy_index(10)
	var desc := tr(TXT_DESC_BASE)
	var res378 := int(world.completed_event_ids.get("event_378", 0))
	if world.get_flag("vietnampeace") and res378 != 2 and (korea == null or korea.puppet_of != GameConstants.LegacySlot.CHINA):
		desc += tr(TXT_DESC_VISITS)
	else:
		desc += tr(TXT_DESC_NO_VISITS)
	desc += tr(TXT_DESC_TAIL)
	event_def.description = desc

	var opt := event_def.options
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var pol := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var res514 := int(world.completed_event_ids.get("event_514", 0))
	if (pol <= 2 and res514 != 1) or res514 == 2:
		_enable(opt[0], tr(TXT_OPT0_EN))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	var mod6 := _modifier_active(world, 6)
	if (pol >= 2 and res514 != 2) or res514 == 1 or not mod6:
		_enable(opt[1], tr(TXT_OPT1_EN))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			for p in ws.politicians:
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.power += 25
					p.loyalty += 50
			_add(W.I_MANPOWER, 15)
			_add(W.I_DIPLO, 25)
			context["result_text"] = tr(TXT_R0)
		1:
			var text := tr(TXT_R1)
			var china := ws.get_country_by_legacy_index(1)
			if china != null and china.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST:
				text += tr(TXT_R1_NORMAL)
			else:
				text += tr(TXT_R1_SPECIAL)
			for p in ws.politicians:
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.power -= 25
					p.loyalty -= 50
			_add_relation(0, 25)
			_add(W.I_MANPOWER, 15)
			context["result_text"] = text


func _modifier_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null and world.modifiers[index].is_active






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_345_shoulder_boards.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_345",
	"nodesc": true,
	"num": 345,
	"priority": 34500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_345_shoulder_boards.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1984.6.5"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
