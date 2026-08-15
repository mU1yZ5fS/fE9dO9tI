extends "res://数据脚本/event_script_base.gd"

## 原作 Event77.cs：往脸上吐口水，在下巴上打一拳，头上一颗子弹（谢胡政变）。
## 触发：TimeScript.cs:10606-10612 ——
##   (月>=11 且 年>=1981 或 年>=1982) && data[60]<1 && c20.SubGosstroy!=11
##   && !c20.econ && !c20.isRIM（.tres ExprNode 表达）。
## 差异：描述与选项显隐按原版动态改写（prepare）；c20 政体/标签映射为
##   government/sub_government/set_tag("对华贸易"/"亲中")。

const TXT_R0 := "谢胡利用手中的国家机关和西古里米，成功地动员了他的支持者，孤立了霍查，然后召开了一次阿尔巴尼亚劳动党中央委员会特别会议，他说，由于医疗原因，第一书记将在一段时间内不能履行他的职责。他的对手最多只能放弃他们在党和政府中的职位，但他们中的许多人最终被关进了西古里米监狱，或者在可疑的情况下死亡。很快就有消息称，霍查死于病情加重，此后，谢胡毫不困难地担任阿尔巴尼亚劳动党中央第一书记。他已经开始与南斯拉夫、苏联和社会主义阵营国家进行谨慎的谈判，这些国家似乎欢迎领导层的这种转变，尽管阿尔巴尼亚的国内政策没有什么改变。"

const TXT_R0_EXTRA := "同时，谢胡恢复了与中国的关系，建立贸易，并邀请我们的顾问到该国来。"

const TXT_R1 := "结果，谢胡与霍查的关系继续恶化，1981年12月18日，谢胡被宣布自杀，之后他被指控为叛国和为美国、苏联和南斯拉夫进行谍报活动。他的总理职位被缺乏主动性和忠诚的阿迪尔·查尔查尼所取代。"

const TXT_R2 := "结果，谢胡与霍查的关系继续恶化，1981年12月18日，谢胡被宣布自杀，之后他被指控为叛国和为美国、苏联和南斯拉夫进行谍报活动。他的总理职位被缺乏主动性和忠诚的阿迪尔·查尔查尼所取代。在这段时间里，我们一直支持霍查的行动，欢迎阿尔巴尼亚从间谍谢胡手中解放出来，为此，我们得到了地拉那的感谢。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 4 and party < 8) or (coal > 66 and party > 7)
	var albania := world.get_country_by_legacy_index(20)
	var opt := event_def.options
	if policy_left and data.size() > W.I_AGENTS and data[W.I_AGENTS] >= 80:
		_enable(opt[0], "帮助谢胡组织一场政变（需要8特工网络）")
	else:
		_disable(opt[0], "我们没有足够的资源")
	_enable(opt[1], "这是他们自己的问题")
	var albania_proprc := albania != null and albania.has_tag("亲中")
	var albania_econ := albania != null and albania.has_tag("econ")
	if albania_proprc or (albania_econ and data.size() > W.I_ALBANIA_BREAK and data[W.I_ALBANIA_BREAK] == 0):
		_enable(opt[2], "我们支持霍查")
	else:
		_disable(opt[2], "为什么我们要支持背叛我们的白眼狼霍查？")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0
			if albania == null or not albania.has_tag("亲中"):
				text += TXT_R0_EXTRA
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_AGENTS, -80)
			_add(W.I_DIPLO, 10)
			if d.size() > W.I_ALBANIA_BREAK:
				d[W.I_ALBANIA_BREAK] = 1
			_add_relation(EmpireData.USSR, 50)
			if albania != null:
				albania.government = 1
				albania.sub_government = 1
				albania.set_tag("对华贸易", true)
				albania.set_tag("亲中", true)
			context["result_text"] = text
		1:
			_add_power(EmpireData.USSR, -10)
			ws.influence_prc -= 10
			if albania != null:
				albania.government = 0
				albania.sub_government = 0
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, 20)
			if albania != null:
				albania.government = 0
				albania.sub_government = 0
			context["result_text"] = TXT_R2


## 原版 summa_3_2 复算。
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
