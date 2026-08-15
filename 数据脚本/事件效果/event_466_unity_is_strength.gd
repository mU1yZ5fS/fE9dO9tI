extends "res://数据脚本/event_script_base.gd"

## 原作 Event466.cs：团结就是力量（印度纳萨尔派二选项）。
## 触发：ReqEventForDLC02.cs:417-419 —— data[32]>=700；fire_only_once 承担 !event_done[466]。
## 差异：Awake 的 summa_3_2 计算为派系支持率缓存，事件内未使用，跳过；
##   button_text[5]/result_num==5 为死代码，跳过。

const TXT_TITLE := "团结就是力量"
const TXT_DESC := "由于我们的援助和介入，纳萨尔派的力量不断壮大，他们在印度东部和北部的农村地区开辟了大量革命根据地和游击区；与此同时，在查鲁·马宗达同志牺牲后陷入分裂的纳萨尔派组织也逐渐再度团结起来。现在他们的主要派别已经初步整合成了印共（马列）人民战争、印度毛主义共产主义中心、印共（马列）中央重组委员会和印共（马列）解放几个较大的组织。但是这些组织之间仍然存在宗派主义问题和较大的路线分歧。分裂的纳萨尔派显然不利于印度革命的开展，或许我们应该更加深入地介入他们？不管怎么样，主席同志，这取决于你！"
const TXT_OPT0 := "印度革命是印度人自己的事……"
const TXT_OPT1 := "让我们帮助印度同志们团结起来！"
const TXT_R1 := "在我们的特工简单地制造了一场“意外”除掉了相当右倾的印共（马列）解放的领导人维诺德·米什拉——他同另外几派组织的分歧最大——之后，一切变得相当顺利。在我们的顾问团的指导和施压下，印共（马列）人民战争、印度毛主义共产主义中心、印共（马列）中央重组委员会和印共（马列）解放以及一些小型的纳萨尔派组织开展了一场谈判，谈判解决了关于查鲁·马宗达等人的历史遗留问题，议定了在当下的印度进行新民主主义革命和社会主义革命的必要性，明确了马列毛主义的共同指导思想和人民战争的共同革命路线。不久后，在的一场联合代表大会上，印度共产党（毛主义）成立了。现在印度革命有了一个统一的组织，距离查鲁·马宗达同志的定下的目标又近了一大步！"
const TXT_R0 := "由于维诺德·米什拉的右倾政策，印共（马列）解放否定了马宗达，开始鼓吹议会斗争并营造对米什拉的个人崇拜，他们甚至与另外几派纳萨尔团体发生了武装冲突。而印共（马列）人民战争、印度毛主义共产主义中心和印共（马列）中央重组委员会则团结起来了，他们将组织合并为印度共产党（毛主义），继续进行武装斗争。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			ws.influence_prc -= 20
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USSR, -100)
			ws.influence_prc += 20



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null

func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n

