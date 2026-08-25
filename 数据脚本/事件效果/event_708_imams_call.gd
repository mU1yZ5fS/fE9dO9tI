extends "res://数据脚本/event_script_base.gd"

## 原作 Event708.cs：伊玛目的召唤（伊拉克什叶派起义，分支 2/4 选项）。 ## 触发：TimeScript.cs:10566-10573 —— ##   ((done36 && result36==3 && c14.prcpower>=150) (年>=1982 月>=7 日>=8) ## (年>=1982 月>=8) 年>=1983) && c14.SubGosstroy==10 && c14.puppetOf<0 ##   && !wars[29].is_going && !event_done[417]（.tres ExprNode 表达）。 ## 差异： ##  - 特殊分支（done36 && result36==3 && prcpower>=80）只有 2 个选项： ##    prepare 动态替换 options 数组（静态备份 4 选项，普通分支还原）。 ##  - 战争 88：TickTime(100) → fortnight_max=100；infl 调整逐字保留。

const TXT_DESC_SPECIAL := "event.script.event_708_imams_call.c0"

const TXT_DESC_NORMAL_PRE := "event.script.event_708_imams_call.c1"

const TXT_DESC_NORMAL_POST := "event.script.event_708_imams_call.c2"

const TXT_R_SPECIAL0 := "event.script.event_708_imams_call.c3"

const TXT_R_SPECIAL1 := "event.script.event_708_imams_call.c4"

const TXT_R0 := "event.script.event_708_imams_call.c5"

const TXT_R1 := "event.script.event_708_imams_call.c6"

const TXT_R2 := "event.script.event_708_imams_call.c7"

const TXT_R3 := "event.script.event_708_imams_call.c8"

static var _opts_full: Array[EventOption] = []


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if _opts_full.is_empty():
		for o in event_def.options:
			_opts_full.append(o)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var done36: bool = world.completed_event_ids.has("iraqi_coalition")
	var result36: int = world.completed_event_ids.get("iraqi_coalition", -1)
	var iraq := world.get_country_by_legacy_index(14)
	var special := done36 and result36 == 3 and iraq != null and iraq.prc_power >= 80
	if special:
		event_def.description = tr(TXT_DESC_SPECIAL)
		var arr_special: Array[EventOption] = []
		arr_special.append(_opts_full[0])
		arr_special.append(_opts_full[1])
		event_def.options = arr_special
		_enable(event_def.options[0], "我们将坚定的支持伊拉克人民的斗争！")
		_enable(event_def.options[1], "尝试置身事外")
		return
	var arr: Array[EventOption] = []
	for o in _opts_full:
		arr.append(o)
	event_def.options = arr
	event_def.description = tr(TXT_DESC_NORMAL_PRE) + _leader_name(world) + tr(TXT_DESC_NORMAL_POST)
	var opt := event_def.options
	if line != 4:
		_enable(opt[0], "强烈谴责伊斯兰主义者的恐怖袭击")
	else:
		_disable(opt[0], "萨达姆可好不到哪里去")
	if line != 4:
		_enable(opt[1], "谴责伊拉克政府的国家恐怖主义行径")
	else:
		_disable(opt[1], "不要和那群大胡子走那么近！")
	var c8 := world.get_country_by_legacy_index(8)
	if c8 == null or c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL:
		_enable(opt[2], "我们将支持伊拉克人民的起义！")
	else:
		_disable(opt[2], "达瓦党已经孤立无援")
	_enable(opt[3], "不要干涉错综复杂的教派纠纷")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var done36: bool = ws.completed_event_ids.has("iraqi_coalition")
	var result36: int = ws.completed_event_ids.get("iraqi_coalition", -1)
	var iraq := ws.get_country_by_legacy_index(14)
	var special := done36 and result36 == 3 and iraq != null and iraq.prc_power >= 80
	var opt := int(context.get("option_index", -1))
	if special:
		# Event708.cs：特殊分支开战在 result_num 分支之前 _start_war88(500, 500)
		if opt == 0:
			if ws.wars.size() > 88 and ws.wars[88] != null:
				ws.wars[88].infl1 += 100
				ws.wars[88].infl2 -= 100
			context["result_text"] = tr(TXT_R_SPECIAL0)
		elif opt == 1:
			context["result_text"] = tr(TXT_R_SPECIAL1)
		return
	match opt:
		0:
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, 20)
			_add_relation(EmpireData.USSR, 20)
			context["result_text"] = tr(TXT_R0).replace("{0}{1}", _leader_name(ws))
		1:
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -70)
			_add_relation(EmpireData.USSR, -70)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -20)
			_add(W.I_ARMY, -20)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_start_war88(500, 500)
			if ws.wars.size() > 88 and ws.wars[88] != null:
				if done36 and result36 == 3 and iraq != null and iraq.prc_power < 80:
					var num := (80 - iraq.prc_power) * 5
					ws.wars[88].infl1 -= num
					ws.wars[88].infl2 += num
				else:
					ws.wars[88].infl1 = 50
					ws.wars[88].infl2 = 950
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)


func _start_war88(infl1: int, infl2: int) -> void:
	game.start_war(88, "什叶派武装", "伊拉克", infl1, infl2, 0, 0)
	if ws.wars.size() > 88 and ws.wars[88] != null:
		ws.wars[88].name_war = "伊拉克什叶派起义"
		ws.wars[88].fortnight_max = 100  # 原版 TickTime(100)




func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_708_imams_call.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_708",
	"nodesc": true,
	"num": 708,
	"priority": 7080,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_708_imams_call.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "iraqi_coalition"}, {"t": "PREV_EVENT_RESULT_IS", "v": 3, "ref": "iraqi_coalition"}, {"t": "COUNTRY_FIELD_AT_LEAST", "key": "prc_power", "v": 150, "target": "14"}]}, {"t": "DATE_AFTER", "key": "1982.7.8"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "14"}, {"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "14"}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 29}]}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_417"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
