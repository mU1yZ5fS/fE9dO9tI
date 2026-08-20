extends "res://数据脚本/event_script_base.gd"

## 原作事件 67–70：波兰危机、光州起义与改革/保守两条五中全会清洗路线。
## 来源：TimeScript.cs:3919-3971，doneventscript.cs:1637-1766，
##       Results_text.cs:5691-6167。



## 事件 67–70 逐字中文文案。
## 来源：Event67.cs / Event68.cs / Event69.cs / Event70.cs。
## 说明：{0}{1} 为原版领袖姓名字段占位，显示前由 _fmt_leader() 替换为 name_display。

const TXT_67_TITLE := "波兰尚未灭亡？"
const TXT_67_DESC := "同志，波兰人民共和国现在已经陷入了严重的政治和经济危机，波兰的修正主义政策迎来了属于他的恶果。对外开放、私有化和市场化改革的政策滋生的大量的小资产阶级对统工党政权产生着异议，盖莱克政府不得不通过“高速度、高积累、高消费”的“三高政策”发展所谓的“消费社会主义”，通过大量举借外债来推动波兰经济高速发展，并利用财政补贴商品以维持较低的价格，以维持政权的稳定。如今，波兰经济的高速增长已经无力维持，近乎停滞，政府已经积累了巨额国债（近400亿美元），不堪重负的波兰政府决定采取冻结工资和部分商品提价的措施以避免危机，不满的波兰民众迅速发起了全国大罢工，不久后罢工的工人组成了全国性的反对派组织和独立自治工会“团结工会”（中情局为他们提供了支持），对统工党政府提出了一系列经济和政治要求。9月6日，波兰统一工人党中央委员会第六届全体会议召开，决定解除领导国家和党10年的爱德华·盖莱克的职务，并以统工党中间派斯坦尼斯瓦夫·卡尼亚取代他。卡尼亚选择对团结工会采取妥协态度。|“团结工会”并非团结在一个意识形态之下——它是一个反统工党政权的大帐篷，其左翼主要由工团主义者、民主社会主义者和基督教左翼组成，反对统工党官僚的统治，希望构建“民主的”社会主义；其右翼由自由主义者、保守主义者和基督教教士组成，希望开展自由化。|统一工人党内部也不是铁板一块，其主要分为左、中、右三派，其左派“党之基石”派主要由亲苏强硬派、斯大林主义者和民族共产主义者组成，由以塔德乌什·格拉布斯基、斯特凡·奥尔绍夫斯基、安杰伊·扎宾斯基和兹基斯瓦夫·库洛夫斯基为首的“四人帮”领导，他们希望镇压团结工会，清除官僚机构的腐败，并让波兰回归正统的马列模式，他们掌握了一众附属团体，与团结工会和统工党右派开展论战；中间派的代表是斯坦尼斯瓦夫·卡尼亚和国防部长沃伊切赫·雅鲁泽尔斯基；其右派为米奇斯瓦夫·拉科夫斯基的改革派和兹比格涅夫·伊万诺夫领导的“平行结构”（指同时具有统工党党籍和团结工会会员的平行身份）派，希望与团结工会合作开展变革。|在苏东阵营内部，保守派的勃列日涅夫、昂纳克和胡萨克都希望以1968年的捷克斯洛伐克为先例，发挥社会主义大家庭的精神，联合镇压反对派并支持“四人帮”；而安德罗波夫、苏斯洛夫和齐奥塞斯库则反对采取军事行动。|在局势如此不稳定和各派分裂的情况下，我们有很大的机会进行干预。请做出我们的选择吧！"
const TXT_67_OPT0 := "波兰的事务与中国无关。他们自己做的事情自己解决！"
const TXT_67_OPT1 := "针对波兰的局势发表我们的声明"
const TXT_67_OPT2 := "激化局势，“帮助”统工党强硬派做出正确决定（需要5特工，需要20百万元预算）"
const TXT_67_OPT2_DIS := "还未恢复《中苏友好同盟互助条约》..."
const TXT_67_OPT3 := "组建囊括米雅尔的反修派波兰共产党、统工党“党之基石”派的民族共产主义者和斯大林主义者以及“PAX协会”（圣像派）等左翼势力的大联盟！（需要15特工网络与30百万元预算）"
const TXT_67_OPT3_DIS1 := "可米雅尔已经离开了阿尔巴尼亚..."
const TXT_67_OPT3_DIS2 := "党内的改革派与自由派对他们没兴趣..."
const TXT_67_OPT4 := "|鼓动华约开展“兄弟般”的干预（需要5特工网络，5军事实力）"
const TXT_67_OPT4_DIS1 := "|我们得是华约的一员..."
const TXT_67_OPT4_DIS2 := "|与苏联的关系应高于60..."
const TXT_67_OPT5 := "让我们支持团结工会和统工党右派的合作，以开展改革（需要10百万元预算，20特工网络）"
const TXT_67_OPT5_DIS1 := "我们得交好美国..."
const TXT_67_OPT5_DIS2 := "与美国的关系应高于60..."

const TXT_67_R0 := "我们未对波兰局势作出任何评论。在这种局面下，波兰军队承担起了国家命运的责任。在得到苏联支持和不会军事干预的保证后，国防部长沃伊切赫·雅鲁泽尔斯基创立了包含统工党三派的救国军事委员会，并在1981年12月13日，宣布在波兰全境实行战时状态。波兰人民军、安全委员会和ZOMO（摩托化预备役部队，波兰民事警察部门的特种单位）的决定性行动，终止了团结工会和波兰统一工人党的活动，波兰国内秩序多少重建了起来。雅鲁泽尔斯基宣布了“社会主义革新路线”，但实质的问题并没有解决，这早晚会找上门来的……"
const TXT_67_R1A := "中国外交部发言人发表声明：“中国人民始终支持波兰人民抗击波兰修正主义和苏联社会帝国主义的正义斗争！波兰人民应该团结在波兰无产阶级的真正核心——波兰共产党周围，重拾斯大林和贝鲁特的遗产，建立真正革命的社会主义制度！”"
const TXT_67_R1B := "中国外交部发言人发表声明：“中国人民始终支持波兰人民抗击波兰修正主义的正义斗争！波兰人民应该团结在波兰无产阶级的真正核心——波兰统工党的健康力量（指“党之基石”派）和波兰共产党周围，重拾斯大林和贝鲁特的遗产，建立真正的社会主义制度！”"
const TXT_67_R1C := "中国外交部发言人发表声明：“波兰各方应该保持对话，减少冲突，在妥协中求进，共建适宜于波兰民族自身发展道路的社会主义。”"
const TXT_67_R1D := "中国外交部发言人发表声明：“苏联不应该在东欧施展霸权主义，东欧人民有选择自己社会主义发展道路的权利。”"
const TXT_67_R1E := "中国外交部发言人发表声明：“中国政府始终支持波兰人民反对极权主义和专制独裁的斗争，让我们和自由和文明的世界中心——美国联合起来，打倒邪恶帝国伸向世界的触手，以波兰为起点，把东欧从苏联奴役中解放出来！”"
const TXT_67_R1_TAIL := "在这种局面下，波兰军队承担起了国家命运的责任。在得到苏联支持和不会军事干预的保证后，国防部长沃伊切赫·雅鲁泽尔斯基创立了包含统工党三派的救国军事委员会，并在1981年12月13日，宣布在波兰全境实行战时状态。波兰人民军、安全委员会和ZOMO（摩托化预备役部队，波兰民事警察部门的特种单位）的决定性行动，终止了团结工会和波兰统一工人党的活动，波兰国内秩序多少重建了起来。雅鲁泽尔斯基宣布了“社会主义革新路线”，但实质的问题并没有解决，这早晚会找上门来的……"
const TXT_67_R2 := "我们放出了波兰国防部方面想要邀请华约采取行动的谣言，这在反对派内部掀起了轩然大波。在一个月黑风高的夜晚，波兰国防部长雅鲁泽尔斯基大将在下班的路上被预先埋设的炸药炸死，据调查，这是由团结工会的激进派代表特奥多尔·克林采维奇策划的，目的是为了“阻止该死的民族败类将祖国交给俄国人……”雅鲁泽尔斯基的死成功坚定了统工党“党之基石”派采取严厉行动的决心，统工党认为事情已经到达了严峻的地步。亲苏强硬派将军尤金纽什·莫尔奇克、约瑟夫·巴里拉和沃齐米日·萨夫丘克牵头组织了“军事革命委员会”，以格拉布斯基为首的“党之基石”的亲苏强硬派成员也大量加入了新的领导机构。莫尔奇克将军宣布在波兰全境实行战时状态。波兰人民军、安全委员会和ZOMO（摩托化预备役部队，波兰民事警察部门的特种单位）的决定性行动，终止了团结工会和波兰统一工人党的活动，波兰国内秩序多少重建了起来。国家的全部权力都交予军事革命委员会，这马上引起了关于“建立军事独裁”的指责，美国已经开始呼吁反对“莫尔奇克的极权军政府”。我国和苏联对波兰发放了大额无息贷款以偿还其国家债务，而波兰则与我们签订了几项合作协定。波兰的新领导层开始重构波兰的政治经济制度，以“回归马列主义秩序”，看起来局势正在恢复，波兰的例子也教会了我们党一些事情……"
const TXT_67_R3 := "在我国驻波兰大使馆的支持下，通过卡齐米日·米雅尔领导的地下活动的波兰共产党，国安部特工联系到不久前在统工党大会上提议解除盖莱克职位并已恢复政治局委员身份的前“游击队”派领导人、现“党之基石”派民族共产主义者的代表——米奇斯瓦夫·莫查，在我们的说服下，他决定一雪前耻（他曾与盖莱克竞争领导人位置），并结束波兰的混乱局面。他设法争取到了大部分“党之基石”团体（如斯大林主义的卡托维兹党论坛、民族共产主义的“格伦瓦尔德”爱国联盟等）和亲共产主义的民族天主教团体PAX协会的支持，并与团结工会的温和派（以雅罗斯瓦夫·西恩凯维奇为代表）、志愿预备役民兵（ORMO）联合，组建了广泛的联盟，同时得到了与莫查有联系的“党之基石”派成员米罗斯瓦夫·米列夫斯基的秘密支持，他领导的内政部所控制的ZOMO（摩托化预备役部队，波兰民事警察部门的特种单位）将为莫查提供帮助。12月2日，在统工党中央委员会和波兰国务委员会的联合会议上，莫查对波兰现领导人斯坦尼斯瓦夫·卡尼亚展开了突然袭击，他指责卡尼亚对反革命分子优柔寡断，不断让步，且未能良好处理波兰的危机，应该为波兰仍未好转的局势负责并辞职谢罪。经由我们的特工提前打点过的统工党中央委员会和国务委员会以多数票支持了他的发言，卡尼亚不得不引咎辞职，莫查被选为新的波兰领导人。紧接着，莫查同志就要求马上召开色姆会议，并在全国范围内宣布戒严。统工党右派试图抵抗，但随后ORMO战士闯入会议室，逮捕了所有这一决定的反对者，莫查称“将对暗藏在党内的反革命进行隔离审查”。|两个月来，波兰事实上在进行小型内战，但安全部门和部分军队成员支持政变，因此联盟得以胜利。最后，波兰领导层进行了新一轮改组，成立了由统工党“党之基石”派的斯大林主义者和民族共产主义者、波兰共产党和团结工会温和派组成的波兰工人党，团结工会基本被摧毁，其左翼成员则类似统一农民党和民主党，能够合法参与政治和提名独立候选人。波兰新领导层宣布将进行“再社会主义化”，并与我们靠近，但同时，莫查表示“波兰将继续基于睦邻和合作的路线发展苏波关系”苏联并未表示有太大不满，实际上承认了变化。新的波兰将重新开展农业集体化，重设人民军政委制度、取消随军牧师，并参考“鞍钢宪法”的“三结合”对国营企业进行民主化改造。莫查谴责梵蒂冈“干预主权国家的内政”，被清洗后由PAX协会主导的波兰教会宣布与梵蒂冈断绝关系。西方谴责波兰的变化，称“这是血腥的斯大林主义在波兰的回归”。"
const TXT_67_R4 := "盖莱克辞职和软弱妥协的卡尼亚的就职给您留下了非常消极的印象。23时，您亲自召见了苏联大使，并要求其亲自向列昂尼德·伊里奇·勃列日涅夫同志递交中方的如下照会：“如果再不采取措施扭转局面，社会主义波兰将遭遇严重威胁。因此，中国共产党与各盟国的兄弟政党，乃至所有的社会主义国家。都不能对此视而不见。波兰事件绝不能简单的看作是某国内政问题。今晚，我们将紧急呼吁华约各国的所有领导人，一致对波兰采取有力的联合军事行动，从而挽救波兰，挽救波兰社会主义。中华人民共和国与中国共产党的领导层坚信。必须为社会主义的大步前进而消灭帝国主义，而波兰依然有机会回到正道。”"
const TXT_67_R4_YES := "我们的呼吁得到了勃列日涅夫、昂纳克和胡萨克等苏东保守派领导人的支持。苏联方面迅速制定了代号为“西方-80”的“军事演习”计划。该计划由苏军总参谋长奥加尔科夫元帅转交给波兰副总参谋长赫帕洛夫斯基。按照该计划，苏联、东德和捷克斯洛伐克的部队将进驻波兰领土，与此同时，波兰军队则留在兵营里。入侵部队由15个苏联师、2个东德师和1个捷克斯洛伐克师组成。行动涉及：捷克斯洛伐克人民军-西部军区司令部和两个陆军司令部；民主德国人民军-两个陆军司令部；苏联军队-国家民航司令部、两个陆军司令部和北方集群司令部。1980年12月9日，苏联武装力量北方集群各单位与民主德国人民军、捷克斯洛伐克人民军各单位进入波兰领土，向波兰重点城市快速推进。波兰军队的一部分没有抵抗。团结工会转入地下，团结工会和统工党的领导人被捕并被带到苏联。新的波兰由统工党“党之基石”派的塔德乌什·格拉布斯基领导，波兰人民军则由亲苏的尤金纽什·莫尔奇克领导。新领导层宣布将进行“社会主义秩序化”，并在苏军的帮助下铲除反对派。美国异常愤怒，全力指责苏联和我们“在波兰建立专制的傀儡政权”。"
const TXT_67_R4_NO := "不幸的是，苏联和其他华约国家的领导层不打算派兵恢复秩序，而是支持并许可波兰军队开展独立行动。在得到苏联支持和不会军事干预的保证后，国防部长沃伊切赫·雅鲁泽尔斯基创立了包含统工党三派的救国军事委员会，并在苏方和我方的压力下于1980年12月13日宣布在波兰全境实行战时状态。波兰人民军、安全委员会和ZOMO（摩托化预备役部队，波兰民事警察部门的特种单位）的决定性行动，终止了团结工会和波兰统一工人党的活动，波兰国内秩序多少重建了起来。雅鲁泽尔斯基宣布了“社会主义革新路线”，但实质的问题并没有解决，这早晚会找上门来的……"
const TXT_67_R5_YES := "我们与中情局取得了联系，并就联合行动达成了协议。我们对统工党改革派和“平行结构”派进行了秘密支持，并为团结工会提供了一批额外援助。局势发生了意想不到的转变——随着动荡加剧，斯坦尼斯瓦夫·卡尼亚在与陆军司令部进行秘密磋商后，出人意料地宣布辞去所有职务。统一工人党中央委员会的第一书记变为了改革的支持者，米奇斯瓦夫·拉科夫斯基，他与波兰国防部长沃伊切赫·雅鲁泽尔斯基将军关系密切。获得了军队支持的改革派开始对波兰领导层进行大换血，“党之基石”派成员被陆续辞退，取而代之的是改革派和兹比格涅夫·伊万诺夫的“平行结构”派。在这种情况下，拉科夫斯基与瓦文萨进行了接触，并达成了一个有利于双方的妥协方案——团结工会正式合法化，停止权力斗争并进入议会，团结工会将在新政府中获得若干职务，并获准起草一项广泛的改革。拥有统工党和团结工会双籍被合法化，事实上，团结工会被吸纳为了自治的官方工会，能够合法参与政治并参与制定生产计划，同时对企业进行民主管理。拉科夫斯基宣布了“社会主义革新路线”的概念，这意味着参考匈牙利和南斯拉夫模式，在马克思主义的旗帜下开展具有工团主义和民主社会主义性质的广泛改革，进行独具特色的波兰式社会主义建设。团结工会领导层支持这些改革，并宣布停止示威和罢工——局势正缓慢地正常化。拉科夫斯基表示，将继续“保持与苏联的友好合作关系并支持世界社会主义事业”。尽管苏东阵营的保守派对此并不高兴，但是鉴于统工党并未失去领导地位，局势正在向好以及1968年“多瑙河行动”和进军阿富汗的恶劣国际影响，他们将不满限制在了牢骚之中。"
const TXT_67_R5_NO := "不幸的是，即使我们支持了美国破坏波兰稳定的行动，也没有产生好的结果。起初，一切按计划进行－12月，团结工会在民众的广泛支持下尝试政变，夺取了华沙的政府区——但是，意料之外的事情发生了。斯坦尼斯瓦夫·卡尼亚逃往比亚韦斯托克，转向华约的政治协商委员会会议寻求军事协助。12月9日，苏联武装力量北方集群，与民主德国人民军和捷克斯洛伐克人民军一道，进入波兰领土，开始向波兰关键城市快速推进。部分波兰军队加入其中或是保持中立。团结工会被彻底摧毁了，莱赫·瓦文萨勉强逃到美国驻华沙大使馆。波兰的新领导层，由沃依切赫·雅鲁泽尔斯基领导，宣布了“社会主义革新路线”，期望在马克思主义框架内，苏联军队监视下开展改革……"

const TXT_68_TITLE := "光州事件"
const TXT_68_DESC := "1979年12月政变后，全斗焕夺取了韩国大权，开始无情地镇压反对军政府的抗议者。5月17日，戒严开始了，5月18日，在光州市，为反对关闭全罗南道国立大学而组织的学生示威遭到军队镇压。这引起了城市的不满风暴，并引发了更大的骚乱，在此期间，起义者成功地占领了警察局和军事基地，并将军队赶出了城市。根据我们的情报，全斗焕政府正准备用正规军夺取光州。通过支持起义者使其能够坚持更长的时间，以及引导我们情报部门的力量煽动邻近地区的不满，我们可以严重破坏韩国政权的稳定。"
const TXT_68_OPT0 := "让他们自己处理"
const TXT_68_OPT1 := "援助起义者和煽动动乱（需要8军事实力，10特工网络）"
const TXT_68_OPT1_DIS := "我们没有足够的资源"
const TXT_68_OPT2 := "呼吁各方对话"
const TXT_68_OPT3 := "支持全斗焕的行动"
const TXT_68_R0 := "5月27日，韩国的空输部队作为入侵的五个师中的先头部队，仅用90分钟就占领了市中心。据各种估计，被杀害的平民人数从几百人到几千人不等。"
const TXT_68_R1 := "因为我们提供的武器，和对韩军计划的扰乱和破坏，对光州的突击变得漫长而血腥。此外，韩国其他城市和地区的人在了解到了正在发生的大屠杀后（多亏了我们的特工），纷纷上街抗议，与军警公开冲突。最终，军队占领光州，严酷地镇压了起义，残存的起义者也被粉碎了。然而，其他城市的抗议活动仍在继续，全斗焕政府仍安危未定。"
const TXT_68_R2 := "我们呼吁韩国当局和光州的起义者进行谈判，寻求妥协。这些声明得到了起义者的支持，但是由于美国（除了支持我们声明的一些政治家）没有表示任何支持抗议者和和平解决冲突的事实，我们的呼吁被当局忽视了。5月27日，韩国的空输部队作为入侵的五个师中的先头部队，冲进市中心，在90分钟内就控制了局面。据各种估计，被杀害的平民人数从几百人到几千人不等。"
const TXT_68_R3 := "韩国军队在90分钟内占领了这座城市，残酷镇压了起义，我们对全斗焕的行动表示支持，说这样的强硬措施是对叛乱者制造混乱的唯一适当反应。韩国政府对我们的支持表示感谢，但不少国家，特别是社会主义阵营，对此极为不满。"

const TXT_69_TITLE := "另一个四人帮？"
const TXT_69_DESC := "同志，在你的努力下，我们终于铲除了文化大革命的遗毒，我们的国家正在走向光明的市场经济未来！然而，仍然有一些人不同意这样的发展，并竭尽全力抗议市场化政策的实施，破坏了我们良好的改革倡议。这些人主要是保守的毛派，由四名党内高层领导，他们拒绝进一步的改革。通过打击他们和他们的支持者，我们可以让更多的权力掌握在改革派手中。此外，在那些没有保守派的地方，我们将有可能促进对改革的积极支持者的产生，毕竟这些改革已在民众和官僚中受到欢迎。"
const TXT_69_OPT0 := "什么也不做。不同的观点是民主的保证"
const TXT_69_OPT1 := "在党的全会上攻击保守派，支持改革派"
const TXT_69_OPT1_DIS := "中国共产党可不会陪你玩过家家"
const TXT_69_OPT2 := "在党的全会上攻击保守派"
const TXT_69_OPT2_DIS := "中国共产党不会让你轻易的消灭他们"
const TXT_69_R0 := "保守派继续担任他们的职务，这将破坏你们的改革，损坏人民和中国共产党的利益。改革派自己也对你的软弱感到不满。"
const TXT_69_R1 := "在今年2月召开的中共中央五中全会上，汪东兴、纪登奎、陈锡联和吴德因“极左倾向”而受到批评，他们被指控在文化大革命中镇压人民，并被命名为“小四人帮”。全会的结果是，四人都被革除了党政职务，他们已经没有任何对于政局的影响力了。同样的命运也降临在保守派的底层干部中。他们的位置已经被你忠实的支持者所替换了。"
const TXT_69_R2 := "在今年2月召开的中共中央五中全会上，汪东兴、纪登奎、陈锡联和吴德因“极左倾向”而受到批评，他们被指控在文化大革命中镇压人民，并被命名为“小四人帮”。全会的结果是，四人都被革除了党政职务，他们已经没有任何对于政局的影响力了。同样的命运也降临在保守派的底层干部中。"

const TXT_70_TITLE := "周恩来继承人的问题"
const TXT_70_DESC := "同志，多亏了你的努力，我们能够像毛主席遗赠给我们的那样，继续朝着一个光明的共产主义未来前进，改革派所有试图动摇我们的制度，破坏社会主义成就，使中国走上资本主义的道路的尝试都失败了。然而，他们中的许多人仍然有足够的影响力，并继续传播他们的修正主义思想，必须对此做些什么。你们最激进的支持者建议，他们不应该与修正主义者共处一室，而是应该直接逮捕他们的领导人，发动反对改革派的运动，但是党和人民不太可能赞成这种专横的行为，你们可以尝试在党的会议室里解决一切问题。并且我们必须决定如何对待温和派——毛泽东死后，他们大多数支持改革派，但现在有些人开始犹豫……"
const TXT_70_OPT0 := "什么也不做。不同的观点是民主的保证"
const TXT_70_OPT1 := "在党的全会上攻击改革派和温和派"
const TXT_70_OPT1_DIS := "改革派不会轻易的放弃！"
const TXT_70_OPT2 := "争取温和派的支持，在全会上攻击改革派"
const TXT_70_OPT2_DIS := "温和派不会支持我们"
const TXT_70_OPT3 := "逮捕改革派的领导人，并发动一场运动反对他们的支持者。这是毛主席的意志！"
const TXT_70_R0 := "改革派继续任职，这损害了你们的事业和你们在人民和中国共产党中的声誉。左翼本身对你的软弱不满意。"
const TXT_70_R1 := "在今年2月召开的中共中央五中全会上，邓小平、叶剑英、赵紫阳等老改革家因修正主义立场、谋求资产阶级自由化和背叛毛泽东思想而受到严厉的批评。尽管有激烈的讨论与争辩，但在全会结束之后，改革派和一些温和派人士的党政职务上都被革除了，他们失去了任何对政局的影响力。同样的命运降临在他们所提拔的基层改革派身上。"
const TXT_70_R2 := "在今年2月召开的中共中央五中全会上，邓小平、叶剑英、赵紫阳等老改革家因修正主义立场、谋求资产阶级自由化和背叛毛泽东思想而受到严厉的批评。此外，这些指责甚至被曾经与改革派团结一致的温和派所支持，这要感谢你们实现了他们所渴望的冻结文化大革命和对毛泽东的重新评价。全会的结果是，改革派的干部被革除了党政职务，他们失去了任何对政局的影响力。同样的命运降临在他们所提拔的基层改革派身上。"
const TXT_70_R3 := "根据你的命令，改革派的领导人被以捏造的罪名逮捕，并被永久地从政治中除名。此后，在我们控制的媒体的积极参与下，改革派思想和被压迫的改革派的支持者开始受到诋毁，党开始清除他们。人民和党自己也很不高兴，认为这是文化大革命事件的重演，但我们摆脱了我们的反对者。"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	d = p_ws.数值表
	match event_def.event_id:
		"polish_crisis":
			_prepare_67(event_def)
		"little_gang_of_four":
			_prepare_69(event_def)
		"zhou_enlai_heirs":
			_prepare_70(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"polish_crisis": _event_67(option_index, context)
		"gwangju_uprising": _event_68(option_index, context)
		"little_gang_of_four": _event_69(option_index, context)
		"zhou_enlai_heirs": _event_70(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_67(option_index: int, context: Dictionary) -> void:
	var poland := ws.get_country_by_legacy_index(2)
	match option_index:
		0:
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USSR, 50)
			if poland != null:
				poland.government = GameConstants.Government.AUTHORITARIAN
				poland.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				poland.set_tag("对华贸易", true)
			context["result_text"] = TXT_67_R0
		1:
			var line := int(ws.数值表[W.I_POLITICAL_LINE])
			var r1 := ""
			if line <= 1:
				_add_data({W.I_DIPLO: 50})
				if not ws.global_flags.get("relres", false):
					r1 = TXT_67_R1A
					_add_empire_relation(EmpireData.USSR, -50)
				else:
					r1 = TXT_67_R1B
			elif line == 2:
				r1 = TXT_67_R1C
				_add_data({W.I_DIPLO: -50})
			elif line == 3:
				r1 = TXT_67_R1D
				_add_empire_relation(EmpireData.USA, 50)
				_add_empire_relation(EmpireData.USSR, -50)
				_add_data({W.I_DIPLO: 50})
			elif line == 4:
				r1 = TXT_67_R1E
				_add_empire_relation(EmpireData.USA, 150)
				_add_empire_relation(EmpireData.USSR, -150)
				_add_data({W.I_DIPLO: -50})
			r1 += TXT_67_R1_TAIL
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USSR, 50)
			if poland != null:
				poland.government = GameConstants.Government.AUTHORITARIAN
				poland.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				poland.set_tag("对华贸易", true)
			context["result_text"] = r1
		2:
			_add_data({W.I_PARTY_SUPPORT: 200, W.I_BUDGET: -200,
				W.I_AGENTS: -50, W.I_THOUGHT_FREEDOM: -10})
			_add_empire_power(EmpireData.USSR, -10)
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, 150)
			if poland != null:
				poland.government = GameConstants.Government.SOCIALIST
				poland.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				poland.set_tag("对华贸易", true)
			context["result_text"] = TXT_67_R2
		3:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_BUDGET: -300,
				W.I_AGENTS: -150, W.I_DIPLO: 100})
			ws.influence_prc += 30
			_add_empire_power(EmpireData.USSR, -30)
			_add_empire_power(EmpireData.USA, -20)
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, -150)
			if poland != null:
				poland.government = GameConstants.Government.AUTHORITARIAN
				poland.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				poland.set_tag("亲苏", false)
				poland.set_tag("亲中", true)
				poland.set_tag("对华贸易", true)
			context["result_text"] = TXT_67_R3
		4:
			var r4 := TXT_67_R4
			if _empire_relation(EmpireData.USSR) >= 800:
				r4 = TXT_67_R4_YES
				_add_data({W.I_PARTY_SUPPORT: 100, W.I_ARMY: -50,
					W.I_AGENTS: -50, W.I_DIPLO: 200,
					W.I_SOVIET_INTERVENTIONS: 1})
				ws.influence_prc += 10
				_add_empire_power(EmpireData.USA, -10)
				_add_empire_relation(EmpireData.USA, -150)
				_add_empire_relation(EmpireData.USSR, 150)
				if poland != null:
					poland.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
					poland.puppet_of = 7
			else:
				r4 = TXT_67_R4_NO
				_add_data({W.I_DIPLO: 200})
				ws.influence_prc += 10
				_add_empire_power(EmpireData.USSR, -20)
				if poland != null:
					poland.government = GameConstants.Government.AUTHORITARIAN
					poland.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = r4
		5:
			var united_states := ws.get_country_by_legacy_index(51)
			if _empire_relation(EmpireData.USA) >= 80 and united_states != null and united_states.development == 1:
				_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 20,
					W.I_THOUGHT_FREEDOM: 160, W.I_BUDGET: -100,
					W.I_AGENTS: -200, W.I_DIPLO: -50})
				_add_empire_power(EmpireData.USSR, -30)
				_add_empire_relation(EmpireData.USA, 150)
				_add_empire_relation(EmpireData.USSR, -50)
				if poland != null:
					poland.government = GameConstants.Government.REFORMIST
					poland.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					poland.set_tag("亲苏", false)
					poland.set_tag("对华贸易", true)
				context["result_text"] = TXT_67_R5_YES
			else:
				_add_data({W.I_AGENTS: -200, W.I_BUDGET: -100,
					W.I_PARTY_SUPPORT: -100, W.I_THOUGHT_FREEDOM: 80})
				_add_empire_power(EmpireData.USSR, -10)
				_add_empire_relation(EmpireData.USA, -300)
				context["result_text"] = TXT_67_R5_NO


func _event_68(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_empire_power(EmpireData.USA, 10)
			context["result_text"] = TXT_68_R0
		1:
			_add_data({W.I_ARMY: -80, W.I_AGENTS: -80, W.I_DIPLO: 10})
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_power(EmpireData.USA, -10)
			ws.set_flag("south_korea_gwangju_rebellion", true)
			context["result_text"] = TXT_68_R1
		2:
			_add_data({W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 20)
			_add_empire_power(EmpireData.USA, 10)
			context["result_text"] = TXT_68_R2
		3:
			_add_data({W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 20)
			_add_empire_relation(EmpireData.USSR, -80)
			_add_empire_power(EmpireData.USA, 20)
			_change_politicians({3: [0, 100]})
			context["result_text"] = TXT_68_R3


func _event_69(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -70})
			_change_politicians({
				0: [0, 100], 1: [-150, 0], 2: [-150, 0], 3: [-150, 0],
			})
			context["result_text"] = TXT_69_R0
		1:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_REFORM_MOMENTUM: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -30})
			_disable_faction(FactionData.MAOIST)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.45)
			_enable_faction(FactionData.LIBERAL)
			_add_faction_ideology({FactionData.REFORMIST: 45, FactionData.LIBERAL: 24})
			_change_politicians({
				0: [-250, -200], 1: [0, 80], 2: [0, 100], 3: [0, 150],
			})
			context["result_text"] = TXT_69_R1
		2:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_REFORM_MOMENTUM: 10,
				W.I_THOUGHT_FREEDOM: 30, W.I_DIPLO: -15})
			_disable_faction(FactionData.MAOIST)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.45)
			_add_faction_ideology({
				FactionData.MODERATE: 27, FactionData.REFORMIST: 45, FactionData.LIBERAL: 15,
			})
			_change_politicians({
				0: [-300, -350], 1: [0, 100], 2: [0, 120], 3: [0, 80],
			})
			context["result_text"] = TXT_69_R2


func _event_70(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 100})
			_add_faction_ideology({FactionData.REFORMIST: 25})
			_change_politicians({0: [-100, 0], 2: [0, 100]})
			context["result_text"] = TXT_70_R0
		1:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_THOUGHT_FREEDOM: -50, W.I_DIPLO: 40})
			_remove_deng_if_modifier_active()
			_add_faction_ideology({FactionData.CONSERVATIVE: 45, FactionData.MAOIST: 30})
			_change_politicians({
				0: [0, 150], 1: [-200, -150], 2: [-200, -350], 3: [-200, -250],
			})
			context["result_text"] = TXT_70_R1
		2:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_THOUGHT_FREEDOM: -50, W.I_DIPLO: 30})
			_remove_deng_if_modifier_active()
			_add_faction_ideology({
				FactionData.MAOIST: 30, FactionData.CONSERVATIVE: 45, FactionData.MODERATE: 24,
			})
			_change_politicians({2: [-200, -350], 3: [-200, -250]})
			context["result_text"] = TXT_70_R2
		3:
			_add_data({W.I_PARTY_SUPPORT: -200, W.I_THOUGHT_FREEDOM: 150,
				W.I_PEOPLE_SUPPORT: -200, W.I_DIPLO: 50})
			_remove_deng_if_modifier_active()
			_add_faction_ideology({FactionData.MAOIST: 30, FactionData.CONSERVATIVE: 45})
			_subtract_faction_fraction(FactionData.MODERATE, 0.09)
			_change_politicians({
				0: [0, 150], 1: [-30, -50], 2: [-30, -350], 3: [-300, -250],
			})
			context["result_text"] = TXT_70_R3


func _remove_deng_if_modifier_active() -> void:
	if ws.modifiers.size() > 14 and ws.modifiers[14] != null and ws.modifiers[14].is_active:
		GameManager.kill_politician(12)
		ws.modifiers[14].is_active = false


func _disable_faction(faction_index: int) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		ws.factions[faction_index].is_enabled = false
		ws.factions[faction_index].is_ally = false


func _enable_faction(faction_index: int) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		ws.factions[faction_index].is_enabled = true


func _empire_relation(empire_index: int) -> int:
	return ws.empires[empire_index].relations if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null else 0


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


func _change_politicians(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			var pair: Array = changes[politician.trait_personality]
			politician.loyalty += int(pair[0])
			politician.power += int(pair[1])


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power

func _prepare_67(event_def: EventDef) -> void:
	if event_def.options.size() < 6:
		return
	var opts := event_def.options
	event_def.title = TXT_67_TITLE
	event_def.description = _leader_name() + TXT_67_DESC
	_enable(opts[0], TXT_67_OPT0)
	_enable(opts[1], TXT_67_OPT1)
	if ws.global_flags.get("relres", false):
		_enable(opts[2], TXT_67_OPT2)
	else:
		_disable(opts[2], TXT_67_OPT2_DIS)
	var albania := ws.get_country_by_legacy_index(20)
	var line := int(ws.数值表[W.I_POLITICAL_LINE])
	var ps := int(ws.数值表[W.I_PARTY_SYSTEM])
	var summa := _summa_3_2()
	var cond := (line < 3 and ps < 8) or (summa > 66 and ps > 7)
	if albania != null and albania.has_tag("亲中") and cond:
		_enable(opts[3], TXT_67_OPT3)
	elif albania == null or not albania.has_tag("亲中"):
		_disable(opts[3], TXT_67_OPT3_DIS1)
	else:
		_disable(opts[3], TXT_67_OPT3_DIS2)
	var china := ws.get_country_by_legacy_index(1)
	if _empire_relation(EmpireData.USSR) >= 600 and china != null and china.has_tag("ovd"):
		_enable(opts[4], TXT_67_OPT4)
	elif china == null or not china.has_tag("ovd"):
		_disable(opts[4], TXT_67_OPT4_DIS1)
	else:
		_disable(opts[4], TXT_67_OPT4_DIS2)
	var united_states := ws.get_country_by_legacy_index(51)
	if _empire_relation(EmpireData.USA) >= 600 and united_states != null and united_states.has_tag("对华贸易"):
		_enable(opts[5], TXT_67_OPT5)
	elif united_states == null or not united_states.has_tag("对华贸易"):
		_disable(opts[5], TXT_67_OPT5_DIS1)
	else:
		_disable(opts[5], TXT_67_OPT5_DIS2)


func _prepare_69(event_def: EventDef) -> void:
	if event_def.options.size() < 3:
		return
	var opts := event_def.options
	event_def.title = TXT_69_TITLE
	event_def.description = _leader_name() + TXT_69_DESC
	_enable(opts[0], TXT_69_OPT0)
	var moderate_reformer_power := _trait_power_sum([1, 2])
	var maoist_power := _trait_power_sum([0])
	if int(ws.数值表[W.I_PARTY_SUPPORT]) >= 650 and moderate_reformer_power > maoist_power:
		_enable(opts[1], TXT_69_OPT1)
	else:
		_disable(opts[1], TXT_69_OPT1_DIS)
	if int(ws.数值表[W.I_PARTY_SUPPORT]) >= 600 and moderate_reformer_power > maoist_power:
		_enable(opts[2], TXT_69_OPT2)
	else:
		_disable(opts[2], TXT_69_OPT2_DIS)


func _prepare_70(event_def: EventDef) -> void:
	if event_def.options.size() < 4:
		return
	var opts := event_def.options
	event_def.title = TXT_70_TITLE
	event_def.description = _leader_name() + TXT_70_DESC
	_enable(opts[0], TXT_70_OPT0)
	var moderate_reformer_power := _trait_power_sum([1, 2])
	var maoist_power := _trait_power_sum([0])
	if int(ws.数值表[W.I_PARTY_SUPPORT]) >= 800 and maoist_power > moderate_reformer_power:
		_enable(opts[1], TXT_70_OPT1)
	else:
		_disable(opts[1], TXT_70_OPT1_DIS)
	if int(ws.数值表[W.I_PARTY_SUPPORT]) >= 700 and int(ws.数值表[W.I_MAO_HISTORY_LINE]) != 0:
		_enable(opts[2], TXT_70_OPT2)
	else:
		_disable(opts[2], TXT_70_OPT2_DIS)
	_enable(opts[3], TXT_70_OPT3)


func _trait_power_sum(traits: Array) -> int:
	var total := 0
	for politician in ws.politicians:
		if politician != null and politician.trait_personality in traits:
			total += int(politician.power)
	return total


func _summa_3_2() -> int:
	if ws.数值表[W.I_PARTY_SYSTEM] <= 7:
		return 0
	var num := 0
	var den := 0
	for i in range(5):
		if i >= ws.factions.size() or ws.factions[i] == null:
			continue
		den += int(ws.factions[i].support)
		if i == FactionData.CONSERVATIVE:
			num += int(ws.factions[i].support)
		elif ws.factions[i].is_ally and ws.factions[i].is_enabled:
			num += int(ws.factions[i].support)
	if den == 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / den


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _fmt_leader(text: String) -> String:
	var n := _leader_name()
	return text.replace("{0}{1}", n).replace("{0}", n).replace("{1}", n)



