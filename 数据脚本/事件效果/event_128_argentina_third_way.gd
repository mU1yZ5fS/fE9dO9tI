extends "res://数据脚本/event_script_base.gd"

## 原作 Event128.cs：第三道路（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_R0 := "阿根廷军政府控制了立法机关，建立了严格的审查制度，压制了媒体自由与言论自由。1976年到1983年的这一段时期被称为肮脏战争时期。逐渐壮大的“左”翼反对派试图推翻军政府，而军政府使用“处决小队”对反对者予以镇压，其结果是，1万至3万名公民在秃鹰计划中作为确凿反对派或嫌疑反对派消失得无影无踪，甚至有儿童在父母被处决前眼睁睁地被带走。军政府任命何塞·阿尔弗雷多·马丁内斯·德霍兹为经济部长，后者开始推行被称为新自由主义路线的政策，即经济稳健化与国有资产私有化，主张国家控制关键行业的法团主义路线的计划部部长拉蒙·迪亚兹将军由于反对德霍兹被很快勒令退休。社会贫富差距正在以极恶劣的速度扩大。"
const TXT_R1 := "在我方情报网络的支持下，我们将所有工会、民主人士与左翼力量团结在了庇隆主义游击队周围，在丛林中设立了地下指挥总部。反对派统战委员会不仅在广泛的群众支持下拯救保护许多人士免遭迫害，而且在全国各地展开总罢工，阿根廷生产陷入严重瘫痪。在军政府内部的倾轧中，罗伯托·爱德华多·维奥拉在拉蒙·迪亚兹、奥兰多·拉蒙·阿戈斯蒂等将领的支持下，发动了政变，逮捕了军政府领导人豪尔赫·拉斐尔·魏德拉、海军上将埃米利奥·爱德华多·马塞等一批狂热党羽，宣布了对受迫害人士的特赦并以平等地位同反对派进行谈判。谈判达成一项协议：即军政府放弃对工会和民主党派的禁令与迫害，但同时承担起“危机结束前”无限期维持国家秩序与稳定的责任，从而有权任命总统、组建内阁，并决定举行议会选举的日期。尽管庇隆主义左派表示激烈不满，但因为民主派、左翼人士与工会对此首肯，庇隆主义者出于免于激化局面的考虑，只能同意解除武装与和平过渡的要求。作为回应，他们要求逮捕和清算阿根廷反共联盟（AAA）及头目何塞·洛佩兹·雷加本人，这得到了军政府的同意。由此，镇压与迫害得到停止，和平与秩序得到恢复，拉蒙·迪亚兹将军掌管了经济部，执行法团主义的经济路线，保持国家对关键行业的控制。军政府明白，虽然他们的统治无法永恒，但至少也能笑到最后。"



func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0


## Country.WantToLeave() 逐行移植（GameState.cs:7370-7394）。
## 只调整亲中/对华贸易/亲美，不整体清空联盟——原版 Event128 结果里
## 选项0 设 Torg=true 后经 WantToLeave 保留（满足条件时），之前误用全清空导致贸易关系丢失。
func _want_to_leave(c: CountryData) -> void:
	if c == null:
		return
	var flag := true
	var sub := c.sub_government
	if sub == 0:
		if _d(W.I_IDEOLOGY) > 2 or _d(W.I_ECON_SYSTEM) >= 13 or _d(W.I_DIPLO) < 700 or _d(W.I_PARTY_SYSTEM) >= 8:
			flag = false
	elif (sub >= 1 and sub <= 3) or sub == 8 or sub == 17:
		if _d(W.I_IDEOLOGY) > 3 or _d(W.I_ECON_SYSTEM) > 13 or _d(W.I_DIPLO) < 500:
			flag = false
	elif sub >= 4 and sub <= 6:
		var china := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) < 2 or _d(W.I_ECON_SYSTEM) < 13 or _d(W.I_DIPLO) > 700 or _d(W.I_PARTY_SYSTEM) < 8 or _d(W.I_PRESS_POLICY) < 18 or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) == 1 or _d(W.I_ECON_SYSTEM) <= 11 or _d(W.I_DIPLO) < 300 or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var argentina := ws.get_country_by_legacy_index(71)
	if argentina == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -5)
			_add(W.I_AGENTS, -5)
			argentina.set_tag("对华贸易", true)
			argentina.government = GameConstants.Government.AUTHORITARIAN
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			argentina.government = GameConstants.Government.LIBERAL
		_:
			argentina.set_tag("亲中", false)
			argentina.government = GameConstants.Government.AUTHORITARIAN
	argentina.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
	# 原版顺序：SubGosstroy=7 之后才调 WantToLeave，因此下面判定用的就是新的 sub==7。
	_want_to_leave(argentina)
	argentina.next_election_year = 1983
	argentina.next_election_month = 10
	argentina.next_election_day = 30
	if argentina.government == GameConstants.Government.AUTHORITARIAN:
		argentina.level_of_instability -= 30
		argentina.level_of_development -= 15
		context["result_text"] = TXT_R0
	elif argentina.government == GameConstants.Government.LIBERAL:
		argentina.level_of_instability -= 15
		argentina.set_tag("亲美", false)
		_add_power(EmpireData.USA, -5)
		context["result_text"] = TXT_R1

