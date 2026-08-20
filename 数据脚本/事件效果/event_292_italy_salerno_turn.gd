## 原作 Event292.cs：“萨莱诺转向”对“意大利社会主义”（意大利社会党/共产党论战，四选项）。
## 触发：全目录搜索无 this_num_event = 292 / Reset(292)；链外 REST 段，原版无自动条件。
## 差异：选项3 原版条件 IsAuthoritarianism(55)/puppetOf<0 按原样复刻（55=突尼斯，原版如此）。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "“意大利式社会主义者”间的狗咬狗？我们可乐见与此！"
const TXT_OPT2_DIS := "阶级对阶级的公式早已过时！"
const TXT_OPT3_DIS := "现代修正主义者不准通过！"
const TXT_R0 := "共产党同社会党间的论战可说是完全无助于前者的陷阱：不论共产党采取何种立场，最终都不过是增强其竞争对手社会党的曝光度，分化民主左翼内部力量，并事实上摧毁在共产党参与下组建新政府的最可行方案之一（即二战结束初双方团结在“人民民主阵线”竞选联盟，争取“左翼替代”的公式）。虽说社会党还不足以借此恢复往日辉煌，可克拉克西切实迈出了将局势搅浑的第一步。与此同时，克拉克西对该国其他小政党所作的宣传工作与对共产党的孤立政策亦不可忽视。意味着若要将共产党拉入政权，要么寻找更加激进（且松散的势力），要么在“历史性妥协”的基础上更进一步，事实上将自身明确为一个更加具有“意大利特性”与“大西洋主义”色彩的政党。可它真的能够就此割舍自己名字当中的“共产”二字吗？"
const TXT_R1 := "考虑到克拉克西的做法无助于在意大利推进任何形式的“民主替代”议程，我们决定立即出手施加干预。通过对社会党组织的渗透，相关人士揪出了不少同党魁克拉克西有关的黑材料（即便目前多只限于线索阶段，但已然足够）：这位小党的领导人不仅有着同其地位不相匹配的未知财政收入，并借此大肆征购别墅与地产；更是借助“非公开政治捐赠”的形式，以党的利益为名建立起秘密账户（并以此“享受分红”）；他同媒体大亨西尔维奥·贝卢斯科尼的合作并非局限于简单的“政治友谊”，更有一旦克拉克西上台，便会为后者的收购计划大开方便之门的蓝图。而这些材料足够我们好好敲打敲打这位“老革命”，并让克拉克西引火烧身：毕竟，与之相对的共产党确实可对其资金赞助问题持坦荡态度，并以清明政坛者的形象打压克拉克西。虽说克拉克西仍能摆脱其中的绝大多数指控，可怀疑的种子切实已经种下。除此之外，我们的资金还为共产党的地方传媒与社区组织送上助力，通过扩大其社区福利设施，强化竞选运动，标榜“民主替代方案”等做法巩固其基本盘。这在议会外极左翼倾向持续遭受排挤的情况下更是引来波“回归”浪潮——这些新人不久便皈依至主打新议题的众议院议长彼得罗·英格拉奥与其支持者构成的“左翼”集团内，并尝试借这逐步恢复斗争性的组织挑战天民党秩序。"
const TXT_R2 := "克拉克西对共产党的挑战恰恰暴露了欧洲共产主义纲领的无力本质，以及意大利共产党事实上被置于“待定性”政党的尴尬位置：既无法同自身作为共产国际支部，从十月革命内汲取意识形态基础及力量的历史割舍；也无法完全拥抱改良主义，将自身转化为纯粹为意大利公民利益而参选的党（这既受到党内左翼的强烈抵制，亦不会被主流建制派所理解）。实际上，主导“萨莱诺转向”的帕尔米罗·陶里亚蒂早已看出这一实质，并将其视为共产党在自身创新下发展出的二元性而对此“沾沾自喜”——他不仅采访中称质疑共产党不可能成为现代意大利民主、统一与国际利益代言人的政治对手称之为“见识到长颈鹿却选择自欺欺人”的可怜人；更在战后政治实践内切实将“社会主义、劳动与民主”的原则写入主宰第一共和国的政治正确内，却同时给强大的安保部门与私营企业深入剥削群众开了绿灯。考虑到这种撮合共治的做法事实上只会导致思想混乱，乃至实践内的裹足不前。我们决定借助共产党近期的失败更进一步，播撒混乱的种子。而这只会证明党内左翼，反对同天民党达成任何形式妥协，主张单独推出左翼议程的党内强硬派彼得罗·英格拉奥；乃至卢西奥·马格里这些早就被迫在党内纪律下同共产党分道扬镳的激进派论断之正确（即便是“改进派”巨头乔治·阿门多拉也不得不承认，不论如何，支持一个共产党无法以任何形式参与其中并获得利益的政府是“毫无意义”的）。最终导致了挂靠共产党的部分工人运动活动家与党内左翼倾向逐步同共产党剥离关系并越加自行其是。其中的绝大多数事实上向早在60年代便另起炉灶的媒体运动“宣言派”看齐——议会外左翼的力量至此得到增强，这对我们来说挺好的。"
const TXT_R3 := "意识到克拉克西初出茅庐便爆发如此能量，前途自是不可限量。很快，我们的专员便抵达罗马拉斐尔酒店同这位社会党巨头共商大计：虽说克拉克西在宣传口大肆标榜自身对欧洲文明的无上忠诚，并要坚决驱逐“亚洲性的马克思列宁主义势力”。可我们送上的真金白银足以给他“脱亚入欧”的良好印象，并让克拉克西底气十足。他对待外援的坦诚态度足以证明了其确实是独具慧眼，出手果决的成熟大政治家。与此同时，借助克拉克西在阿拉伯世界与社会党国际的老朋友们的联系（主要是突尼斯“国父”，该国的政治不倒翁哈比卜·布尔吉巴），我们的资金得以源源不断地注入社会党的秘密账户，并转化为愈加强大的反共宣传攻势。而共产党对此则处处被动，不得不重申自身对于意大利国家核心利益的忠诚，乃至对社会改良价值观的捍卫以维持同建制派间的残存民族团结协定。除此之外，以安东内洛·特龙巴多里为代表的“改进派”人士则从克拉克西的成功经验中证实了修正主义“新道路”的潜在价值。并越加呼吁共产党另起炉灶，将自身的意识形态根基建立在“克伦斯基的民主二月”和同克拉克西一般的“人道民主欧洲性”议程上。修正主义旋风至此席卷全国，大有统摄左翼阵营之势。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var tunisia := world.get_country_by_legacy_index(55)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if line >= 2 and line <= 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line <= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if tunisia != null and world.is_authoritarian(tunisia) and tunisia.puppet_of < 0 and line >= 3:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -40)
			_add(W.I_BUDGET, -80)
			_add(176, 1)
			_add(179, 1)
			_add(172, -1)
			_add(173, -2)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -20)
			_add(176, -2)
			_add(172, 1)
			_add(173, 2)
			_add(134, 20)
			if italy != null:
				italy.内战中 = true
			context["result_text"] = TXT_R2
		3:
			_add(W.I_BUDGET, -100)
			_add(176, -2)
			_add(181, 1)
			context["result_text"] = TXT_R3




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket

