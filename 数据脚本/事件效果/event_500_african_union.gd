extends "res://数据脚本/event_script_base.gd"

## 原作 Event500.cs：非洲的新生（非洲联盟建立）。
## 触发：原版走 Decision 系统（GlobalScript.cs:56 的 HasRevolutionaryLeader/HasMoney/
## HasArmy/IsChineseInfluenceLessThan/IsAfricanProprc/IsAfricanSocialism/AfricanAlliance 链）。
## Godot 决议界面移植说明，事件本体按手动事件（trigger_conditions 空）移植；
## 入口暂由外交面板对原版序号 61（上沃尔特/布基纳法索）的 story action 调用
## game.start_event("african_union")，条件与上述 Decision 链逐项一致。
## 效果逐字对齐 Event500.cs ResultsOfEvents(result_num==0)。
## result_num==5 为空结果，Godot 不建无效果选项。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", 0))
	if opt != 0:
		return

	# 创始成员国（Event500.cs:125-132）
	for legacy_idx in [68, 63, 127, 114, 122, 124, 61]:
		var founder := ws.get_country_by_legacy_index(legacy_idx)
		if founder != null:
			founder.set_tag("au", true)

	# 符合社会主义/亲中/范围条件的国家全部加入（Event500.cs:133-140）
	for c in ws.countries:
		if c == null or c.has_tag("ovd") or c.has_tag("sev"):
			continue
		if not ws.is_socialism(c, true):
			continue
		if c.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or c.sub_government == GameConstants.SubGovernment.TROTSKYIST:
			continue
		if not c.has_tag("亲中"):
			continue
		if not _in_au_range(c.原版序号, c):
			continue
		c.set_tag("au", true)

	# 代价与全局影响（Event500.cs:141-148）
	if d.size() > W.I_BUDGET:
		d.budget -= 300
	if d.size() > W.I_ARMY:
		d.army -= 300
	if ws.empires.size() > EmpireData.USA:
		ws.empires[EmpireData.USA].relations -= 100
		ws.empires[EmpireData.USA].power = clampi(ws.empires[EmpireData.USA].power - 200, 0, 1000)
	if ws.empires.size() > EmpireData.USSR:
		ws.empires[EmpireData.USSR].relations -= 100
		ws.empires[EmpireData.USSR].power = clampi(ws.empires[EmpireData.USSR].power - 200, 0, 1000)
	ws.influence_prc += 100

	# 项目惯例：概览/国家面板读 global_flags.event_done_500（国家面板.gd:983 等）。
	ws.set_flag("event_done_500", true)
	ws.set_flag("result_500", 0)

	context["result_title"] = "非洲的新生"
	context["result_text"] = "今天，布基纳法索共和国首都瓦加杜古应各界邀请，召开了承接了六届泛非大会和三场全非人民大会传统的第七届泛非大会。桑卡拉总统本人亲自带队迎接诸位友好的兄弟国家领导人。此次盛会不可不称为是泛非主义近三十年来数位杰出领导人的集体亮相：如知名泛非主义革命家阿米尔卡·卡布拉尔的胞弟、几内亚佛得角共和国总统路易斯·卡布拉尔；非洲对抗殖民主义的先锋、津巴布韦的独立战争英雄约书亚·通戈加拉总理；和恩克鲁玛，塞古·杜尔等人同一时期掀起反抗和斗争大旗的斗士总统朱利叶斯·尼雷尔则成为了万众瞩目的焦点，这可能是这位年迈的领导人最后几次出国的机会；在60年代以赞比亚举国之力力扛葡萄牙、罗德西亚和南非三国施压和军事威胁，依旧坚定支持莫桑比克和津巴布韦独立运动的“人道的社会主义者”，风趣幽默的肯尼思·卡翁达也率领着自己的代表团来到了正人君子之国；飞行员出身的加纳领导人杰瑞·罗林斯更是亲自驾机带领代表团飞抵瓦加杜古。由第一任中国驻布基纳法索大使谢邦治带队的中国代表团也受到了桑卡拉总统的热烈欢迎。遗憾的是，莫桑比克解放阵线党迫于国内事务繁杂，其领导人无法亲自出席。非洲五十多个国家和部分仍然在争取彻底独立的非洲国家的国旗在瓦加杜古的街头高高飘扬，诸位泛非主义先驱的画像在市中心的独立大道高高立起。就这样我国和布基纳法索签订的第一批建设项目中新建成的国家独立宫迎来了第一批客人。在各国领导人和代表们结束了简要的报告后，坦桑尼亚和津巴布韦代表团联合提交了一份组建新非洲统一机构，即非洲联盟的草案。首先，文件强调了现有的非洲统一组织的不足，指出其无利于甚至是在阻挠非洲革命进程。由此，为了进一步发扬法农、恩克鲁玛、塞古·杜尔与卡布拉尔等人高高举起的泛非火炬，各国有必要组建新的跨国合作组织。文件提供了对完善且更为激进的解决方案，包括组建各国政党的、以科学社会主义和革命泛非主义为指导的跨国合作平台“全非人民革命党团”，并视行政能力，将各地的政治组织缓慢的改造为统一的全非人民革命党的地区支部；调整成员国与成员国之间的关税壁垒和人口流动自由程度；由各国国防武装力量中挑选士兵组建全非人民革命军，致力于维持各冲突地区的安全，在必要的情况下用武装捍卫别国的革命果实，并在章程层面确立了该组织将致力于全非洲以及非裔占多数地区争取平等权利的解放事业。毫无疑问，此份草案在大会上全票通过，各国代表签署了《瓦加杜古宣言》，宣告了非洲联盟的诞生，成员国们纷纷退出原先的非洲统一组织，转而投身于真正的非洲解放事业。我国作为特邀成员国成为了该组织内唯一的亚洲国家。早已沉寂许久的黑豹党和美国的黑人民族主义运动也表达了对这次大会浓厚的兴趣，纷纷在自己的刊物上报道了此次会议，称其为“第三世界新一轮革命浪潮的嚆矢”。除此以外，富有神秘主义色彩，相信“黑人救世主”的牙买加拉斯塔法里运动也表示了对此次大会的支持。我们的战友们遍布非洲大陆，怒吼吧，古老的大陆，让帝国主义震颤吧！"


## Event500.cs:138 的 id 范围：41/42/52/56-68/99(parts[0])/100(parts[0])/106-108/112-133(!=128)/150/153/155/158
func _in_au_range(legacy_idx: int, c: CountryData) -> bool:
	if legacy_idx == 41 or legacy_idx == 42 or legacy_idx == 52:
		return true
	if legacy_idx >= 56 and legacy_idx <= 68:
		return true
	if legacy_idx == 99 or legacy_idx == 100:
		return c.parts.size() > 0 and c.parts[0]
	if legacy_idx >= 106 and legacy_idx <= 108:
		return true
	if legacy_idx >= 112 and legacy_idx <= 133 and legacy_idx != 128:
		return true
	if legacy_idx == 150 or legacy_idx == 153 or legacy_idx == 155 or legacy_idx == 158:
		return true
	return false
