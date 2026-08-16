extends Button

## 决议条目（对齐战争条目模式：.tscn 布局 + setup 数据绑定）。
## 状态语义对齐 DecisionButtonScript.ChangeCondition：
##   done → 绿灰禁用；可执行(can_execute) → 白色可点；不可执行 → 灰禁用。

var decision_id: int = -1


## 条目自身有脚本，BbcTooltip.attach 不适用（attach 会覆盖脚本）；
## 按 build_tooltip 静态工厂的约定自行委托。
func _make_custom_tooltip(for_text: String) -> Control:
	return BbcTooltip.build_tooltip(for_text)


func setup(def: DecisionDef) -> void:
	decision_id = def.id
	var done := DecisionSystem.is_completed(def.id)
	var can_execute: bool = not done and def.condition.is_valid() and def.condition.call()
	var state := "已完成" if done else ("条件未满足" if not can_execute else "可执行")
	# 悬浮介绍多行自动换行（复用 BbcTooltip 静态工厂）
	tooltip_text = "%s\n\n%s\n\n【%s】" % [def.title, def.desc, state]
	var title_label := find_child("标题", true, false) as Label
	if title_label != null:
		if done:
			title_label.text = "%s（已完成）" % def.title
		elif can_execute:
			title_label.text = def.title
		else:
			title_label.text = "%s（条件未满足）" % def.title
	disabled = not can_execute
	if done:
		modulate = Color(0.6, 0.7, 0.6, 1)
	elif can_execute:
		modulate = Color(1, 1, 1, 1)
	else:
		modulate = Color(0.55, 0.55, 0.55, 1)
