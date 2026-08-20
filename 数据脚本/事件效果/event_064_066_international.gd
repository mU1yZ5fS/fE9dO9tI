extends "res://数据脚本/event_script_base.gd"

## 原作事件 64–66：泛阿拉伯统一、莫斯科奥运会与铁托逝世。
## 来源：TimeScript.cs:3890-3918，doneventscript.cs:1523-1636，
##       Results_text.cs:5429-5690。



## 事件 64–66 逐字中文文案。
## 来源：Event64.cs / Event65.cs / Event66.cs。
## 说明：{0}{1} 为原版领袖姓名字段占位，显示前由 _fmt_leader() 替换为 name_display。

const TXT_64_TITLE_SOC := "统一，解放，社会主义！"
const TXT_64_DESC_SOC := "殖民时代以来，阿拉伯地区就被帝国主义列强和封建主义当权者瓜分，特别是在帝国主义的“尺规作图”下，阿拉伯各国被他们用笔直的国境线人为分割开来。过去，阿拉伯民族资产阶级在民族革命后做出了许多重新统一阿拉伯的尝试——阿拉伯联合共和国（1958-1961）、阿拉伯合众国（1958-1961）、阿拉伯共和国联邦（1972-1977）、阿拉伯共和国联盟（1972）和阿拉伯伊斯兰共和国（1974）等。随着复兴党左右两翼的分裂（叙利亚支部和伊拉克支部的分裂）和第三次中东战争的惨败，在阿拉伯社会主义的旗帜下追求阿拉伯民族解放和统一的道路已经逐渐走向破产，而埃及和利比亚两国的决裂更是为这一道路敲响了丧钟。此后，以乔治·哈巴什为代表的一群阿拉伯民族主义者逐渐激进化，转向科学社会主义，在马列主义的旗帜下进行追求阿拉伯民族的解放和统一，掀起了新一轮阿拉伯革命的高潮。如今，大部分阿拉伯国家的反共社会民族主义政权都已倒台，被真正的科学社会主义政权取而代之，新生的各个革命阿拉伯国家意识到，只有在“统一，解放，社会主义”的口号下，互助和共建革命的社会主义，才能在多重势力的觊觎下生存下来。同时，基于意识形态和现实需要，他们也决定逐渐消除殖民者强加在阿拉伯民族头上的国界，在阿拉伯无产阶级的团结下联合起来。"
const TXT_64_TITLE := "泛阿拉伯主义"
const TXT_64_DESC := "自从外国人在中东实行殖民统治以来，阿拉伯统治者和知识分子就一直在考虑建立一个中东所有阿拉伯人的联合国。它反映在由叙利亚和埃及组成的阿拉伯联合共和国，该国在1958年到1971年间一直存在着，但是，由于著名的泛阿拉伯主义者埃及总统纳赛尔努力增强埃及在联合共和国中的权力，叙利亚于1961年退出了该国。随后，在1971年，埃及、叙利亚和利比亚成立了阿拉伯共和国联邦。然而，参与国之间存在矛盾，主要是由纳赛尔之后的萨达特埃及开始实行的自由亲西方政策引起的。但是现在，当萨达特被暗杀后，在埃及，老总统纳赛尔的支持者上台执政，多亏了阿拉伯共和国联邦直到现在还正式存在着，合并其他阿拉伯国家的想法重新占据了统治圈的头脑。此外，7月30日，以色列宣布耶路撒冷为“以色列永恒不可分割的首都”，这引起了阿拉伯世界的不满浪潮，这提供了另一个为了联合起来对付共同的敌人的正当理由。在对埃及给予了一些物质援助并加大了清除对这一发展不满的人的力度之后，我们可以恢复阿拉伯联合共和国，这将极大改变中东地区的权力平衡，并得到一个有价值的盟友。当然，他们会听我们的话的…"
const TXT_64_OPT0_SOC := "统一，解放，社会主义！彻底走向独立和革命的阿拉伯民族万岁！"
const TXT_64_OPT0 := "阿拉伯联合？不值得我们为此做无用功"
const TXT_64_OPT1 := "协助重建阿拉伯联合共和国（需要7百万元预算，5特工网络）"
const TXT_64_OPT1_DIS_AGENTS := "需要5特工网络..."
const TXT_64_OPT1_DIS_REL := "还未恢复与苏联的关系..."
const TXT_64_OPT1_DIS_OTHER := "他们自己都不同意重走纳赛尔主义之路，我们又能帮到啥？"
const TXT_64_R_SOC := "各个革命的社会主义阿拉伯国家举行了一场历史性会议，他们决定成立一个吸收了此前各个泛阿拉伯项目的经验和教训的，参考欧洲经济共同体、经济互助委员会以及共产党和工人党情报局的制度的邦联式的阿拉伯革命社会主义共和国联盟，联盟具有单一货币、军队，联合协商的外交政策，以及经济政治一体化的前景。新国家宣布了对马克思列宁主义原则的忠诚和继续组建所有阿拉伯人的单一革命国家的需要，这刺激了以色列，以色列向美国要求额外的军事援助。苏联对此较为忌惮——这些组成国推翻了此前他们支持的社会民族主义政权，但又打着共产主义旗号，这无疑是在打苏联的脸；美国也对中东出现了一个能挑战他们霸权的共产主义对手十分愤怒。"
const TXT_64_R0 := "什么都没有发生。阿拉伯国家仍然很分散，这给亲美的以色列带来了优势。"
const TXT_64_R1 := "多亏了我们情报部门的干预，大多数联盟的反对者都被瓦解了，我们调节阿拉伯国家统一的意愿，以及发展联合国家的免费援助最终使得谈判达成协议。8月，埃及，利比亚，和叙利亚在开罗举行了历史性会议，决定成立邦联式的阿拉伯联合共和国，国家具有单一货币，军队，联合解决外交政策，以及经济政治一体化的前景。新国家宣布了对阿拉伯社会主义原则的忠诚，和继续组建所有阿拉伯人的单一国家的需要，这刺激了以色列，以色列向美国要求额外的军事援助。苏联欢迎阿拉伯联合共和国的创立，但美国对中东出现了一个挑战他们霸权的强大对手并不开心。"

## 原版 socialist 分支写入 old_modify_texts[46] 与 old_modify_desc[46] 的文案（本版 ModifierCatalog 动态生成，故仅留存溯源）。
const TXT_64_MOD_TITLE := "阿拉伯革命社会主义共和国联盟"
const TXT_64_MOD1 := "集体安全联盟：|军事力量+"
const TXT_64_MOD2 := "；特工网络+"
const TXT_64_MOD3 := "；干涉点数+"
const TXT_64_MOD4 := "|非洲联盟:|军事力量+"
const TXT_64_MOD5 := "；特工网络+"
const TXT_64_MOD6 := "；干涉点数+"
const TXT_64_MOD7 := "|阿拉伯革命同盟:|军事力量+"
const TXT_64_MOD8 := "；特工网络+"
const TXT_64_MOD9 := "；干涉点数+"
const TXT_64_MOD10 := "|阿拉伯联合共和国:|军事力量+"
const TXT_64_MOD11 := "；特工网络+"
const TXT_64_MOD12 := "；干涉点数+"
const TXT_64_MOD13 := "|革命国际主义运动：|军事力量+"
const TXT_64_MOD14 := "；特工网络+"
const TXT_64_MOD15 := "；干涉点数+"

const TXT_65_TITLE := "再见，我们亲爱的米沙…"
const TXT_65_DESC := "主席同志！1980年7月19日，第二十二届夏季奥运会开幕式将在莫斯科举行。苏联奋力争取到了奥运会主办权，在准备中花费了巨额资金，这些资金不得不从其他支出项目中提取（为了收回成本，苏联进行了大规模的奥运标志销售运动）。然而，美国领导层已经公开宣布抵制这届运动会，并呼吁其所有盟友也参加抵制，在费城组织所谓的“奥林匹克抵制运动会”（更广为人知的是“自由钟经典运动会”）。一些党员敦促我们以美国为榜样，派一支队伍去参加美国的运动会，抵制苏联的奥运会，但这会引起苏联的愤怒和人民的误解。也许你不应该加剧分裂，把我们的运动员送到莫斯科，尽管我们国家之间存在政治矛盾？体育无关政治，不是吗…"
const TXT_65_DESC_GANEFO := "然而，一些党员回顾了1963年新兴力量运动会的经验（印度尼西亚总统苏加诺在我们的财政援助下举办的“第三世界”国家的替代性奥运会），建议我们重振这一赛事，并向苏联和美国表明，我们在体育运动中能够独立于它们。"
const TXT_65_OPT0 := "体育运动无关政治！我们将参加莫斯科奥运会并派出最好的运动员！（需要4百万预算）"
const TXT_65_OPT0_DIS := "我们不能忽视西方的意见"
const TXT_65_OPT1 := "我们不宣布抵制，但忽略这两场运动会…"
const TXT_65_OPT1_DIS := "我们不能同时忽视这两场运动会！"
const TXT_65_OPT2 := "我们宣布抵制，但让我们的运动员举着奥运会旗去莫斯科（需要4百万元预算）。"
const TXT_65_OPT2_DIS := "这不是我们的政策！"
const TXT_65_OPT3 := "我们宣布抵制苏联运动会，并将参赛队伍队派往美国（需要3百万预算）"
const TXT_65_OPT3_DIS := "去美国？！你是认真的吗？…"
const TXT_65_OPT4 := "复兴新兴力量运动会（GANEFO），向发展中国家发出邀请（需要10百万预算）"
const TXT_65_OPT4_DIS := "毛派的社会实验已经够多了！"

const TXT_65_R0A := "同志拒绝了抵制莫斯科奥运会的提议，称其为“美国的挑衅”。他亲自打电话给勃列日涅夫，说：“中国决不会加入美国的抵制运动，将会把代表团派往莫斯科”，并祝苏联运动员好运。这位受到感动的苏联领导人对此表示，希望亲自与"
const TXT_65_R0B := "同志在开幕典礼上会面并祝中国队取得胜利。最后，63个国家宣布抵制莫斯科奥运会－美国和其卫星国，以及"
const TXT_65_R_IRAN := "伊朗，"
const TXT_65_R_TAIL := "莫桑比克和卡塔尔的代表团拒绝参加奥运会，英格兰、法国、意大利和西班牙被给予权利决定以自己名义派出运动员，或者以奥委会名义派出运动员（最终，他们都派出了代表团）。在开幕仪式上国际奥委会主席迈克尔·莫里斯在勃列日涅夫发言前，特别感谢了那些不顾抵制，自愿来参加的运动员。中国队得了第三名，获得了35金、30银、38铜的成绩，还破了几项世界纪录。冠亚军是苏联和民主德国。这届奥运会将以历史上组织最出色的奥运会被人们铭记，以及最难忘的闭幕式—奥运会的象征－小熊米沙—伴着阿·巴赫慕托娃和尼·多布朗拉沃夫的歌曲《告别莫斯科》飞上天空。很多人（甚至是外国人）都忍不住流下了眼泪—这是如此的感染人心。在闭幕式上，升起了洛杉矶市旗，而不是美国国旗（下届奥运会举办国），暗示着苏联并没有忘记抵制运动…"
const TXT_65_R1A := "当苏联和美国在国际奥委会中相互威胁、相互抱怨时，中国——出乎意料的是，对每个人来说——却完全忽视了这两届奥运会。对于国际奥委会因莫斯科缺少中国运动员而提出的要求完全困惑，华国锋和中华人民共和国奥委会主席钟世通提到了中国财政困难的状况，这不允许我们参加奥运会。我们在那里的解释似乎引起了强烈的怀疑，但我们收到了一个官方警告——抵制洛杉矶奥运会自动剥夺了我们在国际奥委会的成员资格。人民也不明白为什么国家领导层对奥运会没有反应。最后，63个国家宣布抵制奥运会－美国及其卫星国，以及"
const TXT_65_R_TAIL1 := "莫桑比克和卡塔尔拒绝参加奥运会，英格兰、法国、意大利和西班牙被给予权利决定以自己名义派出运动员，或者以奥委会名义派出运动员（最终，他们都派出了代表团）。在开幕仪式上国际奥委会主席迈克尔·莫里斯在勃列日涅夫发言前，特别感谢了那些不顾抵制，自愿来参加的运动员。这届奥运会将以历史上组织最出色的奥运会被人们铭记，以及最难忘的闭幕式—奥运会的象征－小熊米沙—伴着阿·巴赫慕托娃和尼·多布朗拉沃夫的歌曲《告别莫斯科》飞上天空。很多人（甚至是外国人）都忍不住流下了眼泪—这是如此的感染人心。在闭幕式上，升起了洛杉矶市旗，而不是美国国旗（下届奥运会举办国），暗示着苏联并没有忘记抵制运动…"
const TXT_65_R2A := "中国加入了美国对莫斯科奥运会的抵制，尽管并非毫不犹豫——中国奥委会刚刚在国际奥委会注册，现在完全不希望破坏与它的关系。因此，主席提出由奥委会主席钟世通自行决定是否派一支队伍去莫斯科。在与国际奥委会和美国、意大利、法国、西班牙和英联邦磋商后，他同意以国际奥委会的名义将中国代表团派往莫斯科。最后，63个国家宣布抵制-美国及其卫星国，以及"
const TXT_65_R2_TAIL := "莫桑比克和卡塔尔拒绝参加奥运会，英格兰、法国、意大利和西班牙被给予权利决定以自己名义派出运动员，或者以奥委会名义派出运动员（最终，他们都派出了代表团）。在开幕仪式上国际奥委会主席迈克尔·莫里斯在勃列日涅夫发言前，特别感谢了那些不顾抵制，自愿来参加的运动员。这届奥运会将以历史上组织最出色的奥运会被人们铭记，以及最难忘的闭幕式—奥运会的象征－小熊米沙—伴着阿·巴赫慕托娃和尼·多布朗拉沃夫的歌曲《告别莫斯科》飞上天空。很多人（甚至是外国人）都忍不住流下了眼泪—这是如此的感染人心。在闭幕式上，升起了洛杉矶市旗，而不是美国国旗（下届奥运会举办国），暗示着苏联并没有忘记抵制运动…|我们也派我们的队伍参加了费城的另一场比赛，在那里我们获得了5枚金牌、1枚银牌和4枚铜牌。"
const TXT_65_R3A := "中国加入了美国对莫斯科奥运会的抵制，尽管并非毫不犹豫——中国奥委会刚刚在国际奥委会注册，现在完全不希望破坏与它的关系。然而，主席决定派出中国队前往费城参加美国的“替代”运动会“自由钟”。中华人民共和国奥委会主席钟世通反对这一决定，因此他被开除出党并被撤职，取而代之的是更忠诚的李梦华。我们的队伍名列第三，输给了美国和德国，获得了5枚金牌、1枚银牌和4枚铜牌。最后，63个国家宣布抵制-美国及其卫星国，以及"
const TXT_65_R3_TAIL := "莫桑比克和卡塔尔拒绝参加奥运会，英格兰、法国、意大利和西班牙被给予权利决定以自己名义派出运动员，或者以奥委会名义派出运动员（最终，他们都派出了代表团）。在开幕仪式上国际奥委会主席迈克尔·莫里斯在勃列日涅夫发言前，特别感谢了那些不顾抵制，自愿来参加的运动员。这届奥运会将以历史上组织最出色的奥运会被人们铭记，以及最难忘的闭幕式—奥运会的象征－小熊米沙—伴着阿·巴赫慕托娃和尼·多布朗拉沃夫的歌曲《告别莫斯科》飞上天空。很多人（甚至是外国人）都忍不住流下了眼泪—这是如此的感染人心。在闭幕式上，升起了洛杉矶市旗，而不是美国国旗（下届奥运会举办国），暗示着苏联并没有忘记抵制运动…"
const TXT_65_R4A := "主席同志和中华人民共和国奥委会主席钟世通都支持党员们的想法。我们决定恢复“新兴力量运动会”。全国人大常委会决定于11月在宁波市举办运动会，并向“第二世界”、“第三世界”各国发出邀请。"
const TXT_65_R4_GOOD := "令我们大为吃惊的是，我们邀请的所有国家都同意参加新的运动会——此外，苏联和美国的国家奥委会与中华人民共和国奥委会就运动员的参赛事宜进行了接触（当然不是第一梯队，但是尽管如此……）。比赛会很紧张，赶紧让我们的运动员开始训练…"
const TXT_65_R4_MID := "几乎所有不结盟运动的国家，包括南斯拉夫，都同意参加。这将是一场紧张刺激的比赛！…"
const TXT_65_R4_BAD := "不幸的是，只有16个军事和准军事政权的非洲国家同意参与。当然，我们的团队将获得第一名，但这将是完全无趣的！"
const TXT_65_R4_TAILA := "最后，63个国家宣布抵制-美国及其卫星国，以及"
const TXT_65_R4_TAIL := "莫桑比克和卡塔尔拒绝参加奥运会，英格兰、法国、意大利和西班牙被给予权利决定以自己名义派出运动员，或者以奥委会名义派出运动员（最终，他们都派出了代表团）。在开幕仪式上国际奥委会主席迈克尔·莫里斯在勃列日涅夫发言前，特别感谢了那些不顾抵制，自愿来参加的运动员。这届奥运会将以历史上组织最出色的奥运会被人们铭记，以及最难忘的闭幕式—奥运会的象征－小熊米沙—伴着阿·巴赫慕托娃和尼·多布朗拉沃夫的歌曲《告别莫斯科》飞上天空。很多人（甚至是外国人）都忍不住流下了眼泪—这是如此的感染人心。在闭幕式上，升起了洛杉矶市旗，而不是美国国旗（下届奥运会举办国），暗示着苏联并没有忘记抵制运动…"

const TXT_66_TITLE := "在铁托之后——铁托啊！"
const TXT_66_DESC_P1 := "1980年1月3日，南斯拉夫社会主义联邦共和国的创始人、长期领导人、南斯拉夫共产主义者联盟中央委员会主席约瑟普·布罗兹·铁托元帅在卢布尔雅那的临床中心住院检查腿部血管。经过两次手术和左腿截肢，他的病情有所好转，但在2月份，铁托患上了肺炎：高烧和胃、肠、肺出血也导致败血症，3月份病情加重。今天走向了终结——贝尔格莱德时间15:05卢布尔雅那临床中心心血管疾病诊所，在他88岁生日的前三天，约瑟普·布罗兹·铁托去世了。葬礼将于5月8日举行，我们需要决定是否有必要派一个代表团去贝尔格莱德，或者他值得哀悼吗？尽管我们在思想上存在分歧，在外交上也存在差距，但铁托是反法西斯战争的英雄之一，给他一个铭记的义务是有道理的。苏联和美国已经宣布，他们将派出官方政府代表团参加葬礼，但美国总统卡特不会去贝尔格莱德…也许"
const TXT_66_DESC_P2 := "同志不应该去，而应该派出拥有有限权力的代表团团长姬鹏飞？"
const TXT_66_DESC_ALB := "然而，我们的阿尔巴尼亚盟友已经声明，尽管他们愿意恢复与南斯拉夫的贸易和文化关系，但他们将永远不会停止批评“修正主义者铁托和铁托主义”。如果我们派出代表团，我们很可能把他们从我们身边赶走。"
const TXT_66_OPT0 := "发文表示悼念，但仅此而已"
const TXT_66_OPT1 := "同志将亲率我国政府代表团飞往贝尔格莱德"
const TXT_66_OPT1_DIS := "同志不能亲自飞去参加修正主义者铁托的葬礼！"
const TXT_66_OPT2 := "派出国务院秘书长姬鹏飞率领的代表团。"
const TXT_66_OPT2_DIS := "不许派代表团去贝尔格莱德！"
const TXT_66_OPT3 := "铁托死了？好吧，就这样吧，谁在乎呢？"
const TXT_66_OPT3_DIS := "我们不能不回应他的死亡！"

const TXT_66_R0 := "在致信中，就国家元首铁托元帅的逝世向南斯拉夫主席团、南共联盟中央和所有南斯拉夫人民表示深切哀悼，并表示希望恢复中南“友好关系、经济和文化关系”。这封信发表在《战斗报》上，在为期七天的哀悼结束时，我们收到了南斯拉夫主席团的正式回复，他们感谢我们的哀悼。但是，这对中南关系并没有产生什么影响。"
const TXT_66_R1_P1 := "5月7日，超过200个外国代表团抵达南斯拉夫议会，向铁托元帅告别。纪念活动在5月8日早8时结束。同日12时，在仪仗队结束后，由南斯拉夫主席团和南共联盟中央成员组成，8名海军上将和南人民军将领抬着约瑟普·布罗兹·铁托的棺材。南共联盟中央委员会主席斯特万·多罗尼斯基发表纪念铁托的演讲，随后队伍沿着米洛斯亲王大街和十月革命大道前进，到达5月25日博物馆。最后，南斯拉夫主席团主席拉扎尔·科利舍夫斯基在花房和外国政要看台前，发表了演讲。下午3点后，伴着国际歌，铁托的棺材被抬入花房，从此约瑟普·布罗兹·铁托在此安息。|我国代表团，由"
const TXT_66_R1_P2 := "和姬鹏飞带队，与南斯拉夫新领导层举行会谈，就恢复外交、经济和文化关系达成协议。预计拉扎尔·科利舍夫斯基将在半年内回访北京。但是，人民不满我们改善同南斯拉夫关系的政策，有些人已经把"
const TXT_66_R1_P3 := "同志和赫鲁晓夫相提并论……"
const TXT_66_R1_ALB := "但正如所料，阿尔巴尼亚领导人立即指责我们为“修正主义者”，并断绝了外交关系，将我们所有的顾问都赶出阿尔巴尼亚，拒绝偿还我们提供的贷款。这算什么人哪？……"
const TXT_66_R2 := "5月7日，超过200个外国代表团抵达南斯拉夫议会，向铁托元帅告别。纪念活动在5月8日早8时结束。同日12时，在仪仗队身后，是南斯拉夫主席团和南共联盟中央成员，8名海军上将和南人民军将领抬着约瑟普·布罗兹·铁托的棺材。南共联盟中央委员会主席斯特万·多罗尼斯基发表了纪念铁托的演讲，随后队伍沿着米洛斯亲王大街和十月革命大道前进，到达5月25日博物馆。最后，南斯拉夫主席团主席拉扎尔·科利舍夫斯基在花房和外国政要看台前，发表了演讲。下午3点后，伴着国际歌，铁托的棺材被抬入花房，从此约瑟普·布罗兹·铁托在此安息。南斯拉夫新领导层表示有兴趣恢复与中华人民共和国的关系，但姬鹏飞同志拒绝进行任何谈判，理由是他没有得到授权。“有可能在以后的某一天......但现在不行”，他跟拉扎尔·科利舍夫斯基如此说道。然而，党内不满于我国代表团空手从贝尔格莱德而归的事实......"
const TXT_66_R3_P1 := "中国领导人对铁托的死没有回应，甚至没有表示哀悼。这不仅在南斯拉夫，而且在全世界都引起了惊讶。面对南斯拉夫通讯社机构提问的关于为什么会这样做的问题，"
const TXT_66_R3_P2 := "同志的回复是“无可奉告……”"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	d = p_ws
	match event_def.event_id:
		"pan_arabism":
			_prepare_64(event_def)
		"moscow_olympics":
			_prepare_65(event_def)
		"death_of_tito":
			_prepare_66(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"pan_arabism": _event_64(option_index, context)
		"moscow_olympics": _event_65(option_index, context)
		"death_of_tito": _event_66(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_64(option_index: int, context: Dictionary) -> void:
	var egypt := ws.get_country_by_legacy_index(30)
	if egypt != null and egypt.government == GameConstants.Government.SOCIALIST:
		_add_data({W.I_DIPLO: 10, W.I_MANPOWER: 30})
		_add_empire_relation(EmpireData.USSR, -100)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_power(EmpireData.USSR, -20)
		ws.influence_prc += 10
		if ws.size() > 143:
			ws.oil_price += 5
		_add_empire_power(EmpireData.USA, -20)
		var oar := [30, 13, 14, 35]
		for idx in oar:
			var c := ws.get_country_by_legacy_index(idx)
			if c != null:
				c.set_tag("oar", true)
		_set_modifier(46, true)
		ws.set_flag("oar", true)
		for i in range(1, ws.countries.size()):
			var c := ws.countries[i]
			if c == null:
				continue
			var idx := int(c.原版序号)
			var socialism := c.government == GameConstants.Government.SOCIALIST
			if idx in [54, 55, 18, 40, 104, 93, 53]:
				if socialism:
					c.set_tag("oar", true)
			elif idx == 24 and c.parts.size() > 0 and c.parts[0]:
				if socialism:
					c.set_tag("oar", true)
		# 原版 party_change[2]=0.24 / party_change[3]=0.24 移植说明（DLC 选举系统未启用）。
		context["result_text"] = TXT_64_R_SOC
		return
	if option_index == 0:
		_add_empire_power(EmpireData.USA, 10)
		context["result_text"] = TXT_64_R0
		return
	_add_data({W.I_BUDGET: -70, W.I_AGENTS: -50, W.I_DIPLO: 10,
		W.I_MANPOWER: -30, W.I_INFLUENCE: 10})
	_add_empire_relation(EmpireData.USSR, 80)
	_add_empire_relation(EmpireData.USA, -70)
	_add_empire_power(EmpireData.USSR, 10)
	_add_empire_power(EmpireData.USA, -10)
	ws.set_flag("oar", true)
	var uar := [30, 14, 35]
	for idx in uar:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null:
			c.set_tag("oar", true)
	_add_faction_ideology({FactionData.MODERATE: 24, FactionData.REFORMIST: 24})
	_change_politicians({1: [100, 120], 2: [100, 120]})
	context["result_text"] = TXT_64_R1


func _event_65(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 150, W.I_PEOPLE_SUPPORT: 80,
				W.I_DIPLO: -20, W.I_INFLUENCE: 10, W.I_BUDGET: -40})
			_add_empire_power(EmpireData.USSR, 20)
			_add_empire_relation(EmpireData.USSR, 250)
			_add_empire_relation(EmpireData.USA, -100)
			var r0 := _leader_name() + TXT_65_R0A + _leader_name() + TXT_65_R0B
			var iran := ws.get_country_by_legacy_index(8)
			if iran != null and iran.government == GameConstants.Government.AUTHORITARIAN:
				r0 += TXT_65_R_IRAN
			r0 += TXT_65_R_TAIL
			context["result_text"] = r0
		1:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_INFLUENCE: -20})
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_relation(EmpireData.USA, -150)
			_add_empire_relation(EmpireData.USSR, -50)
			var r1 := TXT_65_R1A
			var iran1 := ws.get_country_by_legacy_index(8)
			if iran1 != null and iran1.government == GameConstants.Government.AUTHORITARIAN:
				r1 += TXT_65_R_IRAN
			r1 += TXT_65_R_TAIL1
			context["result_text"] = r1
		2:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 50,
				W.I_INFLUENCE: -10, W.I_BUDGET: -40, W.I_THOUGHT_FREEDOM: 60})
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_relation(EmpireData.USA, 80)
			_add_empire_relation(EmpireData.USSR, 50)
			var r2 := TXT_65_R2A
			var iran2 := ws.get_country_by_legacy_index(8)
			if iran2 != null and iran2.government == GameConstants.Government.AUTHORITARIAN:
				r2 += TXT_65_R_IRAN
			r2 += TXT_65_R2_TAIL
			context["result_text"] = r2
		3:
			_add_data({W.I_PARTY_SUPPORT: 70, W.I_PEOPLE_SUPPORT: 30,
				W.I_THOUGHT_FREEDOM: 60, W.I_BUDGET: -30})
			_add_empire_relation(EmpireData.USA, 200)
			_add_empire_relation(EmpireData.USSR, -200)
			var r3 := TXT_65_R3A
			var iran3 := ws.get_country_by_legacy_index(8)
			if iran3 != null and iran3.government == GameConstants.Government.AUTHORITARIAN:
				r3 += TXT_65_R_IRAN
			r3 += TXT_65_R3_TAIL
			context["result_text"] = r3
		4:
			_add_data({W.I_PARTY_SUPPORT: 200, W.I_PEOPLE_SUPPORT: 50,
				W.I_INFLUENCE: 20, W.I_BUDGET: -100})
			# 原版 Event65.cs result4：data.budget -= 100（10 百万预算，与选项文案一致）；
			# 旧值 -200 会多扣 10 百万，已修正。
			_add_empire_relation(EmpireData.USA, -50)
			_add_empire_relation(EmpireData.USSR, -50)
			var r4 := TXT_65_R4A
			var reputation := int(ws.diplomatic_reputation)
			if reputation < 65:
				r4 += TXT_65_R4_GOOD
			elif reputation < 85:
				r4 += TXT_65_R4_MID
			else:
				r4 += TXT_65_R4_BAD
			r4 += TXT_65_R4_TAILA
			var iran4 := ws.get_country_by_legacy_index(8)
			if iran4 != null and iran4.government == GameConstants.Government.AUTHORITARIAN:
				r4 += TXT_65_R_IRAN
			r4 += TXT_65_R4_TAIL
			context["result_text"] = r4


func _event_66(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 20)
			_add_empire_relation(EmpireData.USSR, 20)
			context["result_text"] = _leader_name() + TXT_66_R0
		1:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_DIPLO: -20})
			_add_empire_relation(EmpireData.USA, 50)
			_add_empire_relation(EmpireData.USSR, 50)
			var yugoslavia := ws.get_country_by_legacy_index(15)
			if yugoslavia != null:
				yugoslavia.set_tag("对华贸易", true)
			var albania := ws.get_country_by_legacy_index(20)
			if albania != null and albania.has_tag("亲中"):
				albania.set_tag("对华贸易", false)
				albania.set_tag("亲中", false)
			var r1 := TXT_66_R1_P1 + _leader_name() + TXT_66_R1_P2 + _leader_name() + TXT_66_R1_P3
			if albania != null and albania.has_tag("亲中"):
				r1 += TXT_66_R1_ALB
			context["result_text"] = r1
		2:
			_add_data({W.I_PARTY_SUPPORT: -30, W.I_DIPLO: -15})
			_add_empire_relation(EmpireData.USSR, 30)
			_add_empire_relation(EmpireData.USA, 30)
			context["result_text"] = TXT_66_R2
		3:
			_add_data({W.I_DIPLO: 10})
			context["result_text"] = TXT_66_R3_P1 + _leader_name() + TXT_66_R3_P2


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.size():
			ws.add_data_by_index(index, int(changes[raw_index]))


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


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power

func _prepare_64(event_def: EventDef) -> void:
	if event_def.options.size() < 2:
		return
	var opts := event_def.options
	var egypt := ws.get_country_by_legacy_index(30)
	if egypt != null and egypt.government == GameConstants.Government.SOCIALIST:
		event_def.title = TXT_64_TITLE_SOC
		event_def.description = TXT_64_DESC_SOC
		_enable(opts[0], TXT_64_OPT0_SOC)
		_disable(opts[1], TXT_64_OPT1)
		return
	event_def.title = TXT_64_TITLE
	event_def.description = TXT_64_DESC
	_enable(opts[0], TXT_64_OPT0)
	var agents := int(ws.agents)
	var egypt_prosov := egypt != null and egypt.has_tag("亲苏")
	if agents < 50:
		_disable(opts[1], TXT_64_OPT1_DIS_AGENTS)
	elif egypt_prosov and not ws.global_flags.get("relres", false):
		_disable(opts[1], TXT_64_OPT1_DIS_REL)
	elif not ((not egypt_prosov) or ws.global_flags.get("relres", false)):
		_disable(opts[1], TXT_64_OPT1_DIS_OTHER)
	else:
		_enable(opts[1], TXT_64_OPT1)


func _prepare_65(event_def: EventDef) -> void:
	if event_def.options.size() < 5:
		return
	var opts := event_def.options
	event_def.title = TXT_65_TITLE
	event_def.description = TXT_65_DESC
	if ws.factions.size() > 0 and ws.factions[0] != null and ws.factions[0].is_enabled:
		event_def.description += TXT_65_DESC_GANEFO
	var line := int(ws.political_line)
	var ps := int(ws.party_system)
	var summa := _summa_3_2()
	var cond_line_below3 := (line < 3 and ps < 8) or (summa > 66 and ps > 7)
	var cond_line_1_2 := (line > 0 and line < 3 and ps < 8) or (summa > 66 and ps > 7)
	var cond_line_above1 := (line > 1 and ps < 8) or (summa > 66 and ps > 7)
	var china_sev := false
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china_sev = china.has_tag("sev")
	var stage_zero := int(ws.reform_stage) == 0
	var stage_positive := int(ws.reform_stage) > 0
	if (stage_zero and cond_line_below3) or china_sev:
		_enable(opts[0], TXT_65_OPT0)
	else:
		_disable(opts[0], TXT_65_OPT0_DIS)
	if (stage_zero and cond_line_1_2) or (ws.global_flags.get("relres", false) and line != 0):
		_enable(opts[1], TXT_65_OPT1)
	else:
		_disable(opts[1], TXT_65_OPT1_DIS)
	if stage_positive and cond_line_above1:
		_enable(opts[3], TXT_65_OPT3)
	else:
		_disable(opts[3], TXT_65_OPT3_DIS)
	if stage_zero and cond_line_below3:
		_enable(opts[4], TXT_65_OPT4)
	else:
		_disable(opts[4], TXT_65_OPT4_DIS)
	var disabled_count := 0
	for i in [0, 1, 3, 4]:
		if opts[i].enable_condition != null:
			disabled_count += 1
	var cond_line_below4 := (line < 4 and ps < 8) or (summa > 66 and ps > 7)
	if (cond_line_below4 and line != 0) or disabled_count >= 4:
		_enable(opts[2], TXT_65_OPT2)
	else:
		_disable(opts[2], TXT_65_OPT2_DIS)


func _prepare_66(event_def: EventDef) -> void:
	if event_def.options.size() < 4:
		return
	var opts := event_def.options
	event_def.title = TXT_66_TITLE
	event_def.description = TXT_66_DESC_P1 + _leader_name() + TXT_66_DESC_P2
	var albania := ws.get_country_by_legacy_index(20)
	if albania != null and albania.has_tag("亲中"):
		event_def.description += TXT_66_DESC_ALB
	_enable(opts[0], TXT_66_OPT0)
	var line := int(ws.political_line)
	var ps := int(ws.party_system)
	var summa := _summa_3_2()
	var china_sev := false
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china_sev = china.has_tag("sev")
	if (line > 1 and ps < 8) or (summa > 66 and ps > 7) or china_sev:
		_enable(opts[1], _leader_name() + TXT_66_OPT1)
	else:
		_disable(opts[1], _leader_name() + TXT_66_OPT1_DIS)
	if (line > 0 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[2], TXT_66_OPT2)
	else:
		_disable(opts[2], TXT_66_OPT2_DIS)
	if (line < 3 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[3], TXT_66_OPT3)
	else:
		_disable(opts[3], TXT_66_OPT3_DIS)


func _summa_3_2() -> int:
	if ws.party_system <= 7:
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


func _set_modifier(index: int, active: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



