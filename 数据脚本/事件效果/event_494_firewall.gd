extends "res://数据脚本/event_script_base.gd"

## 原作 Event494.cs：防患于未然？（IECS 防火墙，二选项）。
## 触发：ReqEventForDLC02.cs:1534-1536 ——
##   !event_done[112] && event_done[97] && science[16]。
## 差异：science[16] → ExprNode TECH_UNLOCKED(16)；data[8]+data[36] → 预算+外汇。



const TXT_OPT0_DIS := "可惜我们没有这么多钱"

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
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)


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


