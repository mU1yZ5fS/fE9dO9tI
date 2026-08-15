extends "res://数据脚本/event_script_base.gd"

## 原作 Event78.cs：永远的总统（菲律宾马科斯选举，三选项）。
## 触发：TimeScript.cs:10614-10620 ——
##   (月>=6 且 年>=1981 或 年>=1982) && !c1.isASEAN && !c47.okb
##   && !c47.isSEV && !c47.econ && IsAuthoritarianism(47)（.tres ExprNode 表达）。
## 差异：选项显隐 prepare 动态改写；data[37] 直访（菲律宾毛派力量，无命名键）。

const TXT_R0 := "在我们的特勤部队和武器供应的帮助下，菲律宾共产党和国民运动能够展开大规模的煽动和抗议，伴随着大量的游击活动。其他政治力量和普通公民很快也加入了这些不满。当然，抗议很快就被警察镇压了，游击队的进攻也被军队控制了，但我们似乎对马科斯政权造成了严重的破坏，他没有料到中国会突然进行如此无耻的干预。最后，他成功地赢得了总统选举，获得了52%的选票，但他必须更加谨慎地采取行动，共产党的影响力显著增强。或许，帮助他们更进一步，我们将看到菲律宾革命的胜利……"

const TXT_R1 := "结果，马科斯赢得了总统选举，获得了88%的选票。菲律宾似乎在等待他的政策继续。"

const TXT_R2 := "在马科斯以压倒性的88%的选票赢得总统选举后，我们祝贺他获胜，并对1975年开始的我们国家的进一步和睦表示希望。马科斯很乐意利用我们的提议，但许多菲律宾的毛派团体称之为背叛，共产党的影响力有所下降。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 2 and party < 8) or (coal > 66 and party > 7)
	var policy_right := (line > 1 and party < 8) or (coal > 66 and party > 7)
	var opt := event_def.options
	if data.size() > W.I_AGENTS and data[W.I_AGENTS] >= 100 \
			and data.size() > W.I_ARMY and data[W.I_ARMY] >= 80 and policy_left:
		_enable(opt[0], "煽动动乱和支持毛派（需要10特工网络，8军事实力）")
	else:
		_disable(opt[0], "这不值得我们为之努力")
	_enable(opt[1], "这不关我们的事。")
	var dip := data[W.I_DIPLO] if data.size() > W.I_DIPLO else 0
	if dip < 800 and policy_right:
		_enable(opt[2], "祝贺马科斯获胜，并尝试建立合作关系")
	else:
		_disable(opt[2], "我们不需要和美国傀儡合作")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var philippines := ws.get_country_by_legacy_index(47)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, -100)
			if d.size() > 37:
				d[37] += 300
			if philippines != null:
				philippines.set_tag("对华贸易", false)
			context["result_text"] = TXT_R0
		1:
			_add_power(EmpireData.USA, 10)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USA, 50)
			if d.size() > 37:
				d[37] -= 200
			_add_power(EmpireData.USA, 20)
			if philippines != null:
				philippines.set_tag("对华贸易", true)
			context["result_text"] = TXT_R2


func _coalition_percent(world: WorldState) -> int:
	var data := world.数值表
	if data.size() <= W.I_PARTY_SYSTEM or data[W.I_PARTY_SYSTEM] <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
