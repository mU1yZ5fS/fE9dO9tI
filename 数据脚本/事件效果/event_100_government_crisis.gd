extends "res://数据脚本/event_script_base.gd"

## 原作 Event100.cs：政府危机（孟加拉国艾尔沙德，三选项）。
## 触发：TimeScript.cs:10850-10856 ——
##   ((日>=10 且 月>=12 且 年>=1983) || 年>=1984) && c32.puppetOf<0。
## 差异：选项显隐 prepare 动态改写。

const TXT_R0 := "由于我们的情报部门的协调工作，关于由于不断增长的金融危机会引起裁员和工资下降的谣言在孟加拉国首都的几个最大的工厂传播开来。就在第二天，整个城市因罢工和工人与武装警察之间的冲突而陷入瘫痪，一些地区还听到枪声。然而，由于公众的压力和不断增长的动乱，总统不得不宣布提前举行议会选举，在我们的帮助下，左翼联盟赢得了选举，谢赫·哈西娜·瓦吉德成为了新总理。新一届政府宣布启动经济社会改革，扩大中孟贸易。总的来说，国际社会忽视了政府的更迭，但美国怀疑我们参与了这一事件。"

const TXT_R1 := "孟加拉国政府继续控制局势，及时镇压了罢工。"

const TXT_R2 := "艾尔沙德总统感谢我们的帮助，并建议在中国和孟加拉国之间举行一次关于扩大贸易和经济合作的峰会。在谈判中，两国关系得到恢复，中国正式承认孟加拉国脱离巴基斯坦独立，并签署了新的贸易合同。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var agents := data[W.I_AGENTS] if data.size() > W.I_AGENTS else 0
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var opt := event_def.options
	if world.influence_prc >= 50 and agents >= 100 \
			and ((line < 3 and left_party) or (coal > 66 and party > 7)):
		_enable(opt[0], "通过支持反对派来煽动反政府集会")
	else:
		_disable(opt[0], "我们没有足够的力量")
	_enable(opt[1], "我们在国内有自己的问题")
	if (line > 0 and left_party) or (coal > 66 and party > 7):
		_enable(opt[2], "拨款支持政府")
	else:
		_disable(opt[2], "我们不能支持他们")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bangladesh := ws.get_country_by_legacy_index(32)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, 10)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -70)
			if bangladesh != null:
				bangladesh.set_tag("亲中", true)
				bangladesh.set_tag("亲美", false)
				bangladesh.set_tag("对华贸易", true)
				bangladesh.government = 2
				bangladesh.sub_government = 3
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -80)
			if bangladesh != null:
				bangladesh.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -70)
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
