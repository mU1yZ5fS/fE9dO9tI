extends "res://数据脚本/event_script_base.gd"

## 原作 Event436.cs：《苏联1977年宪法》（1977.10）。
## 触发：TimeScript.cs:10144-10150 —— (月>=10 且 年>=1977) 或 年>=1978。
## 文案：Events_text_en.txt 行 1656-1663。
## 差异：
##  - 共同效果（三个选项都执行）：苏联 leaders[2]（契尔年科）support +1
##    （Event436.cs ResultsOfEvents 开头，result_num 分支之外）。
##  - SOV_PRC_PartiesConnection 映射为 I_COMMUNICATIONS（见 event_435 注释）。

const TXT_R0 := "我们以苏联宪法为蓝本，已经将有关公民物质权利与其新义务的相关条款引入了中国宪法。尽管这些改革很可能只是流于形式上，但改革还是增强了公民对政府的信心。当然，这也招致了左翼政客的批评，他们指责我们同市侩情绪和小资产阶级道德调情。"

const TXT_R1 := "我们在《人民之报》的专栏上发文炮打苏联新宪法，指责苏联当局正同市侩情绪和小资产阶级道德调情，不注意做群众工作，不注意加强革命道德宣传，不注意培养适应新社会的生活方式：“苏联当局打算通过批量生产糖衣炮弹，搞各种各样的物质挂帅，将本国的人民给驯化为精神上的资产阶级。从而让他们远离革命的生活方式”。这便是我们这篇文章的主要论点。很显然，苏联领导层与我国的温和派政治家对此持消极态度。"

const TXT_R2 := "1977年10月4日至6日，最高苏维埃两院（即联盟院与民族院）会议听取并审议了苏联新宪法的相关内容。而在10月7日，苏联最高苏维埃两院举行了最后审议：在细致过目了每个章节，并仔细审视了宪法整体构成后，苏联通过了新宪法。同日，苏联最高苏维埃两院则分别表决通过《苏联最高苏维埃关于通过和宣布苏联宪法（根本法）的宣言》、《苏联关于宣布苏联宪法（根本法）通过日为国家法定假日的法律》和《苏联关于制定苏联宪法（根本法）程序的法律》。10月8日，苏联的新宪法在全国各大报纸上全文公布。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# Event436.cs 共同效果：苏联 leaders[2]（契尔年科）support +1
	_ussr_leader_add(2, 1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# Event436.cs result 0
			if d.size() > W.I_BUDGET:
				d[W.I_BUDGET] -= 5
			if d.size() > W.I_PEOPLE_SUPPORT:
				d[W.I_PEOPLE_SUPPORT] += 25
			if d.size() > W.I_THOUGHT_FREEDOM:
				d[W.I_THOUGHT_FREEDOM] -= 25
			if d.size() > W.I_LIVING:
				d[W.I_LIVING] += 25
			if d.size() > W.I_COMMUNICATIONS:
				d[W.I_COMMUNICATIONS] += 5  # 原版 SOV_PRC_PartiesConnection += 5
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty -= 100
				else:
					p.loyalty += 50
			context["result_text"] = TXT_R0
		1:
			# Event436.cs result 1
			if d.size() > W.I_PARTY_SUPPORT:
				d[W.I_PARTY_SUPPORT] += 50
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = clampi(ws.empires[EmpireData.USSR].relations - 50, 0, 1000)
			if d.size() > W.I_COMMUNICATIONS:
				d[W.I_COMMUNICATIONS] -= 5  # 原版 SOV_PRC_PartiesConnection -= 5
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty += 100
					p.power += 25
				else:
					p.loyalty -= 50
			context["result_text"] = TXT_R1
		2:
			# Event436.cs result 2：无效果
			context["result_text"] = TXT_R2


func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta
