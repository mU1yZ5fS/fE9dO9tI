extends "res://数据脚本/event_script_base.gd"

## 原作 Event555.cs：铸剑为犁（西德和平运动，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1239-1241 —— c17.isNATO && (1983.10.22 或 1984+)。
## 差异：isNATO/isSocEU→has_tag；data[147] raw index；empires[0].now_leader→current_leader。

const TXT_TITLE := "铸剑为犁"
const TXT_DESC := ""
const TXT_OPT0 := "让我们帮助示威者，尝试推进和平进程"
const TXT_OPT0_DIS := "我们无法插手"
const TXT_OPT1 := "我们将声援欧洲人民，呼吁结束冷战的对抗"
const TXT_OPT1_DIS_0 := "只是声援吗？"
const TXT_OPT1_DIS_1 := "我们怎么能和美国对着干？"
const TXT_OPT2 := "我们无能为力"
const TXT_R0_A := "在我们的帮助下，示威者提出了让政府下台的口号，并组织了由主张和平的左翼政党广泛参与的人民阵线。西欧的局势也有利于西德的和平运动，这促使了运动的扩大化。西欧的各个进步政权参与到这场示威之中，他们施压德国政府并大力资助民众的抗议，推进示威的激进化，并在经济上向西德施压。一些抗议者开始质疑西德的警察制度和社会上大量未被清算的纳粹余孽，并抨击西德的制度威胁了民主；工会也宣布进行罢工，学生再次走向街头。和平示威很快转向了类似68运动时的更为激烈的对抗，政府无法驱散示威者，基民盟/基社盟内阁宣布辞职，并重新召开大选。
参与示威的左翼政党组织的人民阵线以略微的优势赢得了联邦德国大选，这一选举结果彻底动摇了西德自战后以来的政治格局，组成了西德第一个纯左翼的政府。新政府宣布将退出北约、终止双重决议并对西德政治开展改革，进行更加深度的去纳粹化和转型，并将致力于德国的中立化统一，推进欧洲的无核化。西德和平抗议的成功也促使东方集团内部爆发了新一轮和平运动。"
const TXT_R0_A_SOCEU := "
与此同时，西德新政府宣布加入社会主义联盟，同西欧的温和左翼政权加强联系。"
const TXT_R0_A_UK := "
刚刚赢得大选的英国工党政府看到了新兴社会主义联盟潜力，为更好贯彻“重建福利国家”的政策，主动申请加入社会主义联盟以寻求经济帮助。"
const TXT_R0_B := "在我们的帮助下，示威者提出了让政府下台的口号，并组织了由主张和平的左翼政党广泛参与的人民阵线。西德政府很快驱散和这场有共产党参与的且“威胁德美友谊”的“可疑”示威。部分反对示威的人认为运动有赤化西德的危险。1983年11月22日，德国联邦议院对导弹进行了辩论，大多数议会议员决定赞成导弹的部署。从1983年12月起，导弹被陆续部署在德国。因此，和平运动失败了，没有达到它的目标。"
const TXT_R1 := "我们宣布支持欧洲人民的和平运动，并呼吁东方集团和西方集团冷静下来，减少对抗，推进和平。这并未改变任何局势。尽管随后在布鲁塞尔（1983年10月23日，有400,000人）和海牙（1983年10月29日，有550,000人）发生了进一步的大规模示威活动。部分反对示威的人认为运动有赤化西德的危险。1983年11月22日，德国联邦议院对导弹进行了辩论，大多数议会议员决定赞成导弹的部署。从1983年12月起，导弹被陆续部署在德国。因此，和平运动失败了，没有达到它的目标。"
const TXT_R2 := "和平而无害的示威并不能威胁到任何人。尽管随后在布鲁塞尔（1983年10月23日，有400,000人）和海牙（1983年10月29日，有550,000人）发生了进一步的大规模示威活动。部分反对示威的人认为运动有赤化西德的危险。1983年11月22日，德国联邦议院对导弹进行了辩论，大多数议会议员决定赞成导弹的部署。从1983年12月起，导弹被陆续部署在德国。因此，和平运动失败了，没有达到它的目标。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d[W.I_POLITICAL_LINE]
	if line <= 2 and ws.influence_prc >= 500:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 0 and line < 4:
		_enable(opt[1], TXT_OPT1)
	elif line == 0:
		_disable(opt[1], TXT_OPT1_DIS_0)
	else:
		_disable(opt[1], TXT_OPT1_DIS_1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var _c1 := ws.get_country_by_legacy_index(1)
	var c17 := ws.get_country_by_legacy_index(17)
	var c85 := ws.get_country_by_legacy_index(85)
	var c92 := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var num := 0
			for c in ws.countries:
				if c.has_tag("nato"):
					num += 1
			var num2 := 0
			for c in ws.countries:
				if (c.government == 1 or c.government == 2) and c.原版序号 in [92, 21, 85, 86, 87]:
					num2 += 1
			if num < 11 and (num2 >= 3 or (c21_has_soc_eu())):
				var text := TXT_R0_A
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -200)
				if c17 != null:
					c17.government = 2
					c17.sub_government = 3
					_leave_alliances(c17)
					c17.set_tag("对华贸易", true)
				if c85 != null and c85.has_tag("soc_eu"):
					text += TXT_R0_A_SOCEU
					if c17 != null:
						c17.set_tag("soc_eu", true)
					if _res(147) == 3 and (c92 == null or not c92.has_tag("soc_eu")):
						text += TXT_R0_A_UK
						if c92 != null:
							c92.set_tag("soc_eu", true)
							c92.set_tag("nato", false)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 100)
				_add_power(EmpireData.USA, -50)
				_add_relation(EmpireData.USA, -500)
				ws.influence_prc += 50
				_add(W.I_DIPLO, 10)
				context["result_text"] = text
			else:
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -200)
				_add_relation(EmpireData.USA, -200)
				context["result_text"] = TXT_R0_B
		1:
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, 10)
			_add_power(EmpireData.USA, 50)
			context["result_text"] = TXT_R1
		2:
			_add_power(EmpireData.USA, 50)
			context["result_text"] = TXT_R2


func c21_has_soc_eu() -> bool:
	var c21 := ws.get_country_by_legacy_index(21)
	return c21 != null and c21.has_tag("soc_eu")
