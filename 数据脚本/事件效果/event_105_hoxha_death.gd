extends "res://数据脚本/event_script_base.gd"

## 原作 Event105.cs：阿尔巴尼亚的斯大林的终结（霍查逝世，三选项）。
## 触发：TimeScript.cs:10871-10877 ——
##   ((日>=13 且 月>=4 且 年>=1985) || 年>=1986) && data[60]==0
##   && c20.SubGosstroy!=11 && (!c20.isRIM || c1.isRIM)。
## 差异：描述按 event_done[77] 双分支（prepare）；c20.parts[0]/spec 映射。

const TXT_R0 := "正如预期的那样，拉米兹·阿利雅并没有“打破那些行之有效的方法”。在公共生活的各个方面，劳动党都保持着完全和绝对的监督，正统的斯大林主义者继续统治阿尔巴尼亚劳动党。然而，该政权仍经历了一些并不明显的变化:大规模镇压迅速减少，逮捕神职人员的行动停止，对异见人士的镇压变得“更加精确”。而且，尽管阿利雅不打算恢复与苏联的积极关系，但人们开始感觉到阿尔巴尼亚外交政策倾向于更大程度的开放。"

const TXT_R1_A := "新华社1985年4月11日电，在阿尔巴尼亚首都地拉那爆发了惊人的事件。一伙武装分子在众目睽睽之下，击毙了正在斯坎德培广场做就职演讲的新阿尔巴尼亚劳动党第一书记拉米兹·阿利雅。尽管这位阿尔巴尼亚的新领袖周围占满了卫兵，依然没能阻止惨案的发生。凶手连开三枪，一发打中了前胸，致命的一颗子弹则打进了肺部。夺走了他的生命。在警察部队的不懈努力下，一名科索沃阿尔巴尼亚人被抓获。他承认接受了贝里沙的资金用于除掉阿利雅。随后他被判处死刑。\n随后，一场政变在地拉那爆发了。波克夫·穆拉带领忠诚的人民军士兵攻入了政府大楼，并宣布“要为死去的阿利雅同志复仇”。随后，人民军血洗了整个地拉那，大量无辜的人被扣以“反革命颠覆罪”的帽子被投入修筑碉堡的工作中。阿尔巴尼亚劳动党内的自由派和改革派则被开除党籍后被处死。新生的政府以穆拉为核心，丘科和查尔查尼为辅。外国观察家预测阿尔巴尼亚将会天翻地覆，因为人民军又一次拿起了枪，放下了镐。他们的目标是谁不言而喻……"

const TXT_R1_B := "新华社1985年4月11日电，在阿尔巴尼亚首都地拉那爆发了惊人的事件。一伙武装分子在众目睽睽之下，击毙了正在斯坎德培广场做就职演讲的新阿尔巴尼亚劳动党第一书记拉米兹·阿利雅。尽管这位阿尔巴尼亚的新领袖周围占满了卫兵，依然没能阻止惨案的发生。凶手连开三枪，一发打中了前胸，致命的一颗子弹则打进了肺部。夺走了他的生命。在警察部队的不懈努力下，一名科索沃阿尔巴尼亚人被抓获。他承认接受了贝里沙的资金用于除掉阿利雅。随后他被判处死刑。\n为了防止可能爆发的示威游行，阿尔巴尼亚总理穆罕默德·谢胡和国防部长卡德里·哈兹比乌宣布临时接管政府。并组建了以忠诚的霍查派为核心的“三人帮”，他们分别是涅奇米叶·霍查，莲卡·丘科和阿迪尔·查尔查尼。在我们的帮助下，新生领导层借此机会展开了对阿尔巴尼亚国内的极端民族主义者和反霍查派的审察，监视和处决。那位枪手则被大赦释放。\n新生的阿尔巴尼亚仍然支持中华人民共和国。"

const TXT_R1_C := "新华社1985年4月11日电，在阿尔巴尼亚首都地拉那爆发了惊人的事件。一伙武装分子在众目睽睽之下，击毙了正在斯坎德培广场做就职演讲的新阿尔巴尼亚劳动党第一书记拉米兹·阿利雅。尽管这位阿尔巴尼亚的新领袖周围占满了卫兵，依然没能阻止惨案的发生。凶手连开三枪，一发打中了前胸，致命的一颗子弹则打进了肺部。夺走了他的生命。在警察部队的不懈努力下，一名科索沃阿尔巴尼亚人被抓获。他承认接受了贝里沙的资金用于除掉阿利雅。随后他被判处死刑。\n为了防止可能爆发的示威，阿尔巴尼亚组建了以忠诚的霍查派为核心的“三人帮”，他们分别是涅奇米叶·霍查，莲卡·丘科和阿迪尔·查尔查尼。新生领导层借此暗杀展开了对阿尔巴尼亚国内反霍查派的处决。那位枪手则被大赦释放。霍查仍然被阿尔巴尼亚人民视作一位伟人和英雄。整体上的路线并没有偏离这位领袖定下的方针。\n新生的阿尔巴尼亚仍然支持中华人民共和国，但仍希望我党能在阿劳和一些问题上做同志间的辩论。"

const TXT_R1_EXTRA := "新政府也强调了会继续停留在巴尔干联邦内。"

const TXT_R2 := "中国领导人致函阿尔巴尼亚外交部慰问，并建议他“重启”中阿关系。一周后，拉米兹·阿利雅对中华人民共和国进行了外交访问，重新签署了《中阿友好条约》，中国向阿尔巴尼亚提供了长期稳定的贷款，以示两国和解。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var done77: bool = world.completed_event_ids.has("event_077")
	if done77:
		event_def.description = "来自阿尔巴尼亚的有趣消息：4月11日，阿尔巴尼亚的终身领导人恩维尔·霍查逝世，享年76岁。在这个国家为自己的损失感到悲痛的同时，拉米兹·阿利雅接任了阿尔巴尼亚劳动党中央委员会第一书记的职位，长期以来，他被认为是霍查的继任者，在击败穆罕默德·谢胡的集团中发挥了重要作用。阿利雅欣赏霍查并无条件支持其政策的所有转变，但是，据一些报道，他并不反对与西方和南斯拉夫建立关系，也不反对在国内政治上做出一些让步。一方面，这会影响到我们，另一方面，也不知道它会如何结束。因此，我们可以组织对新统治者的恐怖袭击，当然，如果我们在附近有特工的话。"
	else:
		event_def.description = "新华社1985年4月11日地拉那电：阿尔巴尼亚的终身领导人恩维尔·霍查逝世，享年76岁。在这个国家为自己的损失感到悲痛的同时，拉米兹·阿利雅接任了阿尔巴尼亚劳动党中央委员会第一书记的职位，长期以来，他被认为是霍查的继任者，在PPSh（阿尔巴尼亚劳动党）的早起历程和游击战中立下了汗马功劳。阿利雅欣赏霍查并无条件支持其政策的所有转变，但是，据一些报道，他并不反对与西方和东方集团建立关系，也不反对在国内政治上做出一些让步。一方面，阿尔巴尼亚可能会寻求其他国家的援助而抛弃我们。另一方面，我们也不知道会不会真的这么做。因此，我们可以打打这个不听话小孩的屁股，当然，如果我们在附近有特工的话。"
	var albania := world.get_country_by_legacy_index(20)
	var yugo := world.get_country_by_legacy_index(15)
	var agents := world.数值表[W.I_AGENTS] if world.数值表.size() > W.I_AGENTS else 0
	var opt := event_def.options
	_enable(opt[0], "什么都不做")
	if ((yugo != null and yugo.has_tag("对华贸易")) or (albania != null and albania.has_tag("对华贸易"))) and agents >= 60:
		_enable(opt[1], "招募一群科索沃阿尔巴尼亚人并发动一次恐怖袭击（-6特工网络）")
	else:
		_disable(opt[1], "我们的情报机构对此无能为力")
	if albania != null and not albania.has_tag("对华贸易") and not albania.has_tag("亲中"):
		_enable(opt[2], "尝试与新的管理层建立关系（需要3百万预算）")
	else:
		_disable(opt[2], "中阿关系平稳如常")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if d.size() > W.I_ALBANIA_BREAK:
				d[W.I_ALBANIA_BREAK] = 2
			if albania != null:
				albania.government = 1
				albania.sub_government = 1
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -60)
			ws.influence_prc += 5
			if d.size() > W.I_ALBANIA_BREAK:
				d[W.I_ALBANIA_BREAK] = 3
			var text := ""
			if albania != null and albania.parts.size() > 0 and albania.parts[0]:
				text = TXT_R1_A
				albania.government = 0
				albania.sub_government = 10
			elif albania != null and albania.government == 1:
				text = TXT_R1_B
				albania.government = 0
				albania.sub_government = 0
				if albania.special == 1:
					text += TXT_R1_EXTRA
					albania.set_tag("balecon", true)
			elif albania != null and albania.government == 0:
				text = TXT_R1_C
				albania.government = 0
				albania.sub_government = 10
				if albania.special == 1:
					text += TXT_R1_EXTRA
					albania.set_tag("balecon", true)
			context["result_text"] = text
		2:
			ws.influence_prc += 15
			if albania != null:
				albania.set_tag("对华贸易", true)
				albania.government = 1
				albania.sub_government = 1
			if d.size() > W.I_ALBANIA_BREAK:
				d[W.I_ALBANIA_BREAK] = 2
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_BUDGET, -30)
			_add_relation(EmpireData.USSR, -50)
			_add_relation(EmpireData.USA, -80)
			context["result_text"] = TXT_R2



