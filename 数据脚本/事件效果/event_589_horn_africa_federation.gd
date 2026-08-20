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



const TXT_R0 := "在我们的提议下，埃塞俄比亚领导人与索马里领导人于南也门首都亚丁签订了《埃塞俄比亚-索马里联邦宪章》，决定合并两国政府与议会，非洲之角民主联邦共和国就此诞生。条约中规定了组成联邦的两个主体埃塞俄比亚与索马里具有同等地位，各民族不论语言、种族、宗教信仰的差异一律平等，并将按照民族聚居区域和两国争议地区划分自治区，赋予高度自治权，而欧加登与厄立特里亚就是第一批自治区。尽管两国间仍存在一些隔阂，但相信很快，两国人民就能冰释前嫌，共同建设社会主义的非洲之角。"
const TXT_R1 := "好吧，也许我们没必要完成这个大胆的计划，就让时间来治愈埃塞俄比亚与索马里人民的伤痛与隔阂吧……"
const TXT_NAME_ETHIOPIA := "非洲之角联邦"
## Godot 地图显示增量：原版用 parts 驱动地图合并，本端口用 map_regions 归属覆盖模拟。
## 埃塞俄比亚 gwcode=530，索马里 gwcode=520；联邦成立后索马里区域归属 530。
const HORN_FEDERATION_GWCODE := 530
const SOMALIA_REGION_IDS := [30, 31, 32, 33, 34, 35, 45, 46, 1466, 2028, 2029, 2030, 2031, 4115]


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)


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
				# 政体名优先于 chinese_name，必须同步改 gov_names 才能在世界地图/国家面板显示“非洲之角联邦”。
				# 原版 name 固定为联邦名，不随政体变化，因此覆盖全部政体名。
				for gn_key in ethiopia.gov_names:
					ethiopia.gov_names[gn_key] = TXT_NAME_ETHIOPIA
				ethiopia.government = GameConstants.Government.SOCIALIST
				ethiopia.sub_government = GameConstants.SubGovernment.MAOIST
			if somalia != null:
				_leave_alliances(somalia)
			if ethiopia != null:
				_establish_pro_china(ethiopia)
				ethiopia.set_tag("对华贸易", true)
				_join_all_our_alliances(ethiopia)
			# 地图合并：索马里区域并入埃塞俄比亚（联邦）。
			if GameManager != null:
				game.set_map_region_owner(SOMALIA_REGION_IDS, HORN_FEDERATION_GWCODE)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


## Country.LeaveAlliances() 逐项映射（含原版不常见的联盟标签）。

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



