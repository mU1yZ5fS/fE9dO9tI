extends "res://数据脚本/event_script_base.gd"

## 原作 Event502.cs：末法时代的黄褐色黎明（5选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT3_DIS := "我们已经下定了我们的决心！"
const TXT_R0_A := "《人民日报》发表社论《要问姓资姓社》”后，新的路线被确定了。“以反和平演变为中心”，“双重任务论”（阶级斗争和全面建设）代替了旧的路线。很快，出现了对于改革开放经济措施的部分逆转，比如叫停证卷交易所的开放，在文化生活上掀起对于精神污染的新一波打压。尽管有的经济结构与文化引入的恶果不是朝夕可以倒转的，但我们迈出了坚决地一步。人民对于突然出现的洗牌感觉困惑，而反对派惊呼我们开始了“新文革”。就让他们去骂吧-反正我们的投资者们还是会回来投资的。"
const TXT_R1_A := "很快，你亲自出面为改革的原则背书。一切偏离四项基本原则的言论和行动都是错误的，一切否定和破坏四项基本原则的言论和行动都是不能容许的，但是谁不改革谁就是和整个党对着干，就是“左”的余孽。《解放日报》发表了支持你的路线的言论。与此同时，你决定去这个国家南方巡查那些经济特区，开启了“第二次思想的大解放”。那些保守派在反对“左”的大棒下无地自容，我们胜利了！"
const TXT_R2_A := "很快，你决定在新的政治现实下采用颇具创造力的改革方案。在新的宪法中，中华民族的伟大复兴被提到，而特色社会主义的来源也被引用为“源自于中华民族五千多年文明历史所孕育的中华优秀传统文化”。同时，你进一步让步，通过援引先进社会生产力的发展要求，允许民族企业家进一步参与政治。在课本上，在书店里，在整个社会，潜移默化的变化正在发生-对于抽象的民族与国家的憎恨代替了对帝国主义的憎恨，对于“富国强兵”叙事的崇拜愈演愈烈……不过，我们仅仅是迈出了前往新秩序的第一步。"
const TXT_R3_A := "我们本来就是要为人民带来我们所定义的，作为从上到下政治改革的自由和民主，可事情的发展速度太快，人民的“自发性”太强，导致了转型要近乎功亏一篑，落入彻底的堪比文革的无序当中。幸好，还是有一类自由派值得信任的，而这一类自由派们还有最后一张底牌，那就是你。将镇压归功于“保守派”，你强调了改革依然处于正轨上并且将坚定不移地继续政改的决心。随着强力机关开始逐渐解绑于当获得“中立性”和自主性，那些旧秩序的卫士无力于蛰伏已久，等待用体制外自由派做血祭引诱旧秩序进入毁灭的体制内自由派的对手，纷纷遭到在事件中的责任性调查与追责，一些极端的军人甚至选择了自杀。当系统性的政治清洗结束后，很快将会迎来新的选举，而这一次，我们将用一切手段确信，“无序”的自由不会发生。"
const TXT_R4_A := "好吧，我们决定仅仅回击对于改革开放本身的攻击。不幸的是，没有任何人对我们对党内自由派的妥协感到满意，包括他们自己。天安门事件后，没有什么会和以前一样了……也许我们还可以等到下一代人的时候推行自由化，但当我们无法保证我们自己能做到的时候又怎么能指望下一代呢？"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)
	if ws.数值表[56] == 4:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], event_def.options[4].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c1 := ws.get_country_by_legacy_index(1)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			var fl_idx := -1
			if ws.factions.size() > 2 and ws.factions[2] != null:
				fl_idx = ws.factions[2].leader_index
			if fl_idx >= 0 and fl_idx < ws.politicians.size() and ws.politicians[fl_idx] != null:
				var fl: PoliticianData = ws.politicians[fl_idx]
				if ws.leader != null:
					PoliticianSystem.copy_leader_profile(ws.leader, fl)
				GameManager.kill_politician(fl_idx)
			# 原版 LeaderAsset = 0; MoneyLevel = 0; ServeRMB = false 为 display-only，跳过
			if ws.modifiers.size() > 65: ws.modifiers[65].is_active = false
			# 原版 GlobalScript.inst.gameState.ServeRMB = false；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			if ws.数值表[16] > 12:
				_add(16, -1)
			_set_data(15, 6)
			_set_data(17, 16)
			_set_data(50, 24)
			_add(8, -(40))
			_add(9, -(40))
			_add(1, -(200))
			_add(3, -(100))
			_add(4, -(150))
			_add(6, 80)
			_add_relation(0, -(150))
			_add_relation(1, 150)
			if c1 != null: c1.government = GameConstants.Government.AUTHORITARIAN
			if c1 != null: c1.sub_government = _chinese_sub_government()
			return
		1:
			context["result_text"] = TXT_R1_A
			if ws.数值表[16] < 14:
				_set_data(16, 14)
			else:
				if ws.数值表[16] == 14:
					_set_data(16, 15)
			_set_data(15, 6)
			_set_data(17, 16)
			_add(1, 100)
			_add(3, -(100))
			_add(4, -(100))
			if _mod(6):
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = "无 产 阶 级 专 政"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 无产阶级专政
				# 原版 GlobalScript.inst.gameState.doctr[8] = "人 民 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 人民民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = "协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = "经 典 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 经典计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = "中 式 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中式计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = "国 家 监 护 资 本 主 义"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 国家监护资本主义
				# 原版 GlobalScript.inst.gameState.doctr[14] = "社 会 主 义 导 向 市 场"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 社会主义导向市场
				# 原版 GlobalScript.inst.gameState.doctr[15] = "左 翼 小 政 府"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 左翼小政府
				# 原版 GlobalScript.inst.gameState.doctr[21] = "改 良 区 域 自 治 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 改良区域自治制度
				# 原版 GlobalScript.inst.gameState.doctr[22] = "联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[24] = "文 化 革 命"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 文化革命
			else:
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = " 一 党 制 共 和 国"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党制共和国
				# 原版 GlobalScript.inst.gameState.doctr[7] = "一 党 独 大 式 民 主"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党独大式民主
				# 原版 GlobalScript.inst.gameState.doctr[8] = " 宪 政 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 宪政民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = " 协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = " 中 央 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中央计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = " 分 权 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 分权计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = " 鸟 笼 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 鸟笼经济
				# 原版 GlobalScript.inst.gameState.doctr[14] = " “ 社 会 ” 市 场 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: “社会”市场经济
				# 原版 GlobalScript.inst.gameState.doctr[15] = " 最 小 干 预"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 最小干预
				# 原版 GlobalScript.inst.gameState.doctr[21] = " 联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[22] = " 联 省 自 治"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联省自治
				# 原版 GlobalScript.inst.gameState.doctr[24] = " 破 除 传 统"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 破除传统
			_add(8, -(40))
			_add(9, -(40))
			_add_relation(0, 150)
			_add_relation(1, -(150))
			if c1 != null: c1.government = GameConstants.Government.AUTHORITARIAN
			if c1 != null: c1.sub_government = _chinese_sub_government()
			return
		2:
			context["result_text"] = TXT_R2_A
			_add(1, 150)
			_add(3, 150)
			_add(4, -(100))
			_set_data(31, 900)
			_add(8, -(40))
			_add(9, -(40))
			_set_data(16, 14)
			_set_data(17, 16)
			_set_data(50, 29)
			_set_data(15, 6)
			if ws.modifiers.size() > 6: ws.modifiers[6].is_active = false
			if _mod(6):
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = "无 产 阶 级 专 政"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 无产阶级专政
				# 原版 GlobalScript.inst.gameState.doctr[8] = "人 民 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 人民民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = "协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = "经 典 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 经典计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = "中 式 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中式计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = "国 家 监 护 资 本 主 义"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 国家监护资本主义
				# 原版 GlobalScript.inst.gameState.doctr[14] = "社 会 主 义 导 向 市 场"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 社会主义导向市场
				# 原版 GlobalScript.inst.gameState.doctr[15] = "左 翼 小 政 府"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 左翼小政府
				# 原版 GlobalScript.inst.gameState.doctr[21] = "改 良 区 域 自 治 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 改良区域自治制度
				# 原版 GlobalScript.inst.gameState.doctr[22] = "联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[24] = "文 化 革 命"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 文化革命
			else:
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = " 一 党 制 共 和 国"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党制共和国
				# 原版 GlobalScript.inst.gameState.doctr[7] = "一 党 独 大 式 民 主"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党独大式民主
				# 原版 GlobalScript.inst.gameState.doctr[8] = " 宪 政 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 宪政民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = " 协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = " 中 央 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中央计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = " 分 权 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 分权计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = " 鸟 笼 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 鸟笼经济
				# 原版 GlobalScript.inst.gameState.doctr[14] = " “ 社 会 ” 市 场 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: “社会”市场经济
				# 原版 GlobalScript.inst.gameState.doctr[15] = " 最 小 干 预"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 最小干预
				# 原版 GlobalScript.inst.gameState.doctr[21] = " 联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[22] = " 联 省 自 治"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联省自治
				# 原版 GlobalScript.inst.gameState.doctr[24] = " 破 除 传 统"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 破除传统
			_add_relation(0, -(100))
			_add_relation(1, -(100))
			if c1 != null: c1.government = GameConstants.Government.AUTHORITARIAN
			if c1 != null: c1.sub_government = _chinese_sub_government()
			return
		3:
			context["result_text"] = TXT_R3_A
			_set_data(15, 8)
			_set_data(17, 16)
			if ws.数值表[16] > 14:
				_set_data(16, 14)
			_add(8, -(40))
			_add(9, -(40))
			_add(1, 50)
			_add(3, -(150))
			_add(4, -(50))
			_add_relation(0, 50)
			_add_relation(1, -(50))
			if ws.modifiers.size() > 6: ws.modifiers[6].is_active = false
			if _mod(6):
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = "无 产 阶 级 专 政"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 无产阶级专政
				# 原版 GlobalScript.inst.gameState.doctr[8] = "人 民 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 人民民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = "协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = "经 典 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 经典计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = "中 式 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中式计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = "国 家 监 护 资 本 主 义"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 国家监护资本主义
				# 原版 GlobalScript.inst.gameState.doctr[14] = "社 会 主 义 导 向 市 场"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 社会主义导向市场
				# 原版 GlobalScript.inst.gameState.doctr[15] = "左 翼 小 政 府"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 左翼小政府
				# 原版 GlobalScript.inst.gameState.doctr[21] = "改 良 区 域 自 治 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 改良区域自治制度
				# 原版 GlobalScript.inst.gameState.doctr[22] = "联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[24] = "文 化 革 命"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 文化革命
			else:
				pass
				# 原版 GlobalScript.inst.gameState.doctr[6] = " 一 党 制 共 和 国"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党制共和国
				# 原版 GlobalScript.inst.gameState.doctr[7] = "一 党 独 大 式 民 主"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 一党独大式民主
				# 原版 GlobalScript.inst.gameState.doctr[8] = " 宪 政 民 主 制 度"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 宪政民主制度
				# 原版 GlobalScript.inst.gameState.doctr[9] = " 协 和 民 主 体 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 协和民主体制
				# 原版 GlobalScript.inst.gameState.doctr[10] = " 中 央 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 中央计划经济
				# 原版 GlobalScript.inst.gameState.doctr[11] = " 分 权 计 划 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 分权计划经济
				# 原版 GlobalScript.inst.gameState.doctr[13] = " 鸟 笼 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 鸟笼经济
				# 原版 GlobalScript.inst.gameState.doctr[14] = " “ 社 会 ” 市 场 经 济"；display-only / 修正文案由 Godot 静态维护，跳过。文本: “社会”市场经济
				# 原版 GlobalScript.inst.gameState.doctr[15] = " 最 小 干 预"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 最小干预
				# 原版 GlobalScript.inst.gameState.doctr[21] = " 联 邦 制"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联邦制
				# 原版 GlobalScript.inst.gameState.doctr[22] = " 联 省 自 治"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 联省自治
				# 原版 GlobalScript.inst.gameState.doctr[24] = " 破 除 传 统"；display-only / 修正文案由 Godot 静态维护，跳过。文本: 破除传统
			if c1 != null: c1.government = GameConstants.Government.AUTHORITARIAN
			if c1 != null: c1.sub_government = _chinese_sub_government()
			return
		4:
			context["result_text"] = TXT_R4_A
			_add(1, -(300))
			_add(3, -(300))
			_add(4, 300)

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data[W.I_PARTY_SYSTEM] == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data[W.I_IDEOLOGY] <= 2 and data[W.I_ECON_SYSTEM] < 13 				and data[W.I_DIPLO] >= 700 and data[W.I_PARTY_SYSTEM] < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data[W.I_ECON_SYSTEM] >= 13 and data[W.I_WAR_SUPPORT] >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_WAR_SUPPORT] >= 700 				and data[W.I_DIPLO] >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data[W.I_ECON_SYSTEM] >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data[W.I_PARTY_SYSTEM] <= 7 				and data[W.I_ECON_SYSTEM] <= 12 and data[W.I_RELIGION] <= 25:
			result = 17
		elif data[W.I_IDEOLOGY] == 1 and not _mod_active(6) and data[W.I_RELIGION] <= 26:
			result = 16
		elif data[W.I_ECON_SYSTEM] < 13 and data[W.I_PRESS_POLICY] >= 17 				and data[W.I_IDEOLOGY] == 1 and data[W.I_RELIGION] <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(40):
			result = 8
		elif data[W.I_IDEOLOGY] >= 2 and data[W.I_ECON_SYSTEM] >= 13 				and data[W.I_DIPLO] <= 700 and data[W.I_PARTY_SYSTEM] >= 8 				and data[W.I_PRESS_POLICY] >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] >= 12 				and data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 300 				and data[W.I_TERRITORY] > 21 and data[W.I_WAR_SUPPORT] >= 700:
			result = 11
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 14 				and data[W.I_DIPLO] >= 500 and data[W.I_ECON_SYSTEM] > 11 				and data[W.I_WAR_SUPPORT] >= 400:
			result = 8
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 13 				and data[W.I_PRESS_POLICY] > 17:
			result = 3
		elif data[W.I_PARTY_SYSTEM] <= 8 				and (data[W.I_ECON_SYSTEM] == 13 or data[W.I_ECON_SYSTEM] == 12) 				and data[W.I_WAR_SUPPORT] < 700 and not _mod_active(3) 				and data[W.I_PRESS_POLICY] >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 500:
		result = 4
	elif (data[W.I_PARTY_SYSTEM] <= 8 and data[W.I_PRESS_POLICY] <= 18) 			or data[W.I_WAR_SUPPORT] >= 700:
		result = 12
	elif data[W.I_ECON_SYSTEM] > 13 and data[W.I_DIPLO] < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
