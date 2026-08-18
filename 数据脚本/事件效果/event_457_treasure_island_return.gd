extends "res://数据脚本/event_script_base.gd"

## 原作 Event457.cs：宝岛回归！（单选项）。
## 触发：GlobalScript.cs:27 的 Decision 链 StartEvent(457)（决议系统移植说明）。
##   按项目约定 trigger_conditions=[]（仅定义，待决策系统接入）。

const TXT_TITLE := "宝岛回归！"
const TXT_DESC := "随着中国人民解放军将五星赤旗高高的升在台湾伪政府的总统府上时，中央人民广播电视总台宣布了这一项激动人心的消息：台湾终于回归了！"
const TXT_OPT0 := "为台湾回归而欢呼万岁！中华民族万岁！战无不胜的毛泽东思想万岁！"
const TXT_R0 := "原来的蒋经国政府成员要么被活捉，要么被当场击毙。蒋经国本人在坐飞机逃往美国时，被一枚“红缨-6“导弹击落，通过眼镜碎片证实了这位伪政府领导人的死亡。零星的抵抗运动迅速被战无不胜的中国人民解放军碾碎，大部分伪政府官兵选择向我们投降，这也保证了我们不会发生手足相残的惨剧。前政府高官将被流放到曾经的露天监狱——绿岛，为他们欺压台湾百姓而赎罪。总有些人说我们这是搞“红色恐怖”。但是谁在乎他们呢！\n美帝国主义日薄西山，他们再也不会对我们收复台湾指手画脚了，各国的进步人士纷纷发来贺电。同时，台湾民主自治同盟，台湾劳动党和台湾共产党将会组成中国共产党（台湾支部）暂时担任党机关。吴荣元担任首任党主席。在有效的政府机关成立之前，他们将行使行政责任。在经济方面大部分外企被驱逐，或者被国有化。我们也开始了一项雄心勃勃的铺设海底隧道的方案，这将把祖国和宝岛联系的更为紧密。\n中正纪念堂和全台各地的蒋介石纪念碑都被拆除，蒋介石的遗体被火化后投入海底，没有人会怀念这个暴君。同时这一广场也被改名为“二·二八广场”（或统一广场）。广场上树立起了一尊汉白玉雕像，象征着台湾和大陆居民的两人合抱着一块刻有中华人民共和国完整地图的雕刻。下面用简体字和繁体字写着“伟大的祖国统一万岁！挣脱了铁链的台湾人民万岁！”"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_PEOPLE_SUPPORT, 200)
			_set_data(W.I_THOUGHT_FREEDOM, 0)
			_set_relation(EmpireData.USA, 0)



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

