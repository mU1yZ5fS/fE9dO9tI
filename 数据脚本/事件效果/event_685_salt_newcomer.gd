extends "res://数据脚本/event_script_base.gd"

## 原作 Event685.cs：战略武器限制谈判——新人入局（三选项）。
## 触发：ReqEventsDLC02.cs:232-234 —— china.okb && r544∈{1,2} && science[26/22/29]
##   && data[21]>1980 && influencePRC>=500 && !china.sev/ovd/asean/seato → trigger_script evaluate。
## 差异：names1/names2 → name_display；{2}=军委主席（politics_positions[1]，<100 用槽内人，否则“其他”）；
##   {0}（结果3）=外交部长（politics_positions[2]，<100 用槽内人，否则领袖）；
##   old_modify_desc[50] 为 display-only 文案，按项目惯例跳过并留原文。

const TXT_DESC_FMT := "看上去我们遇到了难得一遇的趣事，{0}{1}同志：中国外交部同时收到了来自美苏两大国领导人的照会与呼吁我国加入“战略武器限制谈判”（SALT）相关机制的申请。看得出来，他们显然是想将日益崛起的我国给纳入国际军控机制的管辖范围内：“战略武器限制谈判”的历史可被追溯至20世纪60年代启动的缓和议程，以应对超级大国越加失控的军备竞赛与膨胀的核武威胁。彼时的美国领导层与苏联共产党领导层均将其作为外交重点来抓，期待在为国内核武库消肿的同时起到削弱对方威慑实力的作用。苏共总书记勃列日涅夫更是将其作为对美政策的中心议题，并在相关方面继续重弹赫鲁晓夫的和平老调。1979年达成的第二轮战略武器限制谈判与其中要求双方均削减核武库存的条款便是最让其“沾沾自喜”的手笔。在很长一段事件内，这种军备管控也只是超级大国间的特权：毕竟美国与苏联是目前公认的少数两个具有核三位一体实力（可使用陆基战略导弹、潜射导弹与战略轰炸机执行核打击任务）、庞大核武库与强势核工业的强权。可随着中国的崛起，时代还是变了。国际军备竞赛迎来了第三方，自然也得准备适应第三方的游戏规则……显然这既是机遇也是挑战：诚然，加入相关机制必然会招致军备发展被束手束脚的可能，而我国目前的武库（自卫为主）也自然不能简单地适用针对老牌超级大国（专注进攻与大规模报复）的标准——削足适履的结果不必多言；可超级大国开出的入场券与连带的声誉与责任本身便是无法估价的隐形资产，为什么不试着接受它，然后使用运动战的方式灵活迂回呢？毕竟战略武器限制谈判和一切国际机制共享缺乏强制力的劣根性，且美苏两国也切实在先前的会议内不止一次地败坏了它的声誉……不论如何，决定权在您。"
const TXT_OPT0_DIS := "走三和外交的黑线？我们绝不允许！"
const TXT_OPT1_DIS := "我们可没那功夫搞特殊！"
# 提取器丢掉了 string.Format 开头的 "{"，见 tmp/event_677_685_fmt.txt Event685 FMT_1/FMT_2。
const TXT_R0_FMT := "{0}{1}同志最终决定前往日内瓦参与高峰会议，并在会议上就裁军与国际局势缓和问题给出中国立场。而有关中国领导人来访的消息很快便一石激起千层浪：毕竟，上次能让中美苏领导人齐聚的大会还得追溯到1954年举行，旨在探讨印度支那地方和平问题的日内瓦会议。人们对这次会议兴味盎然，来自世界各地的3500多名记者齐聚一堂。当然，设想在机制草创之初便达成共识也并不现实。三方宣布新缓和机制将在尊重《禁止核试验条约》、《不扩散核武器条约》等协定的基础上进一步推进国际和平事业：并重申永远不应发动核战争的政治正确。此后便是有关核武器与常规军备的诸多声明与承诺：防止发生太空军备竞赛、停止在地球的军备竞赛、限制并裁减核武、加强双方战略互信。而我们的声明也被淹没在了这些干巴巴的共识当中：党和国家对此多少对此表示不满。毕竟，人们并不喜欢套话与空头文章——唯一的收获似乎也只限于有限的裁军监督机制。我们多少能借此派遣人员了解超级大国的武库容量，以及其在应用的进展；可反过来也是如此——韬光养晦的好日子结束了。"
const TXT_R1_FMT := "{0}{1}同志最终决定前往日内瓦参与高峰会议，并在会议上就裁军与国际局势缓和问题给出中国立场。而有关中国领导人来访的消息很快便一石激起千层浪：毕竟，上次能让中美苏领导人齐聚的大会还得追溯到1954年举行，旨在探讨印度支那地方和平问题的日内瓦会议。人们对这次会议兴味盎然，来自世界各地的3500多名记者齐聚一堂。当然，和气与热闹只是他们的，接下来的暗箭可少不了——实际上，早在{0}{1}同志决定奔赴会议前，政治局便已为讨论相关问题召开了秘密会议，并决定最大限度地利用这一事件作为国内军事制度的改革契机：由于“战略武器限制谈判”机制并未就“战略武器”的种类与质量水平做出详细规定，意味着这一条约的极限适用范围也仅限于军备数量。于是，{0}{1}同志决定创造性地“脚踏两条船”：既要收下加入“战略武器限制谈判”机制的风头，又要在同时最大限度地确保中国国防发展进程免受其潜在的消极影响。实际上，正扮演SALT机制一极的美国便是暗度陈仓的老手：一边是放出缓和信号，唱红脸欢迎苏联裁军的总统；一边则是千方百计拖延裁军条款通过的国会，以及得到总统拨款后持续用新武器丰富武库种类的美国三军与赚得盆满钵满的军工复合体。当然，设想在机制草创之初便达成共识也并不现实，尤其是在新引入的中方也倾向于讨价还价，并坚决要求对“战略武器限制谈判”采取更公开与倾向改革的立场的情况下更是如此：美苏绝不会轻易答应按固定比例裁剪核弹头，划定太平洋非军事区，乃至引入来自第三世界的第四方力量组成军备控制调查团的要求。于是，目前所有的一切也只能流于干巴巴的声明上：三方宣布新缓和机制将在尊重《禁止核试验条约》、《不扩散核武器条约》等协定的基础上进一步推进国际和平事业：并重申永远不应发动核战争的政治正确。此后便是有关核武器与常规军备的诸多声明与承诺：防止发生太空军备竞赛、停止在地球的军备竞赛、限制并裁减核武、加强双方战略互信。也许接下来的缓和只会更难开展，但既然我们已经在这里赚足了风头——那便足够。也就在日内瓦会议结束后，{0}{1}同志便立即乘坐专机直接回国，并同{2}同志等一道制定了《关于深化国防和军队改革的意见》。计划从编制、军备、军种、后勤、征兵制、信息化、快速反应、军事指挥与战略打击能力诸方面下手，通过深化军事研究与持续推进技术革新，在2000年前将人民解放军从传统大兵团转变为短小精悍劲旅，以此面对新世纪各项挑战。"
const TXT_R2_FMT := "中国外交部最终回绝了相应邀请，并称“现在还没到时候。白宫与克里姆林方均未拿出相应的诚意与魄力改变外交路线，并达成全面而彻底的妥协”。当然，美苏双方不会对我们的闭门羹有什么好脸色看，并开始重弹反华宣传的老调。对此，{0}也自有应对之法：“中方高度关切且支持包括战略武器限制谈判在内的一切试图推进国际和平进程与军备控制的措施。然而，恰恰是推出这一机制的超级大国自身败坏了其声誉，使其有效性备受质疑——战略武器限制谈判持续推进的70年代，也恰是超级大国核武器爆炸式增长的时期。而该机制作用也只限于针对部分军备实施有限控制，从未达成一个全面、综合的裁军方案。即便是在双方就限制战略武器达成相关协定后，实施也难以提上日程。因此，直至局势发生根本改观前，中方暂无加入相关机制的打算”。虽说道理如此，可中国日益膨胀的军事力量本身却只会给出另一种答复——无意参与缓和议程的潜台词无非是为取而代之，彻底改变两超级大国相互拌嘴的既定局势做准备，这只会让国际局势朝着越加紧张的方向发展。接下来就得直面冷战了……"
# 原版 old_modify_desc[50] 追加的 display-only 文案（本版由 ModifierCatalog 静态维护，跳过运行时拼接）：
#   R0: |[color=red]参与SALT机制[/color]|中美关系+0.2，中苏关系+0.2，军事实力-0.4，特勤网络+0.2，思想自由化+0.2，外交声誉高于90.0时：外交声誉-0.2，外交声誉低于50.0时：外交声誉+0.2，核战必定不会赢得胜利
#   R1: |[color=red]参与弱化的SALT机制[/color]|中美关系+0.1，中苏关系+0.1，军事实力-0.2，外交声誉高于90.0时：外交声誉-0.1，外交声誉低于50.0时：外交声誉+0.1
#   R1: |[color=red]军备发展新方针：贯彻质量制胜[/color]|预算-4.0，军力+2.0，人民支持度+1.0，生活水平+0.6，干涉点数+4.0，军武支援效果+2.0，外交声誉+0.1，科技点+10.0
#   R2: |[color=red]自行其是的世界第三极[/color]|中美关系-1，中苏关系-1，外交声誉+0.2


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	event_def.description = TXT_DESC_FMT.replace("{0}{1}", _leader_name(world))
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _res(W.I_POLITICAL_LINE) != 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _res(W.I_BUDGET) + _res(W.I_RESERVE) >= 150:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader := _leader_name(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_FMT.replace("{0}{1}", leader)
			_set_data(W.I_DIPLO, 700)
			_add(W.I_PARTY_SUPPORT, -50)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, 80)
			_add_power(EmpireData.USA, 20)
			_add_relation(EmpireData.USSR, 80)
			_add_power(EmpireData.USSR, 20)
		1:
			var military := _military_chairman_name(ws)
			context["result_text"] = TXT_R1_FMT.replace("{0}{1}", leader).replace("{2}", military)
			_set_data(W.I_DIPLO, 800)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_BUDGET, -200)
			ws.influence_prc += 50
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, 10)
			_add_relation(EmpireData.USSR, -50)
			_add_power(EmpireData.USSR, 10)
		2:
			var speaker := _foreign_minister_phrase(ws)
			context["result_text"] = TXT_R2_FMT.replace("{0}", speaker)
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null:
		return false
	var d2 := world.数值表
	if d2.size() <= W.I_YEAR or d2[W.I_YEAR] <= 1980:
		return false
	var china := world.get_country_by_legacy_index(1)
	if china == null or not china.has_tag("okb") \
			or china.has_tag("sev") or china.has_tag("ovd") \
			or china.has_tag("asean") or china.has_tag("seato"):
		return false
	var r544 := world.result_of_event_num(544)
	if r544 != 1 and r544 != 2:
		return false
	if world.techs == null:
		return false
	for idx in [26, 22, 29]:
		if world.techs.unlocked.size() <= idx or not world.techs.unlocked[idx]:
			return false
	return world.influence_prc >= 500


## 原版 {0}{1} 位置 = names1[name_1] + names2[name_2] → Godot name_display。
func _leader_name(world: WorldState) -> String:
	if world != null and world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"


## 原版 politics_dolshnost[1]（军委主席槽）：<100 用槽内政治家，150/200 等哨兵→“其他”。
func _military_chairman_name(world: WorldState) -> String:
	if world != null and world.politics_positions.size() > 1:
		var idx := world.politics_positions[1]
		if idx >= 0 and idx < 100 and idx < world.politicians.size() \
				and world.politicians[idx] != null and world.politicians[idx].name_display != "":
			return "军委主席" + world.politicians[idx].name_display
	return "其他"


## 原版 politics_dolshnost[2]（外交部长槽）：<100 用槽内政治家，否则用领袖。
func _foreign_minister_phrase(world: WorldState) -> String:
	if world != null and world.politics_positions.size() > 2:
		var idx := world.politics_positions[2]
		if idx >= 0 and idx < 100 and idx < world.politicians.size() \
				and world.politicians[idx] != null and world.politicians[idx].name_display != "":
			return "我国外交部长" + world.politicians[idx].name_display + "同志"
	return _leader_name(world) + "同志"
