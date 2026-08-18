extends "res://数据脚本/event_script_base.gd"

## 原作 Event588.cs：欧加登战火重燃（索马里-埃塞俄比亚边境冲突，三选项）。
## 触发：TimeScript.cs:10901-10906 ——
##   日期>=1982.6.1 && c42.SubGosstroy==10
##   && ((!c42.亲苏 && c41.亲苏) || (!c42.亲苏 && c41.亲中) || (c42.亲苏 && c41.亲中))。
## 差异：
##  - 原版 !c42.parts[0] && !c42.parts[2] 由 CountryData.parts 建模；
##  - Attacker/Defender 用 new_events_text[794]/[795] = 索马里/埃塞俄比亚；
##  - SovietSupportAttacker/Defender → ussr_side 0/1，美国不介入 → usa_side=-1；
##  - TickTime(16/4) → fortnight_max=16/4。

const TXT_TITLE := "欧加登战火重燃"
const TXT_DESC := "主席同志，看来欧加登的后遗症并未就此了结。阿卜杜拉希·优素福上校曾担任索马里国民军的指挥官，正是他领导了1978年那场失败的政变，之后他立即逃往埃塞俄比亚。在埃塞俄比亚，优素福打造了为一个名为拯救索马里民主阵线（SSDF）的武装反对巴雷政权的组织。他领导了该组织，不久后开始与埃塞俄比亚军队联手骚扰索马里军队。\n同时，索马里也拒绝承认其在欧加登的惨败，宣传中仍然强调大索马里理念。近期，双方又一次在边境摩拳擦掌，颇有大打出手的劲头。而埃塞俄比亚这次先发制人，派出了大量部队越过边境，这很有可能变成又一次的欧加登战争，主席同志，一边是我们的老朋友，而另一边是苏联走狗，但他终究会是个麻烦的朋友，我们该帮谁呢？"

const TXT_OPT0 := "支持索马里人的保家卫国"
const TXT_OPT1 := "支持埃塞俄比亚人复仇"
const TXT_OPT2 := "关我鸟事？"

const TXT_R0 := "大约10,000至15,000名埃塞俄比亚军队发动了入侵，他们装备了苏联提供的米格战斗机和t-55坦克。3000名SSDF成员同样装备了坦克，并得到了埃塞俄比亚炮兵和空军的支持。\n索马里国民军（SNA）只能派出2500名士兵参加边境战役。保卫边境地区的索马里部队指挥官是优素福·艾哈迈德·萨尔汉将军和他的下属穆罕默德·法拉·艾迪德准将，他指挥中央区军事区。西方观察家估计，在战役开始时，SNA的总兵力约为50,000人。自1978年初欧加登战争结束时遭受严重损失后，SNA装备严重不足，对冲突准备不足。但好在有我们的志愿军，SNA得以获得歼-7战斗机和足够的火炮与反坦克火箭弹。\n现在摆在我们面前的问题是，这到底是一场短暂的边境冲突，还是一次地缘政治大洗牌？"
const TXT_R1 := "大约10,000至15,000名埃塞俄比亚军队发动了入侵，他们装备了苏联提供的米格战斗机和t-55坦克。3000名SSDF成员同样装备了坦克，并得到了埃塞俄比亚炮兵和空军的支持。同时我们也押宝于埃塞俄比亚，他们获得了我们的志愿者和武器装备。\n索马里国民军（SNA）只能派出2500名士兵参加边境战役。保卫边境地区的索马里部队指挥官是优素福·艾哈迈德·萨尔汉将军和他的下属穆罕默德·法拉·艾迪德准将，他指挥中央区军事区。西方观察家估计，在战役开始时，SNA的总兵力约为50,000人。自1978年初欧加登战争结束时遭受严重损失后，SNA装备严重不足，他们不一定能和埃塞俄比亚人扳手腕。他们呼吁白宫/克里姆林方面兑现承诺。\n现在摆在我们的问题是，这到底是一场短暂的边境冲突，还是一次地缘政治大洗牌？"
const TXT_R2 := "大约10,000至15,000名埃塞俄比亚军队发动了入侵，他们装备了苏联提供的米格战斗机和t-55坦克。3000名SSDF成员同样装备了坦克，并得到了埃塞俄比亚炮兵和空军的支持。\n索马里国民军（SNA）只能派出2500名士兵参加边境战役。保卫边境地区的索马里部队指挥官是优素福·艾哈迈德·萨尔汉将军和他的下属穆罕默德·法拉·艾迪德准将，他指挥中央区军事区。西方观察家估计，在战役开始时，SNA的总兵力约为50,000人。自1978年初欧加登战争结束时遭受严重损失后，SNA装备严重不足，他们不一定能和埃塞俄比亚人扳手腕。他们呼吁白宫方面兑现承诺。\n现在摆在我们的问题是，这到底是一场短暂的边境冲突，还是一次地缘政治大洗牌？"

const WAR15_NAME := "索马里-埃塞边境冲突"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	event_def.description = TXT_DESC
	_enable(event_def.options[0], TXT_OPT0)
	_enable(event_def.options[1], TXT_OPT1)
	_enable(event_def.options[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var somalia := ws.get_country_by_legacy_index(42)
	var num := 100 if int(ws.completed_event_ids.get("event_587", 0)) == 2 else 0
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_ARMY, -100)
			_start_war_15(somalia, num, 500, 500, 16)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_ARMY, -100)
			_start_war_15(somalia, num, 300, 700, 16)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_ARMY, -50)
			_start_war_15(somalia, num, 400, 600, 4)
			context["result_text"] = TXT_R2


func _start_war_15(somalia: CountryData, num: int, infl1: int, infl2: int, tick: int) -> void:
	var ussr_side := 0 if somalia != null and somalia.has_tag("亲苏") else 1
	GameManager.start_war(15, "索马里", "埃塞俄比亚", infl1 + num, infl2 - num, -1, ussr_side)
	if ws.wars.size() > 15 and ws.wars[15] != null:
		ws.wars[15].name_war = WAR15_NAME
		ws.wars[15].fortnight_max = tick


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta
