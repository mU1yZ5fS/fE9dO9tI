extends "res://数据脚本/event_script_base.gd"

## 原作 Event709.cs：“托靠真主-6号”行动（伊拉克攻取哈萨绿洲，单选项）。
## 触发：event_709_trigger.gd（TimeScript.cs:10572-10578 的 parts[6]/data.iraq_revolution_timer
##   /IsAuthoritarianism(101) 复合条件）。
## 差异：
##  - c101/c102 LeaveAlliances + JoinAllOurAlliances 按 Country.cs:89-112/42-86
##    核心逻辑映射 tags（与 event_713 同约定）；c101 改名“半岛阿拉伯共和国”。
##  - 原版 Gosstroy=0/SubGosstroy=19 → government/sub_government。
##  - Torg=true → set_tag("对华贸易", true)。

const TXT_RESULT := "event.script.event_709_tawakkalna.c0"


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
		context["result_text"] = tr(TXT_RESULT)


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
