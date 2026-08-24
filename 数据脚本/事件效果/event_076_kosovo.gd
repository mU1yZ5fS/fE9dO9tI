extends "res://数据脚本/event_script_base.gd"

## 原作 Event76.cs：落井下石！（科索沃骚动，四选项）。
## 触发：TimeScript.cs:10596-10602 ——
##   (月>=3 且 年>=1981 或 年>=1982) && !c15.Torg && data.albania_break==0。
## 选项显隐（prepare 动态改写）：
##   原版 summa_3_2 阈值 66 → Godot factions 复算（见 event_075 同款辅助）。
## 差异：
##  - 原版 result1 失败分支的 data.budget++：官方版 DLL 反编译证实为 ref 真实写入，已恢复。
##  - 原版 result3 的 dlc[3] 分支：项目惯例 dlc[3] 视为恒真
##    （world_factory.gd:1462 注释），故采用中文长文本分支，
##    不再取 new_events_text[900] 的 else 分支。
##  - data.yugoslavia_kosovo_chain（科索沃状态）直访 d.yugoslavia_kosovo_chain。

const TXT_R0 := "event.script.event_076_kosovo.c0"

const TXT_R1_BASE := "event.script.event_076_kosovo.c1"

const TXT_R1_OK := "event.script.event_076_kosovo.c2"

const TXT_R1_FAIL := "event.script.event_076_kosovo.c3"

const TXT_R2 := "event.script.event_076_kosovo.c4"

const TXT_R3 := "event.script.event_076_kosovo.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < 8) or (coal > 66 and party > 7)
	var albania := world.get_country_by_legacy_index(20)
	var opt := event_def.options
	if policy_left:
		_enable(opt[0], "我们会在外交上支持科索沃分离主义者，但仅此而已")
	else:
		_disable(opt[0], "那不是我们的问题")
	if policy_left and albania != null and albania.has_tag("亲中"):
		_enable(opt[1], "向阿尔巴尼亚提供援助，帮助其将科索沃从南斯拉夫分离出来（需要5特工网络，需要5百万预算）")
	else:
		_disable(opt[1], "为什么要帮助阿尔巴尼亚？")
	_enable(opt[2], "不干涉")
	if data.size() > W.I_AGENTS and data.agents >= 100:
		_enable(opt[3], "我们将提供特勤和经济援助来帮助科索沃分离主义者（需要10特工网络，10百万预算）。")
	else:
		_disable(opt[3], "我们对南斯拉夫事务不感兴趣")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, 20)
			context["result_text"] = tr(TXT_R0)
		1:
			var text := tr(TXT_R1_BASE)
			if d.size() > W.I_BUDGET and d.size() > W.I_RESERVE and d.size() > W.I_AGENTS \
					and d.budget + d.reserve >= 50 and d.agents >= 50:
				text += tr(TXT_R1_OK)
				_add_power(EmpireData.USA, 10)
				if d.size() > 86:
					d.yugoslavia_kosovo_chain -= 2
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -50)
			else:
				text += tr(TXT_R1_FAIL)
				# 官方版 DLL 反编译（tmp_Event76.cs:109-112）证实 data[8](预算)++ 为
				# ref 真实写入，旧转储 ptr 模式系反编译伪影，已恢复。
				_add(W.I_BUDGET, 1)
			context["result_text"] = text
		2:
			context["result_text"] = tr(TXT_R2)
		3:
			# dlc[3] 恒真（项目惯例 world_factory.gd:1462）
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if d.size() > 86:
				d.yugoslavia_kosovo_chain -= 4
			_add_power(EmpireData.USA, 20)
			context["result_text"] = tr(TXT_R3)


## 原版 summa_3_2 复算（同 event_075）。
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






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_076_kosovo.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_076",
	"num": 76,
	"priority": 7600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_076_kosovo.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.3.1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "15"}]}, {"t": "RESOURCE_EQUALS", "key": "albania_break"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
