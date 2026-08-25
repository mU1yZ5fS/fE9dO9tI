extends "res://数据脚本/event_script_base.gd"

## 原作 Event681.cs：广阔天地，大有作为（上山下乡政策审决，五选项）。
## 触发：TimeScript.cs:10409-10415 —— (月>=12 且 年>=1978 或 年>=1979)。
## 差异：
##  - 5 个选项的文案/显隐按原版 VariantsOfEvents 动态改写（prepare）。
##  - 结果后的 old_modify_desc[15] 拼接是修正说明文案，Godot 由
##    ModifierCatalog 静态维护（modifier_catalog.gd EFFECT_ZH[15]），跳过。
##  - r2/r3/r4 的 {0}{1} 插领导人姓名（r0/r1 无占位符）。

const TXT_R0 := "event.script.event_681_shangshan_xiaxiang.c0"

const TXT_R1 := "event.script.event_681_shangshan_xiaxiang.c1"

const TXT_R2 := "event.script.event_681_shangshan_xiaxiang.c2"

const TXT_R3 := "event.script.event_681_shangshan_xiaxiang.c3"

const TXT_R4 := "event.script.event_681_shangshan_xiaxiang.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null \
		and world.modifiers[3].is_active
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var press := data.press_policy if data.size() > W.I_PRESS_POLICY else 0
	var budget_reserve := 0
	if data.size() > W.I_BUDGET and data.size() > W.I_RESERVE:
		budget_reserve = data.budget + data.reserve
	var opt := event_def.options
	_enable(opt[0], "为什么要破坏仍行之有效的东西？")
	if not mod3 and line > 0:
		_enable(opt[1], "近代的苦日子早过去了！孩子们，也该回城了，该回去读书了！")
	else:
		_disable(opt[1], "动摇毛主席的劳动教育路线？我们决不同意！")
	if mod3 and line <= 2 and budget_reserve >= 180:
		_enable(opt[2], "实践表明，“上山下乡”政策还远远不够。为建设社会主义新农村，我们必须竭尽所能！")
	elif not mod3 or line > 2:
		_disable(opt[2], "路线错了，补救越多越反动！")
	else:
		_disable(opt[2], "囊中羞涩，余力不足，国家现在正困难，得节俭度日")
	if press == 16 and line < 4:
		_enable(opt[3], "“上山下乡”政策当然有其可取之处，尤其是其中算“政治账”的部分……")
	else:
		_disable(opt[3], "你疯了吗？！这么做和封建帝王有什么区别？！")
	if not mod3:
		_enable(opt[4], "“上山下乡”是唯意志论的表现，我们得用新思维取而代之！")
	else:
		_disable(opt[4], "毛主席经验在前，我们没必要重新发明轮子！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name()
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -20)
			_add(W.I_PEOPLE_SUPPORT, -20)
			_add(W.I_THOUGHT_FREEDOM, 80)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGRICULTURE, -20)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -180)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_AGRICULTURE, 50)
			context["result_text"] = tr(TXT_R2).replace("{0}{1}", leader_name)
		3:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, -20)
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			context["result_text"] = tr(TXT_R3).replace("{0}{1}", leader_name)
		4:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			context["result_text"] = tr(TXT_R4).replace("{0}{1}", leader_name)
	# 原版此后的 old_modify_desc[15] 拼接：修正说明文案，Godot 由
	# ModifierCatalog 静态维护，不在事件脚本中改写（见本文件头注）。




func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_681_shangshan_xiaxiang.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_681",
	"num": 681,
	"priority": 6810,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_681_shangshan_xiaxiang.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.12.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
