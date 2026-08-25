extends "res://数据脚本/event_script_base.gd"

## 原作 Event106.cs：民主国际（贾姆巴反共大会，三选项）。
## 触发：TimeScript.cs:10878-10884 ——
##   (月>=6 且 年>=1985 或 年>=1986) && !c7.isNATO && c51.isNATO
##   （is_gkchp/IndOpp 端口建模说明 → 视为恒真，沿用既有约定）。
## 差异：选项1 按 data.agents>=100 动态显隐；国家循环字段映射
##   sovalliance→苏联盟友、Vyshi→亲美、dev→development、stab→stability。

const TXT_R0 := "event.script.event_106_democratic_international.c0"

const TXT_R1 := "event.script.event_106_democratic_international.c1"

const TXT_R2 := "event.script.event_106_democratic_international.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], "我们不关心此事")
	var agents := world.agents if world.size() > W.I_AGENTS else 0
	if agents >= 100:
		_enable(opt[1], "安排一次恐怖袭击并扰乱会议")
	else:
		_disable(opt[1], "我们的情报机构对此无能为力")
	_enable(opt[2], "支持民主国际的形成")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_power(EmpireData.USA, 20)
			_add_power(EmpireData.USSR, -10)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -100)
			_add_power(EmpireData.USSR, 20)
			_add_power(EmpireData.USA, -30)
			ws.influence_prc += 10
			_add_relation(EmpireData.USSR, 200)
			_add_relation(EmpireData.USA, -100)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -120)
			_add_power(EmpireData.USA, 30)
			_add_power(EmpireData.USSR, -20)
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("okb") or c.has_tag("econ"):
					c.social_stability += 50
					if c.has_tag("苏联盟友"):
						c.set_tag("苏联盟友", false)
						_add(W.I_AGENTS, -30)
						_add(W.I_BUDGET, -50)
				elif c.development > 100 and c.stability > 100 and c.has_tag("亲苏"):
					c.stability -= 150
					c.development -= 50
				elif (c.development > 50 or c.stability > 50) and c.has_tag("亲美"):
					c.stability += 150
					c.development -= 100
			context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_106_democratic_international.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_106",
	"num": 106,
	"priority": 10600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_106_democratic_international.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.6.1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "7"}]}, {"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "51"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
