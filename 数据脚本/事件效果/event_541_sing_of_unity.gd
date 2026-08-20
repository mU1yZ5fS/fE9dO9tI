extends "res://数据脚本/event_script_base.gd"

## 原作 Event541.cs：我们高唱团结友谊（世界民主青年联盟，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:202-204 —— relres && 年<=1984。
## 差异：描述由 prepare 动态拼领袖姓名；resultOfEvents 缺省按原版 int 默认 0 处理。

const TXT_DESC := "同志！外联部的同志最近收到了消息，随着我国与苏联关系的缓和，苏共国际部希望就我国在世界民主青年联盟席位的恢复商谈。以防您已经忘了这个组织，请允许我简单的介绍一下：世界民主青年联盟是世界左翼学生运动中规模最大的国际性组织，旨在团结世界各国反帝爱国的进步青年。自我国与苏联决裂以来，中国共产主义青年团和中华全国青年联合会便停止了出席此类活动。而随着我国与苏联关系的回暖，回到此类国际组织也应该成为我们外交政策的一部分。不过无论如何，您都有权利投上庄严的一票！"
const TXT_OPT0_DIS := "我们不同意！"
const TXT_OPT1_DIS := "为什么在有电梯的时候，非得爬楼梯呢？"
const TXT_OPT2_DIS := "可是资本主义世界的人都去了！"
const TXT_R0 := "我们决定重新回到世界民主青年联盟，苏联对于我们的行为非常高兴。在世界民主青年联盟的第十一次大会上，出于对修复我国关系和地沿政治的考量。苏联高调宣布将1985年举办的第十二届世界青年学生联欢会的东道国为中华人民共和国。各个代表都相当高兴，这不仅会成为我们在将来的国际舞台上发光发声的基石。也象征着欧亚大陆上两个最大的社会主义超级大国达成了和解。"
const TXT_R0_ALB := "
但是，总有些不和谐的声音，就比如阿尔巴尼亚的领袖恩维尔·霍查，他认为我们事实上向苏联人投降了。他再三询问"
const TXT_R0_ALB_TAIL := "同志在如此重要的问题上为什么不提前与阿尔巴尼亚同志交流，并再三强调阿尔巴尼亚人民不会向邪恶的社会帝国主义者投降。"
const TXT_R1 := "我们没有直接回应这一决定，相反，我们开始着手组建自己的国际青年联盟。在第一届世界革命青年组织上，缅甸共产主义青年团，菲律宾爱国青年组织，阿尔巴尼亚劳动青年组织，泰国共产党青年翼，阿富汗自由青年组织，秘鲁学生联合会，坦桑尼亚革命党统一青年与学生组织，莫桑比克青年组织等愿意和中华人民共和国坐下来交谈的青年组织收到了邀请函。在广州白云公馆召开的的第一届大会上，一致通过了在1985年5月4日，在北京举办第一节世界革命青年与学生联欢会的相关事宜得到了通过。作为上述党政集团中最有影响力的，"
const TXT_R1_ALB := "
阿尔巴尼亚党政领导人恩维尔·霍查十分高兴地赞扬了我国拒绝修正主义者提案这一举动，并表明“将坚定不移的和中国同志站在一起，同修正主义和帝国主义作斗争”。"
const TXT_R1_TAIL := "
不过苏联可就气坏了，毕竟我们狠狠的打了他们一巴掌，我看是别想回到五十年代那种如胶似漆的好时光了……"
const TXT_R2 := "苏联对我们的态度表示非常遗憾，并希望在下次能得到更积极的回应。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _leader_name() + TXT_DESC
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d.political_line
	if line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if d.albania_break == 0 and ws.influence_prc >= 350 and ws.modifiers[3].is_active:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0
			if d.albania_break == 0:
				text += TXT_R0_ALB + _leader_name() + TXT_R0_ALB_TAIL
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, -50)
			_add_relation(EmpireData.USSR, 100)
			ws.influence_prc += 20
			context["result_text"] = text
		1:
			var text := TXT_R1
			if d.albania_break == 0:
				text += TXT_R1_ALB
			text += TXT_R1_TAIL
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USSR, -150)
			ws.influence_prc += 20
			context["result_text"] = text
		2:
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = TXT_R2


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
