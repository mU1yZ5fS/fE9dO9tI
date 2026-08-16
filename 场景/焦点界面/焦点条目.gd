extends Button

## 焦点条目（对齐战争条目模式：.tscn 布局 + setup 数据绑定）。
## 颜色语义对齐 FocusButtoNScript.ChangeCondition：
##   blocked → 灰；overtime>=time → 红（苏联完成色）；overtime>0 → 黄；其余白。
## 图标对齐 ChangeIcon：focusscene_sp/{country}_{num}，缺失编号原版即无图。


## 条目自身有脚本，BbcTooltip.attach 不适用（attach 会覆盖脚本）；
## 按 build_tooltip 静态工厂的约定自行委托。
func _make_custom_tooltip(for_text: String) -> Control:
	return BbcTooltip.build_tooltip(for_text)


func setup(foc: FocusDef, global_num: int) -> void:
	var state: String
	if foc.blocked:
		state = "已封锁"
	elif foc.overtime >= foc.time:
		state = "已完成（%d/%d）" % [foc.overtime, foc.time]
	elif foc.overtime > 0:
		state = "进行中（%d/%d）" % [foc.overtime, foc.time]
	else:
		state = "未开始（%d/%d）" % [foc.overtime, foc.time]
	tooltip_text = "%s\n\n%s\n\n【%s】" % [foc.title, foc.desc, state]
	var title_label := find_child("标题", true, false) as Label
	if title_label != null:
		title_label.text = foc.title
	var icon_rect := find_child("图标", true, false) as TextureRect
	if icon_rect != null:
		var tex := load("res://资产/UI/焦点/1_%d.png" % global_num)
		icon_rect.texture = tex
		icon_rect.visible = tex != null
	if foc.blocked:
		modulate = Color(0.42, 0.42, 0.42, 1)
	elif foc.overtime >= foc.time:
		modulate = Color(1.0, 0.51, 0.51, 1)
	elif foc.overtime > 0:
		modulate = Color(0.95, 1.0, 0.41, 1)
	else:
		modulate = Color(1, 1, 1, 1)
	disabled = true  # 只读（原版焦点按钮点击仅用于 num<0 切换国家）
