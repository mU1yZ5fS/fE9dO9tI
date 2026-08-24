extends "res://数据脚本/event_script_base.gd"

## 原作 Event102.cs：变革之风（1985.3.10 契尔年科逝世，三候选竞争：戈尔巴乔夫/罗曼诺夫/格里申）。
## 触发：TimeScript.cs:10859（1985.3.10 后 且 苏 now_leader∈{1,2} 且 !=7 且 !IndOpp）。
## .tres 触发条件用 EMPIRE_LEADER_IS 组合表达（苏 current==1 或 ==2）。
## 支持选项需 relres && 苏关系≥500 && 特工≥100；支持者 support +3。
## 判定（Event102.cs）：leaders[6] 戈尔巴乔夫 / leaders[4] 罗曼诺夫 / leaders[5] 格里申
##  support 比较 → now_leader=6/4/5；戈尔巴乔夫胜 → 苏 power -= 250。
## 差异：
##  - allcountries[15].Gosstroy/SubGosstroy==0 → legacy 15 政体判断
##  - data.reform_stage → I_REFORM_STAGE（前置副作用：==0 时戈尔巴乔夫 -1）
const LDR_GORBACHEV := 6   # leaders[6] = 米哈伊尔·戈尔巴乔夫
const LDR_ROMANOV := 4     # leaders[4] = 格里戈里·罗曼诺夫
const LDR_GRISHIN := 5     # leaders[5] = 维克托·格里申


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() <= EmpireData.USSR:
		return
	var ussr: EmpireData = ws.empires[EmpireData.USSR]
	var opt := int(context.get("option_index", -1))

	# 支持效果（Event102.cs ResultsOfEvents 前半）
	match opt:
		0:  # 支持戈尔巴乔夫
			_leader_support(ussr, LDR_GORBACHEV, 3)
			if d.size() > W.I_AGENTS:
				d.agents -= 100
		1:  # 支持罗曼诺夫
			_leader_support(ussr, LDR_ROMANOV, 3)
			if d.size() > W.I_AGENTS:
				d.agents -= 100
		2:  # 支持格里申
			_leader_support(ussr, LDR_GRISHIN, 3)
			if d.size() > W.I_AGENTS:
				d.agents -= 100
		3:  # 不要介入
			pass

	# 无条件副作用（Event102.cs）
	var usa: EmpireData = ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	if usa != null and ussr.power > usa.power:
		_leader_support(ussr, LDR_ROMANOV, 2)
	var c15 := ws.get_country_by_legacy_index(15)
	if c15 != null and c15.government == GameConstants.Government.AUTHORITARIAN and c15.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
		_leader_support(ussr, LDR_GORBACHEV, -1)

	# 判定（Event102.cs ResultsOfEvents 后半）
	var sg: int = _leader_support(ussr, LDR_GORBACHEV)
	var sr: int = _leader_support(ussr, LDR_ROMANOV)
	var sgr: int = _leader_support(ussr, LDR_GRISHIN)
	if sg >= sgr and sg >= sr:
		ussr.current_leader = LDR_GORBACHEV
		ussr.power = clampi(ussr.power - 250, 0, 1000)
		context["result_text"] = tr("event.script.event_102_wind_of_change.i0")
	elif sr >= sgr and sr >= sg:
		ussr.current_leader = LDR_ROMANOV
		context["result_text"] = tr("event.script.event_102_wind_of_change.i1")
	elif sgr + 1 > sr and sgr + 1 > sg:
		ussr.current_leader = LDR_GRISHIN
		context["result_text"] = tr("event.script.event_102_wind_of_change.i2")
	elif sg > sr:
		ussr.current_leader = LDR_GORBACHEV
		ussr.power = clampi(ussr.power - 250, 0, 1000)
		context["result_text"] = tr("event.script.event_102_wind_of_change.i3")
	elif sg < sr:
		ussr.current_leader = LDR_ROMANOV
		context["result_text"] = tr("event.script.event_102_wind_of_change.i4")
	else:
		ussr.current_leader = LDR_GRISHIN
		context["result_text"] = tr("event.script.event_102_wind_of_change.i5")
	context["result_title"] = tr("event.script.event_102_wind_of_change.i6")


## 读取/修改领导人支持度（越界安全，返回修改后值）
func _leader_support(ussr: EmpireData, idx: int, delta: int = 0) -> int:
	if idx < 0 or idx >= ussr.leaders.size() or ussr.leaders[idx] == null:
		return 0
	if delta != 0:
		ussr.leaders[idx].support += delta
	return ussr.leaders[idx].support



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_102_wind_of_change.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "wind_of_change",
	"num": 102,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1985.3.10"}, {"t": "ANY", "c": [{"t": "EMPIRE_LEADER_IS", "key": "1", "v": 1}, {"t": "EMPIRE_LEADER_IS", "key": "1", "v": 2}]}]}],
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "EMPIRE_RELATION_AT_LEAST", "key": "1", "v": 500}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 100}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "EMPIRE_RELATION_AT_LEAST", "key": "1", "v": 500}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 100}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "EMPIRE_RELATION_AT_LEAST", "key": "1", "v": 500}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 100}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
