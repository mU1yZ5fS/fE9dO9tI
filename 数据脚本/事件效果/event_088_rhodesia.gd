extends "res://数据脚本/event_script_base.gd"

## 原作 Event88.cs：那是怎样的时光啊（罗得西亚内部解决方案，三选项）。
## 触发：TimeScript.cs:10717-10723 ——
##   (日>=10 且 月>=3 且 年>=1978 或 月>=4 且 年>=1978 或 年>=1979)。
## 差异：选项显隐 prepare 动态改写；<color> 标签去除（UI 未开 bbcode）。

const TXT_R0 := "我们选择像过去一样支持津巴布韦人民的斗争。在坦桑尼亚和赞比亚的帮助下，大量的武器继续被运往ZANU在卢萨卡的指挥部。为了防止爱德华多·蒙德拉纳那般悲剧性的事件再度发生，我们提出了为ZANU和ZANLA高级领导人提供安保的协议。毕竟他们是白人政权中的眼中钉，而穆加贝本人也长期处在罗得西亚国土安全局的监视下。这会为他们减少潜在的暗杀风险。\n尽管西索尔本人就是ZANU的成员，这也丝毫不影响该党的主要成员对新政权的大加鞭笞。但是ZANU和ZAPU不可能当永远的战友，迟早有一天他们会兵戎相见……\n穆佐雷瓦试图说服英国政府承认过渡政府，但英国政府没有这样做。同样，一些人认为该协议是承认罗得西亚和取消制裁的“充分”理由。美国众议院和美国参议院同意取消制裁，但附加条件是只有“举行选举后”才能取消制裁。据报道，该协议还导致政治犯被释放。但是，由于当时中上阶层的构成，该国的公务员、司法、警察和武装部队继续由以前的官员管理，其中大多数是白人而不是津巴布韦本地人。英联邦秘书处声称，“所谓的‘津巴布韦罗得西亚宪法’“不会比它所取代的UDI（单方面宣称独立）宪法“更合法、更有效”。\n种族隔离政权已经时日无多了，那曾经是多么独特的一段日子啊……"

const TXT_R1 := "我们甚至领先于美国和英国政府承认了该国的政权更迭，称其为“赤道非洲以南的政治奇迹”。很快，我们的国旗便在索尔兹伯里的街头升起，穆佐勒瓦代总统在电报中感谢了中华人民共和国对该国的支持。但是阿尔巴尼亚人非常讨厌我们的行为，称其为“中国修正主义者试图在美苏之间走平衡木的丑态”。他们不过是吃不到葡萄嫌葡萄酸罢了。\n穆佐雷瓦试图说服英国政府承认过渡政府，但英国政府没有这样做。同样，一些人认为该协议是承认罗得西亚和取消制裁的“充分”理由。美国众议院和美国参议院同意取消制裁，但附加条件是只有“举行选举后”才能取消制裁。据报道，该协议还导致政治犯被释放。但是，由于当时中上阶层的构成，该国的公务员、司法、警察和武装部队继续由以前的官员管理，其中大多数是白人而不是津巴布韦本地人。英联邦秘书处声称，“所谓的‘津巴布韦罗得西亚宪法’“不会比它所取代的UDI（单方面宣称独立）宪法“更合法、更有效”。\n种族隔离政权已经时日无多了，那曾经是多么独特的一段日子啊……"

const TXT_R2 := "穆佐雷瓦试图说服英国政府承认过渡政府，但英国政府没有这样做。同样，一些人认为该协议是承认罗得西亚和取消制裁的“充分”理由。美国众议院和美国参议院同意取消制裁，但附加条件是只有“举行选举后”才能取消制裁。据报道，该协议还导致政治犯被释放。但是，由于当时中上阶层的构成，该国的公务员、司法、警察和武装部队继续由以前的官员管理，其中大多数是白人而不是津巴布韦本地人。英联邦秘书处声称，“所谓的‘津巴布韦罗得西亚宪法’“不会比它所取代的UDI（单方面宣称独立）宪法“更合法、更有效”。\n种族隔离政权已经时日无多了，那曾经是多么独特的一段日子啊……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var opt := event_def.options
	if (line < 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[0], "继续支持他们的武装斗争")
	else:
		_disable(opt[0], "他们？他们连保险都不会开！")
	if (line >= 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[1], "和新政府做朋友")
	else:
		_disable(opt[1], "你看不出他们是在演戏？")
	_enable(opt[2], "什么都不做")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var rhodesia := ws.get_country_by_legacy_index(127)
	if rhodesia != null:
		rhodesia.name = "津巴布韦罗得西亚"
		rhodesia.chinese_name = "津巴布韦罗得西亚"
		rhodesia.puppet_of = GameConstants.LegacySlot.NONE
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			context["result_text"] = TXT_R0
		1:
			if rhodesia != null:
				rhodesia.set_tag("对华贸易", true)
			ws.influence_prc -= 40
			context["result_text"] = TXT_R1
		2:
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



