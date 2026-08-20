extends "res://数据脚本/event_script_base.gd"

## 原作 Event709.cs：“托靠真主-6号”行动（伊拉克攻取哈萨绿洲，单选项）。
## 触发：event_709_trigger.gd（TimeScript.cs:10572-10578 的 parts[6]/data.iraq_revolution_timer
##   /IsAuthoritarianism(101) 复合条件）。
## 差异：
##  - c101/c102 LeaveAlliances + JoinAllOurAlliances 按 Country.cs:89-112/42-86
##    核心逻辑映射 tags（与 event_713 同约定）；c101 改名“半岛阿拉伯共和国”。
##  - 原版 Gosstroy=0/SubGosstroy=19 → government/sub_government。
##  - Torg=true → set_tag("对华贸易", true)。

const TXT_RESULT := "最终，沙特阿拉伯王室屈服了，沙特将退出红海沿岸并放弃对当地的主权，沙特在当地的石油企业和伊拉克国家碳氢化合物公司联合组建开采公司，但开采权和76%的收益都会交给伊拉克作为战争赔偿。伊拉克行政机关正在进入并取代沙特的管理机构，新征服的领土将被命名为萨达姆省，省会定于达曼，现在也将改名为萨达姆市。沙特的国防力量也必须被解散，转而有伊拉克提供军事保护。萨达姆的次子，库塞·侯赛因被自己的父亲任命为首任萨达姆省省长，兼任萨达姆省复兴党支部书记。在签订了不受欢迎的卖国条约后，伊本·沙特国王被一名沙特建筑巨头开发商的儿子袭击，刺客被立刻逮捕，老国王伤势严重，并很快由亲伊拉克的军官组成了临时军事委员会接管全国。据信，此次袭击完全是因为王国政府拒绝和本拉登建筑集团展开进一步合作。\n两位主要成员的先后离开使得成立不久的海合会濒临崩溃，阿拉伯联合酋长国希望借此分得一杯羹，同时也是为了防止伊拉克的秋后算账，联合酋长国迅速倒向了伊拉克方面，通过引入伊拉克军队来对抗西方国家的压力，并开展了类似伊拉克的改革，允许复兴党伊拉克派在当地开设支部，组织萨达姆主义学习班。同时还允许伊拉克军队和海军在当地驻军，让伊拉克军官担任军事观察家等。伊拉克还成立了由自己主导的“石油与主权委员会”来处理这些国家的油气问题，同时还率领各国退出欧佩克，加入新的石油主权委员会。美国和苏联都对伊拉克的扩展表示严重关切。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if d.size() > 143:
			d.oil_price += 8
		var iraq := ws.get_country_by_legacy_index(14)
		if iraq != null:
			for i in range(4, 7):
				if iraq.parts.size() > i:
					iraq.parts[i] = false
			if iraq.parts.size() > 7:
				iraq.parts[7] = true
		_convert_country(101)
		_convert_country(102)
		var saudi := ws.get_country_by_legacy_index(101)
		if saudi != null:
			saudi.name = "半岛阿拉伯共和国"
			saudi.chinese_name = "半岛阿拉伯共和国"
		context["result_text"] = TXT_RESULT


func _convert_country(legacy_index: int) -> void:
	var c := ws.get_country_by_legacy_index(legacy_index)
	if c == null:
		return
	_leave_alliances(c)
	c.puppet_of = GameConstants.LegacySlot.IRAQ
	c.government = GameConstants.Government.AUTHORITARIAN
	c.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
	c.set_tag("对华贸易", true)
	_join_our_alliances(c)


## Country.cs:89-112 LeaveAlliances（联盟/倾向清空 + puppetOf=-1）。

func _join_our_alliances(c: CountryData) -> void:
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)
