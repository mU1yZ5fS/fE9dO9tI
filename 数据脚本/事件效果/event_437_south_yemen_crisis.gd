extends "res://数据脚本/event_script_base.gd"

## 原作 Event437.cs：南也门事变？（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:522-524 —— 日>=26 月>=6 年>=1978（.tres ExprNode 表达）。
## 差异：选项显隐 prepare 动态改写；proprc→亲中、prosov→亲苏、Torg→对华贸易；
##   Gosstroy/SubGosstroy→government/sub_government。



const TXT_OPT0_DIS := "event.script.event_437_south_yemen_crisis.c0"

const TXT_R0 := "event.script.event_437_south_yemen_crisis.c1"
const TXT_R1 := "event.script.event_437_south_yemen_crisis.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	# 也门已统一时不再触发（双保险：配合 .tres 的 NOT_HAS_FLAG 守卫，防御手动 queue 绕过扫描条件）
	if world != null and world.get_flag("yemen_unified"):
		return
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var data := world
	var somalia := world.get_country_by_legacy_index(42)
	var ethiopia := world.get_country_by_legacy_index(41)
	var opt := event_def.options
	var ethiopia_ok := false
	if ethiopia != null:
		# Event589“埃索情深”只写 parts[0]，所以两条非洲之角路线都要认。
		var horn_federation := ethiopia.has_part(0) or ethiopia.has_part(1)
		ethiopia_ok = horn_federation and ethiopia.has_tag("亲中") \
				and ethiopia.government == GameConstants.Government.SOCIALIST
	var cond := (somalia != null and somalia.has_tag("亲中")) or ethiopia_ok
	# 原版条件读 data[7]，而 data[7] 是 influencePRC 的镜像；这里必须用 influence_prc，
	# 否则玩家影响力攒在 influence_prc 时仍会错误显示“无从下手”。
	cond = cond and data.budget + data.reserve >= 50 \
			and data.agents >= 50 and world.influence_prc >= 100
	if cond:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var south_yemen := ws.get_country_by_legacy_index(24)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# 原版 EffectsOfEvents 写 data[7]；按本端口语义 data[7] 镜像 influence_prc。
			ws.influence_prc += 50
			_add_relation(EmpireData.USSR, -150)
			if south_yemen != null:
				south_yemen.sub_government = GameConstants.SubGovernment.MAOIST
				south_yemen.set_tag("亲中", true)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(TXT_R0)
		1:
			ws.influence_prc -= 10
			if south_yemen != null:
				south_yemen.set_tag("亲苏", true)
				south_yemen.set_tag("对华贸易", false)
			context["result_text"] = tr(TXT_R1)




func _disable_blank(opt: EventOption) -> void:
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_437_south_yemen_crisis.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_437",
	"num": 437,
	"priority": 43700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_437_south_yemen_crisis.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "day", "v": 26}, {"t": "RESOURCE_AT_LEAST", "key": "month", "v": 6}, {"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1978}]}, {"t": "NOT_HAS_FLAG", "key": "yemen_unified"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
