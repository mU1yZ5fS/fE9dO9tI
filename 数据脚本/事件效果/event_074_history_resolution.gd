extends "res://数据脚本/event_script_base.gd"

## 原作 Event74.cs：关于建国以来党的若干历史问题的决议（1981.7 后 且 event_done[39] 五中全会后）。 ## 触发：TimeScript.cs:10550（1981.7 后 且 event_done[39]）。 ## 选项：0/1/2 按 data.mao_history_line（毛历史评价路线）选择对应版本通过；3=重写（需路线<2 一党制<8 或多党联盟>66%）；4=不通过。 ## 效果（Event74.cs ResultsOfEvents，2026-08 移植）： ##  - result0：党内+50/民众+80/国际声望-100/改革动量-20/思想自由+50、美苏关系-100、政客（0派+100p+150l；1派-50p-50l；2派-100p-100l；3派-150p-150l） ##  - result1：党内+100/民众+80/改革动量+10/国际声望-50/思想自由-30、影响力-20、政客（0派+100l；1/2派+100p+100l；3派+100l） ##  - result2：党内-150/民众-150/兵源-200/改革动量+40/国际声望+250/思想自由-60、美+100/苏+250、影响力-50、 ##           政客（0/1/2派-300l；3派+150l）、load_scene_after_click → number_event=4（触发事件4 党内阴谋）→ 端口 start_event("congress_conspiracy") ##  - result3（重写）：data.political_line<2 → 党内+20/民众+50/改革动量-20/国际声望-60/思想自由+40、data.mao_history_line=0、政客（0派+100p+150l；1派-50p-50l；2派-100p-100l；3派-150p-200l） ##               data.political_line==1 2 → 党内+80/民众+40/改革动量+10/国际声望-50/思想自由-20、data.mao_history_line=1、政客（同 result1） ##               data.political_line>2 → 党内-100/民众-150/兵源-200/改革动量+40/国际声望+200/思想自由-50、影响力-30、data.mao_history_line=2、政客（0/1/2派-300l；3派+150l） ##  - result4（不通过）：无效果 ## 差异：party_change 派系缓冲端口无等价 → 跳过；result2 的 load_scene → start_event("congress_conspiracy") ## 索引映射修正（2026-08-04 随批审查）：原版 data.thought_freedom=思想自由→I_THOUGHT_FREEDOM、data.diplomatic_reputation=国际声望→I_DIPLO。 ##           原稿 freedom/diplo 两参写反，已按《economy_data.gd 数值表 + TimeScript.cs:46 政治危机公式》修正。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = tr("event.script.event_074_history_resolution.i0")
	match opt:
		0:
			_add_data(50, 80, 50, -20, -100)
			_rel(-100, -100)
			_politicians({0: [100, 150], 1: [-50, -50], 2: [-100, -100], 3: [-150, -150]})
			context["result_text"] = tr("event.script.event_074_history_resolution.i1")
		1:
			_add_data(100, 80, -30, 10, -50)
			ws.influence_prc -= 20
			_politicians({0: [0, 100], 1: [100, 100], 2: [100, 100], 3: [0, 100]})
			context["result_text"] = tr("event.script.event_074_history_resolution.i2")
		2:
			_add_data(-150, -150, -60, 40, 250)
			if d.size() > W.I_MANPOWER:
				d.manpower -= 200
			_rel(100, 250)
			ws.influence_prc -= 50
			_politicians({0: [0, -300], 1: [0, -300], 2: [0, -300], 3: [0, 150]})
			# 差异：load_scene_after_click → 原版触发事件4（党内阴谋）
			game.start_event("congress_conspiracy")
			context["result_text"] = tr("event.script.event_074_history_resolution.i3")
		3:
			var line: int = d.political_line if d.size() > W.I_POLITICAL_LINE else 0
			if line < 2:
				_add_data(20, 50, 40, -20, -60)
				if d.size() > W.I_MAO_HISTORY_LINE:
					d.mao_history_line = 0
				_politicians({0: [100, 150], 1: [-50, -50], 2: [-100, -100], 3: [-150, -200]})
				context["result_text"] = tr("event.script.event_074_history_resolution.i4")
			elif line <= 2:
				_add_data(80, 40, -20, 10, -50)
				if d.size() > W.I_MAO_HISTORY_LINE:
					d.mao_history_line = 1
				_politicians({0: [0, 100], 1: [100, 100], 2: [100, 100], 3: [0, 100]})
				context["result_text"] = tr("event.script.event_074_history_resolution.i5")
			else:
				_add_data(-100, -150, -50, 40, 200)
				if d.size() > W.I_MANPOWER:
					d.manpower -= 200
				ws.influence_prc -= 30
				if d.size() > W.I_MAO_HISTORY_LINE:
					d.mao_history_line = 2
				_politicians({0: [0, -300], 1: [0, -300], 2: [0, -300], 3: [0, 150]})
				context["result_text"] = tr("event.script.event_074_history_resolution.i6")
		_:
			context["result_text"] = tr("event.script.event_074_history_resolution.i7")


## 通用数值修正（党内/民众/思想自由/改革动量/声望）
func _add_data(party: int, people: int, freedom: int, momentum: int, diplo: int) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += party
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support += people
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += freedom
	if d.size() > W.I_REFORM_MOMENTUM:
		d.reform_momentum += momentum
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation += diplo


## 帝国关系修正（美/苏）
func _rel(usa_d: int, ussr_d: int) -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.empires[EmpireData.USA].relations = clampi(ws.empires[EmpireData.USA].relations + usa_d, 0, 1000)
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.empires[EmpireData.USSR].relations = clampi(ws.empires[EmpireData.USSR].relations + ussr_d, 0, 1000)


## 政客按性格修正（trait_personality → [power_delta, loyalty_delta]）
func _politicians(changes: Dictionary) -> void:
	for p in ws.politicians:
		if p == null:
			continue
		var ch: Array = changes.get(p.trait_personality, [0, 0])
		p.power += int(ch[0])
		p.loyalty += int(ch[1])



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_074_history_resolution.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "history_resolution_1981",
	"num": 74,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.7.1"}, {"t": "PREV_EVENT_DONE", "ref": "historical_resolution"}]}],
	"options": [{"disabled": true, "cond": {"t": "RESOURCE_EQUALS", "key": "mao_history_line"}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "RESOURCE_EQUALS", "key": "mao_history_line", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "RESOURCE_EQUALS", "key": "mao_history_line", "v": 2}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
