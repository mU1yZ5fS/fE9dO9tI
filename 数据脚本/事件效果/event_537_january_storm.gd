extends "res://数据脚本/event_script_base.gd"

## 原作 Event537.cs：一月风暴（日本社会主义工人党起事，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:307-309 ——
##   event_done[533] && resultOfEvents[533]==0 && !IsAuthoritarianism(86) &&
##   c86.Gosstroy!=3 && !IsAuthoritarianism(87) && c87.Gosstroy!=3 &&
##   c21.SubGosstroy==18 && c92.SubGosstroy==18 && modifies[49].active &&
##   c44.Gosstroy==3 && c44.prcpower>=200 && (1985.1 或 1986+)。
## 差异：IsAuthoritarianism→government == GameConstants.Government.AUTHORITARIAN&&sub_government != GameConstants.SubGovernment.LEFT_RADICAL 复合 ExprNode。

const TXT_OPT0_DIS := "没人对他们有兴趣"
const TXT_R0 := "我们迅速为日本社会主义工人党提供了空前规模的资金和武器援助，帮助他们在这一关键时刻抓住机会。很快他们便动员起大部分城市的青年学生和工人掀起了又一次全共斗。十余年前曾经被扑灭的革命热情被再一次点燃。有备而来的学生们迅速控制了各大校园的主要建筑物，要求政府倾听人民的呼声、反对新自由主义改革，怒斥政府要把整个国家的劳动人民卖给美国。自由民主党高层试图像过去处理学生运动的方式一样解决问题，但这次他们失败了：社会主义工人党成功团结了多数底层民众，组建了日本人民共同斗争委员会。很快委员会的代表发表公开声明，明确拒绝了政府提出的缓和提案，指出这不过是缓兵之计。1月12日，共同斗争委员会组织了上百万人的队伍，在全国主要地区展开统一行动。人们高举旗帜，手持自卫武器，对政府大楼、警察局等地进行全面冲击。政府立刻命令自卫队携带武器前去彻底驱散他们。但参与者早已设置了多重街垒和障碍阻碍自卫队的前进速度，同时对美军基地也展开了包围。在自卫队还没来得及抵达的时候，东京和其他大城市市内的各关键区域就已经被人群所占领。中曾根政府被强行解散，共同斗争委员会正式宣布接管国家。而姗姗来迟的自卫队在面对如此规模的游行人群后，最终也决定不再抵抗。部分地区的自卫队虽然进行了抵抗，但早已有所准备且拥有简易武器和技术指导的共斗参与者很快便粉碎了他们。\n英法两国对社会主义工人党的胜利十分振奋。当天英国首相泰德·格兰特便发表演讲，热烈祝贺日本托派的胜利并表示将全力援助新政府。很快法国国务委员会主席团成员罗伯特·巴西亚也代表委员会向日本托派的胜利表示祝贺。据可靠消息，数周后英法两国的代表团就将飞抵日本进行正式访问。"
const TXT_R1 := "尽管支援仍然不够，但考虑到这样的大好时机绝不会再有第二次，日本社会主义工人党还是迅速动员起大部分城市的青年学生和工人掀起了又一次全共斗。十余年前曾经被扑灭的革命热情被再一次点燃。学生们迅速控制了各大校园的主要建筑物，要求政府倾听人民的呼声、反对新自由主义改革，怒斥政府要把整个国家的劳动人民卖给美国。而自由民主党高层的缓兵之计也被识破。1月12日，社会主义工人党领导的日本人民共同斗争委员会组织了数十万人的队伍，在全国主要地区展开统一行动，对政府大楼、警察局等地进行全面冲击，同时对美军基地也展开了包围。但由于准备不充分，未能完成对自卫队可能前进道路上的障碍的布置。而收到政府命令的自卫队也迅速出动，最终在共斗参与者占领市内的关键区域之前便抵达了这里。在水炮、高压水枪、催泪弹、橡胶子弹的冲击和装甲车缓慢推进的威胁下，人们被迫暂时终止了行动并撤退。同时中曾根政府迅速与美国取得了联系，请求西方伙伴的帮助。尽管自身也是焦头烂额，但美国政府还是同意向日本增兵。很快一批海军陆战队官兵便在日本政府的邀请下抵达各大城市附近，同时对共同斗争委员会的活动区域进行全面封锁。随着时间推移，缺乏物资补给的参与者变得愈发浮躁起来。最终共同斗争委员会不得不接受了政府条件并自动解散。而很快中曾根政府便宣布日本社会主义工人党为“煽动暴乱的非法组织”，并在美军协助下展开了对该党和参与第三次全共斗人员的全面行动。日本社会主义工人党被迫解散，一部分成员前往英法寻求庇护，另一部分留在国内继续开展秘密斗争。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	if d.political_line < 2:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], TXT_OPT0_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c44 != null:
				c44.government = GameConstants.Government.SOCIALIST
				c44.sub_government = GameConstants.SubGovernment.TROTSKYIST
				c44.set_tag("亲美", false)
				c44.set_tag("亲中", true)
				c44.set_tag("对华贸易", true)
				c44.name = "日本革命社会主义共和国"
				c44.chinese_name = "日本革命社会主义共和国"
				_join_alliances(c44)
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -200)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, 25)
			ws.influence_prc += 80
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
