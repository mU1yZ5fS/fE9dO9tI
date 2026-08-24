extends "res://数据脚本/event_script_base.gd"

const T_665_0 := "event.script.event_665_panama_tailor.c0"
const T_665_1 := "event.script.event_665_panama_tailor.c1"
const T_665_2 := "event.script.event_665_panama_tailor.c2"
const T_665_3 := "event.script.event_665_panama_tailor.c3"
const T_665_4 := "event.script.event_665_panama_tailor.c4"
const T_665_5 := "event.script.event_665_panama_tailor.c5"
const T_665_6 := "event.script.event_665_panama_tailor.c6"
const T_665_8 := "event.script.event_665_panama_tailor.c7"
const T_665_9 := "event.script.event_665_panama_tailor.c8"
const T_665_10 := "event.script.event_665_panama_tailor.c9"
const T_665_11 := "event.script.event_665_panama_tailor.c10"
const T_665_12 := "event.script.event_665_panama_tailor.c11"


## 原作 Event665.cs：巴拿马裁缝（巴拿马，三选项）。 ## 触发：TimeScript.cs:11128-11133 —— (日>=31 且 月>=7 且 年>=1981) (月>=8 且 年>=1981) 年>=1982。 ## 差异： ##  - 原版 names1+names2 动态姓名 → ws.leader.name_display（空则回退“华国锋”）。 ##  - 结果0 双分支均设置巴拿马 Torg；原版分支B重复 Torg=true，合并为一次。 ##  - 死代码 result_num==5 跳过。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	event_def.title = tr(T_665_0)
	event_def.description = tr(T_665_1)
	var china := world.get_country_by_legacy_index(1)
	var nicaragua := world.get_country_by_legacy_index(147)
	var usa := world.get_country_by_legacy_index(51)
	var opt := event_def.options
	if _branch_a(world, china, nicaragua) or (china != null and china.has_tag("sev")) \
			or (nicaragua != null and nicaragua.has_tag("亲苏")):
		_enable(opt[0], tr(T_665_2))
	else:
		_disable(opt[0], tr(T_665_3))
	if usa != null and usa.development == 1 and world.techs != null \
			and world.techs.unlocked.size() > 20 and world.techs.unlocked[20]:
		_enable(opt[1], tr(T_665_4))
	else:
		_disable(opt[1], tr(T_665_5))
	_enable(opt[2], tr(T_665_6))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var china := ws.get_country_by_legacy_index(1)
	var nicaragua := ws.get_country_by_legacy_index(147)
	var panama := ws.get_country_by_legacy_index(141)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if _branch_a(ws, china, nicaragua):
				_add(W.I_BUDGET, -80)
				_add(W.I_AGENTS, -50)
				_add(W.I_ARMY, -50)
				_add(W.I_THOUGHT_FREEDOM, 10)
				ws.influence_prc += 20
				_add_relation(EmpireData.USA, -200)
				if panama != null:
					panama.government = GameConstants.Government.REFORMIST
					panama.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					panama.set_tag("对华贸易", true)
					panama.set_tag("亲中", true)
				context["result_text"] = _leader_name() + tr(T_665_9).replace("{0}{1}", "")
			elif (china != null and china.has_tag("sev")) or (nicaragua != null and nicaragua.has_tag("亲苏")):
				_add(W.I_BUDGET, -40)
				_add(W.I_THOUGHT_FREEDOM, 10)
				ws.influence_prc += 10
				_add_power(EmpireData.USSR, 30)
				_add_relation(EmpireData.USA, -100)
				if panama != null:
					panama.government = GameConstants.Government.REFORMIST
					panama.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					panama.set_tag("对华贸易", true)
					panama.set_tag("亲苏", true)
				context["result_text"] = _leader_name() + tr(T_665_10).replace("{0}{1}", "")
		1:
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, 10)
			_add_power(EmpireData.USA, 30)
			_add_power(EmpireData.USSR, -15)
			if panama != null:
				panama.government = GameConstants.Government.AUTHORITARIAN
				panama.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				panama.set_tag("对华贸易", true)
			context["result_text"] = _leader_name() + tr(T_665_11).replace("{0}{1}", "")
		2:
			if panama != null:
				panama.government = GameConstants.Government.AUTHORITARIAN
				panama.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
			context["result_text"] = tr(T_665_12)


func _branch_a(world: WorldState, china: CountryData, nicaragua: CountryData) -> bool:
	if world == null or china == null or nicaragua == null:
		return false
	if china.has_tag("sev"):
		return false
	return (nicaragua.government == GameConstants.Government.REFORMIST and nicaragua.has_tag("亲中")) \
			or world.is_socialism(nicaragua, true)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_665_panama_tailor.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_665",
	"num": 665,
	"priority": 66500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_665_panama_tailor.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.7.31"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
