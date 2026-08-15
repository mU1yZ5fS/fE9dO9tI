extends "res://数据脚本/event_script_base.gd"

## 原作 Event418.cs：黑金（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1346 —— 复杂条件用 evaluate（parts 无 ExprNode 字段）。
## 差异：isOil→set_tag("oil",true)。

const TXT_TITLE := [
	"黑金",
]

const TXT_DESC := [
	"今天，来自阿拉伯半岛的6国领导人宣布建立阿拉伯国家海湾合作委员会。这是一个旨在实现各国在经济、社会与文化等领域合作，并全方面提升一体化水平的组织。海湾合作委员会由下述六国组成：沙特阿拉伯、科威特、巴林、卡塔尔、阿联酋与阿曼。",
]

const TXT_OPT0 := [
	"密切关注",
]

const TXT_R := [
	"专家预测，由于上述国家均是区域内的重要石油出口国，这一组织可能将深刻影响世界油价。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1339 := "黑金"
const TXT_IDX_1340 := "今天，来自阿拉伯半岛的6国领导人宣布建立阿拉伯国家海湾合作委员会。这是一个旨在实现各国在经济、社会与文化等领域合作，并全方面提升一体化水平的组织。海湾合作委员会由下述六国组成：沙特阿拉伯、科威特、巴林、卡塔尔、阿联酋与阿曼。"
const TXT_IDX_1341 := "密切关注"
const TXT_IDX_1342 := "专家预测，由于上述国家均是区域内的重要石油出口国，这一组织可能将深刻影响世界油价。"

## 原文字符串附录（供自检）

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.completed_event_ids.has("event_418"):
		return false
	var d := world.数值表
	if d.size() <= W.I_YEAR:
		return false
	if not ((d[W.I_YEAR] >= 1981 and d[W.I_MONTH] >= 5) or d[W.I_YEAR] >= 1982):
		return false
	if world.wars.size() > 28 and world.wars[28] != null and world.wars[28].is_going:
		return false
	var c14 := world.get_country_by_legacy_index(14)
	if c14 == null:
		return false
	for i in [5, 6, 7, 8]:
		if c14.parts.size() > i and c14.parts[i]:
			return false
	if not (51 < world.modifiers.size() and world.modifiers[51] != null and world.modifiers[51].is_active):
		return false
	var c101 := world.get_country_by_legacy_index(101)
	if c101 == null:
		return false
	return world.is_authoritarian(c101) or c101.government == 3

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	for cid in [36, 101, 102, 103, 105]:
		var c := ws.get_country_by_legacy_index(cid)
		if c != null:
			c.set_tag("oil", true)
	context["result_text"] = TXT_R[0]
