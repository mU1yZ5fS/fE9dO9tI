extends "res://数据脚本/event_script_base.gd"

## 原作 Event111.cs：在幽灵般的灯光下（IECS 反扑，四选项）。
## 触发：TimeScript.cs:10972-10978 —— science[15] && 年>=1983 && modifies[11].active。
## 差异：
##  - 选项显隐 prepare 动态改写；r0 的 load_scene_after_click → Ending6：
##    Godot 设 d[I_ENDING_ROUTE]=6（结局界面后续读取）。
##  - 忠诚<300 杀 3 人循环逐字保留（毛保护/姓名2-2/同领袖性格跳过）。

const TXT_R0 := "末日已至。"

const TXT_R1 := "今天,所有的报纸上都发表了《呼吁人民》这篇文章,在文中，主席呼吁每个爱党爱国、关心中国命运的公民抵制企图复辟的走资派和党内的修正主义者。受到鼓舞的群众自发聚集在天安门广场集会，支持政府和主席同志的行动。结果，三十多万人聚集在国家的主要广场，高呼把反对反动派的文化大革命继续下去的口号。在公众愤怒的压力下，阴谋者不得不辞职，地方官员安抚了人民的热情。这是我们人民的伟大胜利!光荣归于主席!光荣归于中国共产党!"

const TXT_R2 := "由于我们情报部门的协调工作，反对我们的最高领导者提出的自动化政策的人被从所有职位上除名，并即将受到公正的审判。而在基层，一场铲除腐败的运动开始了，震撼了数万名反对党的政策的党内工作人员的立场。对我们亲爱的领袖的反对者的政治镇压激起了党内其他工作人员的不满，他们为了个人安全的原因，不得不隐藏他们的不满。然而，这是我们的伟大胜利!光荣归于主席!光荣归于中国共产党!"

const TXT_R3 := "第二天，忠诚的军队进入北京，阴谋家被逮捕并接受审判。首都实施了宵禁，城市街道由军队控制，局势似乎逐渐稳定。最积极的反动派被开除了,其余人不得不平息他们对{0}主席同志疾风暴雨般的批评。然而，工人阶级的敌人被打败了，这是我们的伟大胜利!光荣归于主席!光荣归于中国共产党!"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var people := data[W.I_PEOPLE_SUPPORT] if data.size() > W.I_PEOPLE_SUPPORT else 0
	var living := data[W.I_LIVING] if data.size() > W.I_LIVING else 0
	var agents := data[W.I_AGENTS] if data.size() > W.I_AGENTS else 0
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	_enable(opt[0], "放弃斗争和辞职")
	if people >= 900 and living >= 900 and mod3:
		_enable(opt[1], "号召人民群众反对党阀的统治")
	else:
		_disable(opt[1], "人民已经受够了大鸣大放，你想复辟文革余毒？")
	if agents >= 400:
		_enable(opt[2], "逮捕阴谋者并开始迫害最积极主动的合伙人（需要40特工网络）")
	else:
		_disable(opt[2], "国安部不会支持我们!")
	if (line < 3 and party < 8) or (coal > 66 and party > 7):
		_enable(opt[3], "动员忠诚的军官反对阴谋家")
	else:
		_disable(opt[3], "军官不会拯救我们")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if d.size() > W.I_ENDING_ROUTE:
				d[W.I_ENDING_ROUTE] = 6
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 70)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, -400)
			_kill_3_low_loyalty()
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -400)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, 50)
			_add(W.I_PARTY_SUPPORT, -500)
			_kill_3_low_loyalty()
			context["result_text"] = TXT_R2
		3:
			_add(W.I_ARMY, -300)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_PARTY_SUPPORT, -500)
			_add(W.I_DIPLO, 50)
			_kill_3_low_loyalty()
			context["result_text"] = TXT_R3.replace("{0}", _leader_name())


## Event111.cs 三结果共同的忠诚<300 杀 3 循环（逐字条件）。
func _kill_3_low_loyalty() -> void:
	var killed := 0
	for i in ws.politicians.size():
		if killed >= 3:
			break
		var p: PoliticianData = ws.politicians[i]
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.loyalty < 300 \
				and not (p.name_first == 2 and p.name_last == 2) \
				and (ws.leader == null or p.trait_personality != ws.leader.trait_personality):
			PoliticianSystem.kill_politician(i)
			killed += 1


func _coalition_percent(world: WorldState) -> int:
	var data := world.数值表
	if data.size() <= W.I_PARTY_SYSTEM or data[W.I_PARTY_SYSTEM] <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
