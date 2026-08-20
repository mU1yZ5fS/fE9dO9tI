extends "res://数据脚本/event_script_base.gd"

## 原作 Event573.cs：地球那边的土地（澳大利亚审视，四选项）。
## 触发：ReqEventForDLC02.cs:779-782 —— (月>=8 且 年>=1982) || 年>=1983 → DATE_AFTER 1982.8.1。
## 差异：
##  - 选项按 data[56]（政治路线）动态显隐；
##  - Torg → 对华贸易；modifies[6].active → ws.modifiers[6].is_active；
##  - resultOfEvents[573] 缺省按原版 int 默认 0 处理。



const TXT_OPT0_DIS := "想想列宁是怎么评价澳大利亚的“自由党”的？"
const TXT_OPT1_DIS := "怎么能支持有种族歧视特色的社会主义者？想想“白澳政策”！"
const TXT_OPT2_DIS := "在英美两国亲自过问的澳大利亚煽动革命？你疯了？"

const TXT_R0 := "我们决定延续对澳大利亚的外交缓和政策——这似乎也是澳大利亚政治界内的普遍共识。不久弗雷泽便欣然接受我国邀请，启动第二次访华之旅。考虑到澳洲牧场与铁矿声名远扬，两国间当然有不少方面能求同存异，合作前景广阔！与此同时，我们得以顺腾摸瓜窥探澳洲内政情况——弗雷泽先生持改革立场，并希望对澳大利亚“自由党”与乡村党联合政府内部的暗面继续清洗……其性质类似我们先前交好的惠特拉姆，看起来他人确实没澳大利亚一些嬉皮士描绘的那么坏。"
const TXT_R1 := "虽然弗雷泽希望同我们进一步缓和关系，但你认为弗雷泽的步子还是“太小，太过保守”：中国需要的是不成文的密切合作伙伴关系——即类似夏尔·戴高乐与吉斯卡尔·德斯坦等致力的“法国”-“苏联”特殊关系。因此，我们将目光投向了老朋友工党。当然，中国代表团登陆澳洲本身便足以让弗雷泽喜出望外。考虑到澳洲牧场与铁矿声名远扬，两国间当然有不少方面能求同存异，合作前景广阔！与此同时，我们得以顺腾摸瓜窥探澳洲内政情况——由于惠特拉姆的执政失当，其政治生涯已然结束。工党内部正接受保罗·基庭和金·本兹利等新一代领导人的“新思维”洗礼。该党的内部洗牌为我们安排工党候选人鲍勃·霍克就位做好了准备：他与工党“硬左派“成员克莱德.卡梅隆律师密切合作，并背靠反战运动和工会组织。这次会议的后续影响犹未可知，不过我们应该开了个好头。"
const TXT_R2_A := "不久弗雷泽便欣然接受我国邀请，启动第二次访华之旅。然而这只是明修栈道，暗度陈仓。我们并不指望能和自由派达成多少共识，只是让其以为我们仍致力于所谓“缓和事业”。与此同时，我国特工同澳共（马列）内老同志E·F·“泰德”·希尔建立了联系。"
const TXT_R2_B := "虽说我国的政治变动部分使得希尔不若以往那般“忠诚”，并使其转向所谓“独立的澳大利亚社会主义道路”，但他依然欢迎我们的帮助。"
const TXT_R2_C := "虽说在短期内将成员甚至不到400人的澳共（马列）组织成革命先锋队与强大的群众政党堪称天方夜谭，但办法总比问题多：希尔同工党“硬左派“克莱德·卡梅隆律师协助推进改良立法的人脉，在全澳大利亚工会界的美名乃至其对“电车与巴士工会”和“维多利亚水道工人工会”的影响力足以使我们借题发挥，并采用“冰山策略”扩展澳共（马列）及同情组织。上述政策甚至吸引到了沉迷于欧洲共产主义实践的澳共注意：考虑到”左翼联合“政策四处碰壁，该党基层党员们自然会重新审视看起来更成功的方略。"
const TXT_R3 := "不久弗雷泽便欣然接受我国邀请，启动第二次访华之旅。我们将延续对澳大利亚的外交缓和政策……可在双方均缺乏决定性改变的情况下，上述缓和事实上程度有限。澳大利亚的社会氛围倾向保守反共，他们甚至三年前才算完全废除了白澳政策。看起来往里面投资似乎毫无意义，对吧？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line > 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line != 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line <= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c135 := ws.get_country_by_legacy_index(135)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if c135 != null:
				c135.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 100)
			_add_power(EmpireData.USA, 10)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -80)
			if c135 != null:
				c135.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			context["result_text"] = TXT_R1
		2:
			var text := TXT_R2_A
			if not _mod_active(6):
				text += TXT_R2_B
			text += TXT_R2_C
			_add(W.I_AGENTS, -100)
			context["result_text"] = text
		3:
			context["result_text"] = TXT_R3


func _mod_active(id: int) -> bool:
	return ws.modifiers.size() > id and ws.modifiers[id] != null and ws.modifiers[id].is_active
