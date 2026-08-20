extends "res://数据脚本/event_script_base.gd"

## 原作 Event323.cs：私立教育（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:549-552 —— 经济体制>=13 且 IsFactionLeadeng(4) 且 日>=12 月>=9 年>=1982。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 203-212。

const TXT_OPT1_DIS := "私有化不可接受！"
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
	_enable(opt[0], event_def.options[0].text)
	if br >= 70 and data[W.I_ECON_SYSTEM] > 13:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data[W.I_DIPLO] >= 700 and data[W.I_ECON_SYSTEM] > 13 and GameManager.is_faction_leading(4):
		_enable(opt[2], event_def.options[2].text)
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



