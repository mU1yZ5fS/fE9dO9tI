extends "res://数据脚本/event_script_base.gd"

## 原作 Event312.cs：李先念的命运（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:509-512 —— NumberOfPolitician(7,7)>=0 且 年>=1981 且 ((党内支持<=750 且 (路线0或1)) 或 NumberOfPolitician(17,17)<0 或 event_done[311])。
## 差异：KillPerson→game.kill_politician；文本来自 Events_text_en 索引 110-115。

const TXT_R0 := "event.script.event_312_li_xiannian_fate.c0"
const TXT_R1 := "event.script.event_312_li_xiannian_fate.c1"

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= W.I_YEAR:
		return false
	if data.year < 1981:
		return false
	if not _has_politician(world, 7, 7):
		return false
	var party_ok: bool = data.party_support <= 750 and (game.is_faction_leading(0) or game.is_faction_leading(1))
	var chain_ok := (not _has_politician(world, 17, 17)) or world.completed_event_ids.has("event_311")
	return party_ok or chain_ok

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -150)
			context["result_text"] = tr(TXT_R0)
		1:
			var num := _find_politician(7, 7)
			_add(W.I_PARTY_SUPPORT, 150)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty -= 250
					p.power -= 250
			if num >= 0:
				game.kill_politician(num)
			context["result_text"] = tr(TXT_R1)

	


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1

func _has_politician(world: WorldState, name1: int, name2: int) -> bool:
	if world == null:
		return false
	for p in world.politicians:
		if p != null and p.name_first == name1 and p.name_last == name2:
			return true
	return false



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_312_li_xiannian_fate.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_312",
	"num": 312,
	"priority": 31200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_312_li_xiannian_fate.gd",
	"trigger_script": "res://数据脚本/事件效果/event_312_li_xiannian_fate.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
