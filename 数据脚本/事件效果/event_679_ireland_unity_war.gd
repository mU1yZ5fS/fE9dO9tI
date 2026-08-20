extends "res://数据脚本/event_script_base.gd"

## 原作 Event679.cs：26+6=1（爱尔兰统一战争，单选项）。
## 触发：ReqEventsDLC02.cs:1466-1469 —— c166.parts[0] && (c166.sub!=1 || !c166.亲中)
##   && IsSocialism(false,29) && (d167==0 || DATE_AFTER 1985.6.1) → trigger_script evaluate。
## 差异：ingamewars[87] 兜底创建后补名；AmericanSupportDefender → usa_side=2。

const TXT_DESC_A := "两个爱尔兰终究不能如此简单直接的合并，双方路线的不合正在以前所未有的速度升级为边境冲突。原先亲如兄弟的两个国度终究祸起萧墙，兄弟阋墙的故事即将重演。一开始，只是都柏林方面要求贝尔法斯特开放边界，随之而来的不仅是爱尔兰居民，更有爱尔兰国防军的安全部队；双方就政治经济合作的一揽子协议完全破裂，北方严厉拒绝了南方所提出的一系列从经济一体化，外交软化到解除武装的任何要求；南方也不希望危险的激进左翼分子激化本就不算稳定的政治局势。以危害国家稳定和勾结恐怖主义组织为理由，爱尔兰共和国逮捕了大批与北方有所联系的共和主义者，其中不乏新芬党和新芬工人党的重要成员，以及北部的线人和武装分子。这触怒了本就认为南方与英帝国主义者沆瀣一气的北爱尔兰领导层，在爆破了南方开设的对话办事处后，北爱尔兰宣布拒绝与爱尔兰共和国进行无效的讨论。\n那么，就只有一种解决方案了。就在近日，北爱尔兰军队正式越过了边境线，并在都柏林散发了哀的美敦书。爱尔兰当局已经宣布开始全国总动员，大批部队向北部边境驰援。欧洲各国均表示希望双方保持冷静。"
const TXT_DESC_B := "自民主共和国建国以来，北方就在积极的宣扬南部是一个邪恶的封建主义——小农本位国家，积极的和国际帝国主义与苏联社会帝国主义势力蝇营狗苟，沆瀣一气，试图挫败伟大的爱尔兰革命。尽管爱尔兰共和国否认了试图颠覆北爱尔兰行政机关的指控，但针锋相对的，爱尔兰共和国也谴责了阿尔斯特方面试图发动恐怖主义袭击；以最严厉的言语批评了现政府包庇前阿尔斯特防御协会和阿尔斯特志愿军成员；以及其针对爱尔兰公民的政治迫害（包括但不局限于剃阴阳头，荡妇羞辱和游街），并威胁到有可能要对阿尔斯特进行军事干涉。\n那么，局势已经很明朗了，既然南方人想要战争，那北佬们就打给他们看。今日，代号“北斗星”的特别军事行动正式展开。南部的大城市悉数感受到了别样的闹钟声：那是火箭弹从北方飞向市区的样子，都柏林已经陷入火海，而裹挟着怒火的不仅是导弹……"
const TXT_R0 := "欧洲正在被自己的怒火所吞没，下一个会是谁？"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	if int(ws.completed_event_ids.get("event_677", 0)) != 4:
		event_def.description = TXT_DESC_A
	else:
		event_def.description = TXT_DESC_B


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = TXT_R0
	GameManager.start_war(87, "北爱尔兰", "爱尔兰", 500, 500, 2, -1)
	if ws.wars.size() > 87 and ws.wars[87] != null:
		ws.wars[87].name_war = "爱尔兰统一战争"
	var northern := ws.get_country_by_legacy_index(166)
	if northern != null:
		_set_part(northern, 1, true)


func evaluate(world: WorldState) -> bool:
	if world == null or world.completed_event_ids.has("event_673"):
		return false
	var northern := world.get_country_by_legacy_index(166)
	if northern == null or northern.parts.size() == 0 or not northern.parts[0]:
		return false
	if northern.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST and northern.has_tag("亲中"):
		return false
	var ireland := world.get_country_by_legacy_index(29)
	if ireland == null or not world.is_socialism(ireland, false):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() > 167 and d.data_167 == 0:
		return true
	return world.date != null and world.date.to_int() >= 19850601


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value
