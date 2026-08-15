extends "res://数据脚本/event_script_base.gd"

## 原作 Event323.cs：私立教育（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:549-552 —— 经济体制>=13 且 IsFactionLeadeng(4) 且 日>=12 月>=9 年>=1982。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 203-212。

const TXT_TITLE := "私立教育"
const TXT_DESC := "在党员队伍之中，合法化私立教育的想法已开始浮现。一群党员提出将私立教育机构合法化的倡议，认为这将减轻国家的部分负担，提高教育质量并能引入新的教育方法。但另一方面，这将会削弱对国家教育的意识形态控制，因教育成本增高而加剧人口分层，并可能使党和底层造成差异。如果我们确实决定将教育私有化，那么就值得决定具体如何进行。一些人提议部分私有化，只允许政府颁发国家认证的机构开展工作，而另一些人则坚持认为，不应该由国家来实施不完全的改革，并呼吁放开私立教育管控。但哪怕在党内水火不容的保守派和极左派都在此时站在一起表示出坚决反对，并要求将那些提出“如此卑鄙的改革”的人开除出党。"
const TXT_OPT0 := "教育不可私有！"
const TXT_OPT1 := "部分允许，但得处于国家控制之下。"
const TXT_OPT1_DIS := "私有化不可接受！"
const TXT_OPT2 := "全面私有化教育领域。"
const TXT_OPT2_DIS := "私有化不可接受！"
const TXT_R0 := "教育私有化遭到严厉批判，提出这一主张的“同志”业已被开除党籍。由于广泛的宣传活动，人们发觉是你拒绝了这一提议，这让你的声望大大提升了。"
const TXT_R1 := "通过同意改革者的提议，您批准了教育机构的有限私有化。但是，这些机构必须遵守一些严格的标准才能获得国家认证和开展私立教育活动的许可。新的教育机构已经开始积极购买现代化设备并开发新的教学方法。"
const TXT_R2 := "出乎所有人意料的是，您为引入私立教育开了绿灯。相当一部分教育机构已经私有化并转移到私人手中。新的教育机构已经开始积极购置现代化设备，开发实验教学方法，以创新吸引学生的注意力。然而，这样的决定在民众中引起了不同的反应。虽然富裕的部分人口欢迎这样的决定并高度赞赏教育质量，但其他人则抱怨学费太贵，并开始指责政府“背叛了革命的理念”。西方国家对改革表示欢迎，并且已经表现出对国际合作和学生交流的渴望，这将对教育质量和我国的形象产生积极的影响。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data[W.I_BUDGET] + data[W.I_RESERVE]
	_enable(opt[0], TXT_OPT0)
	if br >= 70 and data[W.I_ECON_SYSTEM] > 13:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data[W.I_DIPLO] >= 700 and data[W.I_ECON_SYSTEM] > 13 and GameManager.is_faction_leading(4):
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, 25)
			_add(W.I_SCIENCE, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_LIVING, -15)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, 80)
			_add(W.I_SCIENCE, 200)
			_add(W.I_THOUGHT_FREEDOM, 200)
			_add(W.I_LIVING, -250)
			context["result_text"] = TXT_R2

	
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
