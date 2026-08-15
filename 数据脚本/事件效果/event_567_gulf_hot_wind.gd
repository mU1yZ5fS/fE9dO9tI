extends "res://数据脚本/event_script_base.gd"

## 原作 Event567.cs：自由的热风（阿湾人阵重建，二选项）。
## 触发：DiploButtonScript.cs:11533 —— number_event = 567（外交按钮手动触发），无自动触发。
## 差异：
##  - parts[0] → _part(c24, 0)；cw → 内战中；proprc → 亲中；prcpower → prc_power；
##  - resultOfEvents 缺省按原版 int 默认 0 处理；
##  - event_done[567]=false → completed_event_ids.erase("event_567")（引擎随后会重新 _mark_done，
##    此处仅作源码等价标记，与 Event440/883 约定一致）。

const TXT_TITLE := "自由的热风"

const TXT_DESC := "佐法尔解放阵线成立于1962年，是一个包含阿拉伯社会主义者、佐法尔分离主义者、民主主义者、共和派甚至是保守的部落首领的反对派大帐篷，其目标是佐法尔独立以及促进阿拉伯民族统一。1963年6月9日，佐解阵的“六·九革命”拉开了斗争的序幕。\n1967年，佐解阵受挫后，席卷世界的左翼浪潮以及南也门独立和“解放巴勒斯坦人民阵线”（人阵）的成立深刻地影响了佐解阵，在1968年的佐解阵二大上，佐解阵被改组为奉行马克思列宁主义和毛泽东思想的“解放被占领的阿拉伯湾人民阵线”（后来与阿湾民阵合并为“解放阿曼和阿拉伯湾人民阵线”，皆简称阿湾人阵），其目标也转向解放包含阿曼、阿联酋、卡塔尔和巴林在内的整个阿拉伯湾，并在苏联和中国的支持下展开斗争。随着苏联对阿湾人阵的全方位援助以及大力干预，阵线内的亲苏派逐渐压倒了亲华派，毛泽东思想被放弃了。\n不久后，阿湾人阵的群众基础逐渐陷入崩溃。阿湾人阵在内部叛乱的影响和封建买办与帝国主义的联合绞杀下逐渐陷入失败。1974年，阿湾人阵重组为解放阿曼人民阵线和解放巴林人民阵线两个组织，规模显著缩小。1975年，阿曼人阵的所有根据地沦陷。1976年1月，阿曼人阵撤入南也门，只有部分游击小组留在阿曼，在南也门的支持下继续开展小规模的游击斗争。\n如今，也门进入了我们的阵营，并已实现完全统一，我们是否要在阿曼人阵和巴林人阵的基础上重建阿湾人阵，重新塑造他们的意识形态并帮助阿拉伯湾的人民再次开展他们的斗争？"

const TXT_OPT0 := "让我们支持阿拉伯湾人民对封建买办势力的斗争！"
const TXT_OPT0_DIS := "我们还能以社会主义者自居吗？"
const TXT_OPT1 := "还得再等等……"

const TXT_R0_A := "在我们外交人员的努力下，我们联系到阿曼人阵和巴林人阵，在也门开展了一场谈判，谈判最终决定，阿曼人阵和巴林人阵将重新组成解放被占领的阿拉伯湾人民阵线。在一场新的特别代表大会上，阿湾人阵宣布重建，而马克思列宁主义"
const TXT_R0_MAO := "和毛泽东思想"
const TXT_R0_B := "重新成为了阵线的指导思想，留在阿曼的游击小组也被改组为“阿拉伯湾人民解放军”。战斗仍将继续！…"
const TXT_R0_ELSE := "在我们外交人员的努力下，也门、埃及和利比亚同意继续为阿拉伯湾人民提供支持。我们联系到阿曼人阵和巴林人阵，在也门开展了一场谈判，谈判最终决定，阿曼人阵和巴林人阵将重新组成解放阿曼和阿拉伯湾人民阵线。在一场新的特别代表大会上，阿湾人阵宣布重建，并在也门、埃及和利比亚的影响下吸收了过去阿湾人阵宣扬无神论的教训，对伊斯兰教采取更温和的态度，将阿拉伯社会主义和泛阿拉伯主义列为指导思想。留在阿曼的游击小组也被改组为“阿拉伯湾人民解放军”。战斗仍将继续！"
const TXT_R1 := "重建阿湾人阵意味着在阿拉伯湾掀起与英美帝国主义的对抗，我们还没有准备好……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var china := world.get_country_by_legacy_index(1)
	var c30 := world.get_country_by_legacy_index(30)
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var cond := line <= 2 and china != null and (china.government == 1 or china.sub_government == 0 \
			or ((china.government == 2 or china.sub_government == 10 or china.sub_government == 22) \
			and c30 != null and c30.government == 2))
	if cond:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c23 := ws.get_country_by_legacy_index(23)
	var c24 := ws.get_country_by_legacy_index(24)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if _part(c24, 0):
				var text := TXT_R0_A
				if c24 != null and c24.has_tag("亲中"):
					text += TXT_R0_MAO
				text += TXT_R0_B
				if c24 != null:
					c24.内战中 = true
				context["result_text"] = text
			else:
				if c23 != null:
					c23.内战中 = true
				context["result_text"] = TXT_R0_ELSE
			if c24 != null:
				c24.prc_power = 50
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
		1:
			ws.completed_event_ids.erase("event_567")
			context["result_text"] = TXT_R1


func _part(c: CountryData, i: int) -> bool:
	return c != null and c.parts.size() > i and c.parts[i]
