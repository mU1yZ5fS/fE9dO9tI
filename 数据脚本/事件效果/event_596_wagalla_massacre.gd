extends "res://数据脚本/event_script_base.gd"

## 原作 Event596.cs：瓦加拉大屠杀（event_596，三选项）。
## 触发：TimeScript.cs:10929-10934 —— 日期>=1984.2.10 && IsSocialism(false,119)（肯尼亚非社会主义）&& c42.SubGosstroy==10 && (c42.亲中||c42.亲苏)；c41/c42 parts 建模说明恒真跳过。
## 差异：
##  - 原版 SubGosstroy!=10 分支的空白禁用选项在 .tres 中保留空 text 的 _disable 实现；
##  - AmericanSupportDefender.SovietSupportAttacker → usa_side = GameConstants.WarSide.SIDE2/ussr_side = GameConstants.WarSide.SIDE1；
##  - 仅 AmericanSupportDefender → usa_side = GameConstants.WarSide.SIDE2/ussr_side = GameConstants.WarSide.NONE；
##  - TickTime(24) → fortnight_max=24。

const TXT_DESC_BASE := "1984年2月，肯尼亚东北省的瓦吉尔镇爆发了一次部族冲突，肯尼亚国防军奉命制止冲突，随后将五千余名当地人赶到瓦加拉机场的跑道上，一周之内断绝了他们的水源和粮食并开枪随意射杀。索马里当局对此十分不满，并要求肯尼亚政府停止种族屠杀，否则将会推翻现政权并进行占领。"
const TXT_DESC_EXTRA := "我们是否可以借此机会彻底打击肯尼亚的种族灭绝行为，或者对拥有着大索马里美梦的索马里进行一次打击？"

const TXT_OPT0_DIS := "他们不愿意听我们的话"
const TXT_OPT1_DIS := "支持他？这是给我们的敌人递子弹！"

const TXT_R0_A := "在肯尼亚未作出回应之前，新华社发表社论支持索马里人民反抗肯尼亚反动政权并回到索马里的斗争，东北省人民进步党这个曾经试图让东北省重新加入索马里的组织重组了起来并在我们特工的协助下在东北省进行袭扰战，与此同时，索马里也宣布对肯尼亚再次发动战争并试图收复东北省，大量来自东方的货轮正在摩加迪沙港卸下“拖拉机”等“农业设备”，"
const TXT_R0_B := "古巴雇佣兵又一次踏上了东非这片土地，"
const TXT_R0_C := "而来自英国军火和西方的雇佣兵开始在肯尼亚出现。索马里和肯尼亚又一次爆发了战争。"
const TXT_R1_A := "在我们的大力支持下，肯尼亚宣布拒绝接受索马里的条件，并提前在边境地区做好准备以痛击来侵之敌。大量来自东方的货轮正在蒙巴萨港卸下“拖拉机”等“农业设备”，来自英国军火和西方的雇佣兵开始在肯尼亚出现，"
const TXT_R1_B := "索马里开始对肯尼亚宣战，古巴的雇佣兵和苏联的顾问又一次踏上了东非的土地。"
const TXT_R1_C := "索马里在内部混乱之下仓促宣战。"
const TXT_R1_D := "索马里和肯尼亚又一次爆发了战争。"
const TXT_R2 := "肯尼亚被迫答应了要求，释放了被押的索马里人。即将到来的索肯大战也随之消逝。"

const WAR50_NAME := "索马里-肯尼亚战争"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var somalia := world.get_country_by_legacy_index(42)
	var china := world.get_country_by_legacy_index(1)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var somalia_proprc := somalia != null and somalia.has_tag("亲中")
	var somalia_prosov := somalia != null and somalia.has_tag("亲苏")
	var china_sev := china != null and china.has_tag("sev")
	var opt := event_def.options
	if somalia != null and somalia.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		event_def.description = TXT_DESC_BASE + TXT_DESC_EXTRA
		if line <= 2 and (somalia_proprc or (somalia_prosov and china_sev)):
			_enable(opt[0], event_def.options[0].text)
		else:
			_disable(opt[0], TXT_OPT0_DIS)
		if line >= 2 and (not somalia_proprc or (somalia_prosov and not china_sev)):
			_enable(opt[1], event_def.options[1].text)
		else:
			_disable(opt[1], TXT_OPT1_DIS)
		_enable(opt[2], event_def.options[2].text)
	else:
		event_def.description = TXT_DESC_BASE
		_disable(opt[0], "")
		_disable(opt[1], "")
		_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var somalia := ws.get_country_by_legacy_index(42)
	var kenya := ws.get_country_by_legacy_index(119)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_A
			if somalia != null and somalia.has_tag("亲苏"):
				text += TXT_R0_B
			text += TXT_R0_C
			_start_war_50(somalia, 0)
			if kenya != null:
				while kenya.parts.size() <= 0:
					kenya.parts.append(false)
				kenya.parts[0] = true
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -80)
			context["result_text"] = text
		1:
			var text := TXT_R1_A
			if somalia != null and somalia.has_tag("亲苏"):
				text += TXT_R1_B
			elif somalia == null or not somalia.has_tag("亲中"):
				text += TXT_R1_C
			text += TXT_R1_D
			_start_war_50(somalia, 1)
			if kenya != null:
				while kenya.parts.size() <= 0:
					kenya.parts.append(false)
				kenya.parts[0] = true
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -80)
			context["result_text"] = text
		2:
			context["result_text"] = TXT_R2


func _start_war_50(somalia: CountryData, branch: int) -> void:
	var prosov := somalia != null and somalia.has_tag("亲苏")
	if branch == 0:
		if prosov:
			GameManager.start_war(50, "索马里", "肯尼亚", 750, 250, 1, 0)
		else:
			GameManager.start_war(50, "索马里", "肯尼亚", 700, 300, 1, -1)
	else:
		if prosov:
			GameManager.start_war(50, "索马里", "肯尼亚", 550, 450, 1, 0)
		else:
			GameManager.start_war(50, "索马里", "肯尼亚", 450, 550, 1, -1)
	if ws.wars.size() > 50 and ws.wars[50] != null:
		ws.wars[50].name_war = WAR50_NAME
		ws.wars[50].fortnight_max = 24



