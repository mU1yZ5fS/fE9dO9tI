extends "res://数据脚本/event_script_base.gd"

## 原作 Event23.cs：唐山大地震（四选项，选项1 按美苏关系动态显隐）。 ## 触发：TimeScript.cs:10194 —— (月>=8 且 年>=1976) 年>=1977，端口为 DATE_AFTER "1976.8.1"。 ## 差异： ##  - 原版按钮 1 在 empires[0].relations < 600 且 empires[1].relations < 600 时 ##    Destroy(button) 并替换为“外国人不会给我们帮助”，端口为 prepare 动态 _disable。 ##  - influencePRC：端口 ws.influence_prc 直接加减。

const TXT_OPT0 := "event.script.event_023_tangshan.c0"
const TXT_OPT1 := "event.script.event_023_tangshan.c1"
const TXT_OPT1_DIS := "event.script.event_023_tangshan.c2"
const TXT_OPT2 := "event.script.event_023_tangshan.c3"
const TXT_OPT3 := "event.script.event_023_tangshan.c4"

const TXT_R0 := "event.script.event_023_tangshan.c5"

const TXT_R1 := "event.script.event_023_tangshan.c6"

const TXT_R2 := "event.script.event_023_tangshan.c7"

const TXT_R3 := "event.script.event_023_tangshan.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	_enable(opt[0], tr(TXT_OPT0))
	var rel_ok := false
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USA].relations >= 600:
		rel_ok = true
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 600:
		rel_ok = true
	if rel_ok:
		_enable(opt[1], tr(TXT_OPT1))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], tr(TXT_OPT2))
	_enable(opt[3], tr(TXT_OPT3))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_budget_restore(context)
		1:
			_opt_foreign_aid(context)
		2:
			_opt_restore_and_protect(context)
		3:
			_opt_let_province(context)


# 选项0：从预算中拨款支持重建（Event23.cs result 0）
func _opt_budget_restore(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support += 30
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += 50
	if d.size() > W.I_BUDGET:
		d.budget -= 30
	context["result_text"] = tr(TXT_R0)


# 选项1：请求外国的人道主义救援（Event23.cs result 1）
func _opt_foreign_aid(context: Dictionary) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 50
	ws.influence_prc -= 5
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 50
	context["result_text"] = tr(TXT_R1)


# 选项2：分配资金支持重建并开发防震系统（Event23.cs result 2）
func _opt_restore_and_protect(context: Dictionary) -> void:
	if d.size() > W.I_LIVING:
		d.living_standard += 50
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support += 30
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support += 50
	ws.influence_prc += 5
	if d.size() > W.I_BUDGET:
		d.budget -= 50
	context["result_text"] = tr(TXT_R2)


# 选项3：让省政府自行解决（Event23.cs result 3）
func _opt_let_province(context: Dictionary) -> void:
	if d.size() > W.I_LIVING:
		d.living_standard -= 50
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 40
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 50
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 30
	context["result_text"] = tr(TXT_R3)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_023_tangshan_earthquake.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_023",
	"num": 23,
	"priority": 2300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_023_tangshan.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1976.8.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
