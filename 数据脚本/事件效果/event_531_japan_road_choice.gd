extends "res://数据脚本/event_script_base.gd"

## 原作 Event531.cs：变则善，常变则至善（日本保革伯仲链，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:282-284 ——
##   event_done[527]||event_done[528] && !event_done[530] && c44.puppetOf<0
##   && c44.SubGosstroy==8 && (1981.6 或 1982+)。
## 差异：resultOfEvents 缺省按原版 int 默认 0 处理。

const TXT_OPT0_DIS := "没人对他们有兴趣"
const TXT_OPT1_DIS := "没人对他们有兴趣"
const TXT_R0 := "我们派出了大量人员与三个党（特别是社会党）的高层进行了多次沟通，指出了革新政权的来之不易并着重强调了自由民主党的威胁。此前对革新阵营的大力援助也使得我们能够发挥更大的影响力。最终在我们的劝说以及提供更多帮助的承诺下，三党高层同意在争议性问题上各退一步，并达成了正式的协议。\n不久，社会党召开了新一届党代会。会上以绝对多数正式通过了对旧纲领《日本通向社会主义之路》的修改方案：将“无产阶级专政”等带有强烈马克思主义色彩的字眼与条款进行了删改，增加了“国民”“革新”等字眼，只在一处地方保留了“科学的社会主义”这样的文字。不过纲领依旧保留了一些“社会主义”的词句，并且强调了公平、福利、工人权利等方面。总的来说，本次党代会标志着社会党完成了向民主社会主义政党的过渡。\n数周后，联合政府的三个党在东京召开正式会议。会上公明党和民主社会党宣布正式与社会党合并，成立社会革新党，并延续社会党的民主社会主义方针。\n日本媒体对于三党合并的消息感到惊讶。对于这一联盟在接下来的选举中能取得怎样的成绩也有不同的看法。但是对市民阶层而言，一个更具新时代革新色彩，提倡福利政策且并非传统“工会斗士”的左翼政党显然还是很对他们的胃口的。一些报纸已经开始预测在下一届国会选举中，社会革新党将继续执政。"
const TXT_R1 := "我们与社会党和共产党的领导层进行了长期的会谈。得益于我们此前对包括学生组织、工会、反战反核团体等社会组织的大力援助和指导，它们已经形成了一股合力，这让我们在谈判中掌握了更大的话语权。考虑到基层组织的扩展问题以及此时日本社会党已经十分左倾（尽管这种左倾与马列主义仍所区别）这一点，日本共产党最终同意与社会党实现进一步合作。而社会主义协会也表示愿意就马克思主义的相关问题与日共成员相探讨，以实现两党的步调一致。\n不久社会党召开了新一届党代会，会上以绝对多数正式通过了对旧纲领《日本通向社会主义之路》的修改方案，在向坂逸郎领导的社会主义协会的操刀下，该方案不仅保留了“无产阶级专政”等带有强烈马克思主义色彩的字眼，并强调要通过公有化与计划经济提高生产能力并保障国民丰富的生活。社会党要在议会内外获得民主的多数派，并最终建成社会主义社会。尽管社会主义协会一直坚持远离“极左思潮”（且一直被指责是“以19世纪的发展中国家的德国的考茨基为模范的理论的正统派”），但这样的修改方案在一般人看来就是不折不扣的共产主义纲领。\n数周之后，共产党与社会党在东京召开了一次正式会议。会上福田正义表示将积极与社会党合作，促进国民革新运动。虽然该会议并没有明确提及两党的联盟事后也没有任何相关消息流出，但是多数观察家依旧认为这释放了社会党的进一步转向信号。公明党和民主社会党对此感到震惊，它们要求社会党对此作出解释。尽管社会党表示无意沿着苏联等国的“现实社会主义”路线前进，但这样的解释显然不能让人信服。\n日本媒体对此感到惊讶。对于接下来的选举将会出现怎样的局面也有不同的看法。日本的未来更加扑朔迷离了。"
const TXT_R2 := "在飞鸟田一雄的带领下，社会党试图在“社共共斗”路线与“社公民路线”之间取得平衡。但在内部纷争依旧的情况下，其与联合政府其他党派关系仍是每况愈下。许多媒体对革新政权的未来并不乐观，甚至一些评论人士认为在四年任期结束之前这一联合政府就可能瓦解，特别是在以“总评”为代表的左翼工会不再单独支持社会党的情况下。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d[W.I_POLITICAL_LINE]
	var r526 := int(ws.completed_event_ids.get("event_526", 0))
	var r525 := int(ws.completed_event_ids.get("event_525", 0))
	var r522 := int(ws.completed_event_ids.get("event_522", 0))
	var r524 := int(ws.completed_event_ids.get("event_524", 0))
	if (line == 2 or line == 1) and (r526 == 0 or r525 == 0):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line < 2 and r522 == 1 and r526 == 1 and r524 == 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, 5)
			ws.influence_prc += 10
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, 5)
			ws.influence_prc += 10
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2
