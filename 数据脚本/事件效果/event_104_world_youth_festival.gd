extends "res://数据脚本/event_script_base.gd"

## 原作 Event104.cs：第十二届世界青年学生节（单选项，动态长文案）。
## 触发：TimeScript.cs:10868-10874 ——
##   (月>=7 且 年>=1985 或 年>=1986) && event_done[541] && resultOfEvents[541]==0
##   && IsSocialism(true,1)（c1 社会主义用 ANY(gov==1, sub==0) 表达）。
## 差异：
##  - 原版 kolvo_variant=1，result1/2 不可达（死分支），仅移植 result0。
##  - 文案按 USSR now_leader(6戈尔巴乔夫/3谢尔比茨基/5格里申/4罗曼诺夫/8利加乔夫)、
##    dolshnost[0]（politics_positions[0]）、modifies[6] 逐段拼接。

const TXT_OPEN := "第十二届青年节是一次伟大的成功，多达170个国家的青年学生代表均来到我国参加这一盛会。在我国北京的工人体育场，来自各地的进步青年和重要国家领导人齐聚一堂。"

const TXT_LEADERS := "同志和津巴布韦总统穆加贝，赞比亚总统卡翁达等第三世界国家的领袖共襄盛举，甚至包括苏联最高领导人"

const TXT_PREMIER := "同志发表了简短的演讲：“在中国，世界的重要一环，你可以直接感受到我们的年轻人是多么深深地致力于人类、和平和社会正义的崇高理想。我认为我们都同意，今天人类没有比加强和平更重要、更紧迫的任务了。对此，我在这里呼吁，全体世界的青年都应该为了反对一切不公平团结起来！”\n在开幕式上，来自世界各国的青年踏着整齐划一的步子，举着“反抗帝国主义霸权，争取自由解放与和平”的标语，自信的绕着北京工人体育场的跑道经过主席台的检阅。中华人民共和国代表团包括了来自我国56个民族的青年代表，其中也包括港澳台侨胞和归国华侨/他们穿着自己民族特有的服饰，或是中山装。我们的旗手则是总政歌舞团男高音程志，解放军军乐团女高音韩芝萍和总政歌舞团男中音熊卿才。这也是近几年我国参与的最盛大的集会性活动。"

const TXT_PROTEST_MID := "但还是有不和谐的声音，在加拿大代表团行进的过程中，两位代表从包里掏出一块白布，上面写着“"

const TXT_PROTEST_TAIL := "，叛徒去死！”另一个青年的写着“毛泽东同志万岁，修正主义必败！”并用蹩脚的中文大喊着“毛泽东！毛泽东！”。他们很快就被安保人员带走。"

const TXT_CLOSING := "各国的青年也就国际问题进行了讨论。但在涉及到苏联在南部非洲的军事干涉和援助时，辩论最终上升成了苏联的地位究竟是进步国家代表还是社会帝国主义，话题不得不被中止。但对支持核裁军和谴责美国支持的军政府方面，代表还是达成了一致。\n闭幕式上，来自南非，法国和美国的青年代表就呼吁世界和平和反对法西斯主义复活的观点进行了简短的演讲。感谢了苏维埃联盟和中国就维护世界和平与稳定做出的贡献，但依然呼吁我国发挥一个区域性大国在东亚的作用。在巨大的篝火前，来自世界各地的青年手拉着手，围成一个又一个同心圆，他们高声歌唱诸如《venceremos》，《革命人永远是年轻》等歌曲，最后，在一曲《歌唱动荡的青春中》。数以万计的烟火飞向空中，炸开了美丽的火花，这也宣告了节日的闭幕。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		var leader_name := _leader_name()
		var text := TXT_OPEN + leader_name
		var ussr_leader := _empire_leader(1)
		var ussr_name := ""
		match ussr_leader:
			6:
				ussr_name = "戈尔巴乔夫"
			3:
				ussr_name = "谢尔比茨基"
			5:
				ussr_name = "格里申"
			4:
				ussr_name = "罗曼诺夫"
			8:
				ussr_name = "利加乔夫"
		if ussr_name != "":
			text += TXT_LEADERS + ussr_name + "。我国的学生代表向他们献上了鲜花和拥抱。国务院总理"
		var premier := _premier_name()
		text += premier + TXT_PREMIER
		if not _mod_active(6):
			text += TXT_PROTEST_MID + leader_name + TXT_PROTEST_TAIL
		text += TXT_CLOSING
		_add(W.I_THOUGHT_FREEDOM, 20)
		_add(W.I_PEOPLE_SUPPORT, 80)
		ws.influence_prc += 10
		_add(W.I_PARTY_SUPPORT, 50)
		_add_relation(EmpireData.USSR, 100)
		_add_relation(EmpireData.USA, 50)
		context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## 原版 dolshnost[0]（总理槽）!=150/200 时用槽内政治家姓名，否则用领袖姓名。
func _premier_name() -> String:
	if ws.politics_positions.size() > 0:
		var idx := ws.politics_positions[0]
		if idx != 150 and idx != 200 and idx >= 0 and idx < ws.politicians.size():
			var p: PoliticianData = ws.politicians[idx]
			if p != null and p.name_display != "":
				return p.name_display
	return _leader_name()


func _empire_leader(empire_index: int) -> int:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		return ws.empires[empire_index].current_leader
	return -1


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active




