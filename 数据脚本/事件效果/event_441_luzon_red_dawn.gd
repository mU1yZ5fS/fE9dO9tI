extends "res://数据脚本/event_script_base.gd"

## 原作 Event441.cs：吕宋群岛的赤色黎明！（1选项）。
## 触发：TimeScript.cs:1030-1039 —— data[37]>=1000 且 菲律宾(47)非亲中（trigger_script 表达）；
##   原版触发前预设置移入 prepare（事件显示前等价执行）。
## 差异：data[37] 为原版 raw index（菲律宾毛派力量）；prcpower→prc_power；soc_stab→social_stability；
##   JoinAllOurAlliances 按项目约定仅移植经济联盟分支。




const TXT_R0 := "在统一全国之后，菲共立即开始了与中国的全方位合作，并和东南亚的其他兄弟国家一起对印尼进行封锁和渗透。工业设备，机械农具，化肥正逐渐运往菲律宾。菲共正在进行轰轰烈烈的土改，扫盲运动，工业化，并对各少数民族地区实行民族区域自治。菲共的胜利使得美国的亚太战略进一步遭受挫折。澳大利亚和新西兰等澳洲国家则认为澳洲地区现在更容易受到来自东南亚以及中国的威胁，要求美国进一步增加驻军和澳洲军费开支，东南亚的局势似乎变的更加紧张，但我们没什么好怕的！"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world.数值表
	if data.size() <= 37:
		return false
	var philippines := world.get_country_by_legacy_index(47)
	return data[37] >= 1000 and philippines != null and not philippines.has_tag("亲中")


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null:
		return
	# TimeScript.cs:1032-1036 触发前预设置：菲律宾转亲中、Gosstroy=1、退出东盟、SubGosstroy=17、去亲美。
	var philippines := world.get_country_by_legacy_index(47)
	if philippines != null and not philippines.has_tag("亲中"):
		philippines.set_tag("亲中", true)
		philippines.government = 1
		philippines.set_tag("asean", false)
		philippines.sub_government = 17
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
			context["result_text"] = TXT_R0




func _disable_blank(opt: EventOption) -> void:
	opt.text = ""
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
