extends "res://数据脚本/event_script_base.gd"

## 原作 Event655.cs：西非巨人——第三幕（尼日利亚1983政变，三选项）。
## 触发：TimeScript.cs 11056-11060 —— (月>=12 且 日>=31 且 年>=1983 或 年>=1984)。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线）。
##  - 结果1/2 的布哈里声明按 c60.sub_government == GameConstants.SubGovernment.NEOLIBERAL 动态拼接（原版 ?: 字符串）。
##  - OilProd += 100f 已建模（ws.oil_prod）。
##  - 死代码 result 5 测试分支跳过。


const TXT_OPT0_DIS := "event.script.event_655_west_african_giant_act3.c0"
const TXT_OPT1_DIS := "event.script.event_655_west_african_giant_act3.c1"

const TXT_R0 := "event.script.event_655_west_african_giant_act3.c2"
const TXT_R1_BASE := "event.script.event_655_west_african_giant_act3.c3"
const TXT_R1_COND := "event.script.event_655_west_african_giant_act3.c4"
const TXT_R1_SUFFIX := "event.script.event_655_west_african_giant_act3.c5"
const TXT_R2_BASE := "event.script.event_655_west_african_giant_act3.c6"
const TXT_R2_COND := "event.script.event_655_west_african_giant_act3.c7"
const TXT_R2_SUFFIX := "event.script.event_655_west_african_giant_act3.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var opt := event_def.options
	if line >= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	var is_sub12 := nigeria != null and nigeria.sub_government == GameConstants.SubGovernment.NEOLIBERAL
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			ws.oil_prod += 100.0  # Event655.cs OilProd
			context["result_text"] = tr(TXT_R0)
		1:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.AUTHORITARIAN
				nigeria.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.oil_prod += 100.0  # Event655.cs OilProd
			var text1 := tr(TXT_R1_BASE)
			if is_sub12:
				text1 += tr(TXT_R1_COND)
			text1 += tr(TXT_R1_SUFFIX)
			context["result_text"] = text1
		2:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.AUTHORITARIAN
				nigeria.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			var text2 := tr(TXT_R2_BASE)
			if is_sub12:
				text2 += tr(TXT_R2_COND)
			text2 += tr(TXT_R2_SUFFIX)
			context["result_text"] = text2







# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_655_west_african_giant_act3.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_655",
	"num": 655,
	"priority": 65500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_655_west_african_giant_act3.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.12.31"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
