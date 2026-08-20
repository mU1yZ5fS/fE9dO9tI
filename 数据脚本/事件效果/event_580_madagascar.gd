extends "res://数据脚本/event_script_base.gd"

## 原作 Event580.cs：哦，我们亲爱的祖国（马达加斯加，四选项）。
## 触发：ReqEventForDLC02.cs:809-812 —— (月>=5 且 年>=1979) || 年>=1980 → DATE_AFTER 1979.5.1。
## 差异：
##  - 选项显隐 prepare 动态改写；isSEV → sev 标签；Torg → 对华贸易；
##  - data[6] → W.I_DIPLO；proprc/prosov → 亲中/亲苏；puppetOf → puppet_of。



const TXT_OPT0_DIS := "我们对他们的要求太过激进了"
const TXT_OPT1_DIS := "为什么要和苏联人勾肩搭背"
const TXT_OPT2_DIS := "法国人？他们本来也不属于这里"

const TXT_R0 := "在我们大量的经济援助下，马达加斯加迅速摆脱了财政危机，拉齐拉卡也宣布拒绝经济改革，继续保持国有化政策以及加速发展合作社，邀请中国顾问帮助建设，并逐步开始推行温和的宗教管控，我们串联了全国保卫革命阵线内的亲中政党无产阶级掌权党和争取马达加斯加独立全国运动以及前马达加斯加共产党党员并重组了马达加斯加共产党，得益于我们的援助，新组建的马达加斯加共产党获得了较大的影响力并在内阁中获得了更多的职位。在国际事务上马达加斯加亦变得更亲近中国阵营。"
const TXT_R1 := "在我们和苏联的共同援助下，马达加斯加迅速摆脱了财政危机，拉齐拉卡也宣布拒绝经济改革，决定以苏式社会主义为建设样板将工业进行全面国有化并邀请苏联顾问帮助建设。全国保卫革命阵线内的亲苏左翼政党独立大会党因此得以获得更大的影响力并参与组阁。马达加斯加在国际事务中也紧跟苏联老大哥的步伐。"
const TXT_R2 := "在我们的大使与法国的会谈中，暗示了我们对拉齐拉卡的经济改革的不满，并支持法国人出手稳定马达加斯加。\n在拉齐拉卡宣布经济改革之前，法国宣布封锁马达加斯加。在法国特工和马达加斯加社民党等反对派的鼓动下，塔那那利佛市开始出现要求增加消费品和经济改革，要求拉齐拉卡下台开放选举的游行。总统府前，总统护卫队不幸擦枪走火，现场打死数十名游行群众。消息很快便传遍了全国，全国爆发了一次反对拉齐拉卡的游行示威，军队内部也军心不稳，拉齐拉卡被迫宣布下台并进行选举。最后马达加斯加社民党总统候选人，前马达加斯加共和国副总统拉贝马南贾拉获选。新政府更名为马达加斯加共和国，并取缔马达加斯加革命先锋等数个左翼党派，开放选举并进行亲法亲西方外交，放开外资和私有限制。"
const TXT_R3 := "拉齐拉卡宣布了经济改革计划，在之后数年，允许了法资等外资进入国内，福科诺洛纳社会主义逐渐破产，外交也逐渐向中立外交转变。马达加斯加民主共和国的未来究竟是什么样子，只有后人才知道……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var c21 := world.get_country_by_legacy_index(21)
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null else 0
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	var china_sev := china != null and china.has_tag("sev")
	if line < 3 and (china_sev or ussr_rel >= 700):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data.size() > W.I_DIPLO and data[W.I_DIPLO] <= 800 and c21 != null and c21.has_tag("对华贸易"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c133 := ws.get_country_by_legacy_index(133)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -70)
			if c133 != null:
				c133.government = GameConstants.Government.SOCIALIST
				c133.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c133)
				c133.set_tag("亲中", true)
				c133.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add(W.I_DIPLO, 20)
			context["result_text"] = TXT_R0
		1:
			if c133 != null:
				c133.government = GameConstants.Government.SOCIALIST
				c133.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c133)
				c133.set_tag("亲苏", true)
				c133.set_tag("对华贸易", true)
				c133.set_tag("sev", true)
			_add(W.I_BUDGET, -30)
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USSR, 150)
			context["result_text"] = TXT_R1
		2:
			if c133 != null:
				c133.government = GameConstants.Government.LIBERAL
				c133.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				_leave_alliances(c133)
				c133.puppet_of = 21
				c133.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, -300)
			context["result_text"] = TXT_R2
		3:
			if c133 != null:
				c133.government = GameConstants.Government.REFORMIST
				c133.sub_government = GameConstants.SubGovernment.PRAGMATIST
			context["result_text"] = TXT_R3
