extends "res://数据脚本/event_script_base.gd"

## 原作 Event97.cs：自动化？（两选项）。
## 触发：TimeScript.cs:10808-10814 —— science[17] && (data[16]==10 || data[16]==11)。
## 差异：doctr[10]/[11] 显示名（new_events_text[360/361]）Godot 未建模，跳过。

const TXT_R0 := "我国的经济规划自动化项目现在已正式启动，区域性计算机中枢正在积极建设和投入运行，各计算中枢之间的协调网络正在逐步建立。统计部门已经预测我们的生产力会有大幅度的提高，供给也会得到改善，但是并不是所有的党员都对你们的创新感到满意。"

const TXT_R1 := "有人指出有必要逐步和谨慎地采用这种新技术。基层规划部门的自动化进程极其缓慢，且饱受官僚主义的打压。按照这个速度下去，预期的生产率增长将不会很快实现。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if d.size() > W.I_PARTY_SUPPORT:
				d[W.I_PARTY_SUPPORT] = 0
			_add(W.I_BUDGET, -50)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty += 1000
				else:
					p.loyalty -= 500
			_set_modifier(11, true)
			# doctr[10]/[11] = new_events_text[360/361]：显示名未建模，跳过
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set_modifier(index: int, active: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active
