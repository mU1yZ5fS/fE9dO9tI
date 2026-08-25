extends "res://数据脚本/event_script_base.gd"

## 原作 Event17.cs：泰国动乱。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10162（日期>=1976.10 且 !event_done[17]）。
##  - TaiCoup=true：端口无对应字段 → 用 flag "tai_coup" 表达（原版影响后续泰国事件链）。
##  - party_change[0]=1f（派系支持缓冲）：端口无等价 → 跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	ws.set_flag("tai_coup", true)
	var opt := int(context.get("option_index", -1))
	_set_thai_govt()
	match opt:
		0:
			_opt_ignore(context)
		1:
			_opt_uprising(context)
		2:
			_opt_condemn(context)


# 泰国政体变更（三个选项共有）：Gosstroy=0 / SubGosstroy=7
func _set_thai_govt() -> void:
	var thai := ws.get_country_by_legacy_index(34)
	if thai != null:
		thai.government = GameConstants.Government.AUTHORITARIAN
		thai.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN


# 选项0：这不关我们的事（Event17.cs result 0）
func _opt_ignore(context: Dictionary) -> void:
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].power = clampi(ws.empires[0].power + 5, 0, 1000)
	context["result_text"] = tr("event.script.event_017_thailand_instability.i0")


# 选项1：派遣武装的泰国共产党部队（Event17.cs result 1：启动战争2「泰国内战」）
func _opt_uprising(context: Dictionary) -> void:
	if d.size() > W.I_AGENTS:
		d.agents -= 40
	if d.size() > W.I_ARMY:
		d.army -= 30
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].relations -= 100
	var war := ws.wars[2] if ws.wars.size() > 2 else null
	if war != null:
		war.name_war = "泰国内战"
		war.is_going = true
		war.side1 = "共产党"
		war.side2 = "保王党"
		war.usa_side = GameConstants.WarSide.SIDE2
		war.ussr_side = GameConstants.WarSide.SIDE1
		war.infl1 = 300
		war.infl2 = 700
		var thai := ws.get_country_by_legacy_index(34)
		if thai != null and thai.stab == 1:
			war.infl1 += 50
			war.infl2 -= 50
	context["result_text"] = tr("event.script.event_017_thailand_instability.i1")


# 选项2：谴责泰国的暴行（Event17.cs result 2）
func _opt_condemn(context: Dictionary) -> void:
	if ws.empires.size() > 1 and ws.empires[1] != null:
		ws.empires[1].relations += 20
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].relations -= 20
		ws.empires[0].power = clampi(ws.empires[0].power + 5, 0, 1000)
	ws.influence_prc += 10
	context["result_text"] = tr("event.script.event_017_thailand_instability.i2")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_017_thailand_instability.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "thailand_instability",
	"num": 17,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 40}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 30}, {"t": "RESOURCE_EQUALS", "key": "data_41", "v": 100}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
