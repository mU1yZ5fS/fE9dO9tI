extends "res://数据脚本/event_script_base.gd"

## 原作事件 53–62：农业/外资改革、缅甸、越南、日本、伊朗终局、
## 中国主导的经济与军事集团、国歌和内蒙古政策。
## 来源：TimeScript.cs:3858-3947，doneventscript.cs:1307-1488，
##       Results_text.cs:4649-5479。

## 原版 Event54 result0 动态文案。
const TXT_54_R0_A := "尽管有许多抗议和对减缓改革的指责，然而"
const TXT_54_R0_B := "决定将投资的问题推迟一段时间，因为“这样我们才能制定出关于解决这一问题的最佳方案。”"

## 原版 Event55 动态文案。
const TXT_55_R1 := "将天鹅、梭子鱼和虾团结起来并非易事，奈温与巴登顶的会谈很快便以失败告终。然而，奈温试图以“苏加诺二世”身份同我国建立统一战线的计划却得到了{0}{1}同志的青睐与赞许，并将其视为打破东南亚封锁的关键。很快，我们便与缅甸建立了一系列合作关系，就工业与贸易问题达成了多项合作条款。当然，我们并没有将话说绝，没有公开拿出“停止输出革命”的价码：这多少让刚得知邪恶联盟诞生而大感失望的巴登顶稍稍稳定了情绪。也就在党政军高层均参与的内部会议上，{0}{1}同志亲自以“我们不能失去第二个苏加诺”的说法捍卫奈温政府，并以右派与美英势力公开进入缅甸的假设巩固了党内大多数同志的立场。"
const TXT_55_R2_BASE := "考虑到奈温政府的改革只会让该国向经济危机一路狂奔，且缅甸国内局势日益严峻。与其将希望押注在长期游击未取得突破性进展的缅共上，我们决定扶持一个立场相对奈温更“中派资产阶级政府”的集团掌权。也就在奈温于北京全聚德享用最后一餐时，我们的情报人员同时在仰光策动了反奈温政变。\n"
const TXT_55_R2_SAN_YU := "新政府由山友和曾任独立运动时期“三十同志”之一的盛温带领。他们在批判奈温破坏社会主义经济建设，自绝于社会主义阵营与败坏“缅甸社会主义道路”声誉的同时进行改革。大众党的文官统治地位得以巩固，缅甸开始推进农业集体化并重回不结盟运动。当然，掸邦的大小民团，如罗星汉等“风云人物”们对这些变化怒不可遏。此后，我们更是在缅甸北部达成短暂停火协议，事实上完全孤立了巴登顶队伍，后者的灭亡不过时间问题。但已拿到西瓜的我们何必在乎芝麻呢？"
const TXT_55_R2_KHIN_NYUNT := "新政府由华裔特务将军钦纽和热心经济改革的将军昂基带领。他们在批判奈温持反华思潮的大缅族主义，破坏民族间的和谐关系与败坏“缅甸社会主义道路”声誉的同时进行改革。出于应付奈温的灾难性货币改革政策，缅甸经济开启了大规模改革。越来越多的顾问被派到我国以学习我国的管制市场发展模式。此后，我们更是在缅甸北部达成短暂停火协议，事实上完全孤立了巴登顶队伍，后者的灭亡不过时间问题。但已拿到西瓜的我们何必在乎芝麻呢？"

## 原版 Event58 result0 两分支文案。
const TXT_58_R_LEFT := "伊朗的革命者们达成了自己的目标，沙阿和他的家人逃离了这个国家，把权力移交给来自温和保皇反对派的首相沙普尔·巴赫蒂亚尔（他很快丢失了自己对于局势的掌控）。在工人和军事部队的支持下，伊朗共和国被成立了。霍梅尼在欢呼的人群中，被法国航空的一位机长搀扶着缓缓走下飞机。但于此同时，各个反对派组织的矛盾随着沙阿的倒台一并浮现。在最近的制宪议会中，伊斯兰共和党以近乎垄断的姿态占据了多数。我们希望伊朗的事态会向好的一面发展。"
const TXT_58_R_SHAH := "尽管事后统计，参与伊朗革命的人口比例甚至超越了十月革命时期参与俄国革命人口的比率，但在残酷的镇压下伊朗的革命者们没能达成自己的目标，而沙阿继续执政。在SAVAK指导下，针对全国各大反对派乃至相当一大部分人口的的血洗开始了，这招致了除了美国以外的大多数国家的一致谴责。根据国际政治家的观察，该国对人权的尊重程度大致相当于海地的杜瓦利埃政权。霍梅尼选择重新回到在巴黎的故居，继续制作呼吁推翻沙阿的录音带。出于对第二次革命的恐慌，伊朗一方面进一步加强同美国的合作，实际上深化了其附庸关系，而另一方面，该国陷入到了一种狂暴的对伊斯兰宣战的状态，巴列维开始变本加厉用自己的神话、个人崇拜与迷信本身代替信仰对于政治的影响，并更加深陷于盗窃统治。我们希望伊朗的事态会向好的一面发展。"

## 原版 Event59/60 动态成员名单文案。
const TXT_59_R1_BASE := "今天，在我国的倡议下，在北京举行了一场闭门经济会议，会议上正式通过了关于建立经济合作组织（ECO）的决议，其目的在与扩展中国友好国家间的贸易和经济往来。新联盟的成员有中国"
const TXT_60_R0_BASE := "今天在上海，签署了一项关于建立集体安全联盟（CRA）的协议，这是一个军事政治组织，将中国所有的盟国在一个军事集团的旗帜下团结起来。集体安全联盟的目的是建立一个共同反对其他军事联盟（华约和北约）的互助防御体系。新成立的组织的成员为中华人民共和国"
## 原版 Event59 option3 第二禁用文案：我们已经加入了
const TXT_60_R0_TAIL := "。苏联和美国对中国影响力的扩大做出了负面反应，称这一新的联盟“是缓和国际紧张局势的障碍”和“和平共处的毁灭者”。反过来，党和人民对中华人民共和国声望的提高充满了热情和钦佩。似乎国际舞台上出现了第三支力量，希望一切向好。"



## 事件 61（国歌问题）与 62（内蒙古问题）逐字中文文案。
## 来源：Event61.cs / Event62.cs（TextOfEvents / VariantsOfEvents / ResultsOfEvents）。
## 说明：{0}{1} 为原版领袖姓名字段占位，显示前由 _fmt_leader() 替换为 name_display。

const TXT_61_TITLE := "起来，起来，起来！"

const TXT_61_DESC := "{0}{1}同志，既然您决定正式的，以万分严肃的态度处理我国的国歌问题。那么，请现听我稍稍介绍一下我国国歌目前的问题。在我国建国前的政治协商会议上，我国就确立了以田汉作词，聂耳谱曲的《义勇军进行曲》作为代国歌。但并未以正式的法律程序确立其地位，五四宪法中也没有与国歌相关的内容。一切看起来都相对正常……直到无产阶级文化大革命波及到了田汉本人。田汉在文化大革命早期被打倒，因此，义勇军进行曲的歌词被删去，在公共场合一般之采用纯音乐。在造反派占优势的地区和特殊情况下，我国也会演奏赞颂毛泽东主席和共和国的歌曲《东方红》作为国歌。在1977年筹备第五届人大的时候，我国就国歌问题发动了全国各族人民进行大讨论，有许多富有创意的观点得到了讨论。目前我国现行的义勇军进行曲为改词版，在修改了部分歌词的前提下，额外强调了毛泽东主席以及他所缔造的中国共产党在革命中的贡献。同时，还有几份法案得到了人大的支持。其中包括恢复原版作词的义勇军进行曲；党内的左派支持正式确立《东方红》的国歌地位、而将《义勇军进行曲》改为代国歌；更有甚者认为我国有必要效仿苏维埃俄国，立足国内，放眼全球的革命共产主义运动，将《国际歌》确认为我国的正式国歌。当然，也有人支持按照我国的实际国情，对《歌唱祖国》进行改编；1977年所谱成的新歌《中国，鲜红的太阳永不落》也有不少支持者。{0}{1}同志，只要您确定好了大体方案，我们就会在下次的人大大会上对此表决。"

const TXT_61_DESC_AGAIN := "{0}{1}同志，既然您决定正式的，以万分严肃的态度处理我国的国歌问题。那么，请现听我稍稍介绍一下我国国歌目前的问题。在我国建国前的政治协商会议上，我国就确立了以田汉作词，聂耳谱曲的《义勇军进行曲》作为代国歌。但并未以正式的法律程序确立其地位，五四宪法中也没有与国歌相关的内容。一切看起来都相对正常……直到无产阶级文化大革命波及到了田汉本人。田汉在文化大革命早期被打倒，因此，义勇军进行曲的歌词被删去，在公共场合一般之采用纯音乐。在造反派占优势的地区和特殊情况下，我国也会演奏赞颂毛泽东主席和共和国的歌曲《东方红》作为国歌。虽然我们之前已经通过了一个版本，但既然大会已经决定再次讨论这个问题，我们不妨再看看那些我们没有考虑充分的方案：其中包括改词版和恢复原版作词的义勇军进行曲；党内的左派支持正式确立《东方红》的国歌地位、而将《义勇军进行曲》改为代国歌；更有甚者认为我国有必要效仿苏维埃俄国，立足国内，放眼全球的革命共产主义运动，将《国际歌》确认为我国的正式国歌。当然，也有人支持按照我国的实际国情，对《歌唱祖国》进行改编；1977年所谱成的新歌《中国，鲜红的太阳永不落》也有不少支持者。{0}{1}同志，只要您确定好了大体方案，我们就会在下次的人大大会上对此表决。"

const TXT_61_OPT0 := "让我们选用改词版《义勇军进行曲》"
const TXT_61_OPT0_KEEP := "维持现行版本的改词版《义勇军进行曲》"
const TXT_61_OPT0_DIS := "这一套老掉牙的论断…还有人信吗？"
const TXT_61_OPT1 := "恢复原版的《义勇军进行曲》"
const TXT_61_OPT1_KEEP := "维持现行版本的原版《义勇军进行曲》"
const TXT_61_OPT1_DIS := "有些事情…宜粗不宜细"
const TXT_61_OPT2 := "最响亮的歌是《东方红》，它将成为我国的正式国歌！"
const TXT_61_OPT2_KEEP := "维持现行版本的《东方红》"
const TXT_61_OPT2_DIS := "这首歌……实在不合适"
const TXT_61_OPT3 := "我们怎能拘泥于眼前的这一切？英特纳雄耐尔，就一定要实现！"
const TXT_61_OPT3_KEEP := "维持现行版本的《国际歌》"
const TXT_61_OPT3_DIS := "哪怕是对于我们党最为激进的左翼分子而言，这也太夸张了"
const TXT_61_OPT4 := "《歌唱祖国》，这是一首怎么样都不会错的歌"
const TXT_61_OPT4_KEEP := "维持现行版本的《歌唱祖国》"
const TXT_61_OPT5 := "鲜红的太阳永不落，这是首好歌哇"
const TXT_61_OPT5_KEEP := "维持现行版本的《中国，鲜红的太阳永不落》"

const TXT_61_R_INTRO := "新国歌是在全国人民共同努力的基础上产生的。|二十九个省、市、自治区（包括在京的台湾省籍同胞），军委各总部、各大军区、各军兵种和中央各有关部委，接到中华人民共和国国歌征集小组《关于征集国歌的通知》后，都非常重视，把征集国歌工作当作一项重大政治任务来完成。许多单位除组织专业和业余创作人员写词谱曲外，并广泛发动群众，使国歌征集工作成为一次广泛而生动的爱国主义教育，形成一个歌颂伟大祖国的群众性歌曲创作热潮。"
const TXT_61_R0 := "最终，我国确定了以原版《义勇军进行曲》为曲调，再加以重新填词的新版《义勇军进行曲》，全国人大也就此通过了《国歌法》。毛主席历来十分强调加强各民族的团结，号召各族人民同心协力，共同建设我们伟大的社会主义祖国。歌词的第一句，用号召性的短句：“前进！各民族英雄的人民”，表达出中华民族的自豪感，体现各族人民大团结的精神。领导我们事业的核心力量是中国共产党。党政军民学，东西南北中，党是领导一切的。用“伟大的共产党领导我们继续长征”，表现了我们伟大的国家，在{0}主席为首的党中央的领导下，沿着党旗指引的路线向革命的万里征途进军的雄壮气势。结尾的三个前进气势恢宏，高高举起的毛泽东旗帜是我们的象征，让我们高唱继续革命的战歌，去夺取更大的胜利！"
const TXT_61_R1 := "最终，我国决定恢复原版的《义勇军进行曲》。这首耳熟能详的战歌带着我国人民走过了抗击日寇，解放全中国和建设社会主义的三个时代。广大人民群众对它有深厚的感情。它一直在鼓舞我们的革命斗志，至今仍保持着强大的生命力。而且，原国歌曲调短小、精悍、易唱、易记。在国内国际有广泛影响，无论走到哪里，只要听到它的音调，马上就会感到这是中华人民共和国的伟大形象，产生一种崇高的民族自豪感。过去被打为“黑五类”的田汉本人也被平反。"
const TXT_61_R2 := "最终，代表们高票通过了将《东方红》确认为我国正式国歌的法案，全国人大顺势通过了《国歌法》。《东方红》是毛主席时代知名的歌曲，这首歌曲认可了毛泽东主席带领人民，率领人民革命的功绩。这首歌，歌颂的是人民的血汗，要把这首歌继续唱下去，为世人所传诵。此外，《国歌法》中也提到了，在非正式场合，国歌可以采用纯音乐的版本。"
const TXT_61_R3 := "最终，{0}{1}同志亲自上阵，为一个鲜有人支持的方案摇旗呐喊，在得到了党内激进左派和部分干部的支持后，全国人大正式通过了将《国际歌》确认为我国国歌的决议，顺势通过了《国歌法》。我国采纳了最为经典的，由肖三同志，陈乔年，冼星海等人润色后的国际歌。{2}国际歌是全球无产阶级最嘹亮的战歌，我们的祖国不仅仅是我们民族的祖国，更是一切被压迫者的灯塔，是全世界压迫者的敌人。我们要把旧世界打个落花流水，让鲜红的太阳照遍全球。起来吧，起来！"
const TXT_61_R3_ROCK := "一些北京的摇滚乐队积极响应号召，制作了摇滚版的《国际歌》。"
const TXT_61_R4_A := "我国最终决定将原版的《歌唱祖国》作为国歌，这是首简单的爱国主义歌曲。体现了社会主义建设时期中华儿女为祖国繁荣富强奋力拼搏的爱国之情，采用进行曲风格，融合欧洲凯旋式进行曲与中国民族颂歌元素，曲调豪迈雄壮，节奏铿锵有力，情感深厚宽广；歌词朴实真挚，实现了时代性与民族性、艺术性与群众性的统一，成为独立富强、朝气蓬勃的中国形象的写照。响应时代和党中央的战略部署，把文化革命进行到底。其中的歌词被稍加修改。添加了赞颂无产阶级文化大革命的内容，无数青年小将们将听着这首歌，继承毛主席的遗志，将革命进行到底。"
const TXT_61_R4_B := "我国最终决定将原版的《歌唱祖国》作为国歌，这是首简单的爱国主义歌曲。体现了社会主义建设时期中华儿女为祖国繁荣富强奋力拼搏的爱国之情，采用进行曲风格，融合欧洲凯旋式进行曲与中国民族颂歌元素，曲调豪迈雄壮，节奏铿锵有力，情感深厚宽广；歌词朴实真挚，实现了时代性与民族性、艺术性与群众性的统一，成为独立富强、朝气蓬勃的中国形象的写照。响应时代和党中央的战略部署，其中的歌词被稍加修改，在第三段中格外赞扬了毛泽东主席领导我国的功绩。"
const TXT_61_R4_C := "我国最终决定将原版的《歌唱祖国》作为国歌，这是首简单的爱国主义歌曲。体现了社会主义建设时期中华儿女为祖国繁荣富强奋力拼搏的爱国之情，采用进行曲风格，融合欧洲凯旋式进行曲与中国民族颂歌元素，曲调豪迈雄壮，节奏铿锵有力，情感深厚宽广；歌词朴实真挚，实现了时代性与民族性、艺术性与群众性的统一，成为独立富强、朝气蓬勃的中国形象的写照。"
const TXT_61_R5 := "最后，全国人大确立了《中国，鲜红的太阳永不落》作为国歌。歌曲的开头是“分解和弦”的四度跳进，高潮运用是八度的大跳运用，气势宽广，表达出民族的自豪感、自信心和进取的精神。全曲洋溢着爱国主义的激情，用宏大的气势，沉稳的节奏，脍炙人口的歌词，高亢激昂的旋律，表现了中华民族历史文化的辉煌，表达了中国人民不屈不饶的坚毅，描绘了中国蒸蒸日上、欣欣向荣的景象。"
const TXT_61_R5_HUA := "顺带一提，本首歌的第二段额外提及了“华主席率领我们继续革命”等内容。考虑到其身份特殊，很难不让人浮想联翩…"
const TXT_61_R_KEEP := "我们决定暂时不对国歌进行调整。"

## 原版 ResultsOfEvents 末尾同步 old_modify_desc[61] 的文案（本版 ModifierCatalog 动态生成，故仅留存溯源）。
const TXT_61_MOD_TITLE := "国歌："
const TXT_61_MOD0 := "纯音乐版《义勇军进行曲》|凝聚力+0.1"
const TXT_61_MOD1 := "改词版《义勇军进行曲》|党内团结度+0.1"
const TXT_61_MOD1_B := "，十二大时的力量对比更倾向于保守派"
const TXT_61_MOD2 := "《义勇军进行曲》|凝聚力+0.2"
const TXT_61_MOD3 := "《东方红》|人民支持度+0.1"
const TXT_61_MOD3_B := "，十二大时的力量对比更倾向于激进派"
const TXT_61_MOD4 := "《国际歌》|世界观-0.1，若世界观高于70.0时额外-0.3"
const TXT_61_MOD5 := "《歌唱祖国》"
const TXT_61_MOD6 := "《中国，鲜红的太阳永不落》|若应用了先进的社会主义理论：思想自由化-0.2，外交声誉+0.2，世界观+0.4"

const TXT_62_TITLE := "成吉思汗后裔的问题"

const TXT_62_DESC := "{0}{1}同志，随着我们的革命进入了一个新阶段，是时候正式我们过去没能妥善处理的问题了。而今日，党内有一部分同志希望我们能够重新审视云泽同志（即乌兰夫）的问题，借此妥善处理我国的内蒙古自治区的问题。但请先听我对我国的内蒙问题进行一番阐述。|在江西的中华苏维埃时代，中央政府早已对内蒙古问题有了定论：原来内蒙六盟，二十四部，四十九旗，察哈尔土默特二部，及宁夏三特旗之全域，无论是已改县治或为草地，均应归还内蒙人民，作为内蒙古民族之领土，取消热、察、绥三行省之名称与实际行政组织，其他任何民族不得占领或借辞剥夺内蒙古民族之土地；由此，我们成功拉拢了一批进步的蒙古族上层人士，以蒙西的土默特部为主，构成了我党最早的一批蒙族干部。他们在抗日战争中试图统战上层王公贵族反对蒋介石与日本侵略者，但最终失败，蒙族干部遂在晋绥根据地的领导下展开了武装斗争，在构成今日内蒙古自治区的核心地段的乌兰察布盟长期活动。抗日战争取得胜利后，长期在蒙西活动的蒙族干部们成立了“内蒙古自治运动联合会”，以此公开同中央政府要求扩大自治权。与此同时，北部的超级大国苏联开始介入与民国政府的博弈之中，在西部鼓动“三区革命”之外，蒙东的所谓“内蒙古人民革命党”和东北局在错误思想的指导下公开分裂我国领土，要求与蒙古人民共和国合并，就此埋下祸根。我党决定严肃批评东北局的行动并强迫东蒙的自治运动加入西蒙，并许诺其以极大的自治权。在召开了内蒙古地区的代表大会后，以乌兰夫同志为首的蒙族干部们决定拥护我们的新民主主义革命，就此，内蒙古自治区成为了我国最早成立的自治区，是我们民族政策的“头牌”。|事情在建国后变得愈发剪不断理还乱：我国并没有如苏维埃联盟一般建立起中华联邦，此类政策被部分蒙族干部理解为是“对自治权的禁锢”。而在中苏关系急速破裂的50年代中后期，中央对内蒙古自治的问题也随着对苏、蒙关系而急速修改。长期领导内蒙古的乌兰夫同志在多次中央大会上被批评为“搞独立王国”，与中央政策对抗：如拒绝执行中央的“反右”方案、在“四清”时期推动了一场“反对大汉族主义”的运动更是将其推向了火坑。随后，更多相关的黑材料随着无产阶级文化大革命的爆发喷涌而出：拒绝听从中央指挥，歪曲毛泽东思想，对莫斯科和乌兰巴托卑躬屈膝的修正主义小丑乌兰夫就此被打入历史的冷宫。首先是蒙古族干部被停职并隔离审查：尤其是出生自蒙东，曾在伪满洲国时期接受教育的干部们。随后，内蒙古的革命便主要指向了批评，深挖，肃清乌兰夫流毒。并在党内强硬派如康生同志的支持下，中央决定在反抗蒙修与苏修的前线——内蒙古开展军管。由政治斗争引起的政治运动最终演变为了军队完全下场的政治洗牌：以挖清，肃清内蒙古人民革命党流毒为名，内蒙古开展了一轮又一轮政治上的迫害，直到70年代早期才有所转变。至今对死伤人数没有完全定论，这也严重破坏了我国和蒙古人民共和国的关系。|现在，部分同志希望我们能够正视这一问题，这样我们才能正视过去的问题。但是党内也有同志认为不应操之过急，尤其是要担心苏联的潜在渗透问题。{0}{1}同志，您的意见是？"

const TXT_62_OPT0 := "1969方案是我们对他们最大的让步了"
const TXT_62_OPT0_DIS := "完全没必要这么做……"
const TXT_62_OPT1 := "恢复到1969年前的区划"
const TXT_62_OPT1_DIS1 := "打倒勃列日涅夫和泽登巴尔的走卒乌兰夫！"
const TXT_62_OPT1_DIS2 := "打倒大蒙族主义者乌兰夫！"
const TXT_62_OPT2 := "看来不给他们点教训是长不大的……"
const TXT_62_OPT2_DIS := "就不能翻篇了吗！"
const TXT_62_OPT3 := "把蒙东划回内蒙古自治区的同时，狠狠的往里面掺沙子"
const TXT_62_OPT3_DIS1 := "你想吃共产主义的饭还是民族主义的饭？"
const TXT_62_OPT3_DIS2 := "做事，要做绝"
const TXT_62_OPT4 := "内蒙古问题是一面照妖镜……我们将借此机会一劳永逸的解决民族问题！"
const TXT_62_OPT4_DIS := "你说什么？"

const TXT_62_R0 := "最终，人民日报特约评论员“马辉腾”发表了一篇社论《再论‘论民族问题的提法’》。其中高度强调了团结在我党周围的各民族爱国人民必须坚持爱国主义和社会主义理念的统一；团结在党，国家和红旗之下，和狭隘民族主义与分裂主义斗争；强烈反对，拒绝以“纠正历史错误”的名义鼓舞，煽动各民族对党的路线的错误认识。这篇社论还对斯大林著作的基础，即给民族问题的解决方法提供了新的中国方案：要帮助和协助落后民族提高文化水平和经济水平，从“民族权利平等”转向各民族事实上的平等，譬如：（1）研究落后民族和部族的经济状况、生活习惯和文化；（2）发展他们的文化；（3）对他们进行政治教育；（4）把他们逐步地无痛苦地引向高级的经济形式；（5）建立落后民族劳动者和先进民族劳动者之间的经济合作；（6）在尊重国内情况的前提下，巩固以主体民族为主的爱国主义情怀；（7）坚定反对打着解放旗号的分离主义势力。这份社论事实上钉死了“乌兰夫”之流的棺材板，中央屡次驳回了内蒙古地方要求调整行政区划的决议。但是额外强调了要发展，巩固内蒙古的基础建设，并追加了一笔用于修缮自治区内铁路系统的投资。内蒙古自治区的情况一切照常，没有什么特别的变化。"
const TXT_62_R1 := "最终，中央决定重新考虑内蒙古问题，并给出公平公正的答复。国务院在决定恢复乌兰夫同志名誉的同时，决定重新调整内蒙古及临近省份的行政区划。人民日报特约评论员“马辉腾”发表了一篇社论《各族人民团结起来，为繁荣的边疆和巩固的边防而战斗》。其中高度强调了团结在我党周围的各民族爱国人民必须坚持维护国土完整统一；团结在党，国家和红旗之下，和狭隘民族主义与分裂主义斗争；并指出正是在我党的领导下，边疆各区获得了近千年以来未曾有的天翻地覆：不论是水利，电气还是政治生活的空前繁荣，正是我党的功劳。因此，这篇社论在最后提到了要结合我国实际国情，维护各族团结。借此机会，国务院公布了调整后的内蒙古行政区图，将呼伦贝尔、兴安等蒙东地区和阿拉善两旗重新从东北三省，甘肃和宁夏划出，交还给内蒙古自治区。行政机构的交接造成了一定的混乱，尤其是曾大力援助蒙东地区的东三省对这一决定高度不满。而且由于内蒙古的版图急速扩大导致北京军区难以形成完全的管辖，蒙东和阿拉善地区的边防将长期由沈阳和兰州军区分别辅助管理。不过党内的一部分人物认为这是个好迹象：完成了对民族问题的定论之外，有效维护我国的领土完整。蒙古方面也希望能借此机会重新修复两国的关系，二连浩特和满洲里口岸正在筹备重新开张，而内蒙古自治区的“乌兰牧骑”也受蒙古人民革命党的邀请前往了当地演出。"
const TXT_62_R2 := "{0}{1}同志力排众议，在与中央军事委员会和调查部的同志们商讨良久后，最终决定：出于残酷的国际形势，为了反对苏联社会帝国主义及其蒙古修正主义走狗的威胁，有必要在蒙古地区重新利用中国人民解放军的力量，实行军事管辖以肃清间谍威胁。|很快，人民日报特约评论员“马辉腾”发表了一篇社论《边疆群众要拥护解放军，保卫祖国》。严厉批评了自治区内一小撮坏分子，试图背靠修正主义新沙皇，扛起红旗反红旗，离间各族人民群众乃至鼓动武装暴乱的反国家罪行。为此，中央组织了自治区内的各支部队，发挥团结各族人民的功能，以军队的纪律促生产，抓建设。很快，类似1967年的事情又在上演，随着军队接管各级政治机构，受到苏联和蒙古特务蛊惑的平民纷纷走上街去，公开打出了要军区司令员滚回北京的口号，拦车赴京上访。在最后演变成了在呼市等地的大规模暴乱，群众开始冲击军队驻地并公开和民兵以及一般士兵斗殴，拦截军车甚至抢劫军火库。事态严重失控的情况下，解放军设法保留了最大的克制————直到两名解放军士兵在出院买肉时被当街刺伤而流血致死。就此，事态已经开始无法收手，解放军不得不在各大城市和公社中开展宵禁，严格限制自治区的自由通行，同时安排军队眷属迁入内蒙古从事工业和农业生产活动。目前，已经有至少十五名蒙古间谍被抓捕。苏联和蒙古强烈谴责了我们的行径，称其为不亚于北洋匪帮的暴行。内蒙古的军管同时也敲打了各级自治区领导人一番，迫使他们重新考虑自己的政策。"
const TXT_62_R3 := "最终，中央重新考虑了内蒙古问题，并将给出公平公正的答复。国务院在决定重新调整内蒙古及临近省份的行政区划。人民日报特约评论员“马辉腾”发表了一篇社论《各族人民团结起来，为繁荣的边疆和巩固的边防而战斗》。其中高度强调了团结在我党周围的各民族爱国人民必须坚持维护国土完整统一；团结在党，国家和红旗之下，和狭隘民族主义与分裂主义斗争；并指出正是在我党的领导下，边疆各区获得了近千年以来未曾有的天翻地覆：不论是水利，电气还是政治生活的空前繁荣，正是我党的功劳。因此，这篇社论在最后提到了要结合我国实际国情，维护各族团结。借此机会，国务院公布了调整后的内蒙古行政区图，将呼伦贝尔、兴安等蒙东地区重新从东北三省划出，交还给内蒙古自治区。但是，中央依旧留了一个小心眼：蒙东四旗仅保留了名义上的治理权，其票证，教育乃至医疗体系仍然遵从东北三省的各级调度，沈阳军区也仍然负责当地的防御工作。并在蒙西地区大力鼓励汉族迁入，支持各级牧民加入集体化的养殖公社从而削弱可能的敌人渗透。有的干部觉得我们事实上创造了内蒙古自治区内部的分裂：行政中心蒙西和经济重心蒙东的对立对与当地的发展不见的是个好事。不过时间会告诉我们答案，至少人民群众没有什么反对态度。"
const TXT_62_R4 := "最终，中央决定重新考虑内蒙古问题，并给出公平公正的答复。国务院在决定恢复乌兰夫同志名誉的同时，决定重新调整内蒙古及临近省份的行政区划。人民日报特约评论员“马辉腾”发表了一篇社论《各族人民团结起来，为繁荣的边疆和巩固的边防而战斗》。其中高度强调了团结在我党周围的各民族爱国人民必须坚持维护国土完整统一；团结在党，国家和红旗之下，和狭隘民族主义与分裂主义斗争；并指出正是在我党的领导下，边疆各区获得了近千年以来未曾有的天翻地覆：不论是水利，电气还是政治生活的空前繁荣，正是我党的功劳。因此，这篇社论在最后提到了要结合我国实际国情，维护各族团结。借此机会，国务院公布了调整后的内蒙古行政区图，将呼伦贝尔、兴安等蒙东地区和阿拉善两旗重新从东北三省，甘肃和宁夏划出，交还给内蒙古自治区。行政机构的交接造成了一定的混乱，尤其是曾大力援助蒙东地区的东三省对这一决定高度不满。而且由于内蒙古的版图急速扩大导致北京军区难以形成完全的管辖，中央已经允许内蒙古地方从兰州和沈阳军区请求卫戍部队协助其进行边境管理。但问题远没有结束，全国人大还额外通报了对内蒙古自治区上层进行人事调动，为了贯彻落实民族区域自治制度体系，保障少数民族在国内的政治生活权力，内蒙古地区将把自治区高级干部和革命委员会中的蒙古族代表占比从55%增加到75%，同时内蒙古地区党委破天荒的由蒙古族担任，而不是按照以往的惯例由汉族担任。作为制衡，内蒙古自治区将作为全国首例开设“汉族自治地方”的省级行政单位。同时中央对内蒙古在60年代的动荡作出了最终判决：内蒙古问题在一小撮坏分子的错误鼓吹下，强行从群众之间矛盾上升为民族对立的问题，其中的冤假错案必须被悉数平反，中央已经派出专案组对此进行调查。乌兰夫也获准重新返回内蒙古自治区，协助自治区领导层展开行政工作。随着所谓“汉族地方自治机构”的出台，作为出头鸟的内蒙古问题将为我们打开处理新疆，西藏乃至全国少数族裔问题的一个大门……"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	d = p_ws.数值表
	match event_def.event_id:
		"anthem_problem":
			_prepare_61(event_def)
		"inner_mongolia_problem":
			_prepare_62(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"agricultural_reform": _event_53(option_index)
		"reform_investment": _event_54(option_index, context)
		"burmese_socialism": _event_55(option_index, context)
		"teach_vietnam_lesson": _event_56(option_index)
		"red_rising_sun": _event_57(option_index)
		"iranian_revolution_endgame": _event_58(context)
		"economic_union": _event_59(option_index, context)
		"military_alliance": _event_60(option_index, context)
		"anthem_problem": _event_61(option_index, context)
		"inner_mongolia_problem": _event_62(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_53(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 30,
				W.I_PEOPLE_SUPPORT: -30})
			_change_politicians_above(1, -100, 0)
		1:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_AGRICULTURE: 30,
				W.I_REFORM_MOMENTUM: 10, W.I_THOUGHT_FREEDOM: 30,
				W.I_DIPLO: -10, W.I_LIVING: 30, W.I_CORRUPTION: 20})
			_change_politicians({1: [100, 120], 2: [100, 120]})
		2:
			_add_data({W.I_PARTY_SUPPORT: -70, W.I_REFORM_MOMENTUM: 30,
				W.I_THOUGHT_FREEDOM: 50, W.I_PEOPLE_SUPPORT: 70, W.I_DIPLO: -20,
				W.I_BUDGET: 40, W.I_MANPOWER: -30, W.I_CORRUPTION: 30})
			_add_empire_relation(EmpireData.USA, 30)
			_change_politicians({
				0: [-250, -100], 2: [100, 150], 3: [200, 150],
			})
		3:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_BUDGET: -50,
				W.I_PEOPLE_SUPPORT: 70, W.I_LIVING: 30,
				W.I_AGRICULTURE: 50})
			_add_empire_relation(EmpireData.USSR, 50)
			_unlock_first_agri_tech()
			_subtract_faction_fraction(FactionData.MODERATE, 0.09)
			_subtract_faction_fraction(FactionData.REFORMIST, 0.50)
			_subtract_faction_fraction(FactionData.LIBERAL, 0.24)
			_change_politicians({
				0: [150, 120], 1: [-100, -80], 2: [-150, -100], 3: [-200, -150],
			})
	# 原版 Event53 末尾 old_modify_desc[15] 按农业路线/科技动态拼接，
	# 本端口建模说明（modifier_catalog 静态描述），仅保留原文备查，见文件底部注释。


func _event_54(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_DIPLO: 20,
				W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 80})
			_change_politicians({1: [-200, 0], 2: [-200, 0], 3: [-200, 0]})
			context["result_text"] = TXT_54_R0_A + _leader_name() + TXT_54_R0_B
		1:
			_add_data({W.I_BUDGET: 30, W.I_REFORM_MOMENTUM: 10,
				W.I_THOUGHT_FREEDOM: 70, W.I_DIPLO: -20, W.I_MANPOWER: -30})
			ws.数值表[W.I_REFORM_STAGE] = 3
			_add_empire_relation(EmpireData.USA, 100)
			ws.set_flag("sez", true)
			_change_politicians({1: [100, 120], 2: [150, 120]})
		2:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_REFORM_MOMENTUM: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_PEOPLE_SUPPORT: 30, W.I_DIPLO: -30,
				W.I_BUDGET: 50, W.I_MANPOWER: -70})
			ws.数值表[W.I_REFORM_STAGE] = 3
			_add_empire_relation(EmpireData.USA, 150)
			_subtract_faction_fraction(FactionData.MODERATE, 0.09)
			ws.set_flag("sez", true)
			_change_politicians({
				0: [-250, -100], 1: [-80, -50], 2: [50, 100], 3: [200, 150],
			})


func _event_55(option_index: int, context: Dictionary) -> void:
	var burma := ws.get_country_by_legacy_index(33)
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_BUDGET: -30, W.I_DIPLO: 10})
			_add_empire_relation(EmpireData.USA, -50)
			if burma != null:
				burma.set_tag("对华贸易", true)
			context["result_text"] = TXT_55_R1.replace("{0}{1}", _leader_name())
		2:
			_add_data({W.I_AGENTS: -50, W.I_DIPLO: 20})
			_add_empire_relation(EmpireData.USA, -80)
			if burma != null:
				# 原版 allcountries[33].parts[0]=false、prcpower=1000 建模说明，跳过。
				if ws.数值表[W.I_ECON_SYSTEM] <= 12:
					burma.government = 2
					burma.sub_government = 15
					context["result_text"] = TXT_55_R2_BASE + TXT_55_R2_SAN_YU
				else:
					burma.government = 0
					burma.sub_government = 7
					context["result_text"] = TXT_55_R2_BASE + TXT_55_R2_KHIN_NYUNT
				burma.set_tag("对华贸易", true)
				burma.set_tag("亲中", true)


func _event_56(option_index: int) -> void:
	var vietnam := ws.get_country_by_legacy_index(11)
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_INFLUENCE: -20})
			ws.set_flag("vietnam_peace", true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_WAR_PRESSURE: 200, W.I_DIPLO: 20})
			_add_empire_relation(EmpireData.USSR, -200)
			ws.war_state = 1
			var war := _war(1)
			if war != null:
				war.name_war = "中国柬埔寨－越南战争"
				war.side1 = "中国-柬埔寨"
			if vietnam != null:
				vietnam.set_tag("对华贸易", true)
		# 原版 Event56 只有 2 个选项；旧 Godot 自造的“峰会”选项（result 2）已删除。


func _event_57(option_index: int) -> void:
	if option_index != 1:
		return
	_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 20,
		W.I_BUDGET: -40, W.I_AGENTS: -60})
	_add_empire_relation(EmpireData.USA, -150)
	var japan := ws.get_country_by_legacy_index(44)
	if japan != null:
		japan.government = 2
		japan.sub_government = 8
		japan.set_tag("亲美", false)
		japan.set_tag("对华贸易", true)


func _event_58(context: Dictionary) -> void:
	# 原版 Event58.cs:43-103 只有一个结果选项，且只按 data[42]>data[43] 两分支。
	var left := ws.数值表[W.I_IRAN_LEFT_SUPPORT]
	var shah := ws.数值表[W.I_IRAN_SHAH_SUPPORT]
	var iran := ws.get_country_by_legacy_index(8)
	if left > shah:
		_add_empire_power(EmpireData.USA, -10)
		if iran != null:
			iran.government = 2       # 原版 Gosstroy=2（Event58.cs:47）
			iran.sub_government = 8   # 原版 SubGosstroy=8（Event58.cs:48）
			iran.set_tag("亲美", false)   # 原版 Vyshi=false
			iran.set_tag("sento", false)  # 原版 isSENTO=false
			iran.set_tag("asean", false)  # 原版 isASEAN=false
			if iran.development == 1:
				iran.set_tag("对华贸易", true)  # 原版 dev==1 → Torg=true
		if ws.数值表.size() > W.I_IRAN_ISLAMIST_SUPPORT:
			ws.数值表[W.I_IRAN_ISLAMIST_SUPPORT] = 500  # 原版 data[45]=500
		if ws.数值表.size() > 143:
			ws.数值表[143] += 10
		# 原版 event_done[36] && resultOfEvents[36]==3 → allcountries[14].prcpower+=20；
		# 事件 36 移植说明，跳过。
		context["result_text"] = TXT_58_R_LEFT
	else:
		_add_empire_power(EmpireData.USA, 10)
		if iran != null and iran.development == 0:
			iran.set_tag("对华贸易", true)  # 原版 dev==0 → Torg=true
		if ws.数值表.size() > 143:
			ws.数值表[143] -= 7
		context["result_text"] = TXT_58_R_SHAH
	ws.set_flag("iran_revolution_started", false)


func _event_59(option_index: int, context: Dictionary) -> void:
	var china := ws.get_country_by_legacy_index(1)
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 30,
				W.I_PEOPLE_SUPPORT: 80, W.I_THOUGHT_FREEDOM: 50, W.I_BUDGET: -80})
			_add_empire_relation(EmpireData.USSR, -100)
			_add_empire_relation(EmpireData.USA, -100)
			ws.数值表[44] = 1  # 原版 data[44]=1（ECO 计时标记）
			_set_modifier_active(8, true)
			if china != null:
				china.set_tag("econ", true)
				china.social_stability = 1000
			var names: Array[String] = []
			for country in ws.countries:
				if country == null or not _in_original_econ_range(country):
					continue
				if country.has_tag("亲中") and not country.has_tag("亲美") and not country.has_tag("亲苏"):
					country.set_tag("econ", true)
					country.social_stability = 1000
					names.append(country.name)
			_change_all_politicians(100, 0)
			context["result_text"] = TXT_59_R1_BASE + _join_names(names)
		2:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_INFLUENCE: -30,
				W.I_THOUGHT_FREEDOM: 100})
			_add_empire_relation(EmpireData.USSR, 200)
			_add_empire_relation(EmpireData.USA, -200)
			_add_empire_power(EmpireData.USSR, 30)
			if china != null:
				china.stability = 1
				china.set_tag("sev", true)
			if ws.数值表[W.I_ALBANIA_BREAK] == 0:
				var albania := ws.get_country_by_legacy_index(20)
				if albania != null:
					albania.set_tag("亲中", false)
					albania.set_tag("econ", false)
					albania.set_tag("对华贸易", false)
					albania.set_tag("okb", false)
			for country in ws.countries:
				if country == null:
					continue
				var had_econ := country.has_tag("econ")
				country.set_tag("econ", false)
				if had_econ and (country.has_tag("亲苏") or country.has_tag("苏联盟友")
						or country.has_tag("亲中") or country.government == 1
						or (country.government == 2 and not country.has_tag("美国盟友")
							and not country.has_tag("亲美"))):
					country.set_tag("sev", true)
			_change_politicians({2: [-200, 0], 3: [-200, 0]})
		3:
			_add_data({W.I_PARTY_SUPPORT: -300, W.I_BUDGET: -20, W.I_INFLUENCE: -20})
			var country15 := ws.get_country_by_legacy_index(15)
			if country15 != null:
				country15.内战中 = true


func _event_60(option_index: int, context: Dictionary) -> void:
	if option_index != 0:
		return
	_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 20,
		W.I_PEOPLE_SUPPORT: 80, W.I_BUDGET: -50, W.I_AGENTS: -100,
		W.I_ARMY: -300})
	_add_empire_relation(EmpireData.USA, -200)
	_add_empire_relation(EmpireData.USSR, -200)
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china.set_tag("okb", true)
	var country15 := ws.get_country_by_legacy_index(15)
	if country15 != null:
		country15.内战中 = false
	_set_modifier_active(59, true)
	var names: Array[String] = []
	for country in ws.countries:
		if country == null:
			continue
		if not _in_original_military_range(country):
			continue
		if country.has_tag("亲中") and country.has_tag("econ") \
				and not country.has_tag("亲美") and not country.has_tag("亲苏"):
			if country.social_stability <= 0:
				country.social_stability = 1000
			country.set_tag("okb", true)
			if country.has_tag("sev"):
				country.set_tag("sev", false)
				country.set_tag("econ", true)
			names.append(country.name)
	_change_all_politicians(100, 0)
	context["result_text"] = TXT_60_R0_BASE + _join_names(names) + TXT_60_R0_TAIL
	# 原版 Event60 的 old_modify_desc[59] 动态描述（按联盟成员统计）建模说明，
	# 原文备查见文件底部注释。


func _event_61(option_index: int, context: Dictionary) -> void:
	var anthem := int(ws.数值表[185])
	var num := option_index + 1
	if num == anthem:
		context["result_text"] = TXT_61_R_KEEP
		return
	match option_index:
		0:
			_add_data({W.I_PEOPLE_SUPPORT: 10, W.I_PARTY_SUPPORT: 10})
		1:
			pass
		2:
			_add_data({W.I_PARTY_SUPPORT: -20, W.I_PEOPLE_SUPPORT: 20})
		3:
			_add_data({W.I_DIPLO: 50})
			ws.influence_prc += 5
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, -100)
		4:
			pass
		5:
			pass
	ws.数值表[185] = num
	_add_data({W.I_MANPOWER: 30, W.I_PEOPLE_SUPPORT: 100,
		W.I_PARTY_SUPPORT: 50, W.I_BUDGET: -30})
	# 原版 AnthemCooldownTime = 4（四年一次国策冷却）；本版无该字段，跳过。
	match option_index:
		0:
			context["result_text"] = TXT_61_R_INTRO + TXT_61_R0
		1:
			context["result_text"] = TXT_61_R_INTRO + TXT_61_R1
		2:
			context["result_text"] = TXT_61_R_INTRO + TXT_61_R2
		3:
			var r3 := _fmt_leader(TXT_61_R3)
			if int(ws.completed_event_ids.get("event_668", -1)) == 0:
				r3 = r3.replace("2", TXT_61_R3_ROCK)
			else:
				r3 = r3.replace("2", "")
			context["result_text"] = TXT_61_R_INTRO + r3
		4:
			if _mod_active(3) and _mod_active(6):
				context["result_text"] = TXT_61_R_INTRO + TXT_61_R4_A
			elif not _mod_active(3) and _mod_active(6):
				context["result_text"] = TXT_61_R_INTRO + TXT_61_R4_B
			else:
				context["result_text"] = TXT_61_R_INTRO + TXT_61_R4_C
		5:
			var r5 := TXT_61_R5
			if ws.leader != null and ws.leader.name_display.begins_with("华"):
				r5 += TXT_61_R5_HUA
			context["result_text"] = TXT_61_R_INTRO + r5


func _event_62(option_index: int, context: Dictionary) -> void:
	var inner_mongolia := ws.get_country_by_legacy_index(9)
	match option_index:
		0:
			_add_data({W.I_BUDGET: -30, W.I_PARTY_SUPPORT: 50,
				W.I_THOUGHT_FREEDOM: 50, W.I_PEOPLE_SUPPORT: -30,
				W.I_WAR_SUPPORT: 20, W.I_DIPLO: 30})
			_add_empire_relation(EmpireData.USSR, -30)
			_change_politicians({0: [0, 100], 20: [0, 100]})
			context["result_text"] = TXT_62_R0
		1:
			_add_data({W.I_BUDGET: -50, W.I_PARTY_SUPPORT: -70,
				W.I_PEOPLE_SUPPORT: 50, W.I_WAR_SUPPORT: -30,
				W.I_REFORM_MOMENTUM: 20})
			_add_empire_relation(EmpireData.USSR, 30)
			context["result_text"] = TXT_62_R1
		2:
			_add_data({W.I_ARMY: -50, W.I_PEOPLE_SUPPORT: -100,
				W.I_WAR_SUPPORT: 100, W.I_DIPLO: 100,
				W.I_REFORM_MOMENTUM: -10})
			_add_empire_relation(EmpireData.USSR, -100)
			if inner_mongolia != null:
				inner_mongolia.set_tag("对华贸易", false)
			context["result_text"] = TXT_62_R2
		3:
			_add_data({W.I_PARTY_SUPPORT: 30, W.I_THOUGHT_FREEDOM: 30})
			_add_empire_relation(EmpireData.USSR, 20)
			_change_politicians({1: [0, 100], 2: [0, 100], 20: [0, 100]})
			context["result_text"] = TXT_62_R3
		4:
			_add_data({W.I_BUDGET: -80, W.I_PARTY_SUPPORT: -50,
				W.I_PEOPLE_SUPPORT: 50, W.I_WAR_SUPPORT: -50,
				W.I_REFORM_MOMENTUM: 30})
			_add_empire_relation(EmpireData.USSR, 50)
			if int(ws.数值表[W.I_TERRITORY]) < 23:
				ws.数值表[W.I_TERRITORY] += 1
			context["result_text"] = TXT_62_R4
	# 原版 NumberOfPolitician(58,85)（乌兰夫）在 Godot 政治家表无 name_1/name_2 索引，相关忠诚/权力/死亡效果移植说明。


func _in_original_econ_range(country: CountryData) -> bool:
	if country == null:
		return false
	var id := country.原版序号
	if id < 7 or id > 52:
		return false
	return id != 52 and id != 35 and id != 24 and id != 25 and id != 40 \
			and id != 30 and id != 14 and id != 13 and id != 36 and id != 44


func _in_original_military_range(country: CountryData) -> bool:
	if country == null:
		return false
	var id := country.原版序号
	if id < 8 or id > 51:
		return false
	return id != 41 and id != 42 and id != 45 and id != 35 and id != 40 \
			and id != 30 and id != 14 and id != 13 and id != 36 and id != 18 and id != 21


func _join_names(names: Array[String]) -> String:
	var result := ""
	for n in names:
		result += "，" + n
	return result


func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _war(index: int) -> WarData:
	return ws.wars[index] if index >= 0 and index < ws.wars.size() else null


func _unlock_first_agri_tech() -> void:
	for i in [0, 1, 2]:
		if ws.techs != null and i < ws.techs.unlocked.size() and not ws.techs.unlocked[i]:
			ws.techs.unlocked[i] = true
			return


func _set_modifier_active(modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


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


func _change_politicians_above(min_personality: int, loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and politician.trait_personality > min_personality:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


func _change_all_politicians(loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


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


## 原版 Event53 old_modify_desc[15] 备查（去空格/剥 color/||→\n 后逐字）：
## 根据农业发展情况获得效果
## |“上山下乡”政策及其后果|农业+0.1，科技点-1，思想自由化+0.4
## |社会转型阵痛|生活水平-0.1，思想自由化+0.2
## |社会主义新农村|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4
## |“牛棚”群岛|预算+0.1，农业+0.1，特勤网络-0.2，思想自由化-0.2，外交声誉+0.4，科技点-1，与美国关系-1，与苏联关系-1
## |人心思变|农业-0.1，思想自由化+0.3
## |乡村建设理论|预算-0.6，农业+0.2，生活水平+0.2，思想自由化-0.4
## |长期乡建合同|预算+0.2，农业+0.3，工业+0.1，服务业+0.1，生活水平+0.1，思想自由化+1.2，外交声誉-0.2，与美关系+0.2，美国国际影响力+0.1，中国国际影响力-0.1
## |“新”新村运动|预算-0.4，农业+0.3，服务业+0.1，生活水平+0.1，特勤网络+0.1，思想自由化-0.1
## |新乔治主义社会|预算+0.3，农业+0.5，工业-0.4，服务业-0.2，生活水平-0.1，思想自由化+0.2
## |社会主义新农村|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4
## |水稻共和国|预算+1，农业+0.3，工业+0.2，生活水平-0.6，人民支持度-1.0，思想自由化+1.0，与美关系+0.2，与苏关系+0.2，国际影响力-0.1
## |缓慢推进集体化的公社：|农业+0.1，工业+0.1，生活水平+0.2，预算+0.1
## |家庭联产承包责任制：|预算+0.4，腐败+0.3|若福利投资低于20，则农业-0.2，生活水平-0.2，服务业-0.2|若福利投资高于20，则农业+0.2，生活水平+0.2，服务业+0.2
## |私人农场：|农业-0.4，生活水平-0.4，预算+1.0，服务业+0.2，腐败+0.4，寡头+4
## |快速推进集体化的公社：|农业+0.4，工业+0.4，生活水平+0.4，预算+0.2
## |农业机械化：|农业+0.6，工业+0.4
## |普及化肥与杀虫剂：|农业+0.3，生活水平+0.4
## |转基因技术：|农业+0.2，工业+0.2，生活水平+0.5，预算+0.3
##
## 原版 Event60 old_modify_desc[59] 备查（动态数值用 {0}{1}{2}{3} 表示）：
## 集体安全联盟：|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |非洲联盟:|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |阿拉伯革命同盟:|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |阿拉伯联合共和国:|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}
## |革命国际主义运动：|军事力量+{0}.{1}；特工网络+{2}.{3}；干涉点数+{4}.{5}

func _prepare_61(event_def: EventDef) -> void:
	if event_def.options.size() < 6:
		return
	var opts := event_def.options
	event_def.title = TXT_61_TITLE
	if ws.completed_event_ids.has("anthem_problem"):
		event_def.description = _fmt_leader(TXT_61_DESC_AGAIN)
	else:
		event_def.description = _fmt_leader(TXT_61_DESC)
	var anthem := int(ws.数值表[185])
	var m3 := _mod_active(3)
	var m6 := _mod_active(6)
	var china := ws.get_country_by_legacy_index(1)
	var rim := china != null and china.has_tag("rim")
	var socialism := china != null and china.government == 1
	if m6 and int(ws.数值表[W.I_POLITICAL_LINE]) <= 2 and anthem != 1:
		_enable(opts[0], TXT_61_OPT0)
	elif anthem == 1:
		_enable(opts[0], TXT_61_OPT0_KEEP)
	else:
		_disable(opts[0], TXT_61_OPT0_DIS)
	if not m3 and anthem != 2:
		_enable(opts[1], TXT_61_OPT1)
	elif anthem == 2:
		_enable(opts[1], TXT_61_OPT1_KEEP)
	else:
		_disable(opts[1], TXT_61_OPT1_DIS)
	if m3 and m6 and anthem != 3:
		_enable(opts[2], TXT_61_OPT2)
	elif anthem == 3:
		_enable(opts[2], TXT_61_OPT2_KEEP)
	else:
		_disable(opts[2], TXT_61_OPT2_DIS)
	if rim and m3 and m6 and socialism and anthem != 4:
		_enable(opts[3], TXT_61_OPT3)
	elif anthem == 4:
		_enable(opts[3], TXT_61_OPT3_KEEP)
	else:
		_disable(opts[3], TXT_61_OPT3_DIS)
	if anthem != 5:
		_enable(opts[4], TXT_61_OPT4)
	else:
		_enable(opts[4], TXT_61_OPT4_KEEP)
	if anthem != 6:
		_enable(opts[5], TXT_61_OPT5)
	else:
		_enable(opts[5], TXT_61_OPT5_KEEP)


func _prepare_62(event_def: EventDef) -> void:
	if event_def.options.size() < 5:
		return
	var opts := event_def.options
	event_def.title = TXT_62_TITLE
	event_def.description = _fmt_leader(TXT_62_DESC)
	var line := int(ws.数值表[W.I_POLITICAL_LINE])
	var ps := int(ws.数值表[W.I_PARTY_SYSTEM])
	var summa := _summa_3_2()
	if _mod_active(3) or (line < 3 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[0], TXT_62_OPT0)
	else:
		_disable(opts[0], TXT_62_OPT0_DIS)
	if not _mod_active(3) and (line == 4 or ws.global_flags.get("relres", false) or _empire_relation(EmpireData.USSR) >= 500) and ((line > 0 and ps < 8) or (summa > 66 and ps > 7)):
		_enable(opts[1], TXT_62_OPT1)
	elif not ws.global_flags.get("relres", false) and _empire_relation(EmpireData.USSR) < 500:
		_disable(opts[1], TXT_62_OPT1_DIS1)
	else:
		_disable(opts[1], TXT_62_OPT1_DIS2)
	if (line < 4 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[2], TXT_62_OPT2)
	else:
		_disable(opts[2], TXT_62_OPT2_DIS)
	if (line < 4 and line > 0 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[3], TXT_62_OPT3)
	elif line == 0:
		_disable(opts[3], TXT_62_OPT3_DIS1)
	else:
		_disable(opts[3], TXT_62_OPT3_DIS2)
	if not _mod_active(3) and (line == 4 or ws.global_flags.get("relres", false) or _empire_relation(EmpireData.USSR) >= 500) and ((line > 0 and ps < 8) or (summa > 66 and ps > 7)):
		_enable(opts[4], TXT_62_OPT4)
	else:
		_disable(opts[4], TXT_62_OPT4_DIS)


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


func _legacy_cond(max_line_exclusive: int) -> bool:
	var line := int(ws.数值表[W.I_POLITICAL_LINE])
	var ps := int(ws.数值表[W.I_PARTY_SYSTEM])
	return (line < max_line_exclusive and ps < 8) or (_summa_3_2() > 66 and ps > 7)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _empire_relation(empire_index: int) -> int:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		return int(ws.empires[empire_index].relations)
	return 0


func _fmt_leader(text: String) -> String:
	var n := _leader_name()
	return text.replace("{0}{1}", n).replace("{0}", n).replace("{1}", n)


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


