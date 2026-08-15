extends "res://数据脚本/event_script_base.gd"

## 原作 Event590.cs：红色的所罗门雄狮（埃塞门格斯图世袭，二选项）。
## 触发：DiploButtonScript.cs:10794 —— number_event = 590（外交按钮手动触发），无自动触发。
## 差异：
##  - <color> 标签去除（既有约定）；name → chinese_name（含 \n 保留）；
##  - EstablishGovernment(ProChina) → 亲中 true、亲苏/亲美 false；Torg → 对华贸易；
##  - JoinAllOurAlliances(true) → 基类 _join_alliances；
##  - event_done[590]=false → completed_event_ids.erase("event_590")（同 Event440 约定）。

const TXT_TITLE := "红色的所罗门雄狮"

const TXT_DESC := "在1974年率领军官完成了推翻君主制的伟大胜利，在1977年击溃了党内左倾右倾保守革新各派势力，门格斯图·海尔·马里亚姆上校已然成为埃塞俄比亚的无冕之王，超越海尔·塞拉西的“红色尼格斯”。但是，这样的革命果实在他死后还能维持吗？这样超凡脱俗的领袖死后，摇摇欲坠的埃塞是不是会硬着陆呢？也许，他们应该看向东亚冉冉升起的红色巨龙。不仅仅是革命的教条，更是为了让红太阳照遍全球，让我们当一回革命的教员吧！"

const TXT_OPT0 := "老子革命儿好汉！"
const TXT_OPT1 := "这样太疯狂了"

const TXT_R0_A := "在近日，我们邀请社会主义埃塞俄比亚临时军事行政主席门格斯图·海尔·马里亚姆同志来到我国，展开为期一周的国事访问。在访问的路上，门格斯图主席参观了革命军事博物馆，上海江南造船厂，韶山毛主席故居等诸多带有“中国革命心路历程”的建筑。他亲自向毛主席纪念堂献上了花圈，还参观了1969年珍宝岛战争纪念碑。在人民大会堂的招待宴会上，门格斯图主席发表了一篇演讲，其中高度赞扬了"
const TXT_R0_B := "同志。他说：“"
const TXT_R0_C := "同志把中国革命带入了一个新的高潮，尤其是确保革命老将守护革命果实的理念，埃塞俄比亚这样应当学习。”\n在回国后，门格斯图开展了一系列激进的改革。临时军委彻底结束存在，取而代之的是埃塞俄比亚革命工人党，而门格斯图和他的亲戚战友们身居高位。埃塞俄比亚的第一夫人乌班齐·比绍也被任命为政府总理和埃塞俄比亚革命妇女联合会主席。在新政府的落成仪式上，门格斯图为自己换上了一套元帅服。在民间大量的雕像已经开始修建，对于他的个人崇拜的民谣与民俗故事已经在民间流传开来。其中包括他在推翻君主制的革命中如何立下汗马功劳；是怎么用铁拳击溃苏联修正主义，美帝国主义和内部的第五纵队的；如何在国内外战场中身先士卒，亲自指挥，亲自部署，在前线取得一个又一个胜利的；又在建设社会主义时如何以柔软的一面爱戴关怀群众。他给自己安上了无数的头衔，如“来自非洲屋脊的天才”，“当代杰出的马克思列宁主义者”、“革命思想的永恒火焰”，是“前所未有的最天真、最自然、最有感情也最纯粹的革命者”。已经有传言说他会培养他的大女儿为唯一接班人，而这位长公主已经被任命为教育部部长，并被授予了上校军衔，尽管她尚未完成小学教育。一个革命烈士纪念馆也在有条不紊的修建中。在历史课本中，社会主义国家对埃塞的援助被逐渐遗忘，转而变成了大元帅的功劳，而大量曾经的临时军委成员也在历史的长河中失去了姓名。\n埃塞俄比亚国内外的反对派大力谴责这一切，称他为“红色暴君”，但就让他们说去吧，就让他们说门格斯图大元帅这也不行那也不行吧！"
const TXT_R1 := "说笑了，主席同志，他不过是埃塞俄比亚又一个普通的不能再普通的领导人罢了。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c41 := ws.get_country_by_legacy_index(41)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_A + _leader_name() + TXT_R0_B + _leader_name() + TXT_R0_C
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if c41 != null:
				c41.chinese_name = "埃塞俄比亚\n民主主义人民共和国"
				c41.government = 0
				c41.sub_government = 19
				_establish_prochina(c41)
				c41.set_tag("对华贸易", true)
				_join_alliances(c41)
			context["result_text"] = text
		1:
			ws.completed_event_ids.erase("event_590")
			context["result_text"] = TXT_R1


func _establish_prochina(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
