extends "res://数据脚本/event_script_base.gd"

## 原作 Event654.cs：西非巨人——第二幕（尼日利亚1983大选，分支选项 4/6）。
## 触发：TimeScript.cs 11049-11053 —— (月>=8 且 年>=1983 或 年>=1984)。
## 差异：
##  - TextOfEvents 按 c60.sub_government == GameConstants.SubGovernment.NEOLIBERAL/4 动态拼接；string.Format 的 {1} 用 GDScript format 保留原格式串。
##  - VariantsOfEvents 按 c60.sub_government == GameConstants.SubGovernment.NEOLIBERAL 分支为 4 选项，否则 6 选项；prepare 用静态缓存安全恢复 6 选项数组。
##  - 选项显隐 prepare 动态改写（data56 / modifies[3] / data31 / resultOfEvents[653] / num 社会主义+改良+左翼民族主义计数）。
##  - OilProd += 100f 已建模（ws.oil_prod）。
##  - 死代码 result 5 测试分支在 sub12 分支无效果；sub12 的 result 3 与 else 的 result 5 为纯文本选项，已复刻。

static var _saved_full_options: Array[EventOption] = []

const TXT_DESC_INTRO := "event.script.event_654_west_african_giant_act2.c0"
const TXT_DESC_SUB12 := "event.script.event_654_west_african_giant_act2.c1"
const TXT_DESC_SUB4 := "event.script.event_654_west_african_giant_act2.c2"
const TXT_DESC_MID_FMT := "event.script.event_654_west_african_giant_act2.c3"
const TXT_DESC_MID_COND := "event.script.event_654_west_african_giant_act2.c4"

const TXT_OPT0_DIS := "event.script.event_654_west_african_giant_act2.c5"
const TXT_OPT1_DIS := "event.script.event_654_west_african_giant_act2.c6"
const TXT_OPT2_DIS := "event.script.event_654_west_african_giant_act2.c7"

const TXT_ELSE0 := "event.script.event_654_west_african_giant_act2.c8"
const TXT_ELSE0_DIS := "event.script.event_654_west_african_giant_act2.c9"
const TXT_ELSE1 := "event.script.event_654_west_african_giant_act2.c10"
const TXT_ELSE1_DIS := "event.script.event_654_west_african_giant_act2.c11"
const TXT_ELSE2 := "event.script.event_654_west_african_giant_act2.c12"
const TXT_ELSE2_DIS := "event.script.event_654_west_african_giant_act2.c13"
const TXT_ELSE3 := "event.script.event_654_west_african_giant_act2.c14"
const TXT_ELSE3_DIS := "event.script.event_654_west_african_giant_act2.c15"
const TXT_ELSE4 := "event.script.event_654_west_african_giant_act2.c16"
const TXT_ELSE4_DIS := "event.script.event_654_west_african_giant_act2.c17"
const TXT_ELSE5 := "event.script.event_654_west_african_giant_act2.c18"

const TXT_R0_SUB12 := "event.script.event_654_west_african_giant_act2.c19"
const TXT_R1_SUB12 := "event.script.event_654_west_african_giant_act2.c20"
const TXT_R2_SUB12 := "event.script.event_654_west_african_giant_act2.c21"
const TXT_R3_SUB12 := "event.script.event_654_west_african_giant_act2.c22"
const TXT_R0_ELSE := "event.script.event_654_west_african_giant_act2.c23"
const TXT_R1_ELSE := "event.script.event_654_west_african_giant_act2.c24"
const TXT_R2_ELSE := "event.script.event_654_west_african_giant_act2.c25"
const TXT_R3_ELSE := "event.script.event_654_west_african_giant_act2.c26"
const TXT_R4_ELSE := "event.script.event_654_west_african_giant_act2.c27"
const TXT_R5_ELSE := "event.script.event_654_west_african_giant_act2.c28"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.is_empty():
		return
	var nigeria := world.get_country_by_legacy_index(60)
	var is_sub12 := nigeria != null and nigeria.sub_government == GameConstants.SubGovernment.NEOLIBERAL
	var desc := tr(TXT_DESC_INTRO)
	if is_sub12:
		desc += tr(TXT_DESC_SUB12)
	elif nigeria != null and nigeria.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT:
		desc += tr(TXT_DESC_SUB4)
	var mid_cond := tr(TXT_DESC_MID_COND) if is_sub12 else ""
	desc += tr(TXT_DESC_MID_FMT).format(["\n", mid_cond])
	event_def.description = desc
	if _saved_full_options.is_empty() and event_def.options.size() >= 6:
		_saved_full_options = event_def.options.duplicate()
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var war_support := data.war_support if data.size() > W.I_WAR_SUPPORT else 0
	var prev_653 := int(world.completed_event_ids.get("event_653", 0))
	var opt := event_def.options
	if is_sub12:
		if event_def.options.size() > 4:
			event_def.options.resize(4)
		if line >= 2:
			_enable(opt[0], event_def.options[0].text)
		else:
			_disable(opt[0], tr(TXT_OPT0_DIS))
		if line <= 2 and line >= 1:
			_enable(opt[1], event_def.options[1].text)
		else:
			_disable(opt[1], tr(TXT_OPT1_DIS))
		if line <= 3 and line >= 1 and not _modifier_active(world, 3) and war_support >= 600 and prev_653 != 3:
			_enable(opt[2], event_def.options[2].text)
		else:
			_disable(opt[2], tr(TXT_OPT2_DIS))
		_enable(opt[3], event_def.options[3].text)
		return
	if event_def.options.size() < 6 and _saved_full_options.size() >= 6:
		event_def.options = _saved_full_options.duplicate()
		opt = event_def.options
	if line >= 2:
		_enable(opt[0], tr(TXT_ELSE0))
	else:
		_disable(opt[0], tr(TXT_ELSE0_DIS))
	if line <= 3 and line >= 1:
		_enable(opt[1], tr(TXT_ELSE1))
	else:
		_disable(opt[1], tr(TXT_ELSE1_DIS))
	if line <= 3 and line >= 1:
		_enable(opt[2], tr(TXT_ELSE2))
	else:
		_disable(opt[2], tr(TXT_ELSE2_DIS))
	var num := _left_count(world)
	if line <= 2 and num > 5:
		_enable(opt[3], tr(TXT_ELSE3))
	else:
		_disable(opt[3], tr(TXT_ELSE3_DIS))
	if line <= 3 and line >= 1 and not _modifier_active(world, 3) and war_support >= 600 and prev_653 != 3:
		_enable(opt[4], tr(TXT_ELSE4))
	else:
		_disable(opt[4], tr(TXT_ELSE4_DIS))
	_enable(opt[5], tr(TXT_ELSE5))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	var opt := int(context.get("option_index", -1))
	var is_sub12 := nigeria != null and nigeria.sub_government == GameConstants.SubGovernment.NEOLIBERAL
	if is_sub12:
		match opt:
			0:
				if nigeria != null:
					_leave_alliances(nigeria)
					nigeria.government = GameConstants.Government.LIBERAL
					nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
					nigeria.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -40)
				_add(W.I_AGENTS, -40)
				ws.oil_prod += 100.0  # Event654.cs OilProd
				context["result_text"] = tr(TXT_R0_SUB12)
			1:
				if nigeria != null:
					_leave_alliances(nigeria)
					nigeria.government = GameConstants.Government.LIBERAL
					nigeria.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
					nigeria.set_tag("对华贸易", true)
				_add(W.I_BUDGET, -160)
				_add(W.I_AGENTS, -160)
				ws.oil_prod += 100.0  # Event654.cs OilProd
				if nigeria != null:
					nigeria.stab = 1
				context["result_text"] = tr(TXT_R1_SUB12)
			2:
				if nigeria != null:
					_leave_alliances(nigeria)
					nigeria.government = GameConstants.Government.LIBERAL
					nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
					nigeria.内战中 = true
					if int(ws.completed_event_ids.get("event_653", 0)) == 2:
						nigeria.prc_power += 20
					else:
						nigeria.prc_power = 20
				_add(W.I_BUDGET, -100)
				_add(W.I_AGENTS, -100)
				_add(W.I_ARMY, -100)
				context["result_text"] = tr(TXT_R2_SUB12)
			3:
				context["result_text"] = tr(TXT_R3_SUB12)
		return
	match opt:
		0:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.oil_prod += 100.0  # Event654.cs OilProd
			context["result_text"] = tr(TXT_R0_ELSE)
		1:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.oil_prod += 100.0  # Event654.cs OilProd
			context["result_text"] = tr(TXT_R1_ELSE)
		2:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.REFORMIST
				nigeria.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -160)
			_add(W.I_AGENTS, -160)
			ws.oil_prod += 100.0  # Event654.cs OilProd
			context["result_text"] = tr(TXT_R2_ELSE)
		3:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.REFORMIST
				nigeria.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			ws.oil_prod += 100.0  # Event654.cs OilProd
			context["result_text"] = tr(TXT_R3_ELSE)
		4:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if nigeria != null:
				if int(ws.completed_event_ids.get("event_653", 0)) == 2:
					nigeria.prc_power += 20
				else:
					nigeria.prc_power = 20
				nigeria.内战中 = true
			_add(W.I_ARMY, -100)
			context["result_text"] = tr(TXT_R4_ELSE)
		5:
			context["result_text"] = tr(TXT_R5_ELSE)


func _left_count(world: WorldState) -> int:
	var ids := [59, 112, 113, 114, 68, 107, 67, 64, 63, 62, 108, 61, 56, 58]
	var count := 0
	for id in ids:
		var c := world.get_country_by_legacy_index(id)
		if c == null:
			continue
		if c.government == GameConstants.Government.REFORMIST or world.is_socialism(c, true) or c.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
			count += 1
	return count




func _modifier_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null 			and world.modifiers[index].is_active





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_654_west_african_giant_act2.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_654",
	"num": 654,
	"priority": 65400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_654_west_african_giant_act2.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.8.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
