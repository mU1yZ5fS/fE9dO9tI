extends "res://数据脚本/event_script_base.gd"

## 原作 Event497.cs：恩古瓦比的大会？——第二幕（刚果党代会，四选项）。
## 触发：TimeScript.cs:11006-11012 —— (日>=17 且 月>=10 且 年>=1984
##   或 月>=11 年>=1984 / 年>=1985) && c52.Gosstroy==1 && c52.SubGosstroy!=16。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 + relres flag + c1.sev + c52.对华贸易）。
##  - IsSocialism(true, 1) → ws.is_socialism(china, true)（严格社会主义判定）。
##  - LeaveAlliances() 逐项清标签（同 Event587 约定）。



const TXT_OPT0_DIS := "我们没必要把手伸到非洲去"
const TXT_OPT1_DIS := "我们没必要为苏联人做事"
const TXT_OPT2_DIS := "我们不会支持他"

const TXT_R0 := "我们的人适时地点醒了契卡雅同志。萨苏食用了苏联人送的鱼子酱，这导致他因食物中毒“意外”身亡。我们设法争取到部分军事派系、部分党代会代表、甚至是前M-22成员和八月革命元老克洛德-欧内斯特·恩达拉及其背后的南方人的支持，萨苏派的成员成功被排除在权力之外，让-皮埃尔·蒂斯特雷·契卡雅成功成为了新的领导人。他没有忘记是谁帮助了他，在大会上，前M-22的成员被大幅提拔。契卡雅总统宣布，刚果将彻底与新殖民主义决裂，回到真正的马列主义和由恩古瓦比同志指引的道路上，并站在以中国为首的革命阵营一边，这场党代会被称为“又一次恩古瓦比的大会”。我们将为刚果提供帝国主义离开后的经济支持。"

const TXT_R1 := "在党代会上，在卡塔利派、契卡雅派甚至是前M-22成员的支持下，萨苏因“右倾、向帝国主义投降”而被刚果劳动党全国代表大会罢免。弗朗索瓦·格扎维埃·卡塔利被选举为新的总书记。卡塔利宣布，刚果将彻底与殖民主义决裂，站在以苏联为首的社会主义阵营一边。经济互助委员会将为其提供帝国主义离开后的经济支持，许多刚果和法国合资的企业已经开始改为同包括苏联在内的经互会国家合资。"

const TXT_R2_FR_NEUTRAL := "我们的特工提前在刚果劳动党的中央委员会进行了打点，萨苏感谢了我们的支持，同我们签订了一批合作协议。在党代会上，契卡雅遭到了萨苏的突然袭击，他指控契卡雅应该为1982年在布拉柴维尔发生的炸弹袭击事件负责，这导致他被免职。于此同时，卡塔利派也在大会上被边缘化，卡塔利被降职到一个清水衙门。萨苏就这样巩固了他的地位，并将继续他的统治。"

const TXT_R2_FR_PROSU := "得益于我们的支持，萨苏在党代会上顶住了有法国和苏联撑腰的卡塔利派的挑战，调动军队“平息”了党内的异议，契卡雅以及卡塔利派的成员都被解职了。萨苏就这样巩固了他的地位，并将继续他的统治。萨苏谴责法国和苏联“是社会帝国主义，干涉刚果内政”。他感谢我们的支持，宣布倒向我国，并和我们扩大了合作。"

const TXT_R3_FR_NEUTRAL := "在党代会上，契卡雅遭到了萨苏的突然袭击，他指控契卡雅应该为1982年在布拉柴维尔发生的炸弹袭击事件负责，这导致他被免职。于此同时，卡塔利派也在大会上被边缘化，卡塔利被降职到一个清水衙门。萨苏就这样巩固了他的地位，并将继续他的统治。"

const TXT_R3_FR_PROSU := TXT_R1


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var congo := world.get_country_by_legacy_index(52)
	var china := world.get_country_by_legacy_index(1)
	var torg := congo != null and congo.has_tag("对华贸易")
	var sev := china != null and china.has_tag("sev")
	var opt := event_def.options
	if line < 2 and torg:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if world.get_flag("relres") and sev and line < 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line != 0 and line != 4:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var congo := ws.get_country_by_legacy_index(52)
	var france := ws.get_country_by_legacy_index(21)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = 1
				congo.sub_government = 2
				_leave_alliances(congo)
				congo.set_tag("亲中", true)
				congo.set_tag("对华贸易", true)
			ws.influence_prc += 20
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = 1
				congo.sub_government = 16
				_leave_alliances(congo)
				congo.set_tag("亲苏", true)
				congo.set_tag("对华贸易", true)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			var fr_prosu := france != null and france.has_tag("亲苏")
			if congo != null:
				_leave_alliances(congo)
				congo.set_tag("对华贸易", true)
			if not fr_prosu:
				if congo != null:
					congo.government = 2
					congo.sub_government = 21
				ws.influence_prc += 20
				context["result_text"] = TXT_R2_FR_NEUTRAL
			else:
				if congo != null:
					if ws.is_socialism(china, true):
						congo.set_tag("亲中", true)
						congo.government = 1
						congo.sub_government = 1
					elif china != null and china.government == 2:
						congo.set_tag("亲中", true)
						congo.government = 2
						congo.sub_government = 21
				ws.influence_prc += 20
				context["result_text"] = TXT_R2_FR_PROSU
		3:
			if france != null and france.has_tag("亲苏"):
				if congo != null:
					_leave_alliances(congo)
					congo.set_tag("亲苏", true)
					congo.government = 1
					congo.sub_government = 16
				context["result_text"] = TXT_R3_FR_PROSU
			else:
				if congo != null:
					_leave_alliances(congo)
					congo.government = 2
					congo.sub_government = 21
				context["result_text"] = TXT_R3_FR_NEUTRAL


## Country.LeaveAlliances() 逐项映射（同 Event587 约定）。
