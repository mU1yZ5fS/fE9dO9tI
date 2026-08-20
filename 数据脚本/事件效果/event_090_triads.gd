extends "res://数据脚本/event_script_base.gd"

## 原作 Event90.cs：香港再见，澳门再见？（三合会方案，四选项）。
## 触发：TimeScript.cs:10745-10751 ——
##   (月>=12 且 年>=1980 或 年>=1981) && data.hk_macau_status==1（hk_macau_status）。
## 差异：选项显隐 prepare 动态改写；result2 文本插领导人姓名。

const TXT_R0 := "在特勤部队、国有企业和亲中游说组织的帮助下，我们与三合会的三个主要财团建立了联系，分别是“十四K”、“新义安”和“和胜和”。他们得到了我们对其成员和资产不受侵犯的保证，并提出了一项建议，即以极其优惠的条件将其资本投资于该地区经济（特别是生产麻黄）三合会的领导人已经准备在美国重新设置他们的中心，同意我们的建议。他们开始在我国南方省份进行大量投资，并利用他们的影响力压制反对中国统一的人的行动（特别是批评材料从媒体上消失，所有抗议活动在腐败警察的默许下迅速被三合会成员驱散，还有一些香港和澳门商人移居国外）。因此，我们现在得到了辛迪加的支持，但同时也受到了犯罪世界和腐败日益增长的影响。"

const TXT_R1_OK := "我们与三合会最大的三个财团建立了联系，分别是“十四K”、“新义安”和“和胜和”。他们得到了我们的保证，保证他们的成员和资产不受侵犯，他们的领导人同意了这一点，利用自己的影响力压制反对中国统一的人的行动（特别是，媒体中的批评材料消失了，所有的抗议活动都被在腐败警察的默许下，被黑社会成员迅速驱散，一些商人从香港和澳门移居海外。）但是，国安部阻止三合会在中国南部省份站稳脚跟，1997年以后，我们将对他们展开系统性打击。"

const TXT_R1_BAD := "我们与三合会最大的三个财团建立了联系，分别是“十四K”、“新义安”和“和胜和”。他们得到了我们的保证，保证他们的成员和资产不受侵犯，他们的领导人同意了这一点，利用自己的影响力压制反对中国统一的人的行动（特别是，媒体中的批评材料消失了，所有的抗议活动都被在腐败警察的默许下，被黑社会成员迅速驱散，一些商人从香港和澳门移居海外。）但是，国安部阻止三合会在中国南部省份站稳脚跟，1997年以后，我们将对他们展开系统性打击。"

const TXT_R2_A := "断然拒绝与香港犯罪集团进行任何谈判。之后在香港和澳门发生了一系列反华事件，一场系统性的运动开始败坏有关港澳回归协议的名声，最终导致在港澳两地发生的大规模屠杀，以及使得英国和葡萄牙的议会最终拒绝批准回归协议。"

const TXT_R2_B := "但是，我们的朋友给他们施加了压力，使英国和葡萄牙被迫履行了他们的义务。香港和澳门将分别于1997年和1999年回归。"

const TXT_R3 := "“要么共产党战胜腐败，要么腐败战胜共产党”——这一口号在政治局会议上被提出。中国公安部和中央纪委在毗邻香港和澳门的中国南方省份，以及最近开放的经济特区内发起了一场大规模的反腐运动。数百名各级官员被免职，成千上万的人被开除中共党籍，数以百万计的赃款都被没收，成都市长陈希同（被称为“中国的格里申”）因窃取了数十亿元的人民财产和为自己建造豪华别墅的行为被判处枪决。这完全打乱了腐败组织，使得可以在某种程度上矫正局势，切断了我们的精英阶层与和他们在港澳的“同伙”之间的腐败交易。后者以防万一，移民海外。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var econ := data.econ_system if data.size() > W.I_ECON_SYSTEM else 0
	var coal := _coalition_percent(world)
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var left_party := party < 8
	var opt := event_def.options
	if agents >= 40 and ((line > 1 and left_party) or (coal > 66 and party > 7)):
		_enable(opt[0], "我们会对三合会开出他们无法拒绝的条件的（需要4特工网络）")
	else:
		_disable(opt[0], "只有国民党才会这么做！")
	if agents >= 30 and ((line > 0 and left_party) or (coal > 66 and party > 7)):
		_enable(opt[1], "我们可以与犯罪辛迪加们结成战略同盟。但这可不意味着他们有了免死金牌（需要2特工网络）")
	else:
		_disable(opt[1], "不与黑社会妥协!!")
	_enable(opt[2], "我们关心这些强盗干什么？")
	if agents >= 80 and econ <= 13 and ((line < 3 and left_party) or (coal > 66 and party > 7)):
		_enable(opt[3], "现在是时候对我国南方省份的有组织犯罪进行有力打击了！（需要8特工网络）")
	else:
		_disable(opt[3], "他们是非常诚实合法的商人且支持改革开放。我们无权怀疑他们。")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -40)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_BUDGET, 100)
			_add(W.I_CORRUPTION, 150)
			_set_modifier(5, true)
			context["result_text"] = TXT_R0
		1:
			if d.size() > W.I_DIPLO and d.size() > W.I_IDEOLOGY and d.diplomatic_reputation > 300 and d.ideology < 3:
				_add(W.I_AGENTS, -20)
				_add(W.I_PEOPLE_SUPPORT, -50)
				_add(W.I_DIPLO, 20)
				context["result_text"] = TXT_R1_OK
			else:
				_add(W.I_AGENTS, -20)
				_add(W.I_PEOPLE_SUPPORT, -50)
				_add(W.I_DIPLO, 20)
				_add(W.I_CORRUPTION, 80)
				_add(W.I_BUDGET, 50)
				_set_modifier(5, true)
				context["result_text"] = TXT_R1_BAD
		2:
			_set_data(W.I_HK_MACAU_STATUS, 0)
			var text := _leader_name() + TXT_R2_A
			var hk := ws.get_country_by_legacy_index(51)
			var china := ws.get_country_by_legacy_index(1)
			if (hk != null and hk.has_tag("对华贸易")) or (china != null and china.has_tag("sev")):
				text += TXT_R2_B
				_set_data(W.I_HK_MACAU_STATUS, 1)
			context["result_text"] = text
		3:
			_add(W.I_BUDGET, 40)
			_add(W.I_AGENTS, -80)
			_add(W.I_DIPLO, 20)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_CORRUPTION, -150)
			context["result_text"] = TXT_R3


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)


func _set_modifier(index: int, active: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
