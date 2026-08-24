extends "res://数据脚本/event_script_base.gd"

## 原作 Event684.cs：新跃进？（引进外资与十年规划，四选项）。 ## 触发：TimeScript.cs:10325-10330 —— ##   (月>=12 且 年>=1977 或 年>=1978) && (resultOfEvents[25]!=2 resultOfEvents[26]!=2) ##   → .tres 用 NOT(ALL(25==2, 26==2)) 等价表达。 ## 差异： ##  - 选项1 原版按 empires[1].relations>=500 销毁按钮，prepare 动态改写。 ##  - 结果文本 {0}{1}（原版 names1+names2 无空格拼接）插 ws.leader.name_display。 ##  - party_ideology 三个分支是三个独立 if（20→faction1、1→faction2、2→faction3），逐字保留。

const TXT_R0 := "event.script.event_684_new_leap.c0"

const TXT_R1 := "event.script.event_684_new_leap.c1"

const TXT_R2 := "event.script.event_684_new_leap.c2"

const TXT_R3 := "event.script.event_684_new_leap.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options[1]
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null \
			and world.empires[EmpireData.USSR].relations >= 500:
		opt.text = "钞票不会说谎，也许我们能将此作为与社会主义阵营复交的契机"
		opt.disabled_text = ""
		opt.enable_condition = null
	else:
		opt.text = "苏联可不会任我国与东欧诸国眉来眼去！"
		opt.disabled_text = opt.text
		opt.enable_condition = _never_node()


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader_name := _leader_name()
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, -40)
			_add(W.I_BUDGET, -100)
			_add(W.I_LOAN, 250)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_SERVICES, 100)
			_add(W.I_LIVING, 70)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_SCIENCE, 4000)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USA, 100)
			_add_power(EmpireData.USA, 50)
			_adjust_politicians()
			context["result_text"] = tr(TXT_R0).replace("{0}{1}", leader_name)
		1:
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -100)
			_add(W.I_LOAN, 250)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_SERVICES, 100)
			_add(W.I_LIVING, 70)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_SCIENCE, 4000)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USSR, 50)
			_adjust_politicians()
			context["result_text"] = tr(TXT_R1).replace("{0}{1}", leader_name)
		2:
			_add(W.I_DIPLO, -10)
			_add(W.I_BUDGET, -20)
			_add(W.I_LOAN, 50)
			_add(W.I_INDUSTRY, 50)
			_add(W.I_AGRICULTURE, 70)
			_add(W.I_SCIENCE, 2000)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 10)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_AGRICULTURE, 30)
			_add(W.I_INDUSTRY, 20)
			_add(W.I_PARTY_SUPPORT, 50)
			if d.size() > W.I_ECON_SYSTEM and d.econ_system == 11:
				d.econ_system = 12
			if ws.factions.size() > 3:
				var personality := ws.leader.trait_personality if ws.leader != null else -1
				if personality == 20:
					ws.factions[1].ideology += 30
				elif personality == 1:
					ws.factions[2].ideology += 30
				if personality == 2:
					ws.factions[3].ideology += 30
			context["result_text"] = tr(TXT_R3).replace("{0}{1}", leader_name)


## Event684.cs result0/1 共同政治家循环： ## traits[0]==leader.traits[0] → power-=200；else if traits[0]==2 → power+=200。
func _adjust_politicians() -> void:
	var leader_personality: int = ws.leader.trait_personality if ws.leader != null else -1
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == leader_personality:
			p.power -= 200
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.power += 200








func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _never_node() -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	return n



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_684_new_leap.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_684",
	"num": 684,
	"priority": 6840,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_684_new_leap.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1977.12.1"}, {"t": "NOT", "c": [{"t": "ALL", "c": [{"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "gang_of_four"}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "weak_alliance"}]}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
