extends "res://数据脚本/event_script_base.gd"

## 原作 Event638.cs：前进，安哥拉（安哥拉派系抉择，四选项）。
## 触发：DiploButtonScript.cs:12163 —— 外交按钮 1049，手动 StartEvent(638)。
## 差异：原版选项0选择"再想想"时 event_done[638]=false 允许按钮重选；
##   Godot 经 context["skip_mark_done"] 由 EventEngine 跳过完成标记（见 event_engine 注释）。
##   science[19]→techs.unlocked[19]；prcpower/sovpower/usapower→prc_power/sov_power/usa_power。

const TXT_DESC_PRE := "event.script.event_638_angola_choice.c0"
const TXT_DESC_MPLA_100 := "event.script.event_638_angola_choice.c1"
const TXT_DESC_MPLA_200 := "event.script.event_638_angola_choice.c2"
const TXT_DESC_MPLA_ELSE := "event.script.event_638_angola_choice.c3"
const TXT_DESC_TAIL := "event.script.event_638_angola_choice.c4"
const TXT_OPT0_DIS := "event.script.event_638_angola_choice.c5"
const TXT_OPT1_DIS_0 := "event.script.event_638_angola_choice.c6"
const TXT_OPT1_DIS_ELSE := "event.script.event_638_angola_choice.c7"
const TXT_OPT2_DIS_0 := "event.script.event_638_angola_choice.c8"
const TXT_OPT2_DIS_ELSE := "event.script.event_638_angola_choice.c9"
const TXT_R0_PRE := "event.script.event_638_angola_choice.c10"
const TXT_R0_TAIL := "event.script.event_638_angola_choice.c11"
const TXT_R1 := "event.script.event_638_angola_choice.c12"
const TXT_R2 := "event.script.event_638_angola_choice.c13"
const TXT_R3 := "event.script.event_638_angola_choice.c14"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var angola := ws.get_country_by_legacy_index(123)
	var branch := tr(TXT_DESC_MPLA_ELSE)
	if angola != null:
		if angola.level_of_instability == 100:
			branch = tr(TXT_DESC_MPLA_100)
		elif angola.level_of_instability == 200:
			branch = tr(TXT_DESC_MPLA_200)
	event_def.description = tr(TXT_DESC_PRE) + branch + tr(TXT_DESC_TAIL)
	var has_tech19 := ws.techs != null and ws.techs.unlocked.size() > 19 and ws.techs.unlocked[19]
	var opt := event_def.options
	var line := _res(W.I_POLITICAL_LINE)
	if not has_tech19:
		# 原版 :63-70：science[19] 未完成时三选项 Destroy，仅"再想想"
		_disable(opt[0], "")
		_disable(opt[1], "")
		_disable(opt[2], "")
		_enable(opt[3], event_def.options[3].text)
		return
	if line < 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line != 4 and line != 0:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_0))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_ELSE))
	var zaire := ws.get_country_by_legacy_index(117)
	if line > 0 and zaire != null and zaire.has_tag("对华贸易") and zaire.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST \
			and (ws.is_authoritarian(zaire) or zaire.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE):
		_enable(opt[2], event_def.options[2].text)
	elif line == 0:
		_disable(opt[2], tr(TXT_OPT2_DIS_0))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_ELSE))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var angola := ws.get_country_by_legacy_index(123)
	if angola != null:
		angola.prc_power = 600
		angola.sov_power = 300
		angola.usa_power = 100
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var names := ""
			for c in ws.countries:
				if c == null:
					continue
				var i := c.原版序号
				if ((i > 53 and i < 69) or (i > 105 and i < 109) or (i > 111 and i < 134) \
						or i == 41 or i == 42 or i == 52 or i == 99 or i == 100 \
						or i == 150 or i == 151 or i == 155 or i == 158) \
						and i != 55 and i != 54 and i != 128 and i != 123 \
						and c.has_tag("亲中"):
					names += "，" + c.display_name()
			context["result_text"] = tr(TXT_R0_PRE) + names + tr(TXT_R0_TAIL)
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, 50)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, -100)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, -100)
		3:
			context["result_text"] = tr(TXT_R3)
			# 原版 :115 event_done[638]=false → 跳过完成标记，外交按钮可再次选择
			context["skip_mark_done"] = true



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_638_angola_choice.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_638",
	"nodesc": true,
	"num": 638,
	"priority": 63800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_638_angola_choice.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
