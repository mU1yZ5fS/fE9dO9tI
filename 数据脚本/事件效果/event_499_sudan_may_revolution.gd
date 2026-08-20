extends "res://数据脚本/event_script_base.gd"

const T_499_0 := "五月革命是谁人的火焰？"
const T_499_1 := "1969年以来，苏丹的局势一直说不上有多乐观，甚至可以说是混乱。随着以尼迈里为首的自由军官组织夺取了苏丹政权后，苏丹的局势就一直面临着来自各方的挑战：1972年，一场未遂的共产党政变打破了社会主义者之间脆弱的同盟。尼迈里在国际争端中也越发倒向苏联的对立面，与此相对的还有伊斯兰极端主义势力的抬头，1976年的一场未遂政变也使得尼迈里政府不得不沉下心来解决穆斯林问题。但除了政治上的走钢丝，苏丹的民族问题也是个令人苦恼的大麻烦，南方的分离主义组织长期骚扰着政府，阻挠着苏丹南部的正常发展。\n事实上，尼迈里式的阿拉伯社会主义已经濒临崩溃，既无法获得民众的支持，也不能构建一个超越宗教——部落的共和体。苏丹的国债已经失控，经济崩溃，似乎内战已经近在咫尺。作为对苏丹的援助仅次于美利坚合众国的超级大国，苏丹民主共和国正在请求我们的援助。\n但与此同时，我国驻喀土穆大使馆收到了一份情报，称一部分军人渴望得到我们的支持。只要有超级大国愿意为他们背书，他们愿意推翻尼迈里政府。也许是时候跳船了？苏丹的政府已经证明了自己的高效与优越性：他们是一个无底洞，对此，也有的同志建议我们转而支持苏丹人民的反抗。\n主席同志！我们应该做什么？"
const T_499_2 := "同意帮苏丹偿还亏欠的外债（需要8百万预算）"
const T_499_3 := "额，为什么我们要帮他？"
const T_499_4 := "策划一场政变（需要5点特工网络）"
const T_499_5 := "支持一帮布朗基主义者，你疯了？"
const T_499_6 := "没有必要做这种尝试。"
const T_499_7 := "让我们支持真正的革命者推翻尼迈里！"
const T_499_8 := "我们很想要，但我们做不到"
const T_499_9 := "不必管他"
const T_499_10 := "苏丹同志值得一个更光明的未来，我们将稍加点拨……"
const T_499_11 := "当马克思遇上……遇上谁？！"
const T_499_12 := "五月革命是谁人的火焰？"
const T_499_13 := "中华人民共和国近日宣布将给苏丹提供一笔无息贷款，用于解决苏丹近乎于崩溃的经济现状。尼迈里主席感谢了来自我们的帮助。在我们指导人员的帮助下，我们设法修正了尼迈里政府过于激进的土地改革政策，并对1979年以来私有化的工业进行了赎买。在政治方面，我们帮助尼迈里政府改组了苏丹社会主义联盟，该组织是吸纳了该国绝大部分泛阿拉伯社会主义者（主要是阿拉伯复兴社会党——苏丹地区和阿拉伯复兴社会党——苏丹组织）和社会主义者（尤其是被该党所敌视的苏丹共产党）的大帐篷组织。我们也向南部的分离主义者施压，要求他们停止内战。在达累斯萨拉姆，双方签订了新的协议，我们将帮助苏丹政府在停火的基础之上确保南苏丹的自治权。虽然南苏丹还有不少听从于埃塞俄比亚的游击队，但我们相信只要能推进和解政策，苏丹的事情会好起来的。"
const T_499_14 := "在我国和伊拉克的通力合作下，原先影响力极弱的阿拉伯复兴社会党——在苏丹国内，尤其是在苏丹武装力量的下层士兵中的影响力迅速飙升。"
const T_499_15 := "尽管萨达姆本人与尼迈里私交甚佳，但"
const T_499_16 := "借此政局不稳的机会，我们决定抓住机会，促使他们发动了一场政变。借助于喀土穆的大使馆，我方工作者和尼迈里主席彻夜畅谈，痛陈利害，而伊拉克大使提出可以给予尼迈里荣誉公民的身份。在激烈的思想斗争后，尼迈里主席决定顺从，彻底离开苏丹政坛这一伤心地。\n在尼迈里总统发表电视演讲的那一刹那，支持复兴党人的士兵迅速冲入电视台内，他们和总统卫队发生了激烈的交火，全国人民惊恐的在电视和广播里观看了这一画面。尼迈里总统生死未卜电视信号就被切断（事实上一切都是逢场作戏，尼迈里总统早已坐上了前往苏丹港的直升机，他将在那里换乘船只前往伊拉克过完余生），而街道上坦克隆隆作响的声音更是向全国人民心中的疑问做出了回答：一场政变爆发了。在空军的支持下，复兴社会党的高级领导人得以确保其对尼罗河谷的控制。卡尔迈勒·博拉德就此担任了新苏丹的领导人，他宣布正式组建苏丹复兴社会党，并大量吸纳苏丹共产党人加入其下辖的民族进步阵线。参与政变的军官就此扶摇直上，他们在新政府中身居要职。新政权也加大了对伊斯兰主义者和穆斯林兄弟会的压迫力度。苏丹复兴社会党和革命指挥委员会组建了“国民安全大队”，他们身着军装、红袖标和步枪在喀土穆街头巡逻，他们有权搜查和处决他们认为的潜在的“民族敌人”和“扰乱秩序与和平的人”。狂热的群众甚至包围了美国大使馆，指控其支持苏丹南部的分离主义势力。苏丹就这样迎来了自己的斋月革命，仍有斗士试着与新政府对抗。但先是敲门声，再是上膛，又是枪响，最后则是……秩序。"
const T_499_17 := "阿拉伯苏丹共和国"
const T_499_18 := "得益于此前的支持，阿卜杜拉·扎卡里亚（据传，他是《绿皮书》的合著者）领导的苏丹人民社会主义阵线已经在军中争取了大批不满尼迈里的进步军官。看到苏丹政局的不稳，兄弟领袖穆阿迈尔·卡扎菲意识到机会来了，决定一鼓作气地推翻尼迈里政府。而我们的加入更是让利比亚下定了决心。很快，卡扎菲牵头组织了由苏丹人民社会主义阵线领导的苏丹救国革命委员会，约翰·加朗的苏丹人民解放运动以及民族阵线（乌玛党、联合民主党和穆兄会的联盟）也加入了这个委员会。政变很快如期开展。\n清晨，利比亚的图-22轰炸机袭击了苏丹北部的恩图曼，利比亚借口苏丹庇护了“利比亚拯救国家阵线”的成员，有必要展开一场“特别根除行动”。而这不过是利比亚大规模军事干涉的借口，很快利比亚陆军的坦克就出现在了边境线上。恩图曼的沦陷导致了群众对政府极度的失望，而这给利比亚情报局一个大展拳脚的机会。喀土穆的示威游行迅速变成了一场暴乱，群众砸毁了美国英国大使馆，指责尼迈里政府事实上是英美法的傀儡。很快，苏丹人民社会主义阵线旗下的军官就在喀土穆发起了一场政变，事先埋伏在城内的救国委员会部队则成功接管了机场和广播大厦，尼迈里窜逃所坐的飞机也在雷达上神秘失踪。由于苏丹政府长时间无法正常支付军饷，武装部队对政变表示中立。随后，利比亚的武装部队和苏丹人民解放军得以在喀土穆胜利会师，宣告了苏丹民众革命的胜利，阿卜杜拉·扎卡里亚成为了苏丹的“兄弟领袖”。\n在夺取了苏丹港，喀土穆和朱巴后，救国革命委员会宣布组建阿拉伯苏丹人民社会主义民众国，一切都以利比亚的先进经验为模版。由于利比亚和达尔富尔长期的交流，《绿皮书》的推广尚未受阻，但在苏丹南部就略显困难了。兄弟同志是如此的热爱伊斯兰事业，导致他都忘记了苏丹南方事实上并不信仰伊斯兰教。而这就一问题确实困扰到了新生的民众国，为了不重蹈尼迈里的覆辙，救国革命委员会宣称苏丹的“伊斯兰社会主义是革命的，科学的伊斯兰社会主义”，“主爱众人，不分黑白棕”，并通过大力出口油气资源换取对南部的补贴。民众国的实验是否能推广到苏丹……我们走着瞧。"
const T_499_19 := "阿拉伯\n苏丹人民社会主义民众国"
const T_499_20 := "我们联络了奥马尔·巴希尔少将，在我们的支援下，苏丹爆发了一场近乎于内战的小型政变。得益于我们的大力支持，奥马尔的部队击毙了试图逃往沙特阿拉伯的尼迈里。\n但接下来的事情却没有按照我们的意愿发展，奥马尔组建了苏丹革命救国委员会，并迅速取缔了一系列左派政党（包括苏丹社会主义联盟和早已香火断绝的苏丹共产党）。并大力推行沙里亚法，不论穆斯林是否占多数。我们的外交官也被驱逐出境，苏丹断绝了和世界各地的一切关系。半岛电视台在最近的报道中称，苏丹恢复了石刑，断人手脚也变为了常见的惩罚。我们是不是选错人了？"
const T_499_21 := "苏丹共和国"
const T_499_22 := "通过我们在喀土穆的情报网和线人，我们联络到了阿卜杜勒·拉赫曼·斯瓦尔·达哈卜将军，他是革命委员会和苏丹社会主义联盟内的温和派。苏丹发生了一次政权更迭，尼迈里决定流亡到“一个他余生都不会被打扰到的地方”。\n达哈卜将军立刻决定解散议会和苏丹社会主义联盟，并由他牵头组建的临时军事委员会管理国家。达哈卜通过电视和广播许诺苏丹将开展社会变革，他保证苏丹人将享有出版自由，言论自由和信仰自由。他还承诺将恢复南苏丹的自治区。至少苏丹人民很满意，他们每天都为新政府鸣枪三声以示“尊敬”。但我们和超级大国都承认了这一次政府更迭，至少看起来稳定了？"
const T_499_23 := "作为丧失民心的一个补救方案，尼迈里决定投向伊斯兰。很快，在苏丹北部，沙里亚法被重新实行起来，而许多伊斯兰极端主义者也被当作“和解政策”的一部分被吸纳进苏丹社会主义联盟。尼迈里也得到了来自美国的援助，很快，他正式宣布了“将发展和华盛顿方面的关系。”而这引起了长期反抗政府的南苏丹游击战士，政府内的异见者，甚至包括苏丹共产党等左翼反对派的厌恶。我们决定借此机会，给轻率而令人作呕的尼迈里一个教训。在亚历山大港，外联部的同志们会见了苏丹共产党领袖穆罕默德·易卜拉欣·努古德和法鲁克·阿布·伊萨，“指挥官同志”约翰·加朗，“阿尼亚尼亚”组织的“首领”和达尔富尔部族代表；当然，经过内部分裂和尼迈里的大力镇压后已十分弱小的毛派政党苏丹共产党——革命领导也在我方的极力劝说下和苏丹共达成了和解，加入了革命阵营。多方就组建一个各民族平等的社会主义苏丹达成了一致，并许诺在战后交由南苏丹人民自行决定其命运。在签署了《亚历山大协议》后，全苏丹自由与民主解放阵线被组建起来了。而埃塞俄比亚政府愿意为他们提供后勤基地。\n1983年5月，苏丹军队第15师第105营在苏丹南部的博尔和皮比尔镇进行了兵变。政府士兵采取行动镇压兵变，但被叛军击退。该组织宣布成立苏丹人民解放军，一场内战正式开始了！"
const T_499_24 := "第二次苏丹内战"
const T_499_25 := "苏丹"
const T_499_26 := "革命军"
const T_499_27 := "作为丧失民心的一个补救方案，尼迈里决定投向伊斯兰。很快，在苏丹北部，沙里亚法重新被实行起来，而许多伊斯兰极端主义者也被当作“和解政策”的一部分被吸纳进苏丹社会主义联盟。尼迈里也得到了来自美国的援助，很快，他正式宣布了“将发展和华盛顿方面的关系。”\n但苏丹的问题并不是一句“伊斯兰化”或者民族和解就能解决的事情。苏丹人民解放军拿起了武器，并发动了一场起义，第二次苏丹内战就此爆发。"
const T_499_28 := "第二次苏丹内战"
const T_499_29 := "苏丹"
const T_499_30 := "革命军"
const T_499_31 := "在看到社会主义的崭新形式后，加法尔·尼迈里顿悟了。他所想要的并不是什么纳赛尔，也不是泛阿拉伯，而是圣裔和使者所指出来的伊斯兰之路。在和我国民宗委，穆斯林兄弟会中的温和派所召开的“中国-苏丹伊斯兰学者大会”上，苏方代表发表了一通震撼的演讲。经过考究，共产主义和穆斯林的理论并没有冲突，甚至在一定程度上是相通的。安拉的愿景即是在世界实现共产主义，而穆罕默德和马克思作为全人类最接近安拉思想的两人，分别继承了安拉思想的一半，前者只知人要崇高，却造就一群愚味的狂信徒，在列强的威胁下惶惶不可终日；后者只知人要平等，造就一群空虚的暴力狂，只能短暂拥有政权然后就被推翻。毛泽东主席的理论进一步让这两者得到了发展，但他只看到了农民和儒教在其中的力量，忽视了最为核心的教众。而如今加法尔·尼迈里则要将其通三统，让全世界无产阶级真正挣脱异教资产阶级的柳锁，真正在全球范围实现共产主义——用剑与火净化国内的不敬神者，用一场彻底的文化革命消灭阶级敌人。本次大会正式宣告了独特的政治思想：伊斯兰共产主义的诞生（也有学者将其称为尼迈里思想）\n在学习到了中国的社会主义革命成果后。很快，苏丹全国上下都建立起了“人民革命乌玛”。在各个村落里人们都要集体劳作，集体学习尼迈里主席的著作《黄皮书》。反动的阿訇则被批斗，他们被迫吃下狗肉并承认自己是异教徒。革命阿訇们很快接管了全国大大小小的清真寺，基督徒和泛灵论的抗议则被镇压。而为了捍卫革命，苏丹中央革命小组宣布举行思想净化运动，正式废弃了苏丹社会主义联盟，转而设立了苏丹人民权力运动。尼迈里也正式卸任国家主席，转而恢复了自己作为一个阿訇的身份。被问及为什么要这么做时，他说：“我一直都是要做阿訇的，什么主席领袖，讨嫌！”在首都的青年斗士大会接见“红色穆贾希丁”时，尼迈里阿訇如是说道：“哦，我的年轻的战友们，抛弃西方堕落的文化。砸碎那些唱片，倒掉那些酒精，烧毁那些堕落的书本吧。因为他们不是正确的，是魔鬼用来蛊惑人心的，是马克思所不会容忍的。”随后在喀土穆爆发了一场针对外国人的群体性暴力事件，大量的酒吧，舞池和夜店被烧毁。书店里除了《可兰经》，《毛泽东选集（前四卷）》，《资本论》等书籍外均被焚毁，工人和学生也纷纷自发的夺权，接管了工厂和学校的领导权。\n在该国和埃塞俄比亚接壤的边境地区爆发了一场边境冲突，埃塞俄比亚希望借此机会帮助该国支持的南苏丹分离主义者取得进一步的胜利，结果却是以卵击石，不攻自破。埃塞俄比亚军队被打的丢盔弃甲，苏丹又一次取得了胜利。尼迈里主席站在被缴获的T72坦克上自豪的看向他的人民和祖国。他振臂高呼：“打倒异教徒和资产阶级的邪恶联盟！捍卫我们的信仰和无产阶级专政！人民万岁！”"
const T_499_32 := "在看到社会主义的崭新形式后，加法尔·尼迈里顿悟了。他所想要的并不是什么纳赛尔，也不是泛阿拉伯，而是圣裔和使者所指出来的伊斯兰之路。在和我国民宗委，穆斯林兄弟会中的温和派所召开的“中国-苏丹伊斯兰学者大会”上，苏方代表发表了一通震撼的演讲。经过考究，共产主义和穆斯林的理论并没有冲突，甚至在一定程度上是相通的。安拉的愿景即是在世界实现共产主义，而穆罕默德和马克思作为全人类最接近安拉思想的两人，分别继承了安拉思想的一半，前者只知人要崇高，却造就一群愚味的狂信徒，在列强的威胁下惶惶不可终日；后者只知人要平等，造就一群空虚的暴力狂，只能短暂拥有政权然后就被推翻。毛泽东主席的理论进一步让这两者得到了发展，但他只看到了农民和儒教在其中的力量，忽视了最为核心的伊斯兰教众。而如今加法尔·尼迈里则要将其通三统，让全世界无产阶级真正挣脱异教资产阶级的柳锁，真正在全球范围实现共产主义——用剑与火净化国内的不敬神者，用一场彻底的文化革命消灭阶级敌人。本次大会正式宣告了独特的政治思想：伊斯兰共产主义的诞生（也有学者将其称为尼迈里思想）\n很快，苏丹上下都建立起了“人民革命乌玛”。在各个村落里人们都要集体劳作，集体学习尼迈里主席的著作《黄皮书》。反动的阿訇则被批斗，他们被迫吃下狗肉并承认自己是异教徒。革命阿訇们很快接管了全国大大小小的清真寺，基督徒和泛灵论的抗议则被镇压。而为了捍卫革命，苏丹中央革命小组宣布举行思想净化运动，正式废弃了苏丹社会主义联盟，转而设立了苏丹人民权力运动。尼迈里也正式卸任国家主席，转而恢复了自己作为一个阿訇的身份。被问及为什么要这么做时，他说：“我一直都是要做阿訇的，什么主席领袖，讨嫌！”在首都的青年斗士大会接见“红色穆贾希丁”时，尼迈里阿訇如是说道：“哦，我的年轻的战友们，抛弃西方堕落的文化。砸碎那些唱片，倒掉那些酒精，烧毁那些堕落的书本吧。因为他们不是正确的，是魔鬼用来蛊惑人心的，是马克思所不会容忍的。”随后在喀土穆爆发了一场针对外国人的群体性暴力事件，大量的酒吧，舞池和夜店被烧毁。书店里除了《可兰经》，《毛泽东选集（前四卷）》，《资本论》等书籍外均被焚毁，工人和学生也纷纷自发的夺权，接管了工厂和学校的领导权。\n在招待宴会上，门格斯图大元帅和尼迈里阿訇互换了葡萄汁。当被问及和过去的敌人和解后有什么感触时，被热的有些脸红的尼迈里阿訇说道：“埃塞俄比亚也是我们的先生，我们要感谢门格斯图大元帅。你们支持我们的人民敌人，这就省的我们挑出坏分子。这一打就把一盘散沙的苏丹人民打得团结起来了，所以，我们应该感谢你们。为了我们的友谊干杯！”现场充满了欢乐的氛围。"


## 原作 Event499.cs：五月革命是谁人的火焰？（苏丹，五选项）。
## 触发：TimeScript.cs:11149-11154 —— (日>=1 且 月>=9 且 年>=1983) || (月>=10 且 年>=1983) || 年>=1984。
## 差异：
##  - resultOfEvents 缺省按原版 int 默认 0。
##  - 原版 OAR bool → ws.get_flag("oar")。
##  - LeaveAlliances() 按 event_496 完整标签清单；JoinAllOurAlliances(true) 按 event_650 注释逻辑
##    （flag 组 id 跳过军事联盟，只按中国 econ/sev 加入经济联盟）。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	event_def.title = T_499_0
	event_def.description = T_499_1
	var ethiopia := world.get_country_by_legacy_index(41)
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if line < 3:
		_enable(opt[0], T_499_2)
	else:
		_disable(opt[0], T_499_3)
	if line > 0 and line < 4:
		_enable(opt[1], T_499_4)
	elif line == 0:
		_disable(opt[1], T_499_5)
	else:
		_disable(opt[1], T_499_6)
	if line < 2 and ethiopia != null and ethiopia.has_tag("对华贸易"):
		_enable(opt[2], T_499_7)
	else:
		_disable(opt[2], T_499_8)
	_enable(opt[3], T_499_9)
	if china != null and china.sub_government == 19:
		_enable(opt[4], T_499_10)
	else:
		_disable(opt[4], T_499_11)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var sudan := ws.get_country_by_legacy_index(53)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			if sudan != null:
				sudan.government = 2
				sudan.sub_government = 15
				sudan.set_tag("对华贸易", true)
				sudan.set_tag("亲中", true)
			ws.influence_prc += 10
			context["result_text"] = T_499_13
		1:
			_result1(sudan, context)
		2:
			_result2(sudan, context)
		3:
			_result3(sudan, context)
		4:
			_result4(sudan, context)


func _result1(sudan: CountryData, context: Dictionary) -> void:
	if sudan == null:
		return
	var iraq := ws.get_country_by_legacy_index(14)
	var libya := ws.get_country_by_legacy_index(13)
	var egypt := ws.get_country_by_legacy_index(30)
	if sudan.prc_influence == 1 and iraq != null \
			and (iraq.sub_government == 10 or iraq.sub_government == 19 or iraq.government == 2) \
			and not iraq.has_tag("asean") and iraq.puppet_of < 0:
		var text := T_499_14
		if iraq.sub_government == 10 or iraq.sub_government == 19:
			text += T_499_15
		text += T_499_16
		_add(W.I_AGENTS, -50)
		_add_power(EmpireData.USSR, 50)
		_add_power(EmpireData.USA, -100)
		_add_relation(EmpireData.USA, -100)
		sudan.government = iraq.government
		sudan.sub_government = iraq.sub_government
		_leave_alliances(sudan)
		sudan.set_tag("对华贸易", true)
		sudan.name = T_499_17
		if iraq.sub_government == 10 or iraq.sub_government == 19:
			sudan.puppet_of = 14
		elif (ws.get_flag("oar") and egypt != null and egypt.has_tag("亲苏")) or iraq.has_tag("亲苏"):
			sudan.set_tag("亲苏", true)
		elif (ws.get_flag("oar") and egypt != null and egypt.has_tag("亲中")) or iraq.has_tag("亲中"):
			sudan.set_tag("亲中", true)
		context["result_text"] = text
	elif sudan.prc_influence == 2 and libya != null and libya.sub_government == 10:
		_add(W.I_AGENTS, -50)
		_add_relation(EmpireData.USA, -100)
		sudan.government = 0
		sudan.sub_government = 10
		_leave_alliances(sudan)
		sudan.set_tag("对华贸易", true)
		sudan.puppet_of = 13
		sudan.name = T_499_19
		context["result_text"] = T_499_18
	elif d.size() > W.I_WAR_SUPPORT and d[W.I_WAR_SUPPORT] >= 700:
		_add(W.I_AGENTS, -50)
		sudan.government = 0
		sudan.sub_government = 9
		sudan.set_tag("对华贸易", false)
		sudan.name = T_499_21
		_leave_alliances(sudan)
		context["result_text"] = T_499_20
	else:
		_add(W.I_AGENTS, -50)
		if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null \
				and ws.empires[EmpireData.USA].power > ws.influence_prc:
			sudan.government = 0
			sudan.sub_government = 7
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲美", true)
		elif ws.is_socialism(ws.get_country_by_legacy_index(1), true) \
				or (ws.get_country_by_legacy_index(1) != null and ws.get_country_by_legacy_index(1).government == 2) \
				or (ws.get_country_by_legacy_index(1) != null and ws.get_country_by_legacy_index(1).sub_government == 10):
			sudan.government = 2
			sudan.sub_government = 8
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
		elif ws.get_country_by_legacy_index(1) != null and ws.get_country_by_legacy_index(1).government == 3:
			sudan.government = 3
			sudan.sub_government = 5
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
		else:
			sudan.government = 0
			sudan.sub_government = 7
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
		context["result_text"] = T_499_22


func _result2(sudan: CountryData, context: Dictionary) -> void:
	_add(W.I_BUDGET, -50)
	_add(W.I_ARMY, -100)
	if sudan != null:
		sudan.government = 0
		sudan.sub_government = 9
		sudan.set_tag("对华贸易", false)
	_start_war(48, T_499_25, T_499_26, 600, 400, 0, 1, T_499_24, 24)
	_set_part(sudan, 2, true)
	if sudan != null:
		sudan.set_tag("亲美", true)
	_add_power(EmpireData.USA, 20)
	context["result_text"] = T_499_23


func _result3(sudan: CountryData, context: Dictionary) -> void:
	if sudan != null:
		sudan.government = 0
		sudan.sub_government = 7
		sudan.set_tag("亲美", true)
	_add_power(EmpireData.USA, 20)
	_start_war(48, T_499_29, T_499_30, 600, 400, 0, 1, T_499_28)
	_set_part(sudan, 2, true)
	context["result_text"] = T_499_27


func _result4(sudan: CountryData, context: Dictionary) -> void:
	var ethiopia := ws.get_country_by_legacy_index(41)
	if ethiopia != null and ethiopia.sub_government != 19:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -150)
		if sudan != null:
			sudan.government = 0
			sudan.sub_government = 19
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
			_join_alliances(sudan)
		context["result_text"] = T_499_31
	else:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -50)
		if sudan != null:
			sudan.government = 0
			sudan.sub_government = 19
			_leave_alliances(sudan)
			sudan.set_tag("对华贸易", true)
			sudan.set_tag("亲中", true)
			_join_alliances(sudan)
		context["result_text"] = T_499_32


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)


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








func _set_part(country: CountryData, index: int, value: bool) -> void:
	if country == null:
		return
	while country.parts.size() <= index:
		country.parts.append(false)
	country.parts[index] = value


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight
