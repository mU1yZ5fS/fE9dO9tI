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



const TXT_R0 := "大约10,000至15,000名埃塞俄比亚军队发动了入侵，他们装备了苏联提供的米格战斗机和t-55坦克。3000名SSDF成员同样装备了坦克，并得到了埃塞俄比亚炮兵和空军的支持。\n索马里国民军（SNA）只能派出2500名士兵参加边境战役。保卫边境地区的索马里部队指挥官是优素福·艾哈迈德·萨尔汉将军和他的下属穆罕默德·法拉·艾迪德准将，他指挥中央区军事区。西方观察家估计，在战役开始时，SNA的总兵力约为50,000人。自1978年初欧加登战争结束时遭受严重损失后，SNA装备严重不足，对冲突准备不足。但好在有我们的志愿军，SNA得以获得歼-7战斗机和足够的火炮与反坦克火箭弹。\n现在摆在我们面前的问题是，这到底是一场短暂的边境冲突，还是一次地缘政治大洗牌？"
const TXT_R1 := "大约10,000至15,000名埃塞俄比亚军队发动了入侵，他们装备了苏联提供的米格战斗机和t-55坦克。3000名SSDF成员同样装备了坦克，并得到了埃塞俄比亚炮兵和空军的支持。同时我们也押宝于埃塞俄比亚，他们获得了我们的志愿者和武器装备。\n索马里国民军（SNA）只能派出2500名士兵参加边境战役。保卫边境地区的索马里部队指挥官是优素福·艾哈迈德·萨尔汉将军和他的下属穆罕默德·法拉·艾迪德准将，他指挥中央区军事区。西方观察家估计，在战役开始时，SNA的总兵力约为50,000人。自1978年初欧加登战争结束时遭受严重损失后，SNA装备严重不足，他们不一定能和埃塞俄比亚人扳手腕。他们呼吁白宫/克里姆林方面兑现承诺。\n现在摆在我们的问题是，这到底是一场短暂的边境冲突，还是一次地缘政治大洗牌？"
const TXT_R2 := "大约10,000至15,000名埃塞俄比亚军队发动了入侵，他们装备了苏联提供的米格战斗机和t-55坦克。3000名SSDF成员同样装备了坦克，并得到了埃塞俄比亚炮兵和空军的支持。\n索马里国民军（SNA）只能派出2500名士兵参加边境战役。保卫边境地区的索马里部队指挥官是优素福·艾哈迈德·萨尔汉将军和他的下属穆罕默德·法拉·艾迪德准将，他指挥中央区军事区。西方观察家估计，在战役开始时，SNA的总兵力约为50,000人。自1978年初欧加登战争结束时遭受严重损失后，SNA装备严重不足，他们不一定能和埃塞俄比亚人扳手腕。他们呼吁白宫方面兑现承诺。\n现在摆在我们的问题是，这到底是一场短暂的边境冲突，还是一次地缘政治大洗牌？"

const WAR15_NAME := "索马里-埃塞边境冲突"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)
	_enable(event_def.options[2], event_def.options[2].text)


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
			# 原版 TickTime(4)，但 TimeScript.WorldWarsDone 对 war15 另有 fortnight_go>=16 门槛，
			# 有效超时 = max(4,16)=16。
			_start_war_15(somalia, num, 400, 600, 16)
			context["result_text"] = TXT_R2


func _start_war_15(somalia: CountryData, num: int, infl1: int, infl2: int, tick: int) -> void:
	var ussr_side := 0 if somalia != null and somalia.has_tag("亲苏") else 1
	GameManager.start_war(15, "索马里", "埃塞俄比亚", infl1 + num, infl2 - num, -1, ussr_side)
	if ws.wars.size() > 15 and ws.wars[15] != null:
		ws.wars[15].name_war = WAR15_NAME
		ws.wars[15].fortnight_max = tick



