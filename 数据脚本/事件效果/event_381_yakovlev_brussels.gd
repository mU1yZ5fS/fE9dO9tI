extends "res://数据脚本/event_script_base.gd"

## 原作 Event381.cs：从里斯本到符拉迪沃斯托克/从波恩到符拉迪沃斯托克（一选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 标题按 c87.isNATO 动态改写；c7/c17 政体与 c17.parts[0] 逐项移植；
##  - 原版 iron_and_blood 成就 Set(132) 已接 Achievements。

const TXT_TITLE_NATO := "从里斯本到符拉迪沃斯托克"
const TXT_TITLE_OTHER := "从波恩到符拉迪沃斯托克"
const TXT_R0 := "又一件值得注意的大事——雅科夫列夫在结束自己的布鲁塞尔演讲后，便前往了东柏林城区。随后，便是又一场史无前例的胜利——苏联与美国领导人共同宣布“冷战已经彻底成为了历史名词”，因此，作为冷战主要象征的柏林墙“必须被摧毁，德国人民必须再度统一”。\n根据统一方案的要求，德国将被统一为拥有单一军队并实现政治自由的邦联国家，但仍沿用不同的货币、经济体制与政府（尽管已经建立了一个用以讨论全德事务的合议主席团）。\n最终，各方签署了《有关德国统一的法律文件》。参与者分别为东西德国各自的领导人——民主德国国务委员会主席埃里希·昂纳克，联邦德国议长赫尔穆特·科尔，以及以反希特勒联盟的胜者身份参与会议的美苏领导人。"
const TXT_NAME_GERMANY := "统一德国"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var portugal := world.get_country_by_legacy_index(87)
	if portugal != null and portugal.has_tag("nato"):
		event_def.title = TXT_TITLE_NATO
	else:
		event_def.title = TXT_TITLE_OTHER
	if event_def.options.size() >= 1:
		_enable(event_def.options[0], event_def.options[0].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var portugal := ws.get_country_by_legacy_index(87)
	if portugal != null and portugal.has_tag("nato"):
		context["result_title"] = TXT_TITLE_NATO
	else:
		context["result_title"] = TXT_TITLE_OTHER
	context["result_text"] = TXT_R0
	for c in ws.countries:
		if c != null and c.has_tag("sev"):
			c.set_tag("sev", false)
			c.set_tag("eu", true)
	var ussr := ws.get_country_by_legacy_index(7)
	if ussr != null:
		ussr.government = 2
		ussr.sub_government = 3
	# 原作 Event381.cs:56：iron_and_blood → achievements.Set(132)
	Achievements.set_achievement(132)
	var germany := ws.get_country_by_legacy_index(17)
	if germany != null:
		if germany.parts.size() < 1:
			germany.parts.resize(1)
		germany.parts[0] = true
		germany.name = TXT_NAME_GERMANY
		germany.chinese_name = TXT_NAME_GERMANY
		germany.set_tag("亲美", false)
		germany.government = 2
		germany.sub_government = 3


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null
