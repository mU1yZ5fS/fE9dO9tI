extends "res://数据脚本/event_script_base.gd"

## 原作 Event20.cs：批邓反击右倾翻案风。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10175（event_done[19] && !event_done[20] && 日期>=1976.2）。
##    ref_event_id 用端口 event_id "five_no"（event_019）。
##  - data[88]++/--：反编译为死代码（ptr 局部自增/自减未写回），跳过。
##  - politics[12]（固定索引政治家）：端口 ws.politicians[12] 直访（判空）。
##  - 忠诚循环：原版独立 if/else-if 链（==0 → +X；非0 且 ==20 → +Y；非0 且非20 且 ==2 → -Z），逐字保留。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_do_nothing(context)
		1:
			_opt_join(context)
		2:
			_opt_support(context)


# 选项0：什么也别做（Event20.cs result 0）
func _opt_do_nothing(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] -= 20
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] += 40
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 100
	context["result_text"] = "在江青同志所控制的党刊中，开始了对邓小平其人及其思想的批判，现在邓小平已经解除一切公务，赋闲在家了。然而这些举动看起来有些收效甚微，邓小平作为周恩来的亲切战友和名义上纠正大跃进错误的“功臣”而备受尊敬。党的中央委员会在毛主席的3月3日指示确定了文化大革命的合法性和邓小平仍然是一个不称职的党员之后也开始了对邓小平的批判，各个省委也随之开始了对邓小平的批判。"


# 选项1：加入对小平的迫害（Event20.cs result 1）
func _opt_join(context: Dictionary) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] += 80
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] -= 20
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] += 30
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == 0:
			p.loyalty += 50
		if p.trait_personality == 20:
			p.loyalty += 30
		elif p.trait_personality == 2:
			p.loyalty -= 100
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 130
	context["result_text"] = "在江青同志所控制的党刊中，开始了对邓小平其人及其思想的批判，华国锋也认为邓小平以及背后的改革派只能让中国回到资本主义的奴役之中。现在邓小平已经解除一切公务，赋闲在家了。然而这些举动看起来有些收效甚微，邓小平作为周恩来的亲切战友和名义上纠正大跃进错误的“功臣”而备受尊敬。党的中央委员会在毛主席的3月3日指示确定了文化大革命的合法性和邓小平仍然是一个不称职的党员之后也开始了对邓小平的批判，各个省委也随之开始了对邓小平的批判。"


# 选项2：支持小平（Event20.cs result 2）
func _opt_support(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] += 20
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] -= 70
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] += 50
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].loyalty += 200
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == 0:
			p.loyalty -= 100
		elif p.trait_personality == 3:
			p.loyalty += 50
		elif p.trait_personality > 0:
			p.loyalty += 100
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].power -= 80
		ws.politicians[12].loyalty += 250
	context["result_text"] = "在江青同志所控制的党刊中，开始了对邓小平其人及其思想的批判。然而你，作为邓小平的拥护者，声称尽管邓小平犯了错误，但他已经认识到了它们并且为中国的发展做出了贡献。这造成了中共高层的不满，但对人民来说，邓小平作为周恩来的亲切战友和名义上纠正大跃进错误的“功臣”而备受尊敬。党的中央委员会在毛主席的3月3日指示确定了文化大革命的合法性和邓小平仍然是一个不称职的党员之后也开始了对邓小平的批判，各个省委也随之开始了对邓小平的批判。"
