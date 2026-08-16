extends "res://数据脚本/event_script_base.gd"

## 原作 Event680.cs：血河奔流（喀麦隆反对派支援，手动事件，三选项）。
## 触发：DiploButtonScript.cs:1032 入口（selected_country==66）——科技《情报部门新装备》、
##   社会主义或改良主义、影响力>=300、未支持过（或上次选了“再想想”）。
## 入口扣费（data[9]-100 特工、data[22]-100 军力）在 外交互动_批4.gd:715-717 完成。
## 差异：原版 option1 禁用分支误写 button[0]/button_text[0]（Unity bug），按语义禁用 option1；
##   result2 的 event_done[680]=false → context["skip_mark_done"]=true。

const TXT_TITLE := "血河奔流"
const TXT_DESC := "早在二战后，费利克斯·罗兰·穆米埃、鲁本·乌姆·尼奥贝和欧内斯特·万迪埃等进步人士便于1948年创立了喀麦隆人民联盟（UPC），以《联合国宪章》为依据，用和平方式斗争，主张推动喀麦隆自治独立、结束英法托管并实现国家统一。但是殖民当局以暴力镇压乃至取缔作为回应。1956年12月，喀人盟在萨纳加地区发起武装起义，并在之后组建了喀麦隆民族解放军，游击战争蔓延至喀麦隆全国多地，并受到了非洲进步国家和社会主义阵营的支持。在喀麦隆于1960年的“独立”与多数法属非洲殖民地如出一辙，是在法国扶持的阿赫马杜·阿希乔等亲法势力的主导下完成的。而“独立”后的轨迹也高度重合——掌权者迅速推进集权化，通过谈判与威胁并用的手段，将全国多数政党整合为执政党“喀麦隆民族联盟”，由此将多党民主体制彻底转变为一党专制。在这样一个政权的统治下，国家自然也是染上了部族主义、独裁专制、政治腐败和新殖民主义的通病。喀麦隆人民自然不愿意在这样的情况下独立，UPC谴责这样的假独立，并对亲法当局进行武装斗争，阿希乔政府一边假意“招降”，一边联合法国进行镇压。法军在当地的法西斯暴行远超阿尔及利亚战争，他们屠杀当地群众，制造京观，甚至开展了砍人头比赛。在穆米埃、尼奥贝和万迪埃陆续牺牲后，喀人盟的武装斗争也因路线斗争和当局的残酷镇压，陷入了失败。此后，喀人盟在社会主义阵营和法国等多地进行流亡，在国内也仍然留存地下组织网络。目前，喀人盟由勒内·旺利-马萨加等人领导，他们在喀麦隆西部和南部丛林已经重建“人民解放阵线”（FPL），通过主张马列主义的“民主宣言运动”（MANIDEM）吸纳青年知识分子，在杜阿拉、雅温得等地建立秘密据点，开展罢工、破坏基础设施等活动；在法国，喀人盟通过喀麦隆民主斗争组织（OCLD）和喀麦隆人民民主党（DPK）等掩护组织进行活动。不过，UPC现在仍然存在派系分裂、路线分歧和缺乏统一领导集体的问题。\n与此同时，在1975年以来，喀麦隆军队的部分爱国进步低级军官组织了一个名为“为国家生存而战的年轻军官”（JOSE）的运动，该运动对现政权的政治经济政策以及腐败和部族主义充斥国家不满，在喀麦隆军中和民间已经发展一些秘密小组，运动中有部分成员是马克思主义者，他们受到部分非洲国家的由进步青年军官主导的政变式革命影响，计划通过政变甚至是城市游击运动进行夺权和革命。\n同志，我们可以选择两种道路，一是帮助UPC整顿组织并恢复武装斗争，通过人民战争推翻新殖民主义者的傀儡；二是将UPC和JOSE运动联合起来，建立一个广泛的联盟，通过政变来进行一场革命，部分同志认为通过政变来革命是布朗基主义，不过马达加斯加和加纳等地的军官革命也为我们提供了先例。不过，我们有必要破坏1971年与喀麦隆建交以来两国的友谊吗？"
const TXT_OPT0 := "在非洲盟友的支持下，帮助UPC整顿组织并重启武装斗争"
const TXT_OPT0_DIS := "这不符合我们现在的政策"
const TXT_OPT1 := "应该支持新的道路，联合JOSE和UPC"
const TXT_OPT1_DIS := "我们不能支持阴谋集团串联"
const TXT_OPT2 := "不要破坏我们和喀麦隆的关系"
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
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _res(W.I_POLITICAL_LINE) <= 2:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)


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
