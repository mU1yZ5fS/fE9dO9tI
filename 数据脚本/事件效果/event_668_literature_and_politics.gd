extends "res://数据脚本/event_script_base.gd"

## 原作 Event668.cs：文学的敌人是政治（文艺政策论战，四选项）。
## 触发：TimeScript.cs:10358-10363 —— data.year>=1979。
## 差异：
##  - 描述与 4 个选项的文案/显隐均按原版 VariantsOfEvents 三段式动态改写
##    （prepare 等价 SetActive(false)；原版另有 result5 空文本死分支，跳过）。
##  - result0/result2 对 old_modify_desc[3]/[7] 的覆盖是修正说明文案，
##    Godot ModifierCatalog 静态维护（modifier_catalog.gd），不在此处改写。

const TXT_DESC_MOD3 := "event.script.event_668_literature_and_politics.c0"

const TXT_DESC_GOF3 := "event.script.event_668_literature_and_politics.c1"

const TXT_DESC_OTHER := "event.script.event_668_literature_and_politics.c2"

const TXT_R0 := "event.script.event_668_literature_and_politics.c3"

const TXT_R1 := "event.script.event_668_literature_and_politics.c4"

const TXT_R2 := "event.script.event_668_literature_and_politics.c5"

const TXT_R3 := "event.script.event_668_literature_and_politics.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null \
		and world.modifiers[3].is_active
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var gof := data.gang_of_four_path if data.size() > W.I_GANG_OF_FOUR_PATH else 0
	if mod3:
		event_def.description = tr(TXT_DESC_MOD3)
	elif gof == 3:
		event_def.description = tr(TXT_DESC_GOF3)
	else:
		event_def.description = tr(TXT_DESC_OTHER)
	var opt := event_def.options
	if mod3:
		_enable(opt[0], "为无产阶级文化大革命的新高潮欢呼吧！")
	else:
		if line < 2:
			_disable(opt[0], "不是已经胜利结束了吗？")
		elif line == 4:
			_disable(opt[0], "感觉像某个讨厌的浙江佬…")
		else:
			_disable(opt[0], "听起来有点像某个四川佬…")
	if not mod3 and line < 2:
		_enable(opt[1], "给文人们开窗透气，但还是得盯好他们")
	elif mod3:
		_disable(opt[1], "别再畏畏缩缩的了！")
	else:
		_disable(opt[1], "你还想天天跳忠字舞吗？")
	if not mod3 and line >= 2:
		_enable(opt[2], "这理应也是属于文化人的春天")
	elif mod3 or line == 0:
		_disable(opt[2], "软刀子杀人者最为可恶")
	else:
		_disable(opt[2], "这是对毛主席的背叛！")
	if not mod3 and line < 2:
		_enable(opt[3], "这群反动堕落文人最好给我立刻闭嘴！给我把革命小将全部叫回来！")
	elif mod3:
		_disable(opt[3], "这不符合四大自由的精神！")
	elif line == 4:
		_disable(opt[3], "这和焚书坑儒有什么区别！")
	else:
		_disable(opt[3], "极左时代的高压政策已经结束了！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 100)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 150)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, -200)
			_add(W.I_AGENTS, -100)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = tr(TXT_R3)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_668_literature_and_politics.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_668",
	"nodesc": true,
	"num": 668,
	"priority": 6680,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_668_literature_and_politics.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.1.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
