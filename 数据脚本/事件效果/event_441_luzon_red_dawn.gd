extends "res://数据脚本/event_script_base.gd"

## 原作 Event441.cs：吕宋群岛的赤色黎明！（1选项）。
## 触发：TimeScript.cs:1030-1039 —— data.philippines_maoist_power>=1000 且 菲律宾(47)非亲中（trigger_script 表达）；
##   原版触发前预设置移入 prepare（事件显示前等价执行）。
## 差异：data.philippines_maoist_power 为原版 raw index（菲律宾毛派力量）；prcpower→prc_power；soc_stab→social_stability；
##   JoinAllOurAlliances 按项目约定仅移植经济联盟分支。




const TXT_R0 := "event.script.event_441_luzon_red_dawn.c0"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= 37:
		return false
	var philippines := world.get_country_by_legacy_index(47)
	return data.philippines_maoist_power >= 1000 and philippines != null and not philippines.has_tag("亲中")


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	# TimeScript.cs:1032-1036 触发前预设置：菲律宾转亲中、Gosstroy=1、退出东盟、SubGosstroy=17、去亲美。
	var philippines := world.get_country_by_legacy_index(47)
	if philippines != null and not philippines.has_tag("亲中"):
		philippines.set_tag("亲中", true)
		philippines.government = GameConstants.Government.SOCIALIST
		philippines.set_tag("asean", false)
		philippines.sub_government = GameConstants.SubGovernment.MAOIST
		philippines.set_tag("亲美", false)
	if event_def.options.size() >= 1:
		_enable(event_def.options[0], event_def.options[0].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var philippines := ws.get_country_by_legacy_index(47)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(EmpireData.USA, -150)
			_add_power(EmpireData.USA, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, 100)
			if philippines != null:
				philippines.prc_power = 1000
				if ws.is_socialism(ws.get_country_by_legacy_index(1), true) and _modifier_active(6):
					philippines.set_tag("对华贸易", true)
					_join_alliances(philippines)
					philippines.social_stability = 1000
			context["result_text"] = tr(TXT_R0)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_441_luzon_red_dawn.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_441",
	"num": 441,
	"priority": 44100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_441_luzon_red_dawn.gd",
	"trigger_script": "res://数据脚本/事件效果/event_441_luzon_red_dawn.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
