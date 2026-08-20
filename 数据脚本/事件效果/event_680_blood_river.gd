extends "res://数据脚本/event_script_base.gd"

## 原作 Event680.cs：血河奔流（喀麦隆反对派支援，手动事件，三选项）。
## 触发：DiploButtonScript.cs:1032 入口（selected_country==66）——科技《情报部门新装备》、
##   社会主义或改良主义、影响力>=300、未支持过（或上次选了“再想想”）。
## 入口扣费（data[9]-100 特工、data[22]-100 军力）在 外交互动_批4.gd:715-717 完成。
## 差异：原版 option1 禁用分支误写 button[0]/button_text[0]（Unity bug），按语义禁用 option1；
##   result2 的 event_done[680]=false → context["skip_mark_done"]=true。

const TXT_OPT0_DIS := "这不符合我们现在的政策"
const TXT_OPT1_DIS := "我们不能支持阴谋集团串联"
const TXT_R0 := "我国过去就在支持喀人盟，如今也应当重启这个政策。在外联部同志们的工作下，我们联系到了民主宣言运动和喀麦隆人民民主党等UPC的团体，帮助他们建立统一的领导集体，结束路线分歧和斗争，并在坦桑尼亚、赞比亚等非洲盟友和我国本土重启对UPC的援助和训练。在我们的支持下，喀人盟进行了组织整合和整顿，开始加强地下组织网络在全国的发展，强化在工人运动和工会中的渗透，并在农村组织土地斗争和对传统统治者的斗争。依托于已经重建的“人民解放阵线”并吸收上一次武装斗争失败的教训，喀人盟重组了喀麦隆民族解放军，重启游击战。与此同时，我们也帮助UPC同JOSE就未来进行城市游击的方针上同民族解放军的农村斗争进行配合的问题达成了共识。喀麦隆新殖民主义卖国统治集团也对喀人盟的“死灰复燃”进行了谴责和新的镇压，新的斗争开始了。"
const TXT_R1 := "马达加斯加和加纳等地的案例已经证明的这种革命路径的可行性，而过去喀人盟的武装斗争遭遇了巨大的牺牲，不能再花费如此大的代价了，一场政变或许能在伤亡更少的情况下更迅速地达成夺权的目标。在外联部同志们的工作下，一方面，我们帮助喀人盟进行了组织整合和整顿，帮助他们建立统一的领导集体，结束路线分歧和斗争；另一方面，我们对JOSE成员进行了培训，随后便在UPC和JOSE间组织了一场谈判。UPC和JOSE都存在泛非主义和爱国主义的共同基础，且都支持尽可能地联合反政府力量，双方很快就联合达成了协议，决定共同行动，渗透国家机器，并支持工人运动和农村发展，以便在革命行动时进行动员；喀人盟的“人民解放阵线”和地下网络也将为未来的政变提供武装支持。我们也坦桑尼亚、赞比亚等非洲盟友和我国本土进行对他们的的援助和训练。火种已经点燃，等待它未来的爆发吧。"
const TXT_R2 := "我认为UPC大势已去，JOSE难成大事。还是先同喀麦隆政府以及法国朋友打好交道吧，这比那些虚的更有用！"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var china := ws.get_country_by_legacy_index(1)
	var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	var opt := event_def.options
	if _res(W.I_POLITICAL_LINE) <= 1 and mod6 and ws.is_socialism(china, true) \
			and ws.influence_prc >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _res(W.I_POLITICAL_LINE) <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			var cameroon := ws.get_country_by_legacy_index(66)
			if cameroon != null:
				cameroon.level_of_instability = 10
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -75)
			_add(W.I_AGENTS, -75)
			_add(W.I_ARMY, -75)
		2:
			context["result_text"] = TXT_R2
			# 原版 event_done[680]=false：允许外交按钮再次触发。
			context["skip_mark_done"] = true
