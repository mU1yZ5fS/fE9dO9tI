extends "res://数据脚本/event_script_base.gd"

## 原作 Event494.cs：防患于未然？（IECS 防火墙，二选项）。
## 触发：ReqEventForDLC02.cs:1534-1536 ——
##   !event_done[112] && event_done[97] && science[16]。
## 差异：science[16] → ExprNode TECH_UNLOCKED(16)；data[8]+data[36] → 预算+外汇。

const TXT_TITLE := "防患于未然？"

const TXT_DESC := "主席同志，在大规模推广自动化生产后，一些科研人员担心我们的自动化经济系统可能会遭到敌人入侵，用来破坏我们最新的社会主义现代化经济成果。不过得益于我们已经研究了信息化时代的战争方式，或许我们应该给IECS系统研究一种“防火墙”，来抵御未来潜在的威胁？"

const TXT_OPT0 := "好，就这么办！"
const TXT_OPT0_DIS := "可惜我们没有这么多钱"
const TXT_OPT1 := "多一事不如少一事"

const TXT_R0 := "我们的科研人员正在着手开发基于IECS的网络防火墙。在此期间，我们的科研人员不断扮演着网络攻击者与防御者，这使得我们发现了IECS网络系统的大量潜在漏洞，我们的科研人员也借此收获颇丰，得到了大量的关于计算机网络系统攻防的实战经验。"

const TXT_R1 := "我们认为就算是美苏也不至于采用最先进的信息化技术战术来从这个角度进攻我们，所以这个天马行空的计划被搁置了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var budget := world.数值表[W.I_BUDGET] if world.数值表.size() > W.I_BUDGET else 0
	var reserve := world.数值表[W.I_RESERVE] if world.数值表.size() > W.I_RESERVE else 0
	var opt := event_def.options
	if budget + reserve >= 100:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_SCIENCE, 300)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


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
