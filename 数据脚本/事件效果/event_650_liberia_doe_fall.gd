extends "res://数据脚本/event_script_base.gd"

## 原作 Event650.cs：谁成为战士，妈妈？（利比里亚多伊倒台，四选项）。
## 触发：TimeScript.cs:11020-11026 —— (月>=10 且 年>=1985 或 年>=1986)
##   && event_done[696]。
## 差异：
##  - 选项显隐 prepare 动态改写；now_leader→current_leader；
##  - 结果1 的"孔波雷引荐"分支文本插入我国领袖姓名（names1+names2→name_display）；
##  - resultOfEvents[500] 缺省按原版 int 默认 0 处理；
##  - JoinAllOurAlliances(true)：id67 属 flag 组（军事联盟分支跳过），
##    只按 c1.econ/c1.isSEV 加入经济联盟。



const TXT_OPT1_DIS := "我们没处插针"
const TXT_OPT2_DIS := "美国没心思对私生子的生活指手画脚"
const TXT_OPT3_DIS := "我想我们确实是活在更开明的时代"

const TXT_R0 := "显然，人们没法指望并不懂得治国的多伊能在选举上做出什么名堂：靠着猖獗的欺诈与胁迫投票的手段，多伊成功以“等额选举”方式获得压倒性选票，最终实现连任。然而，如此露骨的政治欺诈显然不会使人满意——即便是作为多伊最大靠山的华盛顿当局也愈加不满于该国持续恶化的治安环境，并认为多伊政府难以担当其西非战略的大任。显然，如今的利比里亚总统已是众叛亲离，其垮台也不过时间问题……"

const TXT_R1_INTRO := "通过布基纳法索方的联系，我们很快便找到了足以接管当地局势的代理人。布莱斯·孔波雷亲自向"
const TXT_R1_TAYLOR := "引荐了正协助其改组布基纳法索安全部队，以及训练利比里亚流亡者队伍的查尔斯·泰勒。泰勒曾在利比亚接受反帝国主义训练，并以对利比里亚托尔伯特-多伊两代政权的不妥协斗争态度而著称。这位美籍利比里亚人在美国的黑人社区内也是打出了名头，凑齐了各路人脉资源。足以实现多伊倒台后该国的社会和解。靠着我们的人力与资金支持，泰勒很快便将自己的势力打入了利比里亚，顺势买通了该国数一数二的军官普林斯·约翰逊，接下来便是一场可被视为迷你内战的政变。曾不可一世的多伊在混战中被约翰逊逮捕，并最终在荧幕上以“以牙还牙”的方式被处决。由此开启了利比里亚全国爱国阵线的统治。然而，该政权似乎并没有如我们所料将带来稳定——泰勒与约翰逊间已开始就领导权问题争论不休，国内部族军阀也蠢蠢欲动，且新政权毫无结束管制的心思，甚至也开始同军阀那般养起私兵。看起来事情可不会就此结束。"

const TXT_R1_QUIWONKPA := "通过布基纳法索方的联系，我们很快便找到了足以接管当地局势的代理人。即曾与多伊共事的人民救赎委员会前二把手托马斯·奎翁巴。虽说此人并无明显的政治倾向，但奎翁巴曾作为人民救赎委员会内“良心”的口碑足够让我们为其寄予期望。他在1983年被免去军事领导职务后便被迫流亡，如今正四处物色盟友寻求推翻多伊统治。考虑到仅靠奎翁巴一人单打独斗绝无可能推翻多伊政权，我们决定为其物色更多的盟友，并为奎翁巴训练了一只足够精干的突击队对多伊发起斩首行动。\n"

const TXT_R1_LEFT := "与此同时，我们还联系了曾在推翻托尔伯特政权时活跃的左翼人士（如阿莫斯·索耶律师的利比里亚人民党）和在政府内布有暗线的人民团结党领袖加布里埃尔·马修斯等人进行内外策应。终于发起了场可被视为迷你内战的政变。曾不可一世的多伊在混战中被我军逮捕，并最终在革命法庭前接受绞刑伏诛。考虑到利比里亚已因多伊的长期恶政残破不堪，急需休养生息。新政府很快便选择了拥抱民族和解政策，并试图靠加入非洲一体化引入外来活水的方式迅速稳定国内政治经济局势。而作为交换，该国自然得回顾若干历史问题，并承认自身在恩克鲁玛-博瓦尼争论时“错得离谱”，接下来便是对加纳、几内亚等国的经验按图索骥。曾作为蒙罗维亚派头面旗手的政权就此洗心革面，接纳了社会主义与泛非主义之梦。"

const TXT_R1_PROCHINA := "与此同时，我们还联系了利比里亚国内幸存的各派反建制势力和作为政府内投诚者的奇亚·奇波等人进行内外策应。终于发起了场可被视为迷你内战的政变。曾不可一世的多伊在混战中被我军逮捕，并最终在临时法庭前接受绞刑伏诛。考虑到利比里亚已因多伊的长期恶政残破不堪，急需休养生息。新政府很快便选择了拥抱民族和解政策，并试图靠向中国一边倒引入外来活水的方式迅速稳定国内政治经济局势。西非的橱窗就此染上了我们的颜色。"

const TXT_R2 := "我们决定将多伊政权的劣迹直接上报华盛顿，并将多伊许诺将在1985年时实现民主转型的说法对时任美国总统沃尔特·蒙代尔故事重提。最终，蒙代尔听取了我们的建议，决定以威逼多伊下台的方式实现该国领导层更替，并最终稳定局势。也就在中情局与美国舰队的威胁下，多伊不得不宣布退出大选，并以此秘密交换的接受政治庇护与不被新政权清算的许可。随后的选举则落入曾在托尔伯特时期参议院入主参议院的利比里亚行动党与其党魁杰克逊·多伊手中，看起来该国还是靠着兜兜转转回到了熟悉的民主内……兴许如此。"

const TXT_R3 := "我们的外交人员用简单易懂的方式向多伊表达了合作意愿：即只要多伊能够遵循东方大国发展世袭制度的智慧，那既能摆脱繁琐且需要周期性伪造民意的总统制，又能充分的实现国家上下一心，全体竭诚共进。与此同时，我们还为多伊举了扎伊尔“伟大领袖”黑色江山永不倒，民族情谊万年牢的案例，以及作为“实物参照”的门格斯图大元帅：后者更是对多伊晓之以情，动之以理，以非洲之角一代雄主的伟岸气魄让其心服口服。不久后，多伊便开始参照我们的蓝图设计“有利比里亚特色的社会主义”：可考虑到利比里亚长期受资本主义荼毒的土地实在没法立即供养如此先进的思想，多伊直截了当的将除克兰族黑人嫡系控制的机构纷纷外包给了我们（这事实上意味着彻底驱逐了美国等老牌列强在当地的全部经营，前者可不会高兴的），并要求中方人员以相关指导思想为纲首先向利比里亚精英传授江山代代传的好道理。由此以先觉带动后觉，最终实现共同觉醒。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var china := world.get_country_by_legacy_index(1)
	var burkina := world.get_country_by_legacy_index(61)
	var usa := world.get_country_by_legacy_index(51)
	var liberia := world.get_country_by_legacy_index(67)
	var ethiopia := world.get_country_by_legacy_index(41)
	var c117 := world.get_country_by_legacy_index(117)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if burkina != null and burkina.has_tag("亲中"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	var usa_leader3 := world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null \
			and world.empires[EmpireData.USA].current_leader == 3
	if china != null and china.government == 3 and usa != null and usa.development == 1 and usa_leader3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	var cond := liberia != null and liberia.has_tag("对华贸易") \
			and china != null and china.sub_government == 19 \
			and ethiopia != null and ethiopia.sub_government == 19 \
			and c117 != null and c117.sub_government == 19
	if cond:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var liberia := ws.get_country_by_legacy_index(67)
	var burkina := ws.get_country_by_legacy_index(61)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			if burkina != null and burkina.sub_government == 15:
				var tname := _leader_name()
				if liberia != null:
					liberia.government = 0
					liberia.sub_government = 9
					_leave_alliances(liberia)
					liberia.set_tag("亲中", true)
					liberia.set_tag("对华贸易", true)
				_add_power(EmpireData.USA, -5)
				_add_relation(EmpireData.USA, -200)
				ws.influence_prc += 10
				context["result_text"] = TXT_R1_INTRO + tname + TXT_R1_TAYLOR
			else:
				var text := TXT_R1_QUIWONKPA
				if int(ws.completed_event_ids.get("event_500", 0)) == 0:
					text += TXT_R1_LEFT
					if liberia != null:
						liberia.government = 1
						liberia.sub_government = 1
						_leave_alliances(liberia)
						liberia.set_tag("亲中", true)
						liberia.set_tag("对华贸易", true)
						_join_alliances(liberia)
					_add_power(EmpireData.USA, -15)
					_add_relation(EmpireData.USA, -300)
					ws.influence_prc += 25
				else:
					text += TXT_R1_PROCHINA
					if liberia != null:
						liberia.government = 2
						liberia.sub_government = 15
						_leave_alliances(liberia)
						liberia.set_tag("亲中", true)
						liberia.set_tag("对华贸易", true)
						_join_alliances(liberia)
					_add_power(EmpireData.USA, -10)
					_add_relation(EmpireData.USA, -250)
					ws.influence_prc += 15
				context["result_text"] = text
		2:
			if liberia != null:
				liberia.government = 3
				liberia.sub_government = 6
				_leave_alliances(liberia)
				liberia.set_tag("亲美", true)
				liberia.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, 10)
			_add_relation(EmpireData.USA, 50)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -40)
			_add(W.I_DIPLO, -30)
			context["result_text"] = TXT_R2
		3:
			if liberia != null:
				liberia.government = 0
				liberia.sub_government = 19
				_leave_alliances(liberia)
				liberia.set_tag("亲中", true)
				liberia.set_tag("对华贸易", true)
				_join_alliances(liberia)
			_add_power(EmpireData.USA, -10)
			_add_relation(EmpireData.USA, -250)
			ws.influence_prc += 20
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			context["result_text"] = TXT_R3


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## Country.LeaveAlliances() 逐项映射（同 Event587 约定）。

func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)



