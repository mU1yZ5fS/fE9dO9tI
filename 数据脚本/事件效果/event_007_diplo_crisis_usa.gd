extends "res://数据脚本/event_script_base.gd"

## 原作 Event7.cs：中美外交危机。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10076 自动触发（empires[0].relations<=0 && !event_done[7] &&
##    !event_done[421]），每半年(1月/7月1日)重置可重复（TimeScript.cs:3029）；另有
##    Event705「冠礼」结果链入口（Event705.cs:63）。端口 007 的 trigger_conditions =
##    EMPIRE_RELATION_AT_MOST(0,0) + PREV_EVENT_NOT_DONE(event_421)，421 移植说明前视为恒真。
##  - 海地覆盖（SubGosstroy==19 && !cw 时替换 opt0/opt1 文案并 Destroy 按钮）：依赖
##    705 链后的海地状态，端口 UI 静态文案无法动态替换 → 仅复刻结果末尾的 cw=true 置位，
##    文案覆盖部分在 705 移植时补（届时海地状态恒不成立，行为一致）。
##  - dlc[3]（DLC 购买标志）：端口无 DLC 体系 → 视为恒真（同 game_manager.gd:2225 先例）。
##  - opt3 的 data[111]++：反编译为死代码（ptr 局部变量自增未写回 data），跳过。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))

	match opt:
		0:
			_opt_detente(context)
		2:
			_opt_nuke(context)
		3:
			_opt_indifferent(context)
		4:
			_opt_embargo(context)
	# 海地覆盖（Event7.cs ResultsOfEvents 末尾，所有结果都执行）
	_haiti_aftermath()

	# 无自定义效果时（opt1 声明式），保持 .tres 静态 result_text


# 选项0：我们出资缓和关系（Event7.cs result 0）
func _opt_detente(context: Dictionary) -> void:
	if ws.empires.size() > 0 and ws.empires[0] != null:
		ws.empires[0].relations = 400
	@warning_ignore("integer_division")
	if d.size() > W.I_DIPLO and d[W.I_DIPLO] > 600:
		@warning_ignore("integer_division")
		d[W.I_DIPLO] -= d[W.I_DIPLO] / 50
	if d.size() > W.I_BUDGET:
		d[W.I_BUDGET] -= 100
	context["result_text"] = "我们紧急组织了中美两国外交部长之间的盛大会谈，美国代表团应邀参加了一次豪华的中国之旅，在那里我们准备了各种节日和活动来表达我们和平的愿望。缓和成功了，紧张局势得到了缓和。"


# 选项2：向帝国主义者发射核武器！（Event7.cs result 2：load_scene_after_click → 结局）
func _opt_nuke(context: Dictionary) -> void:
	context["result_text"] = "紧张度提升"
	GameManager.queue_ending_after_event(3)


# 选项3：一点都不在乎（Event7.cs result 3：激活修正17「美国禁运」+ 东盟分支）
func _opt_indifferent(context: Dictionary) -> void:
	var mod17 := _get_mod17()
	if mod17 == null or not mod17.is_active:
		if d.size() > W.I_ARMY:
			d[W.I_ARMY] -= 50
		if d.size() > W.I_AGENTS:
			d[W.I_AGENTS] -= 50
		if mod17 != null:
			mod17.is_active = true
			_set_mod17_text("美国禁运", "我们将减少与美国关系差额10%的收入|失去相当于与美国关系差额5%的特工网络")
		# 差异：原 data[111]++ 为反编译死代码（ptr 局部自增未写回），跳过。
	if mod17 != null and mod17.is_active and _usa_in_asean() and d.size() > 139 and d[139] <= 0:
		d[139] = 5   # 原 data[139]（无端口命名键，数字索引直访）
	context["result_text"] = "紧张度提升"


# 选项4：让我们给帝国主义者一点颜色瞧瞧！（Event7.cs result 4：激活修正17「禁运美国」）
func _opt_embargo(context: Dictionary) -> void:
	var mod17 := _get_mod17()
	if mod17 != null:
		mod17.is_active = true
		_set_mod17_text("禁运美国", "我们将增加与美国影响差额10%的特工网络|获得相当于与美国影响差额5%的预算|美国将减少与中国影响差额10%的影响力|失去相当于与中国影响差额5%的收入")
	context["result_text"] = "很快，我们就发动了联盟内的国家对美国实施了禁运，美方对此十分震惊，谴责中国的“帝国主义行为”，但他们之前威胁我们的时候为什么不想想可能的后果呢？总而言之，美国佬会有一段“难忘”的时光了！"


# 海地后果（Event7.cs 末尾：SubGosstroy==19 && !cw → cw=true）
func _haiti_aftermath() -> void:
	var haiti := ws.get_country_by_legacy_index(139)
	if haiti != null and haiti.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST and not haiti.内战中:
		haiti.内战中 = true


func _get_mod17() -> ModifierSlot:
	if ws.modifiers.size() > 17:
		return ws.modifiers[17]
	return null


## 原 old_modify_texts[17]/old_modify_desc[17]：运行时改 ModifierDef 展示文案（与 UI 读取路径一致）
func _set_mod17_text(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(17)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect


func _usa_in_asean() -> bool:
	var usa := ws.get_country_by_legacy_index(1)
	return usa != null and usa.has_tag("asean")
