extends "res://数据脚本/event_script_base.gd"

## 原作 Event23.cs：唐山大地震（四选项，选项1 按美苏关系动态显隐）。
## 触发：TimeScript.cs:10194 —— (月>=8 且 年>=1976) || 年>=1977，端口为 DATE_AFTER "1976.8.1"。
## 差异：
##  - 原版按钮 1 在 empires[0].relations < 600 且 empires[1].relations < 600 时
##    Destroy(button) 并替换为“外国人不会给我们帮助”，端口为 prepare 动态 _disable。
##  - influencePRC：端口 ws.influence_prc 直接加减。

const TXT_OPT0 := "从预算中拨款支持重建（需要3百万预算）"
const TXT_OPT1 := "请求外国的人道主义救援"
const TXT_OPT1_DIS := "外国人不会给我们帮助"
const TXT_OPT2 := "分配资金支持重建并开发防震系统（需要5百万预算）"
const TXT_OPT3 := "让省政府自行解决"

const TXT_R0 := "从中央预算中拨出的资金立即被用于开展救援和重建工作，这使得地震带来的后续影响得到了削弱。今日发生在唐山的地震，是1556年陕西地震之后，历史上遇难者第二多的地震。"

const TXT_R1 := "国际社会和慈善组织评估了灾难的规模，同意以无偿贷款和派遣志愿者的形式向我们提供协助，这使得地震的影响得到了缓解。今日发生在唐山的地震，是1556年陕西地震之后，历史上遇难者第二多的地震。"

const TXT_R2 := "从中央预算中拨出的资金立即被用于开展救援和重建工作，这使得地震带来的后续影响得到了削弱。今日发生在唐山的地震，是1556年陕西地震之后，历史上遇难者第二多的地震。我们提供了额外的资金用于在灾害多发的地区建造抗震建筑，并进行了大量关于现有建筑适用性的测试，这揭露出了许多违规的操作。我们希望在未来这能有助于减少同样的灾难中的受害者。"

const TXT_R3 := "中央对河北省的问题置之不理，这对善后处理造成了困难，也让人民产生了不满，但地方当局还是以某种方式成功的应对了灾区的形势。今日发生在唐山的地震，是1556年陕西地震之后，历史上遇难者第二多的地震。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	var rel_ok := false
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USA].relations >= 600:
		rel_ok = true
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 600:
		rel_ok = true
	if rel_ok:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_opt_budget_restore(context)
		1:
			_opt_foreign_aid(context)
		2:
			_opt_restore_and_protect(context)
		3:
			_opt_let_province(context)


# 选项0：从预算中拨款支持重建（Event23.cs result 0）
func _opt_budget_restore(context: Dictionary) -> void:
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] += 30
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] += 50
	if d.size() > W.I_BUDGET:
		d[W.I_BUDGET] -= 30
	context["result_text"] = TXT_R0


# 选项1：请求外国的人道主义救援（Event23.cs result 1）
func _opt_foreign_aid(context: Dictionary) -> void:
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] -= 50
	ws.influence_prc -= 5
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] += 50
	context["result_text"] = TXT_R1


# 选项2：分配资金支持重建并开发防震系统（Event23.cs result 2）
func _opt_restore_and_protect(context: Dictionary) -> void:
	if d.size() > W.I_LIVING:
		d[W.I_LIVING] += 50
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] += 30
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] += 50
	ws.influence_prc += 5
	if d.size() > W.I_BUDGET:
		d[W.I_BUDGET] -= 50
	context["result_text"] = TXT_R2


# 选项3：让省政府自行解决（Event23.cs result 3）
func _opt_let_province(context: Dictionary) -> void:
	if d.size() > W.I_LIVING:
		d[W.I_LIVING] -= 50
	if d.size() > W.I_PEOPLE_SUPPORT:
		d[W.I_PEOPLE_SUPPORT] -= 40
	if d.size() > W.I_PARTY_SUPPORT:
		d[W.I_PARTY_SUPPORT] -= 50
	if d.size() > W.I_THOUGHT_FREEDOM:
		d[W.I_THOUGHT_FREEDOM] += 30
	context["result_text"] = TXT_R3


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
