extends "res://数据脚本/event_script_base.gd"

const S_14 := "推倒这堵墙！"
const S_15 := "随着中华人民共和国影响力不断提高，我们也得以对两个德国的命运做最终判决。我们有三个方案，分别是让西德主导统一，东德主导统一或者组成平等的联邦。但决定权在您的手上！"
const S_23 := "西德主导统一"
const S_28 := "他们啃不下东德的"
const S_32 := "东德主导统一"
const S_37 := "西德的情况似乎要好得多"
const S_41 := "组成平等的联邦"
const S_45 := "工农兄弟应当是一家！"
const S_50 := "总有一方会不高兴的"
const S_52 := "下次再说吧"
const S_57 := "推倒这堵墙！"
const S_60 := "Ach(Clone)"
const S_66 := "在我们的大力撮合下，联邦德国成功和民主德国的外交部长得以在基尔就统一达成一致。双方确定了将由西德负责东德未来的发展，而东德地区将解散自己的武装力量，转而由西德接手一切的国营企业。前统社党高层被判以“叛国”和“腐败”罪，昂纳克在统一的前夜逃往智利大使馆寻求庇护。柏林墙最终也被拆除。两德最终统一了，但是代价呢？"
const S_76 := "在东德经历了政局的大洗牌后，西德同志们得以在东德站稳脚跟，以革命领军人的姿态向西德发出邀请。出于对社会主义理念的向往，东德领导人似乎没有理由拒绝。随后，两个德国的领袖在基尔举行了会谈，双方决定了将由西德的同志们主导东德的革命。但东德在一些问题上仍然保有自己的权力。很快，再社会主义化的改革在东德如火如荼的召开了，而西德也为有了足够广阔的农业基地感到高兴。就史塔西问题，双方都一致同意史塔西的监控作用完全可以被工人赤卫队所取代，因此史塔西将被改组为“革命保卫办公室”而继续存在。德国人终于住在同一片屋檐下了。"
const S_86 := "与革命保卫办公室合作"
const S_87 := "特工网络+1.5;|极左派+1;|极左派力量+1."
const S_97 := "统一德国"
const S_100 := "在社会主义阵营在全球高歌猛进的背景下，作为资本主义孤岛的西德已是独木难支。因此，接下来发生的事情便是水到渠成：面对西德人民要求开放边界的汹涌民意，波恩当局不得不选择妥协。让民主德国得以一口吞下整个德国。德国统一社会党总书记昂纳克得以在CCTV，塔斯社和CNN的面前自信的推倒柏林墙，并正式宣布两个德国的统一。可考虑到西德社会的体量优势和资本主义体系绝无可能同社会主义共存的客观情况，统一后的社会转型绝非一日之功。因此，民主德国很自然地转向了促成统一的最大功臣，并按照得到后者放行的政治整合方案开始在全国范围内“狂飙突进”：大型与中型企业纷纷被国有化，并在所有权上被归为“人民企业”，价格管制与民主德国马克也同样走入了西德的大街小巷。两个德国的实质统一显然还要很久，但我们坚信他们必然胜利。"
const S_105 := "在米尔克的强烈要求下，以东德为主导的新德国完成了统一。而新生的政权立刻将这位领袖比做是俾斯麦在世，他在任期内得以重新塑造一个德国，并且得以给德国人民他们想要的一切，诸如除了苏联方案以外的社会主义原则。而社会主义原则被“民族—阶级双斗争”给取代。西德人对于东德新领导人的观感与纳粹无异，在得知要统一后，巨大的人流挤爆了机场。而新政府立刻建立起来了。新政府尽管看上去和曾经的朝鲜民主主义人民共和国无异。但他知道要合理运用德国的优势——足够自给自足的工业和农业来提升生活水平。无论如何，现在的国内对于米尔克的崇拜已经达到了一个新的高度，而德国也得以统一。是非功过还是留给后人诉说吧。"
const S_120 := "德意志自由社会主义共和国"
const S_121 := "我们的苦心经营成功使得马克思列宁主义与亲中政治力量在两德地区同时就位，让和平统一方案已然成为可能。考虑到魏玛共和国的政治教训与昔日人民民主国家内的政党整合经验，第一步便是将早已碎片化的德国工人运动与社会主义潮流重新统一：囊括德国马列主义革命党、德国统一社会党、越加同德国社民党分道扬镳的左翼学生-激进青年运动与德意志人民武装力量在内的德国共产党（斯巴达克联盟）至此成立，宣称其将忠于“卡尔·李卜克内西、恩斯特·台尔曼与威廉·皮克”事业基础上综合“19-20世纪以来的一切成就”。事实上采纳“马克思-列宁-毛泽东主义”推论。紧接着便是在东方以东的特别关照下快速实现社会转型。此后，苏联军队亦按照协定撤离。"
const S_131 := "德意志联邦民主共和国"
const S_133 := "我们的计划得到了一众成员国，尤其是苏联和法国的认可。随着“红色恐慌”面纱的落下以及世界友谊思想的繁荣发展，提倡和平主义、社会改革、友谊与和平的左翼同盟赢得了大选。他们的胜利不仅仅是与民主德国建立关系。而东德的新晋领导人希望能更近一步，在双方的授权下，统一社会党和左翼联盟达成了政治上合并。新成立的德意志社会主义同盟宣布将在德国的领土上建立一个平等而自由的联邦。双方将为了中欧的无核化与和平而奋斗。让我们祝他们好运！"
const S_136 := "而在两德统一后，欧洲社会主义联盟也向统一后的德国抛出了橄榄枝，显然，这个“新生”的国家很乐意接受，毕竟，两个分隔已久的国家合并后会有更多潜在的经济问题……"
const S_143 := "我们下次再决定德国的命运。"


## 原作 Event484.cs：推倒这堵墙！（四选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:10229（this_type==116）手动
##   number_event=484 进入；Godot 侧 trigger_conditions=[]。
## 差异：
##  - iron_and_blood 成就未移植，跳过；old_modify_texts[53]/desc[53] 为展示文案跳过；
##  - prosov→亲苏、proprc→亲中、Torg→对华贸易；dev→development；JoinAllOurAlliances→_join_our_alliances。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var c16 := world.get_country_by_legacy_index(16)
	var c17 := world.get_country_by_legacy_index(17)
	var c1 := world.get_country_by_legacy_index(1)
	var c21 := world.get_country_by_legacy_index(21)
	var ussr := world.empires[EmpireData.USSR] if world.empires.size() > EmpireData.USSR else null
	if c16 != null and c17 != null:
		var west_ok := ((c17.has_tag("nato") and (c16.government == 2 or not c16.has_tag("亲苏"))) \
				or (c17.government == 1 and c16.government != 2 and not c16.has_tag("亲苏"))) \
				and c16.sub_government != 10
		if west_ok:
			_enable(opt[0], S_23)
		else:
			_disable(opt[0], S_28)
		var east_ok := ((c16.has_tag("亲苏") and c16.government == 1 and c1 != null \
				and c1.has_tag("sev") and c1.has_tag("ovd")) or c16.sub_government == 10 \
				or (c16.government == 1 and c16.has_tag("亲中"))) \
				and c16.government != 2 and c17.government != 1 and not c17.has_tag("nato")
		if east_ok:
			_enable(opt[1], S_32)
		else:
			_disable(opt[1], S_37)
		if (c16.government == 2 or (c21 != null and c21.has_tag("soc_eu") and c17.has_tag("soc_eu") \
				and ussr != null and ussr.current_leader == 6)) and c17.government == 2:
			_enable(opt[2], S_41)
		elif c16.government == 1 and c17.government == 1 and not c16.has_tag("亲苏"):
			_enable(opt[2], S_45)
		else:
			_disable(opt[2], S_50)
	_enable(opt[3], S_52)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c16 := ws.get_country_by_legacy_index(16)
	var c17 := ws.get_country_by_legacy_index(17)
	var c21 := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if c16 == null or c17 == null:
			return
		if c17.has_tag("nato"):
			_leave_alliances(c16)
			_set_part(c17, 0, true)
			c17.set_tag("对华贸易", true)
			c17.development = 2
			_set_mod_active(53, false)
			context["result_text"] = S_66
		elif c17.government == 1:
			_set_part(c17, 0, true)
			c17.set_tag("对华贸易", true)
			c17.development = 2
			_set_mod_active(53, true)
			_leave_alliances(c16)
			c17.government = 1
			c17.sub_government = 17
			c17.set_tag("亲中", true)
			_join_our_alliances(c17)
			context["result_text"] = S_76
		else:
			context["result_text"] = S_143
	elif opt == 1:
		if c16 == null or c17 == null:
			return
		_set_part(c16, 0, true)
		c16.set_tag("对华贸易", true)
		_leave_alliances(c17)
		c17.development = 3
		c16.name = S_97
		if ws.is_socialism(c16, true):
			context["result_text"] = S_100
		elif c16.sub_government == 10:
			context["result_text"] = S_105
		else:
			context["result_text"] = S_143
	elif opt == 2:
		if c16 == null or c17 == null:
			return
		if c16.government == 1 and c17.government == 1:
			_leave_alliances(c16)
			_set_part(c17, 0, true)
			_join_our_alliances(c17)
			c17.development = 1
			c17.set_tag("对华贸易", true)
			c17.government = 1
			c17.sub_government = 17
			c17.name = S_120
			context["result_text"] = S_121
		else:
			_leave_alliances(c16)
			_set_part(c17, 0, true)
			_leave_alliances(c17)
			c17.development = 1
			c17.set_tag("对华贸易", true)
			c17.government = 2
			c17.sub_government = 3
			c17.name = S_131
			_set_mod_active(53, false)
			var text := S_133
			if c21 != null and c21.has_tag("soc_eu"):
				text += S_136
				c17.set_tag("soc_eu", true)
			context["result_text"] = text
	else:
		context["result_text"] = S_143


func _set_mod_active(idx: int, active: bool) -> void:
	if idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = active


func _leave_alliances(c: CountryData) -> void:
	if c == null:
		return
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _join_our_alliances(c: CountryData) -> void:
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)


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


func _set_part(c: CountryData, i: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= i:
		c.parts.append(false)
	c.parts[i] = value
