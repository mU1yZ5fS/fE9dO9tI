extends "res://数据脚本/event_script_base.gd"

## 原作 Event639.cs：为了所有人的斐济（斐济左翼行动，单选项）。
## 触发：DiploButtonScript.cs:12193 —— 外交按钮 1050，selected_country==160，入口扣 200/200 后手动触发。
## 差异：Vyshi→亲美、proprc→亲中、Torg→对华贸易、puppetOf→puppet_of、name→chinese_name。

const TXT_R_OK := "社会主义在大洋洲的成功也动摇着斐济这个国家。斐济工会大会发起了总罢工，并在瓦努阿图的支持下开始组织工人民兵，全国联邦党也开始动员议员对执政的联盟党政府提出不信任案。在国内外的广泛压力下，联盟党内阁最后选择辞职，全国联邦党-斐济工会大会达成了组成统一的“人民民主党”的协议，组织了新政府。新政府随即颁布了一系列新政：部分引入直接民主、改革威斯敏斯特体制、尝试推行工人自治、开展国有化和土地改革以及废除酋长特权并吸收了一定美拉尼西亚社会主义的经验。在外交上，斐济采取了反对帝国主义、殖民主义和在太平洋国家进行核试验的政策，宣布同英国和英联邦脱钩，一个共和制的斐济就这样诞生了。"
const TXT_R_FAIL := "斐济工会大会和全国联邦党的行动虽然成功动摇了斐济的政治秩序，但这一行动给斐济族的特权人士带来了恐慌。在西蒂维尼·拉布卡将军的指挥下，10名蒙面武装的士兵进入了斐济众议院，将所有议员赶出了议院。随后，斐济广播电台宣布军方接管了政权。在军方和斐济族酋长的压力下，斐济总督追认了政变的正当性，并授权拉布卡将军组建一个看守政府。新政府随后镇压了全国联邦党和斐济工会大会，并颁布了一部新宪法，其中肯定了斐济族在政治上的霸权，并宣布斐济为共和国。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var fiji := ws.get_country_by_legacy_index(160)
	var vanuatu := ws.get_country_by_legacy_index(159)
	var new_caledonia := ws.get_country_by_legacy_index(154)
	var australia := ws.get_country_by_legacy_index(135)
	var png := ws.get_country_by_legacy_index(136)
	var angola := ws.get_country_by_legacy_index(123)
	if angola != null:
		angola.prc_power = 600
		angola.sov_power = 300
		angola.usa_power = 100
	var opt := int(context.get("option_index", -1))
	if opt != 0 or fiji == null:
		return
	var vanuatu_ok := vanuatu != null and (ws.is_socialism(vanuatu, true) or vanuatu.government == GameConstants.Government.REFORMIST)
	var nc_ok := new_caledonia != null and new_caledonia.puppet_of < 0
	var aus_ok := australia != null and (ws.is_socialism(australia, true) or australia.government == GameConstants.Government.REFORMIST) \
		and australia.sub_government != GameConstants.SubGovernment.LEFT_CONSERVATIVE
	if vanuatu_ok and nc_ok and aus_ok:
		context["result_text"] = TXT_R_OK
		_leave_alliances(fiji)
		fiji.set_tag("亲中", true)
		fiji.set_tag("对华贸易", true)
		if australia != null and ws.is_socialism(australia, true) \
				and vanuatu != null and ws.is_socialism(vanuatu, true) \
				and png != null and ws.is_socialism(png, true):
			fiji.government = GameConstants.Government.SOCIALIST
			fiji.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			fiji.chinese_name = "斐济民主共和国"
			return
		fiji.government = GameConstants.Government.REFORMIST
		fiji.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		fiji.chinese_name = "斐济共和国"
		return
	context["result_text"] = TXT_R_FAIL
	fiji.government = GameConstants.Government.AUTHORITARIAN
	fiji.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
	fiji.chinese_name = "斐济主权民主共和国"
