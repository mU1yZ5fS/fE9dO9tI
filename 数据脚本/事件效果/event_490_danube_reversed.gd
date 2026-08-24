extends "res://数据脚本/event_script_base.gd"

## 原作 Event490.cs：让多瑙河倒流？（罗马尼亚反齐奥塞斯库政变，三选项）。 ## 触发：TimeScript.cs:10628-10635 —— ##   ((年>=1984 月>=10 日>=15) (年>=1984 月>=11) 年>=1985) ##   && event_done[79] && resultOfEvents[79]>2 && !c5.isNATO ##   （result>2 = 结果3 或 4，.tres 用 ANY(==3, ==4) 表达）。 ## 差异： ##  - 描述按 resultOfEvents[79]==3 分支拼接（prepare）。 ##  - OilProd 已建模（ws.oil_prod），result1 炼油技术转让 +100；result0 三路政权分支逐字保留。 ##  - IsSocialism(true,1) → world.is_socialism(c1, true)； ##    result79!=3 分支用 influence_prc > empires[1].power。

const TXT_R0_OPEN := "event.script.event_490_danube_reversed.c0"

const TXT_MINERS := "event.script.event_490_danube_reversed.c1"

const TXT_A1 := "event.script.event_490_danube_reversed.c2"

const TXT_A2 := "event.script.event_490_danube_reversed.c3"

const TXT_A3 := "event.script.event_490_danube_reversed.c4"

const TXT_R1 := "event.script.event_490_danube_reversed.c5"

const TXT_R2 := "event.script.event_490_danube_reversed.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var result79: int = world.completed_event_ids.get("event_079", -1)
	var desc := "长期执掌罗马尼亚大权的齐奥塞斯库以挥霍巨额外债的方式将政府拉入紧缩政策泥潭。该国生活标准也就此跳水：人们一边过着食物凭粮票供应，限制用电、用气和用油的好日子；一边则享受更多工作日。全国正以“节衣缩食”与“多子多福”两大政策为纲。于此同时，齐奥塞斯库仍然没有放弃旧的经济和政治路线，照常建设大型项目，其家族成员的权势和“知识分子集团”的地位正不断垄断党内权力，大兴个人崇拜。然而，并不是所有党员都认可当局的现行政策。另一方面，苏联也对罗马尼亚在苏东阵营中的独立地位感到不满，甚至还存在格鲁乌扶持亲苏军官密谋政变的传言。对此，齐奥塞斯库夫妇则只是拴紧螺丝，积极打压，试图让其彻底出局。\n据了解，"
	if result79 == 3:
		desc += "我们之前组织的罗共秘密团体已经准备好行动了，"
	else:
		desc += "罗共异见党员已经组织了一个阴谋团体，其成员包含在任内批评总统喜好在庞大而低效的项目上浪费开支而被送去“国家水务委员会主席”冷板凳的扬·伊利埃斯库、因有“通苏反齐”嫌疑而被退役转任工业建设部副部长的尼古拉·米利塔鲁将军、被齐奥塞斯库转入预备役的前国防部长、前副总理扬·约尼查将军、民族主义批评者亚诺什·法泽卡什、反对齐奥塞斯库的党内元老西尔维乌·布鲁坎、斯特凡·科斯蒂亚尔少将和海军上校尼古拉·拉杜等人，"
	desc += "他们计划于齐奥塞斯库访问西德期间发动政变，对国家进行拨乱反正。\n我们是否要做些什么？"
	event_def.description = desc
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	if world.influence_prc >= 600 and _tech(world, 25):
		_enable(opt[0], "是时候了，让多瑙河倒流吧！")
	else:
		_disable(opt[0], "齐奥塞斯库是不可动摇的，多瑙河也不可能倒流！")
	if line < 4 and world.influence_prc >= 300:
		_enable(opt[1], "多瑙河永远不会倒流，我们自然也不会背叛这位东欧朋友，支持齐奥塞斯库同志！")
	else:
		_disable(opt[1], "我们不会支持这个独裁者")
	_enable(opt[2], "不要干预罗马尼亚内政，让一切顺其自然")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var romania := ws.get_country_by_legacy_index(5)
	var result79: int = ws.completed_event_ids.get("event_079", -1)
	match opt:
		0:
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			var text := tr(TXT_R0_OPEN)
			var china := ws.get_country_by_legacy_index(1)
			var mod6 := _mod_active(GameConstants.Modifier.MAOIST_BULWARK)
			var china_sev := china != null and china.has_tag("sev")
			if result79 == 3 and china != null and ws.is_socialism(china, true) \
					and mod6 and not china_sev:
				text += tr(TXT_MINERS) + tr(TXT_A1)
				if romania != null:
					romania.government = GameConstants.Government.SOCIALIST
					romania.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
					romania.set_tag("对华贸易", true)
					romania.set_tag("亲苏", false)
					romania.set_tag("亲中", true)
				_add_relation(EmpireData.USSR, -100)
				ws.influence_prc += 20
				context["result_text"] = text
				return
			var ussr_power := ws.empires[EmpireData.USSR].power if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null else 0
			if ((result79 == 3 and china != null and china.government == GameConstants.Government.REFORMIST) \
					or (result79 != 3 and ws.influence_prc > ussr_power)) and not china_sev:
				if result79 == 3:
					text += tr(TXT_MINERS)
				text += tr(TXT_A2)
				if romania != null:
					romania.government = GameConstants.Government.REFORMIST
					romania.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
					romania.set_tag("对华贸易", true)
					romania.set_tag("亲苏", false)
					romania.set_tag("亲中", true)
				_add_relation(EmpireData.USSR, -100)
				ws.influence_prc += 20
				_ussr_leader_add(6, 1)
				context["result_text"] = text
				return
			text += tr(TXT_A3)
			if romania != null:
				romania.government = GameConstants.Government.SOCIALIST
				romania.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				romania.set_tag("对华贸易", true)
				romania.set_tag("亲苏", true)
				romania.set_tag("亲中", false)
				romania.set_tag("balecon", false)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USSR, 20)
			_ussr_leader_add(4, 1)
			context["result_text"] = text
		1:
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -300)
			_add(W.I_AGENTS, -100)
			if romania != null:
				romania.set_tag("对华贸易", true)
				romania.set_tag("亲中", true)
			_add(W.I_SCIENCE, 200)
			ws.oil_prod += 100.0  # Event490.cs result1：炼油技术转让
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)


func _tech(world: WorldState, index: int) -> bool:
	return world.techs != null and world.techs.unlocked.size() > index and world.techs.unlocked[index]


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active




func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_490_danube_reversed.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_490",
	"nodesc": true,
	"num": 490,
	"priority": 4900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_490_danube_reversed.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1984.10.15"}, {"t": "PREV_EVENT_DONE", "ref": "event_079"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "v": 3, "ref": "event_079"}, {"t": "PREV_EVENT_RESULT_IS", "v": 4, "ref": "event_079"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "5"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
