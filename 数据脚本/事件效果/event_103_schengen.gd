extends "res://数据脚本/event_script_base.gd"

## 原作 Event103.cs：申根/马德里协定（联盟签证空间，三选项）。 ## 触发：TimeScript.cs:10980-10986 —— ##   (月>=7 且 年>=1985 或 年>=1986) && (c0.isEU (c21.isSocEU && !c0.isEU)) ##   && c1.econ。 ## 差异：标题/描述/选项0 文案按 c0.isEU 动态改写（prepare）； ##   sovalliance/usalliance → 苏联盟友/美国盟友 标签。

const TXT_R := "event.script.event_103_schengen.c0"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var c0 := world.get_country_by_legacy_index(0)
	var c1 := world.get_country_by_legacy_index(1)
	var is_eu := c0 != null and c0.has_tag("eu")
	if is_eu:
		event_def.title = "申根协定"
		event_def.description = "最近，7月14日，5个欧洲国家（卢森堡、荷兰、比利时、法国和联邦德国）在卢森堡签署了《申根协定》，这意味着简化它们之间边界的护照和签证管制，并概述了几乎完全拒绝护照管制的行动。申根协定是欧洲经济共同体长期以来实行的免签证制度的延续，它促使你们的党员认为我们也有自己的经济联盟。建立单一的签证空间、联盟国家之间的自由流动和简化边境管制，应该有利于我们国家之间的文化交流、旅游业的发展，人们会喜欢它的。问题是，这也会简化持不同政见者和罪犯的生活，事实上，不知道我们的公民会从外国得到什么样的想法……"
	else:
		event_def.title = "马德里协定"
		event_def.description = "最近，7月14日，数个欧洲国家在西班牙签署了《马德里协定》，这意味着简化它们之间边界的护照和签证管制，并概述了几乎完全拒绝护照管制的行动。马德里协定是社会主义联盟长期以来实行的免签证制度的延续，它促使你们的党员认为我们也有自己的经济联盟。建立单一的签证空间、联盟国家之间的自由流动和简化边境管制，应该有利于我们国家之间的文化交流、旅游业的发展，人们会喜欢它的。问题是，这也会简化持不同政见者和罪犯的生活，事实上，不知道我们的公民会从外国得到什么样的想法……"
	var opt := event_def.options
	if c1 != null and c1.has_tag("okb"):
		if is_eu:
			_enable(opt[0], "建立一个类似于申根协议的协议，只适用于我们军事联盟的成员")
		else:
			_enable(opt[0], "建立一个类似于马德里协议的协议，只适用于我们军事联盟的成员")
	else:
		_disable(opt[0], "我们没有军事联盟")
	if is_eu:
		_enable(opt[1], "为我们所有联盟的成员建立一个类似于申根协议的协议")
	else:
		_enable(opt[1], "为我们所有联盟的成员建立一个类似于马德里协议的协议")
	_enable(opt[2], "什么都不做")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_PEOPLE_SUPPORT, 80)
			ws.influence_prc += 10
			_add(W.I_CORRUPTION, 30)
			_add(W.I_BUDGET, 30)
			for c in ws.countries:
				if c == null or not c.has_tag("okb"):
					continue
				_apply_alliance_country(c)
			context["result_text"] = tr(TXT_R)
		1:
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_PEOPLE_SUPPORT, 80)
			ws.influence_prc += 10
			_add(W.I_CORRUPTION, 30)
			_add(W.I_BUDGET, 30)
			for c in ws.countries:
				if c == null or not (c.has_tag("okb") or c.has_tag("econ")):
					continue
				_apply_alliance_country(c)
			context["result_text"] = tr(TXT_R)
		2:
			context["result_text"] = tr("event.script.event_103_schengen.i0")


## Event103.cs result0/1 共同国家循环：soc_stab+=200、budget-=5； ## 无倾向者转亲中（-20）；有美苏盟友者清盟友（-30）。
func _apply_alliance_country(c: CountryData) -> void:
	c.social_stability += 200
	if d.size() > W.I_BUDGET:
		d.budget -= 5
	if not c.has_tag("亲中") and not c.has_tag("苏联盟友") and not c.has_tag("美国盟友"):
		c.set_tag("亲中", true)
		if d.size() > W.I_BUDGET:
			d.budget -= 20
	elif not c.has_tag("亲中") and (c.has_tag("苏联盟友") or c.has_tag("美国盟友")):
		c.set_tag("苏联盟友", false)
		c.set_tag("美国盟友", false)
		if d.size() > W.I_BUDGET:
			d.budget -= 30






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_103_schengen.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_103",
	"num": 103,
	"priority": 11380,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_103_schengen.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.7.1"}, {"t": "ANY", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "0"}, {"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "soc_eu", "target": "21"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "0"}]}]}]}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
