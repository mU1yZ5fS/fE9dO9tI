extends "res://数据脚本/event_script_base.gd"

## 原作 Event589.cs：在同一面红旗之下（埃塞俄比亚-索马里联邦，两选项）。
## 触发：TimeScript.cs:10908-10913 —— 无日期条件：
##   c42.亲中 && c41.亲中 && c42.Gosstroy!=0 && c41.Gosstroy!=0
##   && modifies[6].is_active && (c1.Gosstroy==1 || c1.SubGosstroy==0)
##   && !event_done[403]；parts[0/1/2] 由 CountryData.parts 建模。
## 差异：
##  - EstablishGovernment(ProChina) → 只设 亲中=true、亲苏/亲美=false（不设 government）；
##  - c41.name = "非洲之角联邦" → chinese_name（既有约定）；
##  - JoinAllOurAlliances(true) → 复制玩家全部 true 标签。

const TXT_TITLE := "在同一面红旗之下"
const TXT_DESC := "1977年，古巴领导人菲德尔·卡斯特罗曾试图推动埃塞俄比亚与索马里两个亲苏的“社会主义国家”与南也门组成一个社会主义联盟，然而，在亲自见到了巴雷与门格斯图这两位“革命新星”后，大失所望的卡斯特罗终究还是放弃了这个异想天开的想法。此后没过多长时间，一场围绕着欧加登地区的血腥冲突就席卷了两国，联邦的构想也彻底被埃塞俄比亚与索马里间的血海深仇所埋葬。\n不过，在两位红皮独裁者都被革命所推翻、非洲之角换了新颜的今天，两国政府已经开展了密切的合作，并就欧加登问题展开了谈判。在谈判过程中，建立一个涵盖索马里与埃塞俄比亚的非洲之角联邦的提议又重新回到了两国人民的视线之内。也许我们可以推波助澜，完成古巴佬的未竟之事，让东非的这两个革命国家真正携起手来，化干戈为玉帛，结成一个独立、民主、平等、不结盟的社会主义联邦？"

const TXT_OPT0 := "埃索情谊深，同志加兄弟！"
const TXT_OPT1 := "还是暂时放一下这个想法吧……"

const TXT_R0 := "在我们的提议下，埃塞俄比亚领导人与索马里领导人于南也门首都亚丁签订了《埃塞俄比亚-索马里联邦宪章》，决定合并两国政府与议会，非洲之角民主联邦共和国就此诞生。条约中规定了组成联邦的两个主体埃塞俄比亚与索马里具有同等地位，各民族不论语言、种族、宗教信仰的差异一律平等，并将按照民族聚居区域和两国争议地区划分自治区，赋予高度自治权，而欧加登与厄立特里亚就是第一批自治区。尽管两国间仍存在一些隔阂，但相信很快，两国人民就能冰释前嫌，共同建设社会主义的非洲之角。"
const TXT_R1 := "好吧，也许我们没必要完成这个大胆的计划，就让时间来治愈埃塞俄比亚与索马里人民的伤痛与隔阂吧……"
const TXT_NAME_ETHIOPIA := "非洲之角联邦"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.description = TXT_DESC
	_enable(event_def.options[0], TXT_OPT0)
	_enable(event_def.options[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var ethiopia := ws.get_country_by_legacy_index(41)
	var somalia := ws.get_country_by_legacy_index(42)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ethiopia != null:
				while ethiopia.parts.size() <= 0:
					ethiopia.parts.append(false)
				ethiopia.parts[0] = true
				ethiopia.chinese_name = TXT_NAME_ETHIOPIA
				ethiopia.government = 1
				ethiopia.sub_government = 17
			if somalia != null:
				_leave_alliances(somalia)
			if ethiopia != null:
				_establish_pro_china(ethiopia)
				ethiopia.set_tag("对华贸易", true)
				_join_all_our_alliances(ethiopia)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


## Country.LeaveAlliances() 逐项映射（含原版不常见的联盟标签）。
func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


## 原版 EstablishGovernment(ProChina) 只改倾向标签，不改 government。
func _establish_pro_china(c: CountryData) -> void:
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _join_all_our_alliances(c: CountryData) -> void:
	var player := ws.get_player_country()
	if player == null:
		return
	for tag_key in player.tags:
		if player.tags[tag_key]:
			c.set_tag(tag_key, true)


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta
