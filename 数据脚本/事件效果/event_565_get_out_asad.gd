extends "res://数据脚本/event_script_base.gd"

## 原作 Event565.cs：滚出去，阿萨德（叙利亚内战，3选项）。
## 触发：无自动触发（Event564 结果1 后 EventEngine.enqueue_chain 承接）。

const TXT_OPT0_DIS := "为什么要支持一群神棍？"
const TXT_OPT1_DIS := "他们不会听我们的"
const TXT_OPT2_DIS := "绝不支持自由主义者！"
const TXT_R0 := "在我们的支持下，以圣战者战斗先锋队为首的极端伊斯兰主义者很快将左派和民主派分子处理掉，并宣布将对复兴社会党世俗主义政权发动圣战。"
const TXT_R1 := "在我们的支持下，由库尔德工人党叙利亚支部，阿拉伯社会主义者和共产主义者组织起来的民族民主大会迅速平定了伊斯兰主义者和民主派的叛乱，并开始向背叛革命的阿萨德政府进行进攻。"
const TXT_R2 := "在我们的支持下，由前叙利亚共和国高官，部分民主派，叙利亚库尔德民主党以及温和的伊斯兰主义者为首的叙利亚自由联盟迅速清理掉了左派与伊斯兰主义者中的极端分子，并开始向推翻了叙利亚共和国的阿拉伯社会主义分子复仇。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var c8 := world.get_country_by_legacy_index(8)
	if ws.influence_prc >= 500 and d.war_support >= 600 and not ws.modifiers[3].is_active 			and c8 != null and c8.sub_government != GameConstants.SubGovernment.NEOPATRIARCHAL:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if d.political_line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if d.political_line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war41("伊斯兰主义者", 1, 0)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = TXT_R0
		1:
			_start_war41("全国民主同盟", -1, 0)
			_add_relation(EmpireData.USSR, -200)
			context["result_text"] = TXT_R1
		2:
			_start_war41("叙利亚自由联盟", 1, 0)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = TXT_R2


func _start_war41(side2: String, usa_side: int, ussr_side: int) -> void:
	game.start_war(41, "叙利亚政府军", side2, 700, 300, usa_side, ussr_side)
	if ws.wars.size() > 41 and ws.wars[41] != null:
		ws.wars[41].name_war = "叙利亚内战"
		ws.wars[41].fortnight_max = 24
