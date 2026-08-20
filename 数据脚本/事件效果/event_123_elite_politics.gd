extends "res://数据脚本/event_script_base.gd"

## 原作 Event123.cs：精英政治（4 选项）。
## 触发：由 Decision(GlobalScript.cs:25) 手动触发（精英政治），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻结果效果。

const TXT_R0 := "只要坚持孙中山的思想，不反对宪政秩序，不支持分裂势力，那么党内奉行各种纲领的派别便能合法形成，这也肯定了一党民主的发展方向。让我们希望这一转变将能让我党的队伍焕发生机活力，并诞生许多新奇有用的想法。"
const TXT_R1 := "首先，为了在政治上重树儒家原则，我们需要撤回一切与反孔有关的决定，并修复一切与儒家千年历史有关的纪念碑、雕像与书籍。此外，对儒家思想的攻击也被中国共产党的某些官员认为是动摇中华民族根基的过激行为。随后，政府正式出台了一份文件，要求所有党和国家的干部遵从孔子的道德教导与原则。"
const TXT_R2 := "在一切改革路径中，我们选择了最为艰难、最为漫长的一条——回归法家。在新政策全面生效之前，我们要彻底清除所有意识形态（同时对其颁布禁令），以对法律的崇拜取而代之。让一切归于全面集权，让人民为真正的严刑峻法做好准备，这一切都需要时间。当然，我们首先要树立起对最高统治者的毫不动摇、毫无疑问的服从......"
const TXT_R3 := "我们向全国人民宣告，伟大的中国需要伟大的政治家，那么，又有谁能比一个爱国军官更伟大呢？他能保卫他的祖国，他的手足同胞，乃至于我们中华文明的全部遗产。我们将开始实施我们的伟大计划，现在将只有军官才能在政治生涯中得以晋升，在五年内，每个人要么在适当的地方学习并服役，并被授予军官军衔，要么就与政治切割。大审判将至！"



func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set_modifier_active(24, true)
			_add(W.I_AGENTS, -50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_THOUGHT_FREEDOM, -25)
			_set_modifier_active(25, true)
			_add(W.I_INFLUENCE, -5)
			_add_power(EmpireData.USSR, -25)
			if d[W.I_RELIGION] < 28:
				d[W.I_RELIGION] = 28
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add(W.I_THOUGHT_FREEDOM, -25)
			_set_modifier_active(26, true)
			if d[W.I_PRESS_POLICY] < 16:
				d[W.I_PRESS_POLICY] = 16
			context["result_text"] = TXT_R2
		3:
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add(W.I_ARMY, 250)
			_add(W.I_INFLUENCE, 5)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)
			_set_modifier_active(27, true)
			context["result_text"] = TXT_R3

