extends "res://数据脚本/event_script_base.gd"

## 原作 Event696.cs：人民刚果的文化大革命（三选项）。
## 触发：TimeScript.cs:10992-10998 —— 日>=15 且 月>=3 且 年>=1977
##   （或月>=4 年>=1977 / 年>=1978）。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 + modifies[6]/[3]）。
##  - c52=刚果（布）；prosov→亲苏、proprc→亲中、Torg→对华贸易；
##    empires[1].leaders[4].support++ → 苏联领导人表第4槽支持度+1。

const TXT_TITLE := "人民刚果的文化大革命"

const TXT_DESC := "刚果人民共和国成立后，国家并未就此稳定下来，劳动党党内斗争和南北两大部族的斗争交织在一起，继续动摇着这个新生的社会主义国家，马里安·恩古瓦比掌权不久，就粉碎了两次尤卢派的政变和党内由安吉·迪亚瓦拉领导的亲毛主义和格瓦拉主义的左翼反对派“二月二十二日运动”（M-22）的二月政变及其政变失败后的游击运动。为了重整国内秩序，恩古瓦比开展了清洗运动，党内只剩下不超过160人的党员。同时，为了在全国树立劳动党的领导地位，随后的人民政权化运动使得刚果建立了大批人民民主性质的新政权机构，废除了部族酋长的权力，成立了党委领导的各级机构。\n恩古瓦比执政到现在，刚果的社会主义建设情况一直不大乐观，经济衰退、财政拮据、债台高筑，到1977年，刚果财政赤字猛增到400多亿非洲法郎，外债累计800多亿非洲法郎。经济困难更加深内部矛盾，派别斗争愈演愈烈。1976年2月22日，恩古瓦比在向刚果全国人民发表讲话时说：“近几年中，我国政治形势的特点是，领导人之间发生争执，而不顾劳动人民的最高利益。”\n为了解决“政治领导不一致”，扭转“令人担忧的”国内形势，恩古瓦比于1975年12月主持召开了刚果劳动党中央特别会议，发表了《1975年12月12日声明》，宣布成立“革命特别参谋部”，以取代政治局，筹备召开刚果劳动党第二次全国代表大会和组织“革命政府”，并重申要在全国深入开展一场“从根本上说是‘文化革命’”的“彻底化运动”，一场类似文化大革命的政治运动被发动起来了。据恩古瓦比说，这一运动的目的是“揭发一切机会主义者、分裂主义者和一时的马克思主义者”。但是，这一运动目前似乎还只是止步于办公室清洗和党内整肃。\n恩克瓦比发动的“彻底化运动”从一开始就受到刚果劳动党内外反对派的激烈反对。1976年3月24日，刚果劳动党中央委员、“刚果社会主义青年联盟”第一书记奥卡班德和刚果工会主席孔多等人，在党中央书记皮埃尔·恩泽的支持下，煽动工人罢工，反对彻底化运动。恩古瓦比很快平息了工人罢工，并将恩泽等人开除出党。但斗争仍在继续，也许之后会有更大的阴谋的……\n是时候在刚果采取行动了，主席同志。"

const TXT_OPT0 := "让我们帮助老朋友减轻负担，支持恩古瓦比开展文化大革命！"
const TXT_OPT0_DIS := "我们自己都受够了！"
const TXT_OPT1 := "显然，恩古瓦比掌权这么久都没搞出个名堂来，该消停消停了……"
const TXT_OPT1_DIS_0 := "我们不能背叛革命同志"
const TXT_OPT1_DIS_OTHER := "都是一丘之貉罢了"
const TXT_OPT2 := "我们还有自己的事要忙……"

const TXT_R0 := "我们向恩古瓦比同志表示中国完全支持彻底化运动，面对刚果经济建设上的困难，我们提供了他们一笔无息贷款、一些军事援助和援建项目。在接触中，我们的人无意中发现了一个有陆军上尉巴特米·基卡迪迪等人参与的阴谋集团，正准备刺杀恩古瓦比……得知这一消息的总统也反应迅速，抓捕了阴谋集团。在我们的建议下，恩古瓦比开始重新启用政见更加激进的人物——M-22集团被平反，其中的幸存成员如八月革命元老克洛德-欧内斯特·恩达拉和亲华派安布鲁瓦斯·努马扎莱等人（这一行动也安抚了不满的南方部族，因为恩达拉是南方人）被纳入“革命特别参谋部”，他们开始利用自己过去在学生运动和工人运动中的支持者关系网络，仿照我国的经验进行群众动员，发起大规模的红卫兵运动和造反运动，工厂、集体农庄乃至政府中的保守派都在群众运动的冲击下，被由群众组织重组的革命委员会和革命政府取代。在不久后的刚果劳动党第二次全国代表大会上，恩古瓦比承认：“毛泽东同志和格瓦拉同志的思想启发了我，要用群众的力量扫除部族主义乃至一切落后反动的旧社会残余……毛泽东和格瓦拉的思想应该是刚果劳动党的指导思想之一”。在援助的支持和彻底化运动的影响下，刚果的局势正在缓慢向好，恩古瓦比开始推进经济自立，逐步结束对法国的经济依赖。"

const TXT_R1 := "从刚果劳动党到整个刚果的国家机器内，都不缺乏反对恩古瓦比的人。很快，我们联系到陆军上尉巴特米·基卡迪迪，他愿意为这一使命效力。他的计划也十分简单粗暴——基卡迪迪率领一支由四人组成的“敢死队”，驱车闯入恩古瓦比的住所，并在枪战中将其击毙，从而宣告恩古瓦比时代和这场“文化革命”的结束。但局势并没有朝我们想要的方面演进，随后赶来的安保部队很快擒获了基卡迪迪，并在随后的审讯中供出了是我们支持了他……\n在一场会议后，党内二号人物和理论家让-皮埃尔·蒂斯特雷·契卡雅被选为新的刚果劳动党主席和总统，实用主义保守派政治家德尼·萨苏-恩格索被选为新总理。新一届领导层谴责我国“勾结帝国主义破坏社会主义阵营团结，干涉他国内政”，随后彻底倒向苏联，并以恩古瓦比的名义继续“彻底化运动”，进行社会整肃。新领导层强调继承恩古瓦比的遗志，增进党内团结。不久后，契卡雅主持召开刚果劳动党中央委员会会议，对1972年“二月二十二日运动”和1976年“三月二十四日运动”（即“刚果社会主义青年联盟”第一书记奥卡班德和刚果工会主席孔多等人，在党中央书记皮埃尔·恩泽的支持下，煽动工人罢工，反对彻底化运动的事件）进行重新评价，认为这两次运动是“积极的”，参与者的目的是“为了表明革命的愿望”。因此，在“左派团结起来”的口号下，曾因为参加了这两次运动而被开除出中央委员会或被解除职务的大部分前中央委员又重新回到了中央委员会，其中有些人还得到重用，被选进政治局和书记处。在党、政机构的人事安排上，也注意照顾不同部族和地区的利益，从而逐渐实现了“党内和人民内部的团结”，使长期动荡的刚果政局开始好转，团结一致向前看。刚果终于有了稳定下来的兆头，可惜不是向着我们的方向……"

const TXT_R2 := "1977年3月18日，陆军上尉巴特米·基卡迪迪率领一支由四人组成的“敢死队”，驱车闯入恩古瓦比的住所，并在枪战中将其击毙，从而宣告恩古瓦比时代和这场“文化革命”的结束。激进的社会主义试验所没有解决的严重政治经济问题，也就留给了后来的刚果领导人去解决。\n刚果劳动党中央解散了革命特别参谋部，宣布成立以他的表兄弟若阿基姆·雍比-奥庞戈为主席的刚果劳动党军事委员会，作为最高权力机构，委员会废除了1973年宪法，全权处理国家事务。雍比上台伊始，即大肆清洗异己势力，借口当时一直闲居在家的前总统马桑巴-代巴是谋杀恩古瓦比的幕后策划者，而将他“特别匆忙地”加以处决。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if line <= 1 and mod6 and mod3:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 0 and line < 4:
		_enable(opt[1], TXT_OPT1)
	elif line == 0:
		_disable(opt[1], TXT_OPT1_DIS_0)
	else:
		_disable(opt[1], TXT_OPT1_DIS_OTHER)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var congo := ws.get_country_by_legacy_index(52)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -30)
			if congo != null:
				congo.government = 0
				congo.sub_government = 0
				congo.set_tag("对华贸易", true)
				congo.set_tag("亲中", true)
			_add_relation(EmpireData.USA, -75)
			_add_relation(EmpireData.USSR, -75)
			ws.influence_prc += 20
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = 1
				congo.sub_government = 16
				congo.set_tag("对华贸易", false)
				congo.set_tag("亲苏", true)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 4 \
					and ws.empires[EmpireData.USSR].leaders[4] != null:
				ws.empires[EmpireData.USSR].leaders[4].support += 1
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
