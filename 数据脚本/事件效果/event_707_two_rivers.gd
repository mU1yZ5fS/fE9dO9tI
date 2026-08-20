extends "res://数据脚本/event_script_base.gd"

## 原作 Event707.cs：两河的新娘子（叙伊民族联合行动宪章，1978.11）。
## 触发：TimeScript.cs:10260-10266 ——
##   (月>=11 且 年>=1978 或 年>=1979) 且 event_done[36] 且 resultOfEvents[36]==0
##   且 叙利亚(35).SubGosstroy==15 且 叙利亚.prosov。
## 差异：
##  - 共同效果：伊拉克(14).prosov=false、叙利亚(35).prosov=false
##    → Godot set_tag("亲苏", false)（country_data.gd TAG_ALIASES: is_prosov→亲苏）。
##  - 埃及(30) 的 SubGosstroy==20 / Gosstroy==2 分支逐字保留；原版 option1
##    SubGosstroy==20 命中后 return，故不再检查 Gosstroy==2，逐字保留该结构。

const TXT_BASE := "在《人民日报》上，我国高度赞扬了阿拉伯人民反对帝国主义侵略的行动，称叙利亚——伊拉克两国人民举起了复兴的火炬，势将一切落后势力全都驱散。两国分别拍来电报，感谢我国人民一贯对于阿拉伯人民斗争的支持。\n利比亚的穆阿迈尔·卡扎菲也对进一步的一体化深感兴趣，并希望能为其提供一切支持。布迈丁上校的阿尔及利亚，也门民主人民共和国和北也门都表达了对叙——伊联盟的支持。"

const TXT_EGYPT_20 := "萨达特对这一联盟的崛起深感担忧，认为其可能会进一步加剧阿拉伯世界和以色列的对抗，他呼吁卡特总统为其提供更多物资支援。"

const TXT_EGYPT_2 := "新的埃及政府也对该组织的实践表示支持，并希望借此机会复活过去的联合共和国。"

const TXT_R1_BASE := "我们对两国的进一步发展不做表态，毕竟1961年的时候也是这样的嘛。\n利比亚的穆阿迈尔·卡扎菲也对进一步的一体化深感兴趣，并希望能为其提供一切支持。布迈丁上校的阿尔及利亚，也门民主人民共和国和北也门都表达了对叙——伊联盟的支持。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# Event707.cs ResultsOfEvents 共同效果（先于 result_num 分支）
	_set_prosov(14, false)
	_set_prosov(35, false)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		var text := TXT_BASE
		var egypt := ws.get_country_by_legacy_index(30)
		if egypt != null:
			if egypt.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
				text += "\n" + TXT_EGYPT_20
			elif egypt.government == GameConstants.Government.REFORMIST:
				text += "\n" + TXT_EGYPT_2
		if d.size() > W.I_BUDGET:
			d[W.I_BUDGET] += 50
		context["result_text"] = text
	elif opt == 1:
		var text := TXT_R1_BASE
		var egypt := ws.get_country_by_legacy_index(30)
		if egypt != null:
			if egypt.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
				text += "\n" + TXT_EGYPT_20
			elif egypt.government == GameConstants.Government.REFORMIST:
				text += "\n" + TXT_EGYPT_2
		context["result_text"] = text


func _set_prosov(legacy_index: int, value: bool) -> void:
	var c := ws.get_country_by_legacy_index(legacy_index)
	if c != null:
		c.set_tag("亲苏", value)
