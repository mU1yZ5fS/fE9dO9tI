extends "res://数据脚本/event_script_base.gd"

## 原作 Event115.cs：金三角（三选项）。
## 触发：TimeScript.cs:10943-10947 ——
##   年>=1982 && c33.对华贸易 && !c33.亲中 && c34.对华贸易 && c22.对华贸易。
## 差异：
##  - result 5 为死代码（button_text[5]=""）→ 跳过；
##  - traits[0]==0 → trait_personality==0；loyality→loyalty。


const TXT_OPT1_DIS := "中国人民打击毒贩子可不是为了让我们与他们眉来眼去的"

const TXT_R0 := "一切顺其自然。"
const TXT_R1 := "尽管有原则的党员在得知这项协议后提出抗议，我们仍然能够与坤沙合作，坤沙认为最好不要拒绝这种帮助。现在，国安部特工和解放军人员参与保护鸦片工业，并帮助向西方走私毒品，在我们的坚持下，绝大多数“货物”现在都到了西方。西方国家海洛因销售的激增并没有严重地影响其经济和人民的健康，这需要这些国家的警察付出更多的努力，并需要更多的预算资金。掸族分裂分子对缅甸政府军发动了新的进攻，虽然没有取得多大的胜利。由于我们严守秘密，并没有留下可以用于公开指责我们的材料，但是缅甸当局仍然猜测并减少两国的贸易往来，我们的一些地方官员和有关官员也决定加入这一有利可图的生意。希望我们的利润能弥补这个损失。"
const TXT_R2 := "在我们中华人民共和国、老挝、缅甸和泰国代表出席的会议上，通过了一项联合打击东南亚有组织犯罪的方案。中国国安部的工作人员与这些国家的执法机构进行了多次调查，揭露了毒贩与政府官员的众多联系，并揭露了一些销售渠道。这也使得更准确地确定辛迪加中心的位置变为可能，并在盟国军队和解放军的帮助下进行了几次成功的突袭。当然，金三角的毒贩还远未被完全击败，但这些措施严重的破坏了毒品的生产与交易，让我们的合作伙伴更轻松了，他们真诚地感谢我们，让缅甸最放心的是掸族分裂主义的衰落，最后他们确立了亲中方向的外交政策。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if (line >= 2 and party < 8) or (coal > 66 and party > 7):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var burma := ws.get_country_by_legacy_index(33)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, 70)
			_add(W.I_AGENTS, -10)
			_add(W.I_CORRUPTION, 40)
			_add(W.I_PARTY_SUPPORT, -150)
			_add_power(EmpireData.USSR, -10)
			if burma != null:
				burma.set_tag("对华贸易", true)
			for p in ws.politicians:
				if p != null and p.trait_personality == 0:
					p.loyalty -= 100
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -20)
			_add(W.I_ARMY, -20)
			_add(W.I_CORRUPTION, -20)
			if burma != null:
				burma.set_tag("对华贸易", true)
			context["result_text"] = TXT_R2


## 原版 summa_3_2 复算：仅 party_system>7 时计算执政党(1)+盟友席位数 ×100 / 五党总席位数。
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




