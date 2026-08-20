extends "res://数据脚本/event_script_base.gd"

## 原作 Event694.cs：盗亦有道（窃国者侯 Decision 触发，六选项）。
## 触发：GlobalScript.cs:70 Decision「窃国者侯」→ decision_catalog.gd d50
##   （HasLeaderAsset(50)+非毛主义+非第四国际+非农联+每月一次），d50.effects 已 start_event(694)。
## 差异：MoneyLevel→ws.money_level、LeaderAsset→ws.leader_asset；
##   completedDecisions[50]=false → ws.decisions.completed[50]=false（result5）。

const TXT_OPT0_A := "控制国家物资的方式永远有效"
const TXT_OPT0_B := "利用价格规律致富合情合理"
const TXT_OPT1_A := "在出售国有资产的议程内提供便利，并在其中分占丰厚利润"
const TXT_OPT1_B := "建立空壳投资公司，通过吸收政府补贴获利"
const TXT_R0 := "显然，早已在行政界与经济领域深耕，并颇具势力的您最清楚社会所需，并能最大限度地利用其为自身牟利。通过控制某些关键物资（如粮食，衣物，药品）与奢侈品的流通渠道，您便能同控制水库流量般逐渐拿捏某些地区人口的命脉，并在关键时刻匀出其中一部分，以“竞争上岗”的方式事实上奉行强买强卖政策。掌握议价权并形成买方市场的方式很快便积攒了相当财富，而这自然是以社会的萎靡与需求不足为代价。也就在您与您的亲信们靠着这一手段稳定进帐，并通过产业化运营形成规模效应的同时，国内人民的平均生活水平也开始随之跳水。民间已有人将您同开设国营妓院，炒作布帛价格的古代政治家，以敛财而闻名的管仲相提并论——当然，是消极方面的。"
const TXT_R1_FMT := "我国古代历史的知名贪墨们已为您做出了极佳示范——既然国家政府本身便是个聚宝盆，那为什么不试着同它分利，并将其部分资产中饱私囊呢？不久后，得到{0}{1}先生指示的各种空壳公司与资产管理机制拔地而起：这些头顶“利华”、“华润”、“兴中”等好名字的单位打着替国家分忧，促进社会公益的旗号积极进军财政与金融领域，开始在触及国内多项大宗资产的管理业务的同时吸收社会捐款与国家补贴，源源不断的资金就此流入了您与您亲信的秘密账户上。当然，这些产业并非是只进不出的黑洞与橡皮图章——它们的另一大业务“经济咨询”也办得风风火火：靠着对公共产业的混合所有制改革议程，它们得以在促进私有化的同时以手续费与持股形式分占丰厚利润，并在不久后通过产业化运营形成了规模效应。可考虑到中国有缺什么补什么的习俗，资产管理公司自然是最不懂如何管理资产的角色：经它们之手的产业下场也只能是持续萎靡，并拉着人民生活水平一齐跳水。人们很快便会发现这点的……"
const TXT_R2_FMT := "不久后，得到您默许与国家背书的“中国福利基金会”、“中国智慧基金会”、“中国国家基金会”等顶着多种名目的非盈利财团法人拔地而起。上述“社会公益团体”根据功能界别为自己树立门目，并借此吸纳国家预算与社会捐款。而这不过是个开始：也就在各类基金会崛起的同时，国务院悄然批准了成立各类“发展公司”的决定，并将上述部门的财务系统与人事同公益部门乃至国家机构实现绑定，其负责人自然是{0}{1}先生的亲属：因此，公司很快便成为了高干与其子弟的独立王国，并以中国现有的部委与行政架构照猫画虎，为自家置办类似的产业：发展公司的经营范围也就此四处开花，从石油到运输、从汽车到金融等无所不包。它在以国家名义操办外贸，引进技术与插手海关管理的同时，毫不留情地将原属国家部门管理的产业与部分高附加值产业收入囊中，且常以玩弄价格差的方式以倒买倒卖和经济投机获利。因此，这类公司的能量惊人，不仅绑上了国家的各项优惠政策，同时还近乎涉及国内所有有利可图的产业，并能在经济改革内捷足先登，抢先将国家精简的部门、下放的企业等归入旗下。围绕着基金会与发展总公司的网络正逐步扩大，一方面持续滋养着{0}{1}与其家族，一方面则通过裙带关系与权钱交易形成跨区域、跨派系的中国新氏族集团。变种的贵族政治就此形成，并通过新版分封制对国民敲骨吸髓——而我国国民对此自是深恶痛绝：知识分子将领导人视为“挟祖国而令天下”的当代国贼曹操，平民百姓也创造了“毛泽东的儿子上前线，{0}{1}的儿子倒彩电”如此不留情的口号。"
const TXT_R3_FMT := "考虑到偷税漏税已有明朝晚期官僚与菲律宾总统费迪南德·马科斯的经验“珠玉在前”，您很快便将盗窃国家税收的技巧学得炉火纯青：建立比例税收制度，坚决拒斥累进税和财产税，实现全国人民均等收税只是{0}{1}计划的第一步。接下来便是巧立门目，为我国领导人与高级官员的资产让路的时刻：我们不仅以“开发补贴”、“企业税惠”、“出口退税”、“社会团体免税”等形式给多种资产所有形式让路，并事实上建立了带有反向支付的税务管理体系：即全年从所有公民处收取相等的税款，而在年终则根据收入水平，预算会向我国的特权阶层者分配更多的资金。形成了有中国特色的“先富起来”发展模式。与此同时，我们精心改良了税收与罚款制度本身，使得国家在增税增费，多增门路的同时奉行一种另类的什一税制度：即所有税款在征收后仍需分割出一定比例交予专管“国家保障事业”的特别办公室，而该机构则直接同{0}{1}对接，显然大伙都知道钱的最终走向。我国的国家银行也得到了相应指示，并识时务地在保持基本业务的前提下增印货币，并转移存款准备金与外汇至各路秘密账户。我国金融部门就此成为了一个自行其是的独立王国，包办除经济发展外的一切事务。“敲门砖”制度与有关小费的俚语也就此风行全国：中国官僚与公共服务机构基本成为了一个若无红包或贿赂打点，便基本上无法办成任何事的空壳子。"
const TXT_R4_FMT := "{0}{1}先生在看完《三国演义》内刘焉圈地自保，以及曹操筹建魏国，受封魏公的情节后，很自然地在笔记本上做了批注：“原来想当然地以为处于物质极端贫瘠状态，手腕极其落后的三国时代政治家，敛财水平竟然比中华民国的四大家族都高。我看汉代豪强搞得不错，物质资产极大丰富，国家收入基本榨空，无所不为，专卖垄断也受重视，如果加上我{0}{1}亲自参与，亲自指挥，那汉代三国就是我们理想中的社会了”。此后您很快便召集班子，量身定做的一套在中国境内建构“国中之国”的计划：铁道部、地质部、工业部等领域纷纷交出了各自的最大肥缺供您享用，并事实上将国内最有前景的交通路线、工矿企业与地产交予{0}{1}负责的总开发公司下。与此同时，您的亲信也已摸清了自己家乡的情况，开始依托故居与传统人脉在当地大兴土木，清洗异己以夯实基业（比如拆了当地农民的故居为您的私人园林或机场开路）。省内圈地与人事改组就此形成了现代版的种植园，并逐渐形成了类似苏联勃列日涅夫圈子与各加盟共和国庇护结构的区域氏族与政治黑帮。类似的操作只会在您巩固故乡，完成基层试点后全国推广。由此在国内最发达与最具战略价值的地区内发展自身势力，预计接下来便是在北京、上海与广州等地发展与扩张新业务。当然，您当然没有忘记中国的传统致富经：烟草、食盐、酒精等关键产品的专卖权已通过人事运作逐步向您手中汇集，并让您也可参与其中分红，分占丰厚利润。来自海关的收入与国际合同也没能逃出您的手掌心，配合军警宪特的大棒，保护费也就此变得名副其实。中国业已向着“家天下”的方向迈出一大步，并大有裂解为封建王国的势头：国际社会已将其同蒙博托、马科斯与苏哈托政权的盗贼体制相提并论。国内更是控诉称新任领导人的手段和彼时的“日本三光政策”相比有过之而不及……"
const TXT_R5 := "一切如常，显然中国并没有什么新闻——而您也不过是一位稍稍有点贪婪，但多少能恪守节制美德的普通政客而已。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 6:
		return
	var econ := _res(W.I_ECON_SYSTEM)
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0_A if econ < 14 else TXT_OPT0_B)
	_enable(opt[1], TXT_OPT1_A if econ < 15 else TXT_OPT1_B)
	_enable(opt[2], event_def.options[2].text)
	_enable(opt[3], event_def.options[3].text)
	_enable(opt[4], event_def.options[4].text)
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			ws.money_level += 1
			ws.leader_asset += 50
			_add(W.I_LIVING, -150)
			_add(W.I_AGRICULTURE, -100)
			_add(W.I_INDUSTRY, -50)
			_add(W.I_SERVICES, -50)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_set_mod_active(65)
		1:
			context["result_text"] = TXT_R1_FMT.replace("{0}{1}", leader)
			ws.money_level += 2
			ws.leader_asset += 100
			_add(W.I_LIVING, -100)
			_add(W.I_AGRICULTURE, -150)
			_add(W.I_INDUSTRY, -150)
			_add(W.I_SERVICES, -100)
			_add(W.I_CORRUPTION, 100)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_set_mod_active(65)
		2:
			context["result_text"] = TXT_R2_FMT.replace("{0}{1}", leader)
			ws.money_level += 3
			ws.leader_asset += 150
			_add(W.I_LIVING, -250)
			_add(W.I_AGRICULTURE, -150)
			_add(W.I_INDUSTRY, -150)
			_add(W.I_SERVICES, -150)
			_add(W.I_CORRUPTION, 150)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add(W.I_THOUGHT_FREEDOM, 200)
			_set_mod_active(65)
		3:
			context["result_text"] = TXT_R3_FMT.replace("{0}{1}", leader)
			ws.money_level += 4
			ws.leader_asset += 200
			_add(W.I_LIVING, -100)
			_add(W.I_AGRICULTURE, -250)
			_add(W.I_INDUSTRY, -250)
			_add(W.I_SERVICES, -250)
			_add(W.I_CORRUPTION, 250)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -300)
			_add(W.I_THOUGHT_FREEDOM, 250)
			_set_mod_active(65)
		4:
			context["result_text"] = TXT_R4_FMT.replace("{0}{1}", leader)
			ws.money_level += 5
			ws.leader_asset += 250
			_add(W.I_LIVING, -250)
			_add(W.I_AGRICULTURE, -250)
			_add(W.I_INDUSTRY, -250)
			_add(W.I_SERVICES, -250)
			_add(W.I_CORRUPTION, 300)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -350)
			_add(W.I_THOUGHT_FREEDOM, 300)
			_set_mod_active(65)
		5:
			context["result_text"] = TXT_R5
			# 原版 completedDecisions[50]=false：允许决议再次出现。
			if ws.decisions != null:
				while ws.decisions.completed.size() <= 50:
					ws.decisions.completed.append(false)
				ws.decisions.completed[50] = false


func _set_mod_active(index: int) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
