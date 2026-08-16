extends "res://数据脚本/event_script_base.gd"

## 原作 Event634.cs：Belice de Guatemala（革命危地马拉收复伯利兹，单选项）。
## 触发：DiploButtonScript.cs:12130 —— 外交按钮 1032，selected_country==149（危地马拉），
##   入口扣 data[22]-=80（在 _def_1032 中已移植），随后 StartEvent(634)。
## 差异：ingamewars[65] 未建模 WarDef → GameManager.start_war 兜底创建后手工补名。
##   parts[0/2] 写前 resize；Gosstroy→government；SovietSupportAttacker→ussr_side=1。

const TXT_TITLE := "Belice de Guatemala"
const TXT_DESC := "伯利兹，或称英属洪都拉斯，这片中美洲人口最稀少的土地，本就是玛雅乃至危地马拉神圣而不可分割的一部分。十七世纪，英国无视西班牙的领土要求侵吞蚕食了这一地区，而中美洲联邦解体后由英国所扶持的危地马拉“独立之父”则在1859年与英国签订了条约，正式将伯利兹地区的主权所出卖，使英国彻底占领了这片地区。尽管伯利兹已经于1981年独立，但英国还是在该国保留了一支一千五百人的部队。\n而在危地马拉革命胜利后的今天，也是时候把目光放到这片曾被帝国主义所窃取、只有十余万人的土地，终结帝国主义所铸造的裂痕了。"
const TXT_OPT0 := "游子该归乡了。"
const TXT_R_ANNEX := "危地马拉与英国双方都向伯利兹施加了压力，很快，伯利兹就陷入了物资短缺、经济崩溃。URNG的伯利兹部分和中美洲工人革命党伯利兹支部也趁机鼓动罢工和游行，而政府调集宪兵镇压示威的举措反而成了加速自己倒台的催化剂。在种种内外压力的逼迫下，伯利兹总理宣布辞职，共产主义者夺取了伯利兹的政权。随后，伯利兹宣布以自治形式加入社会主义危地马拉。很快当地便开展了轰轰烈烈的社会主义改造。外国公司与银行被收归国有，原住民权益得到保障，链接该地区的铁路与公路网也开始建设，尽管使用该语言的人口微乎其微，但英语与伯利兹克里奥尔语却也被列为合法语言。"
const TXT_R_WAR := "新生的危地马拉革命军迅速跨过两国边境，一场战争打响了。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var guatemala := ws.get_country_by_legacy_index(149)
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	if uk != null and uk.government == 1:
		context["result_text"] = TXT_R_ANNEX
		if guatemala != null:
			guatemala.level_of_instability += 50
			_set_part(guatemala, 0, true)
		ws.influence_prc += 5
		_add_power(EmpireData.USA, -5)
		_add_relation(EmpireData.USA, -50)
		return
	context["result_text"] = TXT_R_WAR
	if guatemala != null:
		_set_part(guatemala, 2, true)
	_add_relation(EmpireData.USA, -50)
	# 原版 ingamewars[65]=危地马拉统一战争，危地马拉(600) vs 伯利兹(400)，SovietSupportAttacker
	GameManager.start_war(65, "危地马拉", "伯利兹", 600, 400, -1, 1)
	if ws.wars.size() > 65 and ws.wars[65] != null:
		ws.wars[65].name_war = "危地马拉统一战争"


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value
