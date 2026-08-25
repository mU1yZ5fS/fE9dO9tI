extends "res://数据脚本/event_script_base.gd"

## 原作 Event650.cs：谁成为战士，妈妈？（利比里亚多伊倒台，四选项）。
## 触发：TimeScript.cs:11020-11026 —— (月>=10 且 年>=1985 或 年>=1986)
##   && event_done[696]。
## 差异：
##  - 选项显隐 prepare 动态改写；now_leader→current_leader；
##  - 结果1 的"孔波雷引荐"分支文本插入我国领袖姓名（names1+names2→name_display）；
##  - resultOfEvents[500] 缺省按原版 int 默认 0 处理；
##  - JoinAllOurAlliances(true)：id67 属 flag 组（军事联盟分支跳过），
##    只按 c1.econ/c1.isSEV 加入经济联盟。



const TXT_OPT1_DIS := "event.script.event_650_liberia_doe_fall.c0"
const TXT_OPT2_DIS := "event.script.event_650_liberia_doe_fall.c1"
const TXT_OPT3_DIS := "event.script.event_650_liberia_doe_fall.c2"

const TXT_R0 := "event.script.event_650_liberia_doe_fall.c3"

const TXT_R1_INTRO := "event.script.event_650_liberia_doe_fall.c4"
const TXT_R1_TAYLOR := "event.script.event_650_liberia_doe_fall.c5"

const TXT_R1_QUIWONKPA := "event.script.event_650_liberia_doe_fall.c6"

const TXT_R1_LEFT := "event.script.event_650_liberia_doe_fall.c7"

const TXT_R1_PROCHINA := "event.script.event_650_liberia_doe_fall.c8"

const TXT_R2 := "event.script.event_650_liberia_doe_fall.c9"

const TXT_R3 := "event.script.event_650_liberia_doe_fall.c10"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var china := world.get_country_by_legacy_index(1)
	var burkina := world.get_country_by_legacy_index(61)
	var usa := world.get_country_by_legacy_index(51)
	var liberia := world.get_country_by_legacy_index(67)
	var ethiopia := world.get_country_by_legacy_index(41)
	var c117 := world.get_country_by_legacy_index(117)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if burkina != null and burkina.has_tag("亲中"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	var usa_leader3 := world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null \
			and world.empires[EmpireData.USA].current_leader == 3
	if china != null and china.government == GameConstants.Government.LIBERAL and usa != null and usa.development == 1 and usa_leader3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	var cond := liberia != null and liberia.has_tag("对华贸易") \
			and china != null and china.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST \
			and ethiopia != null and ethiopia.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST \
			and c117 != null and c117.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST
	if cond:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var liberia := ws.get_country_by_legacy_index(67)
	var burkina := ws.get_country_by_legacy_index(61)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			if burkina != null and burkina.sub_government == GameConstants.SubGovernment.PRAGMATIST:
				var tname := _leader_name()
				if liberia != null:
					liberia.government = GameConstants.Government.AUTHORITARIAN
					liberia.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					_leave_alliances(liberia)
					liberia.set_tag("亲中", true)
					liberia.set_tag("对华贸易", true)
				_add_power(EmpireData.USA, -5)
				_add_relation(EmpireData.USA, -200)
				ws.influence_prc += 10
				context["result_text"] = tr(TXT_R1_INTRO) + tname + tr(TXT_R1_TAYLOR)
			else:
				var text := tr(TXT_R1_QUIWONKPA)
				if int(ws.completed_event_ids.get("event_500", 0)) == 0:
					text += tr(TXT_R1_LEFT)
					if liberia != null:
						liberia.government = GameConstants.Government.SOCIALIST
						liberia.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
						_leave_alliances(liberia)
						liberia.set_tag("亲中", true)
						liberia.set_tag("对华贸易", true)
						_join_alliances(liberia)
					_add_power(EmpireData.USA, -15)
					_add_relation(EmpireData.USA, -300)
					ws.influence_prc += 25
				else:
					text += tr(TXT_R1_PROCHINA)
					if liberia != null:
						liberia.government = GameConstants.Government.REFORMIST
						liberia.sub_government = GameConstants.SubGovernment.PRAGMATIST
						_leave_alliances(liberia)
						liberia.set_tag("亲中", true)
						liberia.set_tag("对华贸易", true)
						_join_alliances(liberia)
					_add_power(EmpireData.USA, -10)
					_add_relation(EmpireData.USA, -250)
					ws.influence_prc += 15
				context["result_text"] = text
		2:
			if liberia != null:
				liberia.government = GameConstants.Government.LIBERAL
				liberia.sub_government = GameConstants.SubGovernment.LIBERAL
				_leave_alliances(liberia)
				liberia.set_tag("亲美", true)
				liberia.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, 10)
			_add_relation(EmpireData.USA, 50)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -40)
			_add(W.I_DIPLO, -30)
			context["result_text"] = tr(TXT_R2)
		3:
			if liberia != null:
				liberia.government = GameConstants.Government.AUTHORITARIAN
				liberia.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				_leave_alliances(liberia)
				liberia.set_tag("亲中", true)
				liberia.set_tag("对华贸易", true)
				_join_alliances(liberia)
			_add_power(EmpireData.USA, -10)
			_add_relation(EmpireData.USA, -250)
			ws.influence_prc += 20
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			context["result_text"] = tr(TXT_R3)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## Country.LeaveAlliances() 逐项映射（同 Event587 约定）。

func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_650_liberia_doe_fall.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_650",
	"num": 650,
	"priority": 65000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_650_liberia_doe_fall.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.10.1"}, {"t": "PREV_EVENT_DONE", "ref": "event_696"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
