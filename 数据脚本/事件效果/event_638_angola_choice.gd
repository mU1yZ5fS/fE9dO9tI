extends "res://数据脚本/event_script_base.gd"

## 原作 Event638.cs：前进，安哥拉（安哥拉派系抉择，四选项）。
## 触发：DiploButtonScript.cs:12163 —— 外交按钮 1049，手动 StartEvent(638)。
## 差异：原版选项0选择"再想想"时 event_done[638]=false 允许按钮重选；
##   Godot 经 context["skip_mark_done"] 由 EventEngine 跳过完成标记（见 event_engine 注释）。
##   science[19]→techs.unlocked[19]；prcpower/sovpower/usapower→prc_power/sov_power/usa_power。

const TXT_DESC_PRE := "安哥拉是葡萄牙的非洲殖民地中最出名的一块。自冷战以来，诸多超级大国都纷纷把这里当做一块棋盘，就连我国也曾经在独立战争中支持过该国的反抗组织。在葡萄牙的康乃馨革命之后，原先尚能面对共同敌人而团结一致的各个团体立刻陷入了内斗中（争取卡宾达飞地解放阵线除外，该组织由于丝毫不掩饰它的分离主义倾向而被所有势力甚至葡萄牙所反对）。现在随着我们试图在各个战线击败我们的国际对手，是时候下定决心支持某一派系了。但就在做决定前，还请允许我介绍一下目前的局势：\n首先是安哥拉人民解放运动——劳动党，该党是目前的安哥拉合法政府。"
const TXT_DESC_MPLA_100 := "得益于我们的支持，安哥拉共产主义组织得以借壳上市。该党支持毛泽东思想并反对超级大国对南部非洲的干涉，古巴驻军对他们的存在保持担心。"
const TXT_DESC_MPLA_200 := "尼托·阿尔维斯在我们的帮助下确保了自己对安人运的控制，目前该党对我们的路线保有兴趣，但在关于经济话题上仍然有值得讨论的空间。古巴驻军对他们的存在保持怀疑。"
const TXT_DESC_MPLA_ELSE := "该党由强硬的亲苏派多斯桑托斯控制，并获得了古巴驻军的支持。"
const TXT_DESC_TAIL := "\n然后是大名鼎鼎的争取安哥拉彻底独立联盟。该党目前由若纳斯·萨文比所统帅。我们曾在该党露出真面目前支持过他们。在古巴军队的攻势下，该党目前退守万博，并建立了安哥拉民主主义人民共和国。而且白人南非政权也大力支持该组织，南非政权的雇佣兵多次越境打击藏身安哥拉的SWAPO和SWANU游击队。\n随后是安哥拉民族解放阵线，这是一个为该国的独立立下汗马功劳的组织。党主席奥尔登·罗伯托曾是刚果王国的合法王储，但最终毅然决然的选择踏足政治而非当皇太子。该党是非盟曾经背书的最早的，也一度是最大的安哥拉独立力量，直到UNITA的异军突起，随后便慢慢淡出了视野。不过罗伯托的妹夫蒙博托·塞塞·塞科依然在支持着他们，他们也许能够成为我们的盟友。\n主席同志，我们要支持谁？"
const TXT_OPT0_DIS := "要安哥拉不要赤匪的安哥拉！"
const TXT_OPT1_DIS_0 := "我们被假毛派害得还不够惨么？"
const TXT_OPT1_DIS_ELSE := "就我而言，他也太过份了"
const TXT_OPT2_DIS_0 := "他不会成为最优解的"
const TXT_OPT2_DIS_ELSE := "安解阵，三振出局！"
const TXT_R0_PRE := "我们决定支持安人运政府，很快大量的武器便被送入了罗安达。不久之后，安人运的学员和教官也将来到我国的军校学习作战经验。在我们的号召下"
const TXT_R0_TAIL := "纷纷表示愿意提供资金和弹药。坦桑尼亚和赞比亚更是成为了安人运政府的后勤保障基地。相信在不久的将来，安哥拉将彻底解放。"
const TXT_R1 := "我们决定支持萨文比和安盟，一如60年代一样，很快大量的武器便被送入了万博。不久之后，安盟的学员和教官也将来到我国的军校学习作战经验。但非洲国家对我们的选择表示十分困惑和难以理解。但美国高兴的支持了我们的选择，并额外提供了一笔资金。相信在不久的将来，安哥拉将彻底解放。"
const TXT_R2 := "我们决定支持罗伯托和安解阵，一如60年代一样，很快大量的武器便被赠送给了蒙博托，由他转赠给安解阵。不久之后，安解阵的学员和教官也将来到我国的军校学习作战经验。但非洲国家对我们的选择表示十分困惑和难以理解。但美国高兴的支持了我们的选择，并额外提供了一笔资金。相信在不久的将来，安哥拉将彻底解放。"
const TXT_R3 := "没事的主席同志，其实安哥拉人并没有那么脆弱。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var angola := ws.get_country_by_legacy_index(123)
	var branch := TXT_DESC_MPLA_ELSE
	if angola != null:
		if angola.level_of_instability == 100:
			branch = TXT_DESC_MPLA_100
		elif angola.level_of_instability == 200:
			branch = TXT_DESC_MPLA_200
	event_def.description = TXT_DESC_PRE + branch + TXT_DESC_TAIL
	var has_tech19 := ws.techs != null and ws.techs.unlocked.size() > 19 and ws.techs.unlocked[19]
	var opt := event_def.options
	var line := _res(W.I_POLITICAL_LINE)
	if not has_tech19:
		# 原版 :63-70：science[19] 未完成时三选项 Destroy，仅"再想想"
		_disable(opt[0], "")
		_disable(opt[1], "")
		_disable(opt[2], "")
		_enable(opt[3], event_def.options[3].text)
		return
	if line < 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line != 4 and line != 0:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], TXT_OPT1_DIS_0)
	else:
		_disable(opt[1], TXT_OPT1_DIS_ELSE)
	var zaire := ws.get_country_by_legacy_index(117)
	if line > 0 and zaire != null and zaire.has_tag("对华贸易") and zaire.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST \
			and (ws.is_authoritarian(zaire) or zaire.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE):
		_enable(opt[2], event_def.options[2].text)
	elif line == 0:
		_disable(opt[2], TXT_OPT2_DIS_0)
	else:
		_disable(opt[2], TXT_OPT2_DIS_ELSE)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var angola := ws.get_country_by_legacy_index(123)
	if angola != null:
		angola.prc_power = 600
		angola.sov_power = 300
		angola.usa_power = 100
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var names := ""
			for c in ws.countries:
				if c == null:
					continue
				var i := c.原版序号
				if ((i > 53 and i < 69) or (i > 105 and i < 109) or (i > 111 and i < 134) \
						or i == 41 or i == 42 or i == 52 or i == 99 or i == 100 \
						or i == 150 or i == 151 or i == 155 or i == 158) \
						and i != 55 and i != 54 and i != 128 and i != 123 \
						and c.has_tag("亲中"):
					names += "，" + c.display_name()
			context["result_text"] = TXT_R0_PRE + names + TXT_R0_TAIL
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, 50)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, -100)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, -100)
		3:
			context["result_text"] = TXT_R3
			# 原版 :115 event_done[638]=false → 跳过完成标记，外交按钮可再次选择
			context["skip_mark_done"] = true
