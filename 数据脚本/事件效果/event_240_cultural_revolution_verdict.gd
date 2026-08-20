extends "res://数据脚本/event_script_base.gd"

## 原作 Event240.cs：革命无罪，造反另说（十一届全会评定文革遗产，4 选项）。
## 触发：TimeScript.cs:10206-10212 ——
##   ((日>=12 且 月>=8 且 年>=1977) 或 (月>=9 且 年>=1977) 或 年>=1978)
##   且 data.gang_of_four_path==3 且 !event_done[240]。
## 差异：
##  - 选项1 原版按 data.gang_of_four_path==3 决定按钮文案（真=“不偏不倚…”，假=销毁按钮换“文革已经得罪了所有人啦”），
##    本版用 enable_condition + disabled_text 等价建模。
##  - party_change[] 仅 UI 摆动数值，Godot 建模说明，跳过。
##  - 原版逐 if/else-if 忠诚链与 >0/<3 边界逐字保留。

const TXT_R0 := "毛主席发动文化大革命的初心是为了打击党内一小撮走资本主义路线的党权派，如今他们已经被革命群众全部消灭，这说明主席的目标已经达成，如果再让人民群众进行这么多缺少纪律的运动，国家若再陷入混乱那就是背离毛主席的本意了。最终华国锋通过自己的威望成功的说服了大部分代表，中央得以在最终决议上庄严的宣布持续十余年之久的无产阶级文化大革命在反革命的覆灭后得以“胜利结束”。在此之后，华国锋在会上宣布将继续毛泽东的事业，并提出“凡是毛主席作出的决策，我们都坚决维护，凡是毛主席的指示，我们都始终不渝地遵循”的“两个凡是”作为新的政治纲领代替旧文革路线，中国将沿着毛主席所指的道路，建设一个富强稳定的社会主义国家。\n群众对反革命势力得以“肃清”与文革的“最终胜利”感到高兴，但极左派却对于这项决定感到无比的失望与担忧，他们认为华国锋将文化大革命的理论庸俗化了，部分成员已经认为华国锋已经背叛了毛泽东的革命事业，准备在此密谋对抗，但极左派的力量得以延续至今，很大程度上是依靠着与华国锋的盟约，且如今作为他们生存基础的文革路线已经消失，极左派们的“革命道路”还能走多远呢？"

const TXT_R1 := "无产阶级文化大革命是一场触及人们心灵的大革命，绝不是清除了某几个走资派就能宣告胜利结束的，它将为我国人民捍卫无产阶级专政提供最重要的思想武器，是毛主席最宝贵的革命遗产。在粉碎叶剑英军事阴谋集团的行动中极左派的表现无疑十分亮眼，他们成功的向世人展现了革命群众的无穷力量，这也让他们在党内积攒起了空前的威望，在极左派的努力下，毛泽东主席晚年最重要的理论与实践成果得以保留，且在大会的最终决议里，成功的将“坚持在无产阶级专政之下继续革命”等文革重要理论写入党章，显然，中国还会继续坚持最激烈的反修正主义路线。华国锋等保守派对于现状的保持十分不满，但迫于毛主席的“最高指示”他们不能表现出太大的不满，但可以预知的事，他们绝不会将毛泽东的遗产拱手让人，在不久的将来也定会给极左派持续造成威胁。随着持续十余年的运动热情逐渐走向冷却，人民群众对于大会的决议并没有感到兴奋，甚至已经觉得厌烦，极左派若有意将文化大革命的运动常态化，就必须想办法重新点燃群众的热情。对此，极左派依然表现得信心十足……\n历经波折，毛主席最骄傲的门徒们终于有了一个机会去挥舞导师所留下的宝剑，但他们的前途仍然崎岖而坎坷的，道路在何方？这一切仍需要时间验证……"

const TXT_R2 := "你说文化大革命已经完成了它的历史任务，所以你开始消灭文化大革命的最后遗产。同时，您特别强调了中国调整经济结构和进行现代化建设的必要性，您还没有提出具体的措施，但改革派和人民正在等待着中国的改变，期望您让它变得更好。"

const TXT_R3 := "你说要迅速消灭文化大革命的遗毒，这是党和人民都喜欢的。同时，您也谈到了中国经济进一步市场化改革的必要性，以及如何逐步进入世界市场的问题。为此，您开始积极推动赵紫阳、邓小平等老改革家回归，使他们回到了副总理的位置。人民在等待着中国的变化，但党内的保守派对你的决定表示不满。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_set_modifier_off(3)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 100
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty += 80
				elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					p.loyalty -= 100
				elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty += 50
			_set_data(W.I_POST_MAO_COURSE, 1)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add(W.I_DIPLO, 100)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 100
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty += 80
				elif p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 200
					p.power -= 100
			_set_data(W.I_POST_MAO_COURSE, 2)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, -10)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 80)
			_set_modifier_off(3)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 20
				elif p.trait_personality < GameConstants.PoliticianPersonality.LIBERAL:
					p.loyalty += 100
			_set_data(W.I_POST_MAO_COURSE, 3)
			context["result_text"] = TXT_R2
		3:
			_add(W.I_PEOPLE_SUPPORT, 80)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_set_modifier_off(3)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 100
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty -= 50
				elif p.trait_personality > GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty += 100
			_set_data(W.I_POST_MAO_COURSE, 4)
			context["result_text"] = TXT_R3




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)




func _set_modifier_off(index: int) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = false
