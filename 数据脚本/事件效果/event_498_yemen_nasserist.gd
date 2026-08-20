extends "res://数据脚本/event_script_base.gd"

const T_498_0 := "也门最后的纳赛尔主义者？"
const T_498_1 := "主席同志！我们最近截获了一份报告，称南也门党内正在谋划针对北也门领袖艾哈迈德·加什米的暗杀计划。加什米总统一贯反对美帝国主义和苏联修正主义者对阿拉伯世界的颐指气使，并大力推进阿拉伯统一事业。也许我们应当警告他们？毕竟这可以极大的促进我们和阿拉伯也门之间的合作。"
const T_498_2 := "警告北也门关于阴谋的事情（需要3特工网络）"
const T_498_3 := "党对这些事不感兴趣"
const T_498_4 := "没有这个必要"
const T_498_5 := "也门最后的纳赛尔主义者？"
const T_498_6 := "我们警告了加什米总统关于刺杀的阴谋案，在询问了南也门方面后，我们竟然设法破获了一起预谋推翻南也门总统鲁巴伊的政变。南也门的刺客被国安局的特务抓获，加什米总统设法逃过一劫。加什米总统很感谢我们的所作所为，北也门加大了和我们的合作力度。"
const T_498_7 := "我们无动于衷，很快，加什米总统在前往亚丁参加南也门国庆的前几天被南也门刺客暗杀。指挥委员会临时推选了萨利赫作为北也门的代行领导人。萨利勒一转先前反帝的政策，他开始推动经济的市场化，与北方的宰德派和解，并谋求和以色列和解。北也门与南也门的关系日渐紧张。阿盟国家也指责其试图背叛阿拉伯民族的事业。"


## 原作 Event498.cs：也门最后的纳赛尔主义者？（北也门，两选项）。
## 触发：TimeScript.cs:11142-11147 —— (日>=14 且 月>=6 且 年>=1978) || (月>=7 且 年>=1978) || 年>=1979。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = T_498_0
	event_def.description = T_498_1
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], T_498_2)
	else:
		_disable(opt[0], T_498_3)
	_enable(opt[1], T_498_4)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var north_yemen := ws.get_country_by_legacy_index(25)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -30)
			if north_yemen != null:
				north_yemen.government = GameConstants.Government.REFORMIST
				north_yemen.sub_government = GameConstants.SubGovernment.PRAGMATIST
				north_yemen.set_tag("对华贸易", true)
				north_yemen.set_tag("亲中", true)
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = T_498_6
		1:
			if north_yemen != null:
				north_yemen.government = GameConstants.Government.AUTHORITARIAN
				north_yemen.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				north_yemen.set_tag("亲美", true)
			_add_power(EmpireData.USA, 20)
			context["result_text"] = T_498_7



