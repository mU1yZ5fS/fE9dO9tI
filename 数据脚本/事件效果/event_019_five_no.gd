extends "res://数据脚本/event_script_base.gd"

## 原作 Event19.cs：五"不准"。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10169（日期>=1976.2 且 !event_done[19]）。
##  - 原版按钮 0-3 对应 number_otvet 1-4（按钮号+1），端口选项索引 0-3 直接对应。
##  - opt0 的 data.democracy_movement++ / opt2 的 data.democracy_movement--：反编译为死代码（ptr 局部自增/自减未写回），跳过；
##    opt3 的 data.democracy_movement += 2 为真实效果（保留）。
##  - data.democracy_movement（无端口命名键）：数字索引直访。
##  - politics[12].loyality += 200：端口 ws.politicians[12] 直访（判空）。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_pass(context)
		1:
			_opt_enforce(context)
		2:
			_opt_criticize(context)
		3:
			_opt_sabotage(context)


# 选项0：让它通过，我们静观其变（Event19.cs number_otvet==1）
func _opt_pass(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 50
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 50
	context["result_text"] = "作为运动的一部分，警察和工人民兵拆除了纪念周恩来的临时纪念碑，一些纪念周恩来的大字报和宣传画也被撤下。政府对祭奠周恩来行为的压制引起了人民的不满，而江青同志则被认为是幕后黑手……"


# 选项1：严格执行这场运动（Event19.cs number_otvet==2）
func _opt_enforce(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 70
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 50
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation += 10
	_add_loyalty_by_trait(0, 70)
	context["result_text"] = "作为国务院总理，公安部部长，您亲自指挥了这次驱散运动。作为运动的一部分，警察和工人民兵拆除了纪念周恩来的临时纪念碑，一些纪念周恩来的大字报和宣传画也被撤下。政府对祭奠周恩来行为的压制引起了广泛的不满，而江青同志和华国锋同志则被认为是幕后黑手……"


# 选项2：严格执行这场运动，并在媒体上批评这种行为（Event19.cs number_otvet==3）
func _opt_criticize(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 100
	if d.size() > W.I_THOUGHT_FREEDOM:
		d.thought_freedom += 70
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation += 10
	_add_loyalty_by_trait(0, 100)
	context["result_text"] = "作为国务院总理，公安部部长，您亲自指挥了这次驱逐活动并在人民日报的头版发表了对纪念周恩来行为的批评，然而这看起来收效甚微，看起来群众已经厌倦了文化大革命中无止境的批判运动了。作为运动的一部分，警察和工人民兵拆除了纪念周恩来的临时纪念碑，一些纪念周恩来的大字报和宣传画也被撤下。政府对祭奠周恩来行为的压制和在媒体上的批判引起了广泛的不满，而江青同志和华国锋同志则被认为是幕后黑手……"


# 选项3：轻微地破坏这场运动（Event19.cs number_otvet==4）
func _opt_sabotage(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d.people_support -= 10
	if d.size() > 88:
		d.democracy_movement += 2   # 原 data.democracy_movement（无端口命名键）
	if d.size() > W.I_PARTY_SUPPORT:
		d.party_support -= 50
	if d.size() > W.I_DIPLO:
		d.diplomatic_reputation -= 10
	if ws.politicians.size() > 12 and ws.politicians[12] != null:
		ws.politicians[12].loyalty += 200   # 原 politics[12].loyality += 200
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 70
		elif p.trait_personality >= GameConstants.PoliticianPersonality.MODERATE or p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 50
	context["result_text"] = "作为国务院总理，公安部部长，您尽全力的将这次运动的规模控制在最小范围内，一些下令完全禁止纪念活动的官员被调任。作为运动的一部分，警察和工人民兵拆除了纪念周恩来的临时纪念碑，一些纪念周恩来的大字报和宣传画也被撤下。政府对祭奠周恩来行为的压制引起了人民的不满，而江青同志则被认为是幕后黑手。然而由于您的出手，这些不满并没有到不可收拾的程度……"


## 指定 traits[0]（性格）的政治家忠诚变化
## 注：参数名不用 trait（Godot 4.3+ 保留字），用 trait_id
func _add_loyalty_by_trait(trait_id: int, delta: int) -> void:
	for p in ws.politicians:
		if p != null and p.trait_personality == trait_id:
			p.loyalty += delta
