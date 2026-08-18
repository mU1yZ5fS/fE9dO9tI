extends "res://数据脚本/event_script_base.gd"

## 原作 Event462.cs：一个中国?（单选项）。
## 触发：GlobalScript.cs:26 的 Decision 链 StartEvent(462)（决议系统移植说明）。
##   按项目约定 trigger_conditions=[]（仅定义，待决策系统接入）。
## 差异：names1/names2 拼接→ws.leader.name_display。

const TXT_TITLE := "一个中国?"
const TXT_DESC := "在我们消除威权分子的毒害并确立自由民主的政治体制后，美国与我们的关系日益升温，我们也不断加强与他们各方面的合作。随着时间的推移，我们开始再度审视两岸和平统一的可能性。令人欣喜的是，美国人出于战略需要，居然愿意帮助我们与台湾当局斡旋！这表明他们支持我们的统一。我们离统一，似乎只有一步之遥！"
const TXT_OPT0 := "结果将会如何？"
const TXT_R0_P1 := "当地时间"
const TXT_R0_NIAN := "年"
const TXT_R0_YUE := "月"
const TXT_R0_P2 := "日，在美国的默许下，我国领袖"
const TXT_R0_P3 := "率领代表团对台北进行了历史性的访问，在此期间，经过闭门谈判后，决定成立一个委员会，制定台湾和中国大陆逐步统一的原则。\n我们最终同意建立台湾特别行政区来解决两岸问题。台湾特别行政区保留自己现有的政治体制（蒋经国同意在中央政府指导下逐步实行民主政治）和经济体制，但在重大事宜（如外交）上要与中国大陆步调一致，并宣布统一于中央政府。谈判结束后，两岸领导人合影留念。在我们宣布谈判结果后，民众欢呼雀跃，高兴不已。两岸的经济文化交流迅速展开，不少由于国民党逃到台湾而离开大陆的的同胞也回到了自己的家乡，两岸的血又流到了一起。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var taiwan := _country(38)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var year := str(_res(W.I_YEAR))
			var month := str(_res(W.I_MONTH))
			var day := str(_res(W.I_DAY))
			context["result_text"] = TXT_R0_P1 + year + TXT_R0_NIAN + month + TXT_R0_YUE + day + TXT_R0_P2 + _leader_name() + TXT_R0_P3
			if taiwan != null:
				taiwan.sub_government = 8



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

