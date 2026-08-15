extends "res://数据脚本/event_script_base.gd"

## 原作 Event542.cs：第一届世界革命青年与学生联欢会（1选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:207-209 ——
##   event_done[541] && resultOfEvents[541]==1 && modifies[3].active && (1985.5.4 或 1986+)。
## 差异：描述/结果由 prepare/execute 动态拼领袖姓名与总理姓名。

const TXT_TITLE := "第一届世界革命青年与学生联欢会"
const TXT_DESC := "同志，如你所知，第一节世界革命青年与学生联欢会将在我国举行，我国已经成功证明有能力和苏联在世界革命运动中扳手腕，甚至是东风压倒西风。很快，我们就将在首都北京举办这一场风头不输奥运会的盛大庆典。"
const TXT_OPT0 := "革命青年要志在四方！"
const TXT_R0_A := "第一届青年节是一次伟大的成功，多达170个国家的青年学生代表均来到我国参加这一盛会。在我国北京的工人体育场，来自各地的进步青年和重要国家领导人齐聚一堂。"
const TXT_R0_PM := "同志和津巴布韦总统穆加贝，阿尔巴尼亚的霍查夫人等世界人民的领袖共襄盛举。我国的学生代表向他们献上了鲜花和拥抱。国务院总理"
const TXT_R0_SPEECH := "同志在开幕式上做了简单的演讲：“在这里，在伟大的毛泽东主席的故乡。我们的年轻人是多么深深地致力于解放、自由和社会主义的崇高理想。我们都同意，今天人类没有比解放受压迫者重要、更紧迫的任务了。我很高兴看到世界的青年都和我一样，渴望全人类的解放远超过一切。”
在开幕式上，来自世界各国的青年踏着整齐划一的步子，举着写有“永远铭记革命导师，开创青崭新世界”的横幅和标语，自信的绕着北京工人体育场的跑道经过主席台的检阅。中华人民共和国代表团包括了来自我国56个民族的青年代表，其中也包括港澳台侨胞和归国华侨他们穿着自己民族特有的服饰，或是致敬65式军装的礼服。我们的旗手则是总政歌舞团男高音程志，解放军军乐团女高音韩芝萍和总政歌舞团男中音熊卿才。最令人惊喜的则是来自苏联的无产阶级专政党的青年代表队，他们尽管人数不是最多的。他们高举毛泽东和斯大林的画像，志气昂扬的喊着“苏联修正党必败！”的口号，这为他们博得了不少镜头。
"
const TXT_R0_ZA := "各国的青年也就国际问题进行了充分的讨论：就声援饱受种族隔离之苦的南非人民，终结美帝国主义针对古巴的无理封锁和干涉中美洲国家内政问题，大会一致通过了决议。同时，大会一致通过决定，谴责苏联在南部非洲扶植的法西斯主义代理人，并赤裸裸的干涉内政达成了谴责。正式将苏联定性为社会帝国主义超级大国。就支持核裁军和侵犯人权的军政府方面，代表们达成了一致。
"
const TXT_R0_OTHER := "各国的青年就彻底批倒批臭美帝国主义，苏联社会帝国主义大会一致通过了决议。同时，大会特别开设了“关于被压迫者追求正义特别法庭”，旨在为曾在中美洲军事独裁政权，美国禁运的古巴，苏联武装入侵过的捷克斯洛伐克以及饱受战争之苦的各国人民声张正义。法庭判处了苏联曾经的领导人列昂尼德勃列日涅夫2800年有期徒刑。以“人民进步法院”为名要求逮捕基辛格，其罪名是多次干涉他国内政，残酷的谋杀了智利总统阿连德。尽管这只是个玩笑话，但代表们还是达成了一致，并焚烧了画有美国总统和苏联最高领导人头像的稻草人。
"
const TXT_R0_CLOSE := "闭幕式上，来自布基纳法索，英国和智利的青年代表就谴责帝国主义干涉和反对法西斯主义复活的观点进行了简短的演讲。他们感谢了中华人民共和国积极参与解放世界被压迫者的斗争，并坚信我国将会取得胜利，终究会向帝国主义者们证明共产主义定胜利。在巨大的篝火前，来自"
const TXT_R0_CLOSE_TAIL := "同志的青年们手拉着手，围成一圈又一圈，同声高唱着《团结就是力量》与《venceremos》。青年代表们相信，世界革命必将在不远的将来取得最后的胜利。在歌声之中，本届世界革命青年与学生联欢会正式宣告闭幕。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _leader_name() + TXT_DESC


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c131 := ws.get_country_by_legacy_index(131)
	var text := TXT_R0_A + _leader_name()
	var pm := _prime_minister_name()
	text += TXT_R0_PM + pm + TXT_R0_SPEECH
	if c131 != null and (c131.sub_government == 9 or c131.sub_government == 7):
		text += TXT_R0_ZA
	else:
		text += TXT_R0_OTHER
	text += TXT_R0_CLOSE + _leader_name() + TXT_R0_CLOSE_TAIL
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_DIPLO, 50)
	_add(W.I_BUDGET, -150)
	_add_relation(EmpireData.USSR, -100)
	_add_relation(EmpireData.USA, -100)
	ws.influence_prc += 50
	context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _prime_minister_name() -> String:
	if ws.politics_positions.size() > 0:
		var idx := ws.politics_positions[0]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null:
			var p := ws.politicians[idx]
			if p.name_display != "":
				return p.name_display
	return _leader_name()
