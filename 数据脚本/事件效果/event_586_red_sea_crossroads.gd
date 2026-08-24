extends "res://数据脚本/event_script_base.gd"

## 原作 Event586.cs：红海的十字路口（吉布提局势，三选项）。 ## 触发：ReqEventForDLC02.cs:834-837 —— !c42.parts[0] && !c41.parts[1] ##   && ((日>=7 且 月>=10 且 年>=1981) (月>=11 且 年>=1981) 年>=1982)。 ##   parts 数组不可用 ExprNode 表达 → trigger_script evaluate。 ## 差异： ##  - 选项显隐 prepare 动态改写；resultOfEvents[585] 缺省按原版 int 默认 0； ##  - Torg → 对华贸易；proprc → 亲中；prosov → 亲苏； ##  - influencePRC vs empires[1].power → ws.influence_prc vs ws.empires[USSR].power。



const TXT_OPT0_DIS := "event.script.event_586_red_sea_crossroads.c0"
const TXT_OPT1_DIS := "event.script.event_586_red_sea_crossroads.c1"

const TXT_R0 := "event.script.event_586_red_sea_crossroads.c2"
const TXT_R1_FAIL := "event.script.event_586_red_sea_crossroads.c3"
const TXT_R1_WIN := "event.script.event_586_red_sea_crossroads.c4"
const TXT_R1_USSR := "event.script.event_586_red_sea_crossroads.c5"
const TXT_R1_PRC := "event.script.event_586_red_sea_crossroads.c6"
const TXT_R1_END := "event.script.event_586_red_sea_crossroads.c7"
const TXT_R2 := "event.script.event_586_red_sea_crossroads.c8"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var c42 := world.get_country_by_legacy_index(42)
	var c41 := world.get_country_by_legacy_index(41)
	if c42 != null and c42.has_part(0):
		return false
	if c41 != null and c41.has_part(1):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= 21:
		return false
	if d.year >= 1982:
		return true
	if d.year >= 1981 and d.month >= 11:
		return true
	if d.year >= 1981 and d.month >= 10 and d.day >= 7:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line != 0 and line != 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c106 := ws.get_country_by_legacy_index(106)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c106 != null:
				c106.government = GameConstants.Government.REFORMIST
				c106.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(c106)
				c106.set_tag("对华贸易", true)
				c106.set_tag("亲中", true)
				c106.social_stability = 1000
			ws.influence_prc += 20
			_add(W.I_DIPLO, 15)
			context["result_text"] = tr(TXT_R0)
		1:
			var r585 := int(ws.completed_event_ids.get("event_585", 0))
			if r585 != 2:
				context["result_text"] = tr(TXT_R1_FAIL)
			else:
				var text := tr(TXT_R1_WIN)
				if c106 != null:
					_leave_alliances(c106)
				var ussr_power := ws.empires[EmpireData.USSR].power if ws.empires.size() > EmpireData.USSR \
						and ws.empires[EmpireData.USSR] != null else 0
				if ws.influence_prc < ussr_power:
					text += tr(TXT_R1_USSR)
					if c106 != null:
						c106.set_tag("亲苏", true)
					_add_power(EmpireData.USSR, 20)
				else:
					text += tr(TXT_R1_PRC)
					if c106 != null:
						c106.set_tag("亲中", true)
						c106.social_stability = 1000
					ws.influence_prc += 20
				text += tr(TXT_R1_END)
				_add(W.I_ARMY, -50)
				if c106 != null:
					c106.government = GameConstants.Government.AUTHORITARIAN
					c106.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					c106.set_tag("对华贸易", true)
				_add_relation(EmpireData.USA, -100)
				_add(W.I_DIPLO, 5)
				context["result_text"] = text
		2:
			context["result_text"] = tr(TXT_R2)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_586_red_sea_crossroads.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_586",
	"num": 586,
	"priority": 58600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_586_red_sea_crossroads.gd",
	"trigger_script": "res://数据脚本/事件效果/event_586_red_sea_crossroads.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
