extends CanvasLayer

## 国家面板 — 点选地球上某国后显示，展示国家属性 + 可执行的外交互动。
## 节点结构（来自 外交.tscn 中 国家面板 子树）：
##   国家面板 (CanvasLayer, 本脚本, visible=false)
##     背景 (TextureRect)
##     关闭 (TextureButton)
##     当前选中国家名称 (Label)
##     国家属性背景 (TextureRect)
##     政府类型 (TextureRect)
##     军事联盟 (TextureRect)
##     经济联盟 (TextureRect)
##     贸易伙伴 (TextureRect)
##     在某国影响下 (TextureRect)
##     互动按钮 / 互动按钮2 / 互动按钮3 / 互动按钮4 (Button)
##     执行当前互动按钮所需条件及检查 (Label)

# ── 图标资源 ──

const W = preload("res://数据脚本/world_state.gd")
const ACTION_CATALOG_SCRIPT := preload("res://数据脚本/外交互动/外交互动目录.gd")
const COUNTRY_CHAIN_SCRIPT := preload("res://场景/外交界面/国家面板/国家面板_逐国链.gd")

## 子意识形态图标：原版最终显示的是 sub_znachki[SubGosstroy]
## （CountryScript.cs:52，ChangeIcons() 末尾会调用 ChangeSubIcons() 覆盖政体图标）。
## 文件按 Diplomacy.unity:182-205 的 sub_znachki 序列化顺序复制为 sub_00..sub_22.png。
const SUB_ICONS := {
	0: preload("res://资产/UI/外交/子意识形态图标/sub_00.png"),
	1: preload("res://资产/UI/外交/子意识形态图标/sub_01.png"),
	2: preload("res://资产/UI/外交/子意识形态图标/sub_02.png"),
	3: preload("res://资产/UI/外交/子意识形态图标/sub_03.png"),
	4: preload("res://资产/UI/外交/子意识形态图标/sub_04.png"),
	5: preload("res://资产/UI/外交/子意识形态图标/sub_05.png"),
	6: preload("res://资产/UI/外交/子意识形态图标/sub_06.png"),
	7: preload("res://资产/UI/外交/子意识形态图标/sub_07.png"),
	8: preload("res://资产/UI/外交/子意识形态图标/sub_08.png"),
	9: preload("res://资产/UI/外交/子意识形态图标/sub_09.png"),
	10: preload("res://资产/UI/外交/子意识形态图标/sub_10.png"),
	11: preload("res://资产/UI/外交/子意识形态图标/sub_11.png"),
	12: preload("res://资产/UI/外交/子意识形态图标/sub_12.png"),
	13: preload("res://资产/UI/外交/子意识形态图标/sub_13.png"),
	14: preload("res://资产/UI/外交/子意识形态图标/sub_14.png"),
	15: preload("res://资产/UI/外交/子意识形态图标/sub_15.png"),
	16: preload("res://资产/UI/外交/子意识形态图标/sub_16.png"),
	17: preload("res://资产/UI/外交/子意识形态图标/sub_17.png"),
	18: preload("res://资产/UI/外交/子意识形态图标/sub_18.png"),
	19: preload("res://资产/UI/外交/子意识形态图标/sub_19.png"),
	20: preload("res://资产/UI/外交/子意识形态图标/sub_20.png"),
	21: preload("res://资产/UI/外交/子意识形态图标/sub_21.png"),
	22: preload("res://资产/UI/外交/子意识形态图标/sub_22.png"),
}

const MIL_ALLIANCE_ICONS := {
	# 顺序与原版 CountryScript.ChangeIcons 军事槽判定一致
	# （NAZIMAO → FXSEU → OVD → RIM → OKB → NATO → SEATO → SENTO，:135-218）
	"nazimao": preload("res://资产/UI/外交/军事联盟_欧罗巴解放阵线.png"),
	"fxseu": preload("res://资产/UI/外交/军事联盟_欧洲社会国家组织.png"),
	"ovd": preload("res://资产/UI/外交/军事联盟_华沙条约.png"),
	"rim": preload("res://资产/UI/外交/军事联盟_革命国际.png"),
	"okb": preload("res://资产/UI/外交/军事联盟_集体安全.png"),
	"nato": preload("res://资产/UI/外交/军事联盟_北约.png"),
	"seato": preload("res://资产/UI/外交/军事联盟_东南亚条约.png"),
	"sento": preload("res://资产/UI/外交/军事联盟_中央条约.png"),
}
const MIL_ALLIANCE_NAMES := {
	"nazimao": "欧罗巴解放阵线", "fxseu": "欧洲社会国家组织",
	"ovd": "华沙条约", "rim": "革命国际", "okb": "集体安全条约（由玩家组建）",
	"nato": "北大西洋公约", "seato": "东约组织", "sento": "中央条约组织",
}

const ECON_ALLIANCE_ICONS := {
	# 顺序与原版 CountryScript.ChangeIcons 经济槽判定一致（SEV → ECON → 石油 → 社会欧盟 → 欧共体 → 东盟）
	"sev": preload("res://资产/UI/外交/经济联盟_经互会.png"),
	"econ": preload("res://资产/UI/外交/经济联盟_双边经济.png"),
	"oil": preload("res://资产/UI/外交/经济联盟_石油联盟.png"),
	"soc_eu": preload("res://资产/UI/外交/经济联盟_社会主义欧盟.png"),
	"eu": preload("res://资产/UI/外交/经济联盟_欧共体.png"),
	"asean": preload("res://资产/UI/外交/经济联盟_东盟.png"),
}
const ECON_ALLIANCE_NAMES := {
	"sev": "经济互助委员会", "econ": "经济合作组织（由玩家组建）", "asean": "东盟",
	"eu": "欧洲经济共同体", "soc_eu": "社会主义联盟", "oil": "海湾合作委员会",
}

## 原版 Znach(3) 贸易伙伴图标：razmerika.png（CountryScript.cs:278-288）
const TRADE_PARTNER_ICON := preload("res://资产/UI/外交/贸易伙伴_中国.png")
const TRADE_PARTNER_NAME := "中国的贸易伙伴"

const INFLUENCE_ICONS := {
	# key 与 CountryData 势力圈返回码一致；法国=4（原版 PuppetIcons/21.png，
	# CountryScript.cs:302-305）、南非=5（znachki[27]=南非傀儡.png，:391-395）
	0: preload("res://资产/UI/外交/在某国影响下_美国.png"),
	1: preload("res://资产/UI/外交/在某国影响下_苏联.png"),
	2: preload("res://资产/UI/外交/在某国影响下_中国.png"),
	4: preload("res://资产/UI/外交/在某国影响下_法国.png"),
	5: preload("res://资产/UI/外交/在某国影响下_南非.png"),
	# 6 澳大利亚影响：原版 znachki[26]，暂缺对应图标资源，待补充后加 preload。
}
const INFLUENCE_NAMES := {
	0: "在美国影响下", 1: "在苏联影响下", 2: "在我国影响下",
	4: "在法国影响下", 5: "在南非影响下", 6: "在澳大利亚影响下",
}


# ── 外交互动定义 ──
# 每个互动：{id, text, conditions: [{desc, check: Callable}], effects: Callable}
# conditions 中每项 check 返回 true 表示满足

# ── 外交互动编号目录（移植自 DiploButtonScript）──
# 每个编号对应原版 this_type：Show()=条件, OnMouseDown()=效果。
# caption 来自 CountryScript.Show 的标签；opis 来自 DiploButtonScript.this_opis。
const DIPLO_BTN_TRADE9 := 9
const DIPLO_BTN_TRADE24 := 24
const DIPLO_BTN_ECON10 := 10
const DIPLO_BTN_MIL19 := 19
const DIPLO_BTN_MAOIST1 := 1
const DIPLO_BTN_RIM5000 := 5000
const DIPLO_BTN_AU5001 := 5001

var _current_country: CountryData
var _current_actions: Array[Dictionary] = []
var _buttons: Array[Button] = []
var _action_catalog: DiploActionCatalog
var _country_chain  # 无 class_name 的预载脚本实例，动态调用 build()


func _ready() -> void:
	visible = false
	_action_catalog = ACTION_CATALOG_SCRIPT.new()
	_country_chain = COUNTRY_CHAIN_SCRIPT.new()
	_buttons = []
	for btn_name in ["互动按钮", "互动按钮2", "互动按钮3", "互动按钮4"]:
		var btn := find_child(btn_name, true, false)
		if btn is Button:
			_buttons.append(btn)

	# 关闭按钮
	var close_btn := find_child("关闭", true, false)
	if close_btn is TextureButton:
		close_btn.pressed.connect(_close)

	# 连接按钮点击
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_action_pressed.bind(i))
		_buttons[i].mouse_entered.connect(_on_action_hover.bind(i))
		_buttons[i].mouse_exited.connect(_on_action_unhover)

	# 连接地球选择信号
	var earth := get_parent().get_node_or_null("地球")
	if earth and earth.has_signal("country_selected"):
		earth.country_selected.connect(_on_country_selected)

	# 实时刷新：贸易/联盟/影响力等由事件或外交互动改完后，面板保持打开也要立即更新
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_on_stats_changed):
			GameManager.stats_changed.connect(_on_stats_changed)
		if GameManager.has_signal("world_state_loaded") and not GameManager.world_state_loaded.is_connected(_on_stats_changed):
			GameManager.world_state_loaded.connect(_on_stats_changed)


func _on_stats_changed() -> void:
	if visible and _current_country != null:
		_refresh(_current_country, "")
		# 数值在日/月块变化后，悬停中的条件列表也要立即刷新。
		for i in range(_buttons.size()):
			if _buttons[i].is_hovered():
				_on_action_hover(i)


func _on_country_selected(gwcode: int, country_name: String) -> void:
	if gwcode <= 0 or GameManager.world == null:
		_close()
		return

	var w: WorldState = GameManager.world

	# 原版 CountryScript.OnMouseDown 不排除玩家本国（中国=allcountries[1] 有自己的按钮链），
	# 仅对 69 西藏/70 维吾尔斯坦做 data.tibet_policy/data.xinjiang_policy 非零门控，故此处不再屏蔽自己。
	var country := w.get_country_by_gwcode(gwcode)

	# 原版 CountryScript.OnMouseDown L470：69 西藏需 data.tibet_policy!=0、70 维吾尔斯坦需 data.xinjiang_policy!=0
	# 才允许打开面板，否则点击不响应（这里关闭面板等价）。
	if country != null:
		var legacy := int(country.原版序号)
		if legacy == 69 and w.tibet_policy == 0:
			_close()
			return
		if legacy == 70 and w.xinjiang_policy == 0:
			_close()
			return

	# 即使 WorldState 中无此国家数据，只要地图有名字也显示基本面板
	if country == null:
		_current_country = null
		_show_basic_panel(country_name)
		return

	_current_country = country
	_refresh(country, country_name)
	visible = true


func _close() -> void:
	visible = false
	_current_country = null


## 无 CountryData 时显示只有名字的基本面板
func _show_basic_panel(display_name: String) -> void:
	var name_label := find_child("当前选中国家名称", true, false) as Label
	if name_label:
		name_label.text = display_name if display_name != "" else "未知国家"
	for node_name in ["政府类型", "军事联盟", "经济联盟", "贸易伙伴", "在某国影响下"]:
		var icon := find_child(node_name, true, false) as TextureRect
		if icon:
			icon.visible = false
	_current_actions.clear()
	for btn in _buttons:
		btn.visible = false
		btn.disabled = true
	_clear_condition_text()
	visible = true


# ── 刷新面板全部内容 ──

func _refresh(country: CountryData, display_name: String) -> void:
	# 国家名称（优先用 display_name 参数，回退到动态国名）
	var name_label := find_child("当前选中国家名称", true, false) as Label
	if name_label:
		name_label.text = country.display_name() if display_name == "" else display_name

	_refresh_icons(country)
	_refresh_actions(country)
	_clear_condition_text()


# ── 图标显示 ──

func _refresh_icons(country: CountryData) -> void:
	var gov_icon := find_child("政府类型", true, false) as TextureRect
	var mil_icon := find_child("军事联盟", true, false) as TextureRect
	var econ_icon := find_child("经济联盟", true, false) as TextureRect
	var trade_icon := find_child("贸易伙伴", true, false) as TextureRect
	var inf_icon := find_child("在某国影响下", true, false) as TextureRect

	# 子意识形态图标（原版 ChangeSubIcons 最终覆盖政体图标后的显示）+ 政体/意识形态 tooltip
	if gov_icon:
		var tex: Texture2D = SUB_ICONS.get(country.sub_government)
		if tex:
			gov_icon.texture = tex
			var gov_label: String = CountryData.GOV_NAME.get(country.government, "")
			var ideo_label: String = country.ideology_name()
			gov_icon.tooltip_text = "%s\n%s" % [gov_label, ideo_label]
			gov_icon.visible = true
		else:
			gov_icon.visible = false

	# 军事联盟
	if mil_icon:
		var found := false
		for tag in MIL_ALLIANCE_ICONS:
			if country.has_tag(tag):
				mil_icon.texture = MIL_ALLIANCE_ICONS[tag]
				mil_icon.tooltip_text = MIL_ALLIANCE_NAMES.get(tag, tag)
				mil_icon.visible = true
				found = true
				break
		if not found:
			for tag in MIL_ALLIANCE_NAMES:
				if country.has_tag(tag):
					mil_icon.tooltip_text = MIL_ALLIANCE_NAMES[tag]
					mil_icon.visible = true
					found = true
					break
		if not found:
			mil_icon.visible = false

	# 经济联盟
	if econ_icon:
		var found := false
		for tag in ECON_ALLIANCE_ICONS:
			if country.has_tag(tag):
				econ_icon.texture = ECON_ALLIANCE_ICONS[tag]
				econ_icon.tooltip_text = ECON_ALLIANCE_NAMES.get(tag, tag)
				econ_icon.visible = true
				found = true
				break
		if not found:
			for tag in ECON_ALLIANCE_NAMES:
				if country.has_tag(tag):
					econ_icon.tooltip_text = ECON_ALLIANCE_NAMES[tag]
					econ_icon.visible = true
					found = true
					break
		if not found:
			econ_icon.visible = false

	# 贸易伙伴（原版 Znach(3)：Torg → razmerika.png，CountryScript.cs:278-288）
	if trade_icon:
		if country.has_tag("对华贸易"):
			trade_icon.texture = TRADE_PARTNER_ICON
			trade_icon.tooltip_text = TRADE_PARTNER_NAME
			trade_icon.visible = true
		else:
			trade_icon.visible = false

	# 在某国影响下
	if inf_icon:
		var sphere := country.in_sphere_of_influence()
		var tex: Texture2D = INFLUENCE_ICONS.get(sphere)
		if tex:
			inf_icon.texture = tex
			var label: String = INFLUENCE_NAMES.get(sphere, "")
			# 原版法国托管地特殊文案（CountryScript.cs:306-315）
			if sphere == CountryData.SPHERE_FRANCE and country.原版序号 == 154:
				label = "法国的一部分"
			elif sphere == CountryData.SPHERE_FRANCE and country.原版序号 == 159:
				label = "英-法共同托管"
			inf_icon.tooltip_text = label
			inf_icon.visible = true
		else:
			inf_icon.visible = false


# ── 互动按钮 ──

func _refresh_actions(country: CountryData) -> void:
	_current_actions = _build_actions_v2(country)

	for i in _buttons.size():
		if i < _current_actions.size():
			_buttons[i].text = _current_actions[i].text
			_buttons[i].visible = true
			# 原版 Show 后按 uslovie_bool 置灰：条件不满足的按钮不可点击，
			# 避免暂停状态下反复按（尤其贸易/同盟这类效果执行后条件即时翻转的动作）。
			var all_ok := true
			var conditions: Array = _current_actions[i].get("conditions", [])
			for cond in conditions:
				if cond.has("check"):
					var ok: bool = bool(cond.check.call())
					if not ok:
						all_ok = false
						break
			_buttons[i].disabled = not all_ok
		else:
			_buttons[i].visible = false
			_buttons[i].disabled = true


func _on_action_pressed(index: int) -> void:
	if index >= _current_actions.size():
		return
	if index < _buttons.size() and _buttons[index].disabled:
		return
	var action: Dictionary = _current_actions[index]
	var conditions: Array = action.get("conditions", [])
	for cond in conditions:
		if cond.has("check") and not cond.check.call():
			return
	if action.has("effect"):
		action.effect.call()
		# 外交互动可能直接改写 empires[].relations，立即钳制到合法区间
		if GameManager.world:
			GameManager.world.clamp_empire_relations()
		# 广播刷新：地图渲染/状态栏等监听 stats_changed 实时更新
		if GameManager != null:
			GameManager.notify_stats_changed()
	# 剧情外交操作会立即切入事件场景，不能再刷新即将离树的国家面板。
	if GameManager.current_event_id != "":
		return
	# 上面 notify_stats_changed() 已同步刷新过一次（display_name=""，会落到动态国名）；
	# 这里再刷新一次是为了恢复地图传入的国名，并统一重建悬停条件文本。
	var name_label := find_child("当前选中国家名称", true, false) as Label
	_refresh(_current_country, name_label.text if name_label else "")
	if index < _buttons.size() and _buttons[index].is_hovered():
		_on_action_hover(index)


func _on_action_hover(index: int) -> void:
	if index >= _current_actions.size():
		return
	var action: Dictionary = _current_actions[index]
	var conditions: Array = action.get("conditions", [])
	var lines: PackedStringArray = []
	for cond in conditions:
		var met: bool = cond.check.call() if cond.has("check") else true
		lines.append("%s  [%s]" % [cond.get("desc", ""), "√" if met else "×"])
	if action.has("effect_desc"):
		lines.append("\n效果：%s" % action.effect_desc)
	var label := find_child("执行当前互动按钮所需条件及检查", true, false) as Label
	if label:
		label.text = "\n".join(lines)


func _on_action_unhover() -> void:
	_clear_condition_text()


func _clear_condition_text() -> void:
	var label := find_child("执行当前互动按钮所需条件及检查", true, false) as Label
	if label:
		label.text = ""


# ============================================================================
# 外交互动构建 — 根据目标国家动态生成可用互动列表
# 移植自原版 CountryScript.ChineseButtons() + DiploButtonScript.ChineseInfo()
# ============================================================================

## [已弃用 2026-07-27] 手写近似互动，被 _build_actions_v2（编号目录驱动）取代。
## 保留供后续批次比对，勿在生产路径调用。
func _def_9(w: WorldState, d: WorldState, country: CountryData) -> Dictionary:
	var opis := "深化经贸关系"
	if country.原版序号 == 104:
		opis = "建立正式外交关系并深化经贸关系"
	var conds: Array = []
	# 条件1：声誉档（DBS L263-292，按目标国政体分档）
	conds.append(_cond(_diplo_rep_desc(w, country), func(): return _diplo_rep_check(w, d, country)))
	# 条件2：战乱国内战分支（DBS L293-312）；通用项=尚未深化经贸
	var desc2 := "尚未深化经贸关系"
	var check2 := func() -> bool: return not country.has_tag("对华贸易")
	if country.原版序号 == 34 and w.war_going(2):
		desc2 = "没有内战"
		check2 = func() -> bool: return false
	elif country.原版序号 == 109 and w.war_going(31):
		desc2 = "没有内战"
		check2 = func() -> bool: return false
	elif country.原版序号 == 110 and w.war_going(32):
		desc2 = "没有内战"
		check2 = func() -> bool: return false
	conds.append(_cond(desc2, check2))
	# 条件3：工业档（DBS L313-327，亲中→30；欧美列强集合→70；其余→50）
	conds.append(_cond(_diplo_industry_desc(country), func(): return _diplo_industry_check(d, country)))
	# 条件4（DBS L328-341）：苏联入北约排他 / 魁北克不亲美
	var ussr := w.get_country_by_legacy_index(7)
	if ussr != null and ussr.has_tag("nato") and (
			country.has_tag("亲美") or country.has_tag("亲苏") or country.has_tag("nato")):
		conds.append(_cond("苏 联 未 加 入 北 约", func():
			var c7 := w.get_country_by_legacy_index(7)
			return c7 == null or not c7.has_tag("nato")))
	elif country.原版序号 == 167:
		conds.append(_cond("魁 北 克 政 府 不 亲 美", func(): return not country.has_tag("亲美")))
	return {
		"caption": "发展贸易", "opis": opis, "conditions": conds, "dormant": false,
		"effect": func(): country.set_tag("对华贸易", true),
	}


## 声誉档描述（DBS L263-287 的 uslovie[0] 分档）
func _diplo_rep_desc(w: WorldState, country: CountryData) -> String:
	# 108 受法国控制时的专属改写（DBS L288-292）
	if country.原版序号 == 108:
		var france := w.get_country_by_legacy_index(21)
		if france != null and france.has_tag("对华贸易") and country.puppet_of == GameConstants.LegacySlot.FRANCE:
			return "与法国有贸易关系"
	if w.leader_property.size() > 2 and w.leader_property[2] and w.is_socialism(country, false):
		return "外交声誉低于 11451.4"
	if w.is_authoritarian(country):
		return "外交声誉在 39 到 80 之间"
	if w.is_socialism(country, true):
		return "外交声誉高于 69"
	if country.government == GameConstants.Government.REFORMIST:
		return "外交声誉在 39 到 85 之间"
	return "外交声誉低于 50"


func _diplo_rep_check(w: WorldState, d: WorldState, country: CountryData) -> bool:
	if country.原版序号 == 108:
		var france := w.get_country_by_legacy_index(21)
		if france != null and france.has_tag("对华贸易") and country.puppet_of == GameConstants.LegacySlot.FRANCE:
			return france.has_tag("对华贸易")
	if w.leader_property.size() > 2 and w.leader_property[2] and w.is_socialism(country, false):
		return d.diplomatic_reputation < 114514
	if w.is_authoritarian(country):
		return d.diplomatic_reputation > 390 and d.diplomatic_reputation < 800
	if w.is_socialism(country, true):
		return d.diplomatic_reputation > 690
	if country.government == GameConstants.Government.REFORMIST:
		return d.diplomatic_reputation > 390 and d.diplomatic_reputation < 850
	return d.diplomatic_reputation < 500


## 工业档（编号9 的 uslovie[2]，DBS L313-327）
func _diplo_industry_desc(country: CountryData) -> String:
	if country.has_tag("亲中"):
		return "工业不低于 30"
	var n := country.原版序号
	if n == 92 or n == 85 or n == 136 or n == 135 or n == 137 \
			or (n > 87 and n < 92) or n == 0:
		return "工业不低于 70"
	return "工业不低于 50"


func _diplo_industry_check(d: WorldState, country: CountryData) -> bool:
	if country.has_tag("亲中"):
		return d.industry >= 300
	var n := country.原版序号
	if n == 92 or n == 85 or n == 136 or n == 135 or n == 137 \
			or (n > 87 and n < 92) or n == 0:
		return d.industry >= 700
	return d.industry >= 500


# ============================================================================
# 编号 24 · 发展贸易（变体）
# DiploButtonScript Show L778-837 / OnMouseDown L9039
# ============================================================================
func _def_24(w: WorldState, d: WorldState, country: CountryData) -> Dictionary:
	var conds: Array = []
	# uslovie[0]（DBS L782-810）：14 伊朗 sub==20 首档 + 通用声誉档
	var rep_desc := _diplo_rep_desc(w, country)
	var rep_check := func() -> bool: return _diplo_rep_check(w, d, country)
	if country.原版序号 == GameConstants.LegacySlot.IRAQ and country.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
		rep_desc = "外交声誉低于 11451.4"
		rep_check = func() -> bool: return d.diplomatic_reputation < 114514
	conds.append(_cond(rep_desc, rep_check))
	conds.append(_cond("尚未深化经贸关系", func(): return not country.has_tag("对华贸易")))
	conds.append(_cond("工业不低于 70", func(): return d.industry >= 700))
	# uslovie[3]（DBS L816-836）：按国专属排他
	var player := w.get_player_country()
	var n := country.原版序号
	if n == 14:
		conds.append(_cond("该 国 不 受 伊 朗 人 的 摆 布", func(): return country.puppet_of != 8))
	elif ((n >= 2 and n <= 6) or n == 16) and player != null and player.has_tag("sev"):
		conds.append(_cond("中 国 已 加 入 经 互 会", func():
			var p := w.get_player_country()
			return p != null and p.has_tag("sev")))
	elif (n >= 2 and n <= 6) or n == 16:
		conds.append(_cond("该 国 不 受 苏 联 的 影 响", func(): return not country.has_tag("亲苏")))
	return {
		"caption": "发展贸易", "opis": "深化经贸关系", "conditions": conds, "dormant": false,
		"effect": func(): country.set_tag("对华贸易", true),
	}


# ============================================================================
# 编号 10 · 经济合作
# DiploButtonScript Show L343-431 / OnMouseDown L8839-8855
# ============================================================================
func _def_10(w: WorldState, d: WorldState, country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var conds: Array = []
	# 条件1(uslovie[0])：按国专属（DBS L347-361）
	var desc0 := "已深化经贸关系或该国持亲中立场"
	var check0 := func() -> bool: return country.has_tag("对华贸易") or country.has_tag("亲中")
	if country.原版序号 == 9:
		desc0 = "蒙古人民相信我们的善意"
		check0 = func() -> bool: return country.has_tag("亲中") and w.result_of_event_num(62) != 2
	elif country.原版序号 == 35 or country.原版序号 == GameConstants.LegacySlot.IRAQ:
		desc0 = "该国持亲中立场"
		check0 = func() -> bool: return country.has_tag("亲中")
	# 8 伊朗的声誉档改写（DBS L401-430）
	if country.原版序号 == 8:
		if w.leader_property.size() > 2 and w.leader_property[2] and w.is_socialism(country, false):
			desc0 = "外交声誉低于 11451.4"
			check0 = func() -> bool: return d.diplomatic_reputation < 114514
		elif country.government == GameConstants.Government.AUTHORITARIAN:
			desc0 = "外交声誉在 39 到 80 之间"
			check0 = func() -> bool: return d.diplomatic_reputation > 390 and d.diplomatic_reputation < 800
		elif country.government == GameConstants.Government.SOCIALIST:
			desc0 = "外交声誉高于 69"
			check0 = func() -> bool: return d.diplomatic_reputation > 690
		elif country.government == GameConstants.Government.REFORMIST:
			desc0 = "外交声誉在 39 到 85 之间"
			check0 = func() -> bool: return d.diplomatic_reputation > 390 and d.diplomatic_reputation < 850
		else:
			desc0 = "外交声誉低于 50"
			check0 = func() -> bool: return d.diplomatic_reputation < 500
	conds.append(_cond(desc0, check0))
	# 条件2(uslovie[1])：中国已建经合组织(econ) 或 已入经互会(sev)
	conds.append(_cond("中国已建立经合组织，或中国已加入经互会",
		func(): return player != null and (player.has_tag("sev") or player.has_tag("econ"))))
	# 条件3(uslovie[2])：目标国未加入任何经济组织
	conds.append(_cond("该国未加入经合组织",
		func(): return not country.has_tag("sev") and not country.has_tag("econ") and not country.has_tag("asean")))
	# 条件4(uslovie[3])：原版是顺序 if 改写同一槽，不是 AND；按最后一次命中为准（DBS L366-430）
	var slot3_desc := ""
	var slot3_check := Callable()
	if country.has_tag("亲美") or country.has_tag("美国盟友"):
		slot3_desc = "该 国 不 受 美 国 的 影 响"
		slot3_check = func(): return not country.has_tag("亲美") and not country.has_tag("美国盟友")
	if (country.has_tag("亲苏") or country.has_tag("苏联盟友")) and (player == null or not player.has_tag("sev")):
		slot3_desc = "该 国 不 受 苏 联 的 影 响"
		slot3_check = func(): return not country.has_tag("亲苏") and not country.has_tag("苏联盟友")
	if country.原版序号 == 29:
		slot3_desc = "该 国 不 在 北 约 与 欧 共 体 内"
		slot3_check = func(): return not country.has_tag("nato") and not country.has_tag("eu")
	if country.has_tag("soc_eu"):
		slot3_desc = "该 国 不 在 社 会 主 义 联 盟"
		slot3_check = func(): return not country.has_tag("soc_eu")
	if country.原版序号 == 8 and (w.war_going(3) or w.war_going(5)):
		slot3_desc = "伊 朗 与 阿 富 汗 均 无 战 事"
		slot3_check = func(): return not w.war_going(3) and not w.war_going(5)
	if slot3_desc != "":
		conds.append(_cond(slot3_desc, slot3_check))
	var eff := func():
		if player != null and player.has_tag("sev"):
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].power += 20
			w.influence_prc += 10
			country.set_tag("sev", true)
		else:
			d.people_support += 20
			w.influence_prc += 20
			country.set_tag("econ", true)
			country.social_stability = 1000
			d.party_support += 30
	return {
		"caption": "经济合作", "opis": "允许该国加入我国经济联盟，建立全面战略合作伙伴关系",
		"conditions": conds, "dormant": false, "effect": eff,
	}


# ============================================================================
# 编号 19 · 军事同盟
# DiploButtonScript Show L636-661 / OnMouseDown L8951-8976
# ============================================================================
func _def_19(w: WorldState, d: WorldState, country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var conds: Array = []
	# 原版 uslovie 赋值序为 [1],[3],[0],[2]；此处按可读顺序列出，条件为 AND 故顺序不影响判定
	conds.append(_cond("至少 2 军事实力", func(): return d.army >= 20))
	conds.append(_cond("外交声誉高于 79", func(): return d.diplomatic_reputation > 790))
	conds.append(_cond("他们已加入经合组织或经互会",
		func(): return country.has_tag("sev") or country.has_tag("econ")))
	var slot_desc := "他们未参与军事联盟，且中国已成立集安组织或已加入华约"
	if country.has_tag("oar"):
		var c30 := w.get_country_by_legacy_index(30)
		if c30 == null or c30.government != GameConstants.Government.SOCIALIST:
			slot_desc = "他 们 还 未 加 入 阿 拉 伯 联 合 共 和 国"
	conds.append(_cond(slot_desc,
		func(): return _mil19_slot_check(w, player, country)))
	var eff := func():
		if player != null and player.has_tag("ovd"):
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
				w.empires[EmpireData.USSR].power += 20
			w.influence_prc += 10
			country.set_tag("ovd", true)
			if country.has_tag("亲中"):
				country.prc_influence = 500
			elif country.has_tag("亲苏"):
				country.sov_influence = 500
		else:
			w.influence_prc += 20
			country.set_tag("okb", true)
			if country.social_stability <= 0:
				country.social_stability = 1000
	return {
		"caption": "军事同盟", "opis": "邀请该国参与我国军事联盟，实现合作无上限，保障地区安全稳定",
		"conditions": conds, "dormant": false, "effect": eff,
	}


## 编号19 uslovie[2]：军事联盟排他（忠实 DBS Show L646-660）
## 非 oar 目标 → OVD/okb 排他式；oar 目标 → 仅当 allcountries[30] 为社会主义(Gosstroy==1) 才放行，否则封锁(!oar=false)
func _mil19_slot_check(w: WorldState, player: CountryData, country: CountryData) -> bool:
	if player == null:
		return false
	var via_ovd := not country.has_tag("ovd") and player.has_tag("ovd") and not country.has_tag("seato")
	var via_okb := not country.has_tag("okb") and player.has_tag("okb") and not country.has_tag("ovd") and not country.has_tag("seato")
	var complex := via_ovd or via_okb
	if not country.has_tag("oar"):
		return complex
	var c30 := w.get_country_by_legacy_index(30)
	if c30 != null and c30.government == GameConstants.Government.SOCIALIST:
		return complex
	return false


# ============================================================================
# 编号 1 · 扶持极左派（支持毛派组织）
# DiploButtonScript Show L54-73 / OnMouseDown L8622-8665
# 西欧 = 原版序号 ∈ {92,21,17}；否则东欧
# ============================================================================
func _def_1(w: WorldState, d: WorldState, country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var is_west := country.原版序号 == 92 or country.原版序号 == GameConstants.LegacySlot.FRANCE or country.原版序号 == 17
	var conds: Array = []
	# uslovie[0]：特工≥50 且 预算+外汇≥30（DBS L58）
	conds.append(_cond("至少 5 特工网络和 3 百万预算",
		func(): return d.agents >= 50 and d.budget + d.reserve >= 30))
	# uslovie[1]：modifies[6].active（DBS L60）
	conds.append(_cond("我们始终坚持伟大的毛泽东思想！",
		func(): return _modifier_active(w, 6)))
	# uslovie[2]：声誉>750（DBS L62）
	conds.append(_cond("外交声誉高于 75", func(): return d.diplomatic_reputation > 750))
	# uslovie[3]：西欧读 war_active[0]，东欧读 war_active[1]（DBS L64-71，每年一次冷却）
	if is_west:
		conds.append(_cond("西欧：每年一次", func(): return not _war_active_flag(w, 0)))
	else:
		conds.append(_cond("东欧：每年一次", func(): return not _war_active_flag(w, 1)))
	var eff := func():
		if is_west:
			var usa := _empire(w, EmpireData.USA)
			if usa != null:
				var pen := 50
				if usa.current_leader == 3:
					pen = 75
				elif usa.current_leader == 5:
					pen = 100
				usa.power -= pen
				usa.relations -= 200
			_set_war_active(w, 0, true)
			if player != null and player.has_tag("rim"):
				w.influence_prc += 25
		else:
			# 原版怪异逻辑：读 empires[0](美).now_leader 却扣 empires[1](苏).power（忠实保留，八荣八耻①，DBS L8647-8654）
			var usa := _empire(w, EmpireData.USA)
			var ussr := _empire(w, EmpireData.USSR)
			var pen := 50
			if usa != null and usa.current_leader == 5:
				pen = 100
			if ussr != null:
				ussr.power -= pen
				ussr.relations -= 200
			_set_war_active(w, 1, true)
			# DBS L8657-8660：completedDecisions[9] → influencePRC += 25
			if w.decisions != null and w.decisions.completed.size() > 9 and w.decisions.completed[9]:
				w.influence_prc += 25
		d.agents -= 50
		d.budget -= 30
		d.army -= 50
	return {
		"caption": "扶持极左派", "opis": "支持毛派组织",
		"conditions": conds, "dormant": false, "effect": eff,
	}


func _empire(w: WorldState, idx: int) -> EmpireData:
	if idx >= 0 and idx < w.empires.size():
		return w.empires[idx]
	return null


func _modifier_active(w: WorldState, mod_id: int) -> bool:
	if mod_id >= 0 and mod_id < w.modifiers.size() and w.modifiers[mod_id] != null:
		return w.modifiers[mod_id].is_active
	return false


func _war_active_flag(w: WorldState, idx: int) -> bool:
	return idx >= 0 and idx < w.war_active.size() and w.war_active[idx]


func _set_war_active(w: WorldState, idx: int, value: bool) -> void:
	if idx >= 0 and idx < w.war_active.size():
		w.war_active[idx] = value


# 编号 5000 革命国际（休眠）：条件 DBS L5520-5538，效果 DBS L12585-12588。
# 休眠守卫 uslovie[0]=event_done[548]，事件移植说明→get_flag 默认 false。
func _def_5000(w: WorldState, _d: WorldState, country: CountryData) -> Dictionary:
	var player := w.get_player_country()
	var conds: Array = []
	# uslovie[0]：event_done[548]（DBS L5524，事件移植说明）
	conds.append(_cond("已建立革命国际", func(): return w.get_flag("event_done_548")))
	# 列表级守卫（CS L550 等）：中国已入革命国际
	conds.append(_cond("中国已加入革命国际", func(): return player != null and player.has_tag("rim")))
	# uslovie[1]：非 gkchp / gkchp 两分支（DBS L5528/L5533）
	if not w.get_flag("is_gkchp"):
		conds.append(_cond("该国已建立革命的政权", func(): return _rim5000_regime_check(w, country)))
	else:
		conds.append(_cond("该国愿意认可我们", func():
			return ((country.sub_government == GameConstants.SubGovernment.LEFT_RADICAL or country.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST
					or country.sub_government == GameConstants.SubGovernment.MAOIST or country.sub_government == GameConstants.SubGovernment.MARXIST_LENINIST)
				and not country.has_tag("sev") and not country.has_tag("ovd")
				and country.has_tag("亲中"))))
	# 列表级守卫（CS L550 等）：目标亲中；134/136 用 okb 变体，批3 各自分支处理
	conds.append(_cond("该国持亲中立场", func(): return country.has_tag("亲中")))
	# uslovie[2]：!isRIM（DBS L5536）
	conds.append(_cond("尚未加入", func(): return not country.has_tag("rim")))
	var eff := func():
		w.influence_prc += 50
		country.set_tag("rim", true)
	return {
		"caption": "革命国际",
		"opis": "邀请该国加入革命国际主义运动，为争得新世界而战！",
		"conditions": conds, "dormant": true, "effect": eff,
	}


# 编号 5000 uslovie[1] 非 gkchp 分支：IsSocialism(true) && SubGosstroy!=16 && !=18
# && !isSEV && !isOVD && !prosov（DBS L5528）。
func _rim5000_regime_check(w: WorldState, country: CountryData) -> bool:
	if country == null:
		return false
	return w.is_socialism(country, true) \
		and country.sub_government != GameConstants.SubGovernment.SOVIET_STYLE \
		and country.sub_government != GameConstants.SubGovernment.TROTSKYIST \
		and not country.has_tag("sev") \
		and not country.has_tag("ovd") \
		and not country.has_tag("亲苏")


# 编号 5001 非洲联盟（休眠）：条件 DBS L5539-5551，效果 DBS L12590-12593。
# 休眠守卫 uslovie[0]=event_done[500]，事件移植说明→get_flag 默认 false。
func _def_5001(w: WorldState, d: WorldState, country: CountryData) -> Dictionary:
	var conds: Array = []
	# uslovie[0]：event_done[500]（DBS L5543，事件移植说明）
	conds.append(_cond("非洲联盟已建立", func(): return w.get_flag("event_done_500")))
	# 列表级守卫（CS L2679 等）：目标社会主义 且 亲中
	conds.append(_cond("该国是社会主义政权", func(): return w.is_socialism(country, true)))
	conds.append(_cond("该国持亲中立场", func(): return country.has_tag("亲中")))
	# uslovie[1]：data.army>=20（DBS L5545）
	conds.append(_cond("至少 2 军事实力", func(): return d.army >= 20))
	# uslovie[2]：!isAU（DBS L5547）
	conds.append(_cond("他们未加入非洲联盟", func(): return not country.has_tag("au")))
	# uslovie[3]：data.diplomatic_reputation>790（DBS L5549）
	conds.append(_cond("外交声誉高于 79", func(): return d.diplomatic_reputation > 790))
	var eff := func():
		w.influence_prc += 30
		country.set_tag("au", true)
	return {
		"caption": "非洲联盟",
		"opis": "邀请该国加入非洲联盟，投身于非洲革命与解放的伟大事业中",
		"conditions": conds, "dormant": true, "effect": eff,
	}


# 编号 → 定义分发（返回 {caption, opis, conditions, effect, dormant} 或 {}）。
# 优先查 外交互动目录（批1-6 全量翻译，共 213 个编号）；查不到再回退到本文件旧定义。
func _diplo_action_def(编号: int, w: WorldState, d: WorldState, country: CountryData) -> Dictionary:
	if _action_catalog != null:
		var catalog_def: Dictionary = _action_catalog.build_action(编号, {
			"w": w, "d": d, "country": country, "caption": "",
		})
		if not catalog_def.is_empty():
			return catalog_def
	match 编号:
		DIPLO_BTN_MAOIST1: return _def_1(w, d, country)
		DIPLO_BTN_TRADE9: return _def_9(w, d, country)
		DIPLO_BTN_ECON10: return _def_10(w, d, country)
		DIPLO_BTN_MIL19: return _def_19(w, d, country)
		DIPLO_BTN_TRADE24: return _def_24(w, d, country)
		DIPLO_BTN_RIM5000: return _def_5000(w, d, country)
		DIPLO_BTN_AU5001: return _def_5001(w, d, country)
	return {}


# ============================================================================
# 列表构建器 —— 按国序号逐国分发（忠实镜像 CountryScript 中文链 L495-3949）
# 结构：块J(隐藏) → match 逐国分支 → 块K(仅发展贸易)
# 元素约定：
#   int           → 动作编号，文案由动作目录默认值提供
#   Dictionary    → {"type": int, "caption": String}，文案必须用 CountryScript 分支原文
# 已移植分支：2/4/5/6/98、109/110、113/114、122/124、133/135、155/158、167
# 其余分支仍在分批补齐；缺失国明确返回 []，不用通用按钮冒充。
# ============================================================================
func _build_country_numbers(w: WorldState, country: CountryData) -> Array:
	# 完整逐国链（CountryScript.cs L495-3949 中文链 + 块J/K/H 已由独立文件镜像）。
	# 旧 _chain_numbers 保留仅供比对，不再走生产路径。
	if _country_chain != null:
		return _country_chain.build(w, country)
	return _truncate4(_chain_numbers(w, country))


## 主链逐国分发（CS 中文链 L497-3929）
func _chain_numbers(w: WorldState, country: CountryData) -> Array:
	var n := country.原版序号
	match n:
		1:
			# CS L625-644：中国自己的面板（玩家国家不再被屏蔽）。
			return _china_numbers(w, country)
		7:
			# CS L497-523：苏联面板。
			return _soviet_numbers(w, country)
		0, 27, 28, 88, 89, 90, 91:
			# CS L3710-3766：dlc[3] 中西欧组（卢森堡/奥地利/瑞典/低地）。
			return _dlc_west_numbers(w, country)
		69, 70:
			# CS L2112-2118：西藏(69)/维吾尔斯坦(70) 分离实体；点击门控在 _on_country_selected。
			return [
				_btn(76, "经 济 帮 扶"),
				_btn(77, "组 织 政 变"),
				_btn(78, "建 立 军 事 基 地"),
				_btn(79, "实 现 再 统 一"),
			]
		112:
			# CS L2691-2728：塞内加尔。
			return _x112_numbers(w, country)
		2, 4, 5, 98:
			return _sev_satellite_numbers(w, country)
		6:
			return _six_numbers(w, country)
		109, 110:
			# CS L2664：无条件 9, 10
			return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
		113:
			# CS L2729：分支头需 africaOff（非洲机制禁用）；未禁用则落入链尾块H
			if not country.禁用非洲机制:
				return _africa_block_numbers(w, country)
			return _au_rim_country_numbers(w, country, false)
		114:
			# CS L2751
			return _au_rim_country_numbers(w, country, false)
		122:
			# CS L2928：puppet<0 → 9 + [Gos∉{0,3}&&ev598&&!war53] 10,5001,5000；else → 9
			return _econ_gate_country_numbers(w, country, "event_done_598")
		124:
			# CS L3000：同上，ev581
			return _econ_gate_country_numbers(w, country, "event_done_581")
		133:
			# CS L3264：9,10 + [亲中] 5001(Gos==1)/5000
			return _x133_numbers(w, country)
		135:
			# CS L3316：9 + [!亲美] 10/19/5000
			return _x135_numbers(w, country)
		155, 158:
			# CS L3584/L3627：puppet<0 → 9+亲中尾；else → 9
			return _au_rim_country_numbers(w, country, true)
		167:
			# CS L3365：!NATO → 9 + [社会主义] 10,5000
			return _x167_numbers(w, country)
		71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83:
			# CS L2136 区间分支：82-88 全移植说明 注；仅 80 有 revint 变体 5000
			if n == 80 and _revint_sub17_ok(w, country):
				return [DIPLO_BTN_RIM5000]
			return []
		84:
			# CS L2182：整支在 dlc[3] 内，dlc 建模说明 → 无按钮 注
			return []
		85:
			# CS L2213：整支在 dlc[3] 内（cw/perevorot/ev481/ev398/ev401 均建模说明）→ 无按钮 注
			return []
		86:
			# CS L2262：整支在 dlc[3] 内 → 无按钮 注
			return []
		87:
			# CS L2282：data.hk_macau_status 建模说明 → 按 !=0 走第二分支 注；
			# data65==0 的特别军事行动(2/3)移植说明；128 移植说明
			if country.has_tag("亲美") and country.government == GameConstants.Government.AUTHORITARIAN:
				return []
			# !ev419 && !ev420（事件移植说明→默认 true）→ 128(C)+9 → 只 9
			if not w.get_flag("event_done_419") and not w.get_flag("event_done_420"):
				return [DIPLO_BTN_TRADE9]
			var n87: Array[int] = [DIPLO_BTN_TRADE9]
			# Torg && (soc || (auth && !亲美 && 1.sub∈{7,9})) → 10 + [亲中]19 + [revint]5000
			var p87 := w.get_player_country()
			if country.has_tag("对华贸易") and (w.is_socialism(country, true) \
					or (w.is_authoritarian(country) and not country.has_tag("亲美") \
					and p87 != null and (p87.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or p87.sub_government == GameConstants.SubGovernment.NEO_FASCIST))):
				n87.append(DIPLO_BTN_ECON10)
				if country.has_tag("亲中"):
					n87.append(DIPLO_BTN_MIL19)
					if _revint_ok(w, country):
						n87.append(DIPLO_BTN_RIM5000)
			return n87
		92:
			# CS L2325：data.hk_macau_status 建模说明 → 按 !=0 且 !auth 分支 注；
			# 2/3/113/1064-1066/10000 移植说明
			if w.is_authoritarian(country):
				return []
			var n92: Array[int] = [DIPLO_BTN_TRADE9]
			# soc && Torg && sub!=18 → 10,19 + [revint]5000
			if w.is_socialism(country, true) and country.has_tag("对华贸易") and country.sub_government != GameConstants.SubGovernment.TROTSKYIST:
				n92.append(DIPLO_BTN_ECON10)
				n92.append(DIPLO_BTN_MIL19)
				if _revint_ok(w, country):
					n92.append(DIPLO_BTN_RIM5000)
			return n92
		93:
			# CS L2391：整支在 dlc[3] 内（93/1002/1079/67 移植说明）→ 无按钮 注
			return []
		94:
			# CS L2419：!cw（cw 建模说明→视为真 注）→ 9；95/1075/1074/53 移植说明
			var n94: Array[int] = [DIPLO_BTN_TRADE9]
			# revint && econ && !cw → 5000
			if _revint_ok(w, country) and country.has_tag("econ"):
				n94.append(DIPLO_BTN_RIM5000)
			return n94
		95:
			# CS L2443：整支在 dlc[3] 内（96/53 移植说明）→ 无按钮 注
			return []
		139, 143, 144, 146, 148:
			# CS L2155 区间分支（145/147 有专属分支除外）：!亲中 → 1036(移植说明 注)
			if not country.has_tag("亲中"):
				return []
			var n139: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n139.append(DIPLO_BTN_RIM5000)
			# 注：139 的 70 巫术（1.sub==19，CS L2170）
			return n139
		36, 101, 102, 103, 105:
			# CS L2456 组（分支头需 modifies[51].active）
			# 组内 1023/1022/142-146/1079/67 移植说明 注
			if not _modifier_active(w, 51):
				return []
			var n36: Array[int] = []
			# 101 且 !ev569 && !auth → 9,10（CS L2462）
			if n == 101 and not w.get_flag("event_done_569") and not w.is_authoritarian(country):
				n36.append(DIPLO_BTN_TRADE9)
				n36.append(DIPLO_BTN_ECON10)
			# 组内统一 revint → 5000（CS L2507）
			if _revint_ok(w, country):
				n36.append(DIPLO_BTN_RIM5000)
			return n36
		99:
			# CS L2512：based/ingamewars[26] 建模说明 → 首分支恒真 注（proprc 分支原版即死分支）
			if country.puppet_of >= 0:
				return []
			var n99: Array[int] = []
			if _soc500_ok(w, country):
				n99.append(DIPLO_BTN_AU5001)
			if _revint_econ_ok(w, country):
				n99.append(DIPLO_BTN_RIM5000)
			return n99
		100:
			# CS L2544：based/ingamewars[25] 建模说明 → 恒真 注
			# 原版 L2546 检查 99.puppetOf（原版笔误，忠实保留）
			var c99 := w.get_country_by_legacy_index(99)
			if c99 == null or c99.puppet_of >= 0:
				return []
			var n100: Array[int] = []
			if _soc500_ok(w, country):
				n100.append(DIPLO_BTN_AU5001)
			if _revint_econ_ok(w, country):
				n100.append(DIPLO_BTN_RIM5000)
			return n100
		104:
			# CS L2576：分支头需 dlc[3]，dlc 建模说明 → 无按钮 注
			return []
		106:
			# CS L2600：亲中 → 10, [soc500]5001, 9, [revint-Torg]5000
			if not country.has_tag("亲中"):
				return []
			var n106: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n106.append(DIPLO_BTN_AU5001)
			n106.append(DIPLO_BTN_TRADE9)
			if _revint_torg_ok(w, country):
				n106.append(DIPLO_BTN_RIM5000)
			# 注：1035 非洲之角 (41.parts&&41.sub==17, CS L2614)
			return n106
		107:
			# CS L2620：亲中 → 10, [soc500]5001, [revint]5000, 9
			if not country.has_tag("亲中"):
				return []  # 1053 革命左翼移植说明 注
			var n107: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n107.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n107.append(DIPLO_BTN_RIM5000)
			n107.append(DIPLO_BTN_TRADE9)
			return n107
		108:
			# CS L2640：9 + [亲中] 10,5001,5000（1032/70 移植说明 注）
			var n108: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n108, w, country)
			return n108
		119:
			# CS L2669：分支头需 africaOff；未禁用则落入链尾块H
			if not country.禁用非洲机制:
				return _africa_block_numbers(w, country)
			if country.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
				return []
			# 1032 协助左派移植说明 注
			var n119: Array[int] = []
			_append_au_rim_tail(n119, w, country)
			return n119
		123:
			# CS L2954：ev638/1047-1049/142-144/1080/70 移植说明 注 → 仅 9
			return [DIPLO_BTN_TRADE9]
		125:
			# CS L3026：puppet<0 → auth: 9(1032移植说明) / !auth: 9,10 + 亲中尾
			if country.puppet_of >= 0:
				return []
			if w.is_authoritarian(country):
				return [DIPLO_BTN_TRADE9]  # 1032 施压移植说明 注
			var n125: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			_append_rim_tail(n125, w, country)
			return n125
		126:
			# CS L3053：分支头需 ev623（移植说明→恒 false）→ 无按钮 注
			return []
		127:
			# CS L3084：puppet<0 → 9 + [Gos∉{0,3}] 10 + 亲中尾（70 移植说明 注）
			if country.puppet_of >= 0:
				return []
			var n127: Array[int] = [DIPLO_BTN_TRADE9]
			if country.government != GameConstants.Government.AUTHORITARIAN and country.government != GameConstants.Government.LIBERAL:
				n127.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n127, w, country)
			return n127
		129:
			# CS L3110：亲中 → 9,10,5001,5000；!亲中&&puppet<0&&sub!=7 → 9(1043-45移植说明)
			if country.has_tag("亲中"):
				var n129: Array[int] = [DIPLO_BTN_TRADE9]
				_append_au_rim_tail(n129, w, country)
				return n129
			if country.puppet_of < 0 and country.sub_government != GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
				return [DIPLO_BTN_TRADE9]
			return []  # sub==7 的 62-66 移植说明 注
		130:
			# CS L3150：!cw(建模说明→真) → 1038 移植说明 注；cw 分支的 9,10,5001,5000 待 cw 建模
			return []
		131:
			# CS L3173：57 抗议运动(cw 建模说明)移植说明 注
			if country.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
				return []
			var n131: Array[int] = []
			if country.sub_government != GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
				n131.append(DIPLO_BTN_TRADE9)
			# cw 建模说明(默认 false) → auth&&sub!=19 分支无输出且跳过 Gos!=3 else-if
			if not (w.is_authoritarian(country) and country.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST) and country.government != GameConstants.Government.LIBERAL:
				n131.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n131, w, country)
			# 注：70 博莱斯 (sub==19, CS L3207)
			return n131
		132:
			# CS L3213：9 + [puppet<0] 10 + 亲中尾（1037 移植说明 注）
			var n132: Array[int] = [DIPLO_BTN_TRADE9]
			if country.puppet_of < 0:
				n132.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n132, w, country)
			return n132
		153:
			# CS L3240：9 + [Gos!=2] 10 + 亲中尾（1039/1040 移植说明 注）
			var n153: Array[int] = [DIPLO_BTN_TRADE9]
			if country.government != GameConstants.Government.REFORMIST:
				n153.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n153, w, country)
			return n153
		115:
			# CS L2773：sub==9 → 9+[亲中]10；sub!=9 → 9+亲中尾（1032/70 移植说明 注）
			if country.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
				if not country.has_tag("亲中"):
					return [DIPLO_BTN_TRADE9]
				return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			var n115: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n115, w, country)
			return n115
		116:
			# CS L2819：9 + [!亲美&&puppet<0&&ev619] 10,5001,5000
			#（10 不受 proprc 门控；1024/1044/1032 移植说明 注）
			var n116: Array[int] = [DIPLO_BTN_TRADE9]
			if not country.has_tag("亲美") and country.puppet_of < 0 and w.get_flag("event_done_619"):
				n116.append(DIPLO_BTN_ECON10)
				_append_rim_tail(n116, w, country)
			return n116
		117:
			# CS L2847：sub==9&&亲中 → 10,19；sub!=9 → 9+亲中尾（1041/1042/70 移植说明 注）
			if country.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
				if country.has_tag("亲中"):
					return [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
				return []
			var n117: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n117, w, country)
			return n117
		118:
			# CS L2893：!ev659||ev661 → 9,10+亲中尾；否则 1057 移植说明 注
			if w.get_flag("event_done_659") and not w.get_flag("event_done_661"):
				return []
			if not country.has_tag("亲中") or w.is_authoritarian(country):
				return []
			var n118: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			_append_rim_tail(n118, w, country)
			return n118
		134:
			# CS L3280：依赖 135/50 的政体与立场；1024/1025/1079 移植说明 注
			var c135 := w.get_country_by_legacy_index(135)
			var c50 := w.get_country_by_legacy_index(50)
			var n134: Array[int] = []
			if c135 != null and (c135.has_tag("亲中") or c135.has_tag("亲苏")):
				n134.append(DIPLO_BTN_TRADE9)
				if country.puppet_of < 0:
					n134.append(DIPLO_BTN_ECON10)
					if c135.has_tag("亲中"):
						n134.append(DIPLO_BTN_MIL19)
						if _revint_okb_ok(w, country):
							n134.append(DIPLO_BTN_RIM5000)
			if c50 != null and w.is_socialism(c50, true) and (c135 == null or not c135.has_tag("亲美")):
				if country.puppet_of < 0:
					n134.append(DIPLO_BTN_ECON10)
					if country.has_tag("亲中"):
						n134.append(DIPLO_BTN_MIL19)
						if _revint_okb_ok(w, country):
							n134.append(DIPLO_BTN_RIM5000)
			return n134
		136:
			# CS L3335：9 + [!51.isNATO&&亲中] 10,19,[revint-okb]5000（1024 移植说明 注）
			var c51 := w.get_country_by_legacy_index(51)
			var n136: Array[int] = [DIPLO_BTN_TRADE9]
			if c51 != null and not c51.has_tag("nato") and country.has_tag("亲中"):
				n136.append(DIPLO_BTN_ECON10)
				n136.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country):
					n136.append(DIPLO_BTN_RIM5000)
			return n136
		137:
			# CS L3352：sub!=7 → 9,10（1076/1077 移植说明 注）
			if country.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
				return []
			return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
		138:
			# CS L3380：!7.isNATO && !gkchp(建模说明→真) → 亲中: 9,10,[revint]5000 / 否则 9
			# 49/1033/1034 移植说明 注；cw&&(亲苏||亲美) 全隐藏 cw 建模说明
			var c7 := w.get_country_by_legacy_index(7)
			if c7 != null and c7.has_tag("nato"):
				return []
			if country.has_tag("亲中"):
				var n138: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
				if _revint_ok(w, country):
					n138.append(DIPLO_BTN_RIM5000)
				return n138
			return [DIPLO_BTN_TRADE9]
		140:
			# CS L3417：亲中 → 9,10 + [revint]5000（1026/1027 移植说明 注）
			if not country.has_tag("亲中"):
				return []
			var n140: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n140.append(DIPLO_BTN_RIM5000)
			return n140
		141:
			# CS L3434：parts 建模说明(→else 分支) → 9,10 + [revint]5000（1062 移植说明 注）
			var n141: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n141.append(DIPLO_BTN_RIM5000)
			return n141
		145:
			# CS L3450：cw 建模说明 → !cw 分支(1028-1031) 移植说明 注；cw 分支 10/5000 待 cw 建模
			return []
		147:
			# CS L3468：level_of_unstab 建模说明(视为0) → !soc&&Gos!=2: 9 / 其余: 9+亲中尾
			# 1043/1044 移植说明 注
			if not w.is_socialism(country, true) and country.government != GameConstants.Government.REFORMIST:
				return [DIPLO_BTN_TRADE9]
			var n147: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n147.append(DIPLO_BTN_ECON10)
				if _revint_ok(w, country):
					n147.append(DIPLO_BTN_RIM5000)
			return n147
		149:
			# CS L3499：同 147；parts/ingamewars[66] 建模说明 → 1045 移植说明 注
			if not w.is_socialism(country, true) and country.government != GameConstants.Government.REFORMIST:
				return [DIPLO_BTN_TRADE9]
			var n149: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n149.append(DIPLO_BTN_RIM5000)
			return n149
		152:
			# CS L3536：!auth → 9；亲中&&!soc → 1032(移植说明 注) → 只 9；亲中 → 10,[revint]5000
			# 49 邀请乐队移植说明 注
			if w.is_authoritarian(country):
				return []
			if country.has_tag("亲中") and not w.is_socialism(country, true):
				return [DIPLO_BTN_TRADE9]
			var n152: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n152.append(DIPLO_BTN_ECON10)
				if _revint_ok(w, country):
					n152.append(DIPLO_BTN_RIM5000)
			return n152
		154:
			# CS L3556：ev630 建模说明(默认false) → 1032/1046 分支移植说明 注
			if w.get_flag("event_done_630"):
				if country.puppet_of < 0:
					var n154: Array[int] = [DIPLO_BTN_TRADE9]
					if country.has_tag("亲中"):
						n154.append(DIPLO_BTN_ECON10)
						n154.append(DIPLO_BTN_MIL19)
						if _revint_okb_ok(w, country):
							n154.append(DIPLO_BTN_RIM5000)
					return n154  # 49 度假移植说明 注
			return []
		157:
			# CS L3610：puppet<0 → 9,19 + [revint]5000（53 移植说明 注）；else → 9
			if country.puppet_of >= 0:
				return [DIPLO_BTN_TRADE9]
			var n157: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n157.append(DIPLO_BTN_RIM5000)
			return n157
		159:
			# CS L3653：puppet<0 → 9 + [亲中] 10,19,[revint-okb]5000（1045 移植说明 注）
			if country.puppet_of >= 0:
				return []  # 1043/1044 移植说明 注
			var n159: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n159.append(DIPLO_BTN_ECON10)
				n159.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country):
					n159.append(DIPLO_BTN_RIM5000)
			return n159
		160:
			# CS L3675：亲中 → 10,19,[revint]5000（1050/1051 移植说明 注）
			if not country.has_tag("亲中"):
				return []
			var n160: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n160.append(DIPLO_BTN_RIM5000)
			return n160
		161:
			# CS L3692：同 160（1050/1051 移植说明 注）
			if not country.has_tag("亲中"):
				return []
			var n161: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n161.append(DIPLO_BTN_RIM5000)
			return n161
		29:
			# CS L3767 块B：data169/parts/FXSEU/NAZI 建模说明 → 简化；1068 移植说明 注
			if country.has_tag("soc_eu"):
				return []
			return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
		166:
			# CS L3809 块C：1067 移植说明 注
			return []
		12:
			# CS L805：9,19 + [revint]5000（68 移植说明 注）
			var n12: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n12.append(DIPLO_BTN_RIM5000)
			return n12
		13:
			# CS L815：soc → 9,10,19 + [revint-okb&&亲中]5000；else 22/23 移植说明 注
			if not w.is_socialism(country, true):
				return []
			var n13: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n13.append(DIPLO_BTN_RIM5000)
			return n13
		14:
			# CS L841：133/1078/56/25/70/53/119/120/ev36 移植说明 注
			# [sub==20&&puppet<0] 24；[亲中] 24,19 + [revint-okb&&puppet<0]5000；else 24,19
			var n14: Array[int] = []
			if country.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN and country.puppet_of < 0:
				n14.append(DIPLO_BTN_TRADE24)
			if country.has_tag("亲中"):
				n14.append(DIPLO_BTN_TRADE24)
				n14.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country) and country.puppet_of < 0:
					n14.append(DIPLO_BTN_RIM5000)
			else:
				n14.append(DIPLO_BTN_TRADE24)
				n14.append(DIPLO_BTN_MIL19)
			return n14
		15:
			# CS L894：!7.NATO&&!2.okb&&!4.okb&&!5.okb&&!98.okb → 72/73 移植说明 注
			# else → 10,19 + [revint-!亲苏]5000
			var c2 := w.get_country_by_legacy_index(2)
			var c4b := w.get_country_by_legacy_index(4)
			var c5 := w.get_country_by_legacy_index(5)
			var c98 := w.get_country_by_legacy_index(98)
			var n15: Array[int] = []
			var c7b := w.get_country_by_legacy_index(7)
			if not (c7b != null and c7b.has_tag("nato")) and not (c2 != null and c2.has_tag("okb")) \
					and not (c4b != null and c4b.has_tag("okb")) and not (c5 != null and c5.has_tag("okb")) \
					and not (c98 != null and c98.has_tag("okb")):
				return n15  # 72/73 不结盟运动移植说明 注
			n15.append(DIPLO_BTN_ECON10)
			n15.append(DIPLO_BTN_MIL19)
			if _revint_noprosov_ok(w, country):
				n15.append(DIPLO_BTN_RIM5000)
			return n15
		16:
			# CS L926：dlc 建模说明 → 非 dlc 分支 24（135/116 移植说明 注）；
			# [proprc&&parts] 分支 parts 建模说明 → 不触发 注
			return [DIPLO_BTN_TRADE24]
		17:
			# CS L950：parts 建模说明(→真) → [!1.isASEAN] 1；116/137/138(dlc) 移植说明 注
			var p17 := w.get_player_country()
			if p17 != null and not p17.has_tag("asean"):
				return [DIPLO_BTN_MAOIST1]
			return []
		18:
			# CS L986：整支在 dlc[3] 内 → 无按钮 注
			return []
		19:
			# CS L1002：ev72/resultOfEvents/completedDecisions[14] 建模说明 → 首分支移植说明 注
			# [亲中] → [!SEV&&!econ] 10 / else 19 + [revint sub17+econ+okb]5000
			if not country.has_tag("亲中"):
				return []
			var p19 := w.get_player_country()
			var n19: Array[int] = []
			if not country.has_tag("sev") and not country.has_tag("econ"):
				n19.append(DIPLO_BTN_ECON10)
			else:
				n19.append(DIPLO_BTN_MIL19)
			if w.get_flag("event_done_548") and p19 != null and p19.has_tag("rim") \
					and country.sub_government == GameConstants.SubGovernment.MAOIST and not country.has_tag("sev") \
					and not country.has_tag("ovd") and country.has_tag("econ") \
					and country.has_tag("okb") and country.has_tag("亲中"):
				n19.append(DIPLO_BTN_RIM5000)
			return n19
		20:
			# CS L1037：parts 建模说明(→真) → 19 + [revint]5000（31/32 移植说明 注）
			var n20: Array[int] = [DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n20.append(DIPLO_BTN_RIM5000)
			return n20
		21:
			# CS L1050：ev483 建模说明 → else 分支；33/34/1009/1010/107 移植说明 注
			var p21 := w.get_player_country()
			var n21: Array[int] = [DIPLO_BTN_TRADE24]
			# sub∈{17,22,19} || ((1.sub∈{7,9}) && sub==9) → 10,19
			if country.sub_government == GameConstants.SubGovernment.MAOIST or country.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST or country.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST \
					or (p21 != null and (p21.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or p21.sub_government == GameConstants.SubGovernment.NEO_FASCIST) and country.sub_government == GameConstants.SubGovernment.NEO_FASCIST):
				n21.append(DIPLO_BTN_ECON10)
				n21.append(DIPLO_BTN_MIL19)
				# revint 变体 (L1102): IsSocialism(true) && sub∉{1,18} && !SEV && !OVD && 亲中
				if _revint_core_ok(w, country) and country.sub_government != GameConstants.SubGovernment.STATE_SOCIALIST \
						and country.sub_government != GameConstants.SubGovernment.TROTSKYIST and country.has_tag("亲中"):
					n21.append(DIPLO_BTN_RIM5000)
			return n21
		22:
			# CS L1108：1.isSEV&&puppet==11 → 24,10,19；else !ev454(建模说明→真) → [puppet<0] 19 + [revint]5000
			var p22 := w.get_player_country()
			if p22 != null and p22.has_tag("sev") and country.puppet_of == 11:
				return [DIPLO_BTN_TRADE24, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			# 35/36/126 移植说明 注
			if country.puppet_of < 0:
				var n22: Array[int] = [DIPLO_BTN_MIL19]
				if _revint_ok(w, country):
					n22.append(DIPLO_BTN_RIM5000)
				return n22
			return []
		23:
			# CS L1137：分支头需 !prosov；24,10,19 + [revint]5000
			if country.has_tag("亲苏"):
				return []
			var n23: Array[int] = [DIPLO_BTN_TRADE24, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_ok(w, country):
				n23.append(DIPLO_BTN_RIM5000)
			return n23
		24, 25:
			# CS L1147：102/121 移植说明 注；[亲中] 19 + [revint-okb&&亲中]5000（res437 视为 0）
			if not country.has_tag("亲中"):
				return []
			var n24: Array[int] = [DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n24.append(DIPLO_BTN_RIM5000)
			return n24
		26:
			# CS L1175：based 建模说明 → 1/123/148/149/53 分支不触发 注；
			# 主分支 [revint-okb&&亲中]5000（50 移植说明 注）
			var n26: Array[int] = []
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n26.append(DIPLO_BTN_RIM5000)
			return n26
		30:
			# CS L1217：38/39 移植说明 注；[24] + soc → 19 + [revint-okb&&亲中]5000
			var n30: Array[int] = [DIPLO_BTN_TRADE24]
			if w.is_socialism(country, true):
				n30.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country) and country.has_tag("亲中"):
					n30.append(DIPLO_BTN_RIM5000)
			return n30
		31:
			# CS L1234：40/41 移植说明 注；[revint]5000
			var n31: Array[int] = []
			if _revint_ok(w, country):
				n31.append(DIPLO_BTN_RIM5000)
			return n31
		32, 42:
			# CS L1243：puppet<0 → 10 + [32]19 + [revint]5000
			if country.puppet_of >= 0:
				return []
			var n32: Array[int] = [DIPLO_BTN_ECON10]
			if n == 32:
				n32.append(DIPLO_BTN_MIL19)
			if _revint_ok(w, country):
				n32.append(DIPLO_BTN_RIM5000)
			return n32
		33:
			# CS L1267：42/1061 移植说明 注；亲中&&!1.isASEAN → 10,19 + [sub17 变体]5000
			var p33 := w.get_player_country()
			if not country.has_tag("亲中") or (p33 != null and p33.has_tag("asean")):
				return []
			var n33: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_sub17_ok(w, country):
				n33.append(DIPLO_BTN_RIM5000)
			return n33
		34:
			# CS L1291：43/44 移植说明 注；9,19 + [revint-okb&&亲中]5000
			var n34: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n34.append(DIPLO_BTN_RIM5000)
			return n34
		35:
			# CS L1302：ev564 建模说明(→!ev564) → 1016 移植说明 注
			return []
		37:
			# CS L1327：45/46 移植说明 注；24,10,19 + [revint-okb&&亲中]5000
			var n37: Array[int] = [DIPLO_BTN_TRADE24, DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n37.append(DIPLO_BTN_RIM5000)
			return n37
		38:
			# CS L1345：ev461 建模说明 → 首分支 48/1005 移植说明 注；
			# ev461&&亲中 → 10,19（119/120 移植说明 注）
			if w.get_flag("event_done_461") and country.has_tag("亲中"):
				return [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
			return []
		39:
			# CS L1366：49/148/149/53 全移植说明 注
			return []
		40:
			# CS L1395：sub==20 → 1019/1020 移植说明 注；sub==10 → 9,10（ev563 建模说明）
			if country.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
				return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			return []
		41:
			# CS L1435：ev403 建模说明 → proprc 分支；101/110/111/70 移植说明 注
			# [Gos==1||sub==0] → 10 + 5001(soc500) + [revint-无soc]5000；else → 10
			if not country.has_tag("亲中"):
				return []
			if country.government == GameConstants.Government.SOCIALIST or country.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
				var n41: Array[int] = [DIPLO_BTN_ECON10]
				if _soc500_ok(w, country):
					n41.append(DIPLO_BTN_AU5001)
				if _revint_nosoc_ok(w, country):
					n41.append(DIPLO_BTN_RIM5000)
				return n41
			return [DIPLO_BTN_ECON10]
		43, 96, 97:
			# CS L1476：puppet!=1 → 97/98/99 移植说明 注；[revint]5000
			if country.puppet_of == GameConstants.LegacySlot.CHINA:
				return []
			var n43: Array[int] = []
			if _revint_ok(w, country):
				n43.append(DIPLO_BTN_RIM5000)
			return n43
		44:
			# CS L1489：1014/51/52/1015/119 移植说明 注；亲中&&!soc_eu → 19 + [revint-okb&&亲中]5000
			if not country.has_tag("亲中") or country.has_tag("soc_eu"):
				return []
			var n44: Array[int] = [DIPLO_BTN_MIL19]
			if _revint_okb_ok(w, country) and country.has_tag("亲中"):
				n44.append(DIPLO_BTN_RIM5000)
			return n44
		45:
			# CS L1531：!94.cw(建模说明→真) 且 (war19||!auth 视为真) → 9；54 移植说明 注
			# soc → 10 + [亲中] 19 + [revint]5000
			var n45: Array[int] = [DIPLO_BTN_TRADE9]
			if w.is_socialism(country, true):
				n45.append(DIPLO_BTN_ECON10)
				if country.has_tag("亲中"):
					n45.append(DIPLO_BTN_MIL19)
					if _revint_ok(w, country):
						n45.append(DIPLO_BTN_RIM5000)
			return n45
		46:
			# CS L1554：parts/ev31 → 55/1013/122 全移植说明 注
			return []
		47:
			# CS L1583：!1.isASEAN → 56(移植说明 注)+[revint]5000；9,19（44 移植说明 注）
			var p47 := w.get_player_country()
			var n47: Array[int] = []
			if p47 == null or not p47.has_tag("asean"):
				if _revint_ok(w, country):
					n47.append(DIPLO_BTN_RIM5000)
			n47.append(DIPLO_BTN_TRADE9)
			n47.append(DIPLO_BTN_MIL19)
			return n47
		48:
			# CS L1597：9 + [Gos!=3] 10 + [revint]5000
			var n48: Array[int] = [DIPLO_BTN_TRADE9]
			if country.government != GameConstants.Government.LIBERAL:
				n48.append(DIPLO_BTN_ECON10)
				if _revint_ok(w, country):
					n48.append(DIPLO_BTN_RIM5000)
			return n48
		52:
			# CS L1609：ev497||sub==0 → 24 + [res497!=2(视为真)] 10 + [亲中] 5001,5000
			if not w.get_flag("event_done_497") and country.sub_government != GameConstants.SubGovernment.LEFT_RADICAL:
				return []
			var n52: Array[int] = [DIPLO_BTN_TRADE24]
			n52.append(DIPLO_BTN_ECON10)
			if country.has_tag("亲中"):
				_append_rim_tail(n52, w, country)
			return n52
		49:
			# CS L1631：24 + soc → 10 + [亲中] 19 + [revint]5000
			var n49: Array[int] = [DIPLO_BTN_TRADE24]
			if w.is_socialism(country, true):
				n49.append(DIPLO_BTN_ECON10)
				if country.has_tag("亲中"):
					n49.append(DIPLO_BTN_MIL19)
					if _revint_ok(w, country):
						n49.append(DIPLO_BTN_RIM5000)
			return n49
		50:
			# CS L1647：sub!=9 → 58(移植说明 注) + [亲中] 10 + [soc] 19 + [revint-okb&&亲中]5000 + 24
			if country.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
				return []
			var n50: Array[int] = [DIPLO_BTN_TRADE24]
			if country.has_tag("亲中"):
				n50.append(DIPLO_BTN_ECON10)
				if w.is_socialism(country, true):
					n50.append(DIPLO_BTN_MIL19)
					if _revint_okb_ok(w, country) and country.has_tag("亲中"):
						n50.append(DIPLO_BTN_RIM5000)
			return n50
		128:
			# CS L1667：soc → 10,19 + [revint]5000；24
			var n128: Array[int] = [DIPLO_BTN_TRADE24]
			if w.is_socialism(country, true):
				n128.append(DIPLO_BTN_ECON10)
				n128.append(DIPLO_BTN_MIL19)
				if _revint_ok(w, country):
					n128.append(DIPLO_BTN_RIM5000)
			return n128
		51:
			# CS L1695：!7.NATO && !modifies[49] → 60/34/61/75 全移植说明 注
			return []
		53:
			# CS L1719：ev499 建模说明(→false) → 1058-1060 移植说明 注
			return []
		54:
			# CS L1778：9 + [auth&&!ev560(建模说明→真)] → 1006/1007 移植说明 注
			# else → 10 + [sub!=11&&Gos!=3] 19 + [revint-okb&&亲中]5000
			if w.is_authoritarian(country):
				return [DIPLO_BTN_TRADE9]
			var n54: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if country.sub_government != GameConstants.SubGovernment.TITOIST and country.government != GameConstants.Government.LIBERAL:
				n54.append(DIPLO_BTN_MIL19)
				if _revint_okb_ok(w, country) and country.has_tag("亲中"):
					n54.append(DIPLO_BTN_RIM5000)
			return n54
		55:
			# CS L1803：亲中 → 10,19 + [revint-okb]5000；else Gos==2 → 10（67 移植说明 注）
			if country.has_tag("亲中"):
				var n55: Array[int] = [DIPLO_BTN_ECON10, DIPLO_BTN_MIL19]
				if _revint_okb_ok(w, country):
					n55.append(DIPLO_BTN_RIM5000)
				return n55
			if country.government == GameConstants.Government.REFORMIST:
				return [DIPLO_BTN_ECON10]
			return []
		56:
			# CS L1828：亲中 → 10 + 5001(soc500) + [revint]5000；else 1024/1032 移植说明 注
			if not country.has_tag("亲中"):
				return []
			var n56: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n56.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n56.append(DIPLO_BTN_RIM5000)
			return n56
		57:
			# CS L1852：亲中 → 10 + 5001(soc500) + [revint-puppet<0]5000；else 1056 移植说明 注
			if not country.has_tag("亲中"):
				return []
			var n57: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n57.append(DIPLO_BTN_AU5001)
			if _revint_puppet_ok(w, country):
				n57.append(DIPLO_BTN_RIM5000)
			return n57
		58:
			# CS L1871：ev458 建模说明(→false) → 1003 移植说明 注；ev458&&亲中 → 10+5001+5000
			if not w.get_flag("event_done_458") or not country.has_tag("亲中"):
				return []
			var n58: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n58.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n58.append(DIPLO_BTN_RIM5000)
			return n58
		59:
			# CS L1897：soc → 9,10 + [亲中] 5001,5000；sub==10||Gos==2 → 9,10；else → 9
			#（1032/1043-1045 移植说明 注）
			if w.is_socialism(country, true):
				var n59: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
				if country.has_tag("亲中"):
					_append_rim_tail(n59, w, country)
				return n59
			if country.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST or country.government == GameConstants.Government.REFORMIST:
				return [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			return [DIPLO_BTN_TRADE9]
		60:
			# CS L1939：9 + 亲中 → 10,5001,5000（1054/1045 移植说明 注）
			var n60: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				_append_au_rim_tail(n60, w, country)
			return n60
		61:
			# CS L1967：亲中&&puppet<0 → 10 + 5001(soc500) + [revint]5000
			if not country.has_tag("亲中") or country.puppet_of >= 0:
				return []
			var n61: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n61.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n61.append(DIPLO_BTN_RIM5000)
			return n61
		62:
			# CS L1982：亲中 → 10 + 5001(soc500) + [revint]5000
			if not country.has_tag("亲中"):
				return []
			var n62: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n62.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n62.append(DIPLO_BTN_RIM5000)
			return n62
		63:
			# CS L1997：分支头需 africaOff；亲中 → 10 + 5001(soc500) + [revint]5000
			if not country.禁用非洲机制:
				return _africa_block_numbers(w, country)
			if not country.has_tag("亲中"):
				return []
			var n63: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n63.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n63.append(DIPLO_BTN_RIM5000)
			return n63
		64:
			# CS L2012：亲中 → 10 + 5001(soc500) + [revint]5000；else 1032/data16 移植说明 注
			if not country.has_tag("亲中"):
				return []
			var n64: Array[int] = [DIPLO_BTN_ECON10]
			if _soc500_ok(w, country):
				n64.append(DIPLO_BTN_AU5001)
			if _revint_ok(w, country):
				n64.append(DIPLO_BTN_RIM5000)
			return n64
		65:
			# CS L2035：puppet<0 → 9,10 + [亲中] 5001,5000（70 移植说明 注）
			if country.puppet_of >= 0:
				return []
			var n65: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if country.has_tag("亲中"):
				_append_rim_tail(n65, w, country)
			return n65
		66:
			# CS L2058：ev617 建模说明(→!ev617) → 9 + [sub==7] 1032(移植说明 注)；
			# [亲中||res618==1] → 10 + 5001(soc500) + [revint]5000
			var n66: Array[int] = [DIPLO_BTN_TRADE9]
			if country.has_tag("亲中"):
				n66.append(DIPLO_BTN_ECON10)
				if _soc500_ok(w, country):
					n66.append(DIPLO_BTN_AU5001)
				if _revint_ok(w, country):
					n66.append(DIPLO_BTN_RIM5000)
			return n66
		68:
			# CS L2089：!亲美 → 9,10 + [亲中] 5001(soc500) + [revint-无proprc]5000；亲美 → 9
			if country.has_tag("亲美"):
				return [DIPLO_BTN_TRADE9]
			var n68: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if country.has_tag("亲中"):
				if _soc500_ok(w, country):
					n68.append(DIPLO_BTN_AU5001)
				if _revint_core_ok(w, country):
					n68.append(DIPLO_BTN_RIM5000)
			return n68
		150, 151:
			# CS L1748/L1763：ev499 建模说明(→false) → 10/5001/5000 分支不触发 注
			return []
		3:
			# CS L645：100/123/103-106 移植说明 注；[!1.isASEAN] 1 + 24 + [revint]5000
			var p3 := w.get_player_country()
			var n3: Array[int] = []
			if p3 != null and not p3.has_tag("asean"):
				n3.append(DIPLO_BTN_MAOIST1)
			n3.append(DIPLO_BTN_TRADE24)
			if _revint_ok(w, country):
				n3.append(DIPLO_BTN_RIM5000)
			return n3
		8:
			# CS L672：prcpower 建模说明(0≠1000) → 首分支；8 支持友方派系(ev58)移植说明 注
			return [DIPLO_BTN_TRADE9]
		9:
			# CS L706：11 联络反对派移植说明 注；war22/data.soviet_reorganization_war_state/res62 建模说明 → 视为通过
			var n9: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
			if _revint_ok(w, country):
				n9.append(DIPLO_BTN_RIM5000)
			return n9
		10:
			# CS L723：res495 建模说明(0≠1) → 首分支；13/14/15/16 移植说明 注
			# [econ||SEV] → 19；L750 变体(无 prosov&&puppet<0) → 5000
			var n10: Array[int] = []
			if country.has_tag("econ") or country.has_tag("sev"):
				n10.append(DIPLO_BTN_MIL19)
			if _revint_core_ok(w, country) and not country.has_tag("亲苏") and country.puppet_of < 0:
				n10.append(DIPLO_BTN_RIM5000)
			return n10
		11:
			# CS L766：ev535 建模说明 → 中间分支；17/18/1000/80 移植说明 注
			# [econ&&puppet<0] → 19（war<=0 分支的 19 依赖 ev43 建模说明）
			if country.has_tag("econ") and country.puppet_of < 0:
				return [DIPLO_BTN_MIL19]
			return []
		_:
			# 移植说明分支 → 链尾块H（非洲区间）或 无按钮
			var block := _africa_block_numbers(w, country)
			if not block.is_empty():
				return block
			return []


## 经互会卫星 2/4/5/98（CS L524-556/L557-588）
func _sev_satellite_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var player := w.get_player_country()
	var n := country.原版序号
	var c4 := w.get_country_by_legacy_index(4)
	# L528：NATO 分支 → 103-106（移植说明 注）；ingamewars[17] 移植说明 → !war17 视为真
	if (player.has_tag("nato") and country.has_tag("ovd")) or (n != 4 and c4 != null and c4.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST):
		return []
	# L535：!中国NATO && !中国SEV && 目标SEV → [1|123] + 24
	if not player.has_tag("sev") and country.has_tag("sev"):
		var nums: Array[int] = []
		if not player.has_tag("asean"):
			nums.append(DIPLO_BTN_MAOIST1)
		# else：123（CS L543，移植说明 注）
		nums.append(DIPLO_BTN_TRADE24)
		return nums
	# L547 else：24 + [revint]5000
	var nums2: Array[int] = [DIPLO_BTN_TRADE24]
	if _revint_ok(w, country):
		nums2.append(DIPLO_BTN_RIM5000)
	return nums2


## 6（CS L590-623）：同卫星分支；else: 24 + [sub==17] 10,19,[revint6]5000
func _six_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var player := w.get_player_country()
	var c4 := w.get_country_by_legacy_index(4)
	# L592：NATO 分支（注意 6 无 n!=4 豁免）→ 103-106（移植说明 注）
	if (player.has_tag("nato") and country.has_tag("ovd")) or (c4 != null and c4.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST):
		return []
	# L599：!中国SEV && 目标SEV → [1|123] + 24
	if not player.has_tag("sev") and country.has_tag("sev"):
		var nums: Array[int] = []
		if not player.has_tag("asean"):
			nums.append(DIPLO_BTN_MAOIST1)
		nums.append(DIPLO_BTN_TRADE24)
		return nums
	# L611 else：24 + [sub==17] 10,19,[revint6]5000
	var nums2: Array[int] = [DIPLO_BTN_TRADE24]
	if country.sub_government == GameConstants.SubGovernment.MAOIST:
		nums2.append(DIPLO_BTN_ECON10)
		nums2.append(DIPLO_BTN_MIL19)
		# L618：sub==17 变体（无 soc/sub 检查）
		if _revint_sub17_ok(w, country):
			nums2.append(DIPLO_BTN_RIM5000)
	return nums2


## 1 中国自身面板（CS L625-644）。
## other_text_en 索引：183=联系总参谋部、184=联系总情报局、234=承认台湾。
func _china_numbers(w: WorldState, _country: CountryData) -> Array:
	var nums: Array = []
	var player := w.get_player_country()
	if player == null:
		return nums
	# dlc[3]（项目 2026-08-16 裁决默认开）
	if w.dlc.size() > 3 and w.dlc[3]:
		nums.append(_btn(114, "联 系 总 参 谋 部"))
		nums.append(_btn(115, "联 系 总 情 报 局"))
	if player.has_tag("sev") or player.has_tag("asean"):
		nums.append(_btn(124, "承 认 台 湾"))
	if w.event_done_num(464) and w.result_of_event_num(464) == 2:
		nums.append(_btn(1008, " 东 方 申 根 协 定"))
	if w.event_done_num(464) and w.result_of_event_num(464) != 2:
		var france := w.get_country_by_legacy_index(21)
		var gdr := w.get_country_by_legacy_index(16)
		var frg := w.get_country_by_legacy_index(17)
		if france != null and france.has_tag("okb") \
				and ((gdr != null and gdr.has_tag("okb")) or (frg != null and frg.has_tag("okb"))):
			nums.append(_btn(1063, " 合 作"))
	return nums


## 0/27/28/88-91 dlc[3] 中西欧组（CS L3710-3766）。
func _dlc_west_numbers(w: WorldState, country: CountryData) -> Array:
	if not (w.dlc.size() > 3 and w.dlc[3]):
		return []
	var nums: Array = []
	var n := country.原版序号
	if (n > 87 and n < 92) or n == 0:
		nums.append(_btn(9, "发 展 贸 易"))
	else:
		nums.append(_btn(50, "发 展 贸 易"))
	var spain := w.get_country_by_legacy_index(85)
	var france := w.get_country_by_legacy_index(21)
	var ussr := w.get_country_by_legacy_index(7)
	var hungary := w.get_country_by_legacy_index(4)
	var player := w.get_player_country()
	var no_alt_europe: bool = (spain == null or not spain.has_tag("soc_eu")) \
		and (france == null or (not france.has_tag("fxseu") and not france.has_tag("nazimao")))
	if no_alt_europe:
		if w.event_done_num(686) and w.result_of_event_num(686) == 0 \
				and not country.有驻军基地 \
				and (not country.has_tag("econ") or not country.has_tag("okb")):
			nums.clear()
			nums.append(_btn(1069, "扶 持 亲 中 势 力"))
			nums.append(_btn(1070, "遏 制 苏 联 集 团"))
			nums.append(_btn(1071, "形 成 经 济 联 盟"))
			nums.append(_btn(1072, "签 署 安 保 协 定"))
		elif w.event_done_num(686) and country.has_tag("econ") \
				and country.has_tag("okb") and not country.有驻军基地:
			if _revint_ok(w, country):
				nums.append(_btn(5000, "革 命 国 际"))
		elif w.event_done_num(686) and country.有驻军基地 \
				and ((ussr != null and ussr.has_tag("sev")) or w.get_flag("is_gkchp")
				or (hungary != null and hungary.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST)):
			if player == null or not player.has_tag("asean"):
				nums.append(_btn(1, "扶 持 极 左 派"))
			else:
				nums.append(_btn(123, "战 争"))
		if country.有驻军基地 and (ussr == null or not ussr.has_tag("sev")) \
				and not w.get_flag("is_gkchp") \
				and (hungary == null or hungary.sub_government != GameConstants.SubGovernment.FEUDAL_SOCIALIST):
			nums.append(_btn(53, "经 济 合 作"))
			nums.append(_btn(148, "欧 洲 左 派"))
			nums.append(_btn(149, "欧 洲 右 派"))
	elif france != null and france.has_tag("fxseu"):
		nums.append(_btn(148, " 支 持 主 权 欧 洲"))
	elif france != null and france.has_tag("nazimao"):
		nums.append(_btn(148, " 支 持 民 族 欧 洲"))
	elif spain != null and spain.has_tag("soc_eu"):
		nums.append(_btn(148, " 促 进 欧 洲 团 结"))
	return nums


## 7 苏联面板（CS L497-523）。
func _soviet_numbers(w: WorldState, country: CountryData) -> Array:
	var player := w.get_player_country()
	var d := w
	if country.has_tag("nato") or w.war_going(22) \
			or (d.size() > 133 and (d.soviet_reorganization_war_state == 1 or d.soviet_reorganization_war_state == 3)) \
			or w.modifier_active(49) or w.get_flag("is_gkchp") or w.ind_opp:
		return []
	var nums: Array = []
	if not w.get_flag("relres"):
		nums.append(_btn(4, "恢 复 关 系"))
	else:
		nums.append(_btn(81, "科 技 交 易"))
	if (country.has_tag("对华贸易") or (player != null and player.has_tag("sev"))) and country.has_tag("sev"):
		nums.append(_btn(5, "经 互 会"))
	elif country.has_tag("sev"):
		nums.append(_btn(74, "申 请 列 席"))
	if country.has_tag("ovd"):
		nums.append(_btn(6, "华 沙 条 约"))
	nums.append(_btn(7, "两 国 修 好"))
	return nums


## 112 塞内加尔（CS L2691-2728）。
func _x112_numbers(w: WorldState, country: CountryData) -> Array:
	var nums: Array = []
	if not w.event_done_num(616):
		nums.append(_btn(9, "发 展 贸 易"))
		if country.level_of_instability < 1000 and w.result_of_event_num(615) == 2:
			nums.append(_btn(1024, "支持极左翼"))
			if w.event_done_num(500) and w.result_of_event_num(500) == 0:
				nums.append(_btn(1045, "志 愿 军"))
		else:
			nums.append(_btn(1032, "发动革命"))
	elif not w.is_authoritarian(country):
		nums.append(_btn(9, "发 展 贸 易"))
		if country.has_tag("亲中"):
			nums.append(_btn(10, "经 济 合 作"))
			if _soc500_ok(w, country):
				nums.append(_btn(5001, " 非 洲 联 盟"))
			if _revint_ok(w, country):
				nums.append(_btn(5000, "革 命 国 际"))
	return nums


## 中非通用模板（CS L2731/L2753/L3586/L3629）：puppet<0 → 9 + 亲中尾；puppet 由 trade_if_puppet 决定
func _au_rim_country_numbers(w: WorldState, country: CountryData, trade_if_puppet: bool) -> Array[int]:
	if country.puppet_of >= 0:
		if trade_if_puppet:
			return [DIPLO_BTN_TRADE9]
		return []
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	_append_au_rim_tail(nums, w, country)
	return nums


## 事件门经济模板（CS L2930-2952/L3002-3024）：puppet<0 → 9 + [Gos∉{0,3}&&ev_flag] 10,5001,5000；else → 9
func _econ_gate_country_numbers(w: WorldState, country: CountryData, ev_flag: String) -> Array[int]:
	if country.puppet_of >= 0:
		return [DIPLO_BTN_TRADE9]
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	# 注：ingamewars[53].is_going 移植说明 → 视为无战争
	if country.government != GameConstants.Government.AUTHORITARIAN and country.government != GameConstants.Government.LIBERAL and w.get_flag(ev_flag):
		nums.append(DIPLO_BTN_ECON10)
		_append_rim_tail(nums, w, country)
	return nums


## 亲中尾段（CS L2734-2746 等）：[亲中] 10 + [soc500] 5001 + [revint] 5000
func _append_au_rim_tail(nums: Array[int], w: WorldState, country: CountryData) -> void:
	if not country.has_tag("亲中"):
		return
	nums.append(DIPLO_BTN_ECON10)
	_append_rim_tail(nums, w, country)


## 联盟尾段（CS L2938-2946 等）：[亲中] 5001(soc500) + 5000(revint)
func _append_rim_tail(nums: Array[int], w: WorldState, country: CountryData) -> void:
	if not country.has_tag("亲中"):
		return
	if _soc500_ok(w, country):
		nums.append(DIPLO_BTN_AU5001)
	if _revint_ok(w, country):
		nums.append(DIPLO_BTN_RIM5000)


## 133（CS L3264）：9,10 + [亲中] ([Gos==1&&ev500]5001 + [revint]5000)
func _x133_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var nums: Array[int] = [DIPLO_BTN_TRADE9, DIPLO_BTN_ECON10]
	if not country.has_tag("亲中"):
		return nums
	# 注：原版 5001 守卫为 Gosstroy==1（非 IsSocialism）；resultOfEvents[500]==0 移植说明
	if country.government == GameConstants.Government.SOCIALIST and w.get_flag("event_done_500"):
		nums.append(DIPLO_BTN_AU5001)
	if _revint_ok(w, country):
		nums.append(DIPLO_BTN_RIM5000)
	return nums


## 135（CS L3316）：9 + [!亲美] ([亲中||Gos∉{0,3}]10 + [亲中]19 + [revint]5000)
func _x135_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	if country.has_tag("亲美"):
		return nums
	if country.has_tag("亲中") or (country.government != GameConstants.Government.LIBERAL and country.government != GameConstants.Government.AUTHORITARIAN):
		nums.append(DIPLO_BTN_ECON10)
	if country.has_tag("亲中"):
		nums.append(DIPLO_BTN_MIL19)
		if _revint_ok(w, country):
			nums.append(DIPLO_BTN_RIM5000)
	return nums


## 167（CS L3365）：!NATO → 9 + [社会主义] 10 + [revint]5000
func _x167_numbers(w: WorldState, country: CountryData) -> Array[int]:
	if country.has_tag("nato"):
		return []
	var nums: Array[int] = [DIPLO_BTN_TRADE9]
	if w.is_socialism(country, true):
		nums.append(DIPLO_BTN_ECON10)
		if _revint_ok(w, country):
			nums.append(DIPLO_BTN_RIM5000)
	return nums


## 链尾块H（CS L3914）：非洲区间+亲中+!africaOff → 10,[soc500]5001,[revint]5000
## 注：66 资源开发区（CS L3925，data.africa_coup_route 移植说明）
func _africa_block_numbers(w: WorldState, country: CountryData) -> Array[int]:
	var n := country.原版序号
	var in_range := (n > 53 and n < 69) or (n > 105 and n < 109) or (n > 111 and n < 134) or n == 42
	if not in_range or n == 55 or n == 54 or n == 106:
		return []
	if not country.has_tag("亲中") or country.禁用非洲机制:
		return []
	var nums: Array[int] = [DIPLO_BTN_ECON10]
	if _soc500_ok(w, country):
		nums.append(DIPLO_BTN_AU5001)
	if _revint_ok(w, country):
		nums.append(DIPLO_BTN_RIM5000)
	return nums


## revint 列表级守卫（CS L550 等）：ev548 && 中国.isRIM && IsSocialism(true)
## && sub∉{16,18} && !SEV && !OVD && 亲中
## 注：gkchp 变体 (sub==10&&is_gkchp，is_gkchp 建模说明) 移植说明
func _revint_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("亲中")


## revint 公共部分（CS L550 等）：ev548 && 中国.isRIM
## && (IsSocialism(true) || (sub==10 && is_gkchp)) && sub∉{16,18} && !SEV && !OVD
func _revint_core_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	if not w.get_flag("event_done_548") or not player.has_tag("rim"):
		return false
	var regime_ok := w.is_socialism(country, true) \
		or (country.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST and w.get_flag("is_gkchp"))
	if not regime_ok or country.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or country.sub_government == GameConstants.SubGovernment.TROTSKYIST:
		return false
	if country.has_tag("sev") or country.has_tag("ovd"):
		return false
	return true


## revint econ 变体（CS L2525/L2557）：末尾 econ 而非亲中
func _revint_econ_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("econ")


## revint Torg 变体（CS L2610）：末尾 对华贸易 而非亲中
func _revint_torg_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("对华贸易")


## revint okb 变体（CS L3292/L3344/L3575）：末尾 okb 而非亲中
func _revint_okb_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("okb")


## revint !亲苏 变体（CS L920）：末尾 !prosov 而非亲中
func _revint_noprosov_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and not country.has_tag("亲苏")


## revint 无 IsSocialism 变体（CS L1461）：sub∉{16,18} && !SEV && !OVD && 亲中（无 soc 检查）
func _revint_nosoc_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	if not w.get_flag("event_done_548") or not player.has_tag("rim"):
		return false
	if country.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or country.sub_government == GameConstants.SubGovernment.TROTSKYIST:
		return false
	if country.has_tag("sev") or country.has_tag("ovd"):
		return false
	return country.has_tag("亲中")


## revint puppet<0 变体（CS L1861）：末尾 puppetOf<0 而非亲中
func _revint_puppet_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.puppet_of < 0


## revint sub==17 变体（CS L618/L2150）：ev548 && 中国.isRIM && sub==17 && !SEV && !OVD && 亲中
func _revint_sub17_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	return w.get_flag("event_done_548") and player.has_tag("rim") \
		and country.sub_government == GameConstants.SubGovernment.MAOIST \
		and not country.has_tag("sev") and not country.has_tag("ovd") and country.has_tag("亲中")


## AU 列表级守卫（CS L2739 等）：IsSocialism(true) && ev500 && res==0
## 注：resultOfEvents[500] 移植说明，视为 0
func _soc500_ok(w: WorldState, country: CountryData) -> bool:
	return w.is_socialism(country, true) and w.get_flag("event_done_500")


## 块K（CS L3942）：ev713 && n!=1 && puppet<0 && IsSocialism(true) && sub∉{16,18}
## && !亲苏 && !亲美 && !SEV && !OVD && !NATO && !EU && !SEATO && !SENTO
func _block_k_ok(w: WorldState, country: CountryData) -> bool:
	if not w.get_flag("event_done_713") or country.原版序号 == GameConstants.LegacySlot.CHINA:
		return false
	if country.puppet_of >= 0:
		return false
	if not w.is_socialism(country, true) or country.sub_government == GameConstants.SubGovernment.SOVIET_STYLE or country.sub_government == GameConstants.SubGovernment.TROTSKYIST:
		return false
	if country.has_tag("亲苏") or country.has_tag("亲美") or country.has_tag("sev") \
			or country.has_tag("ovd") or country.has_tag("nato") or country.has_tag("eu") \
			or country.has_tag("seato") or country.has_tag("sento"):
		return false
	return true


func _truncate4(nums: Array) -> Array:
	if nums.size() > 4:
		nums.resize(4)
	return nums


## 分支文案包装器：caption 为 CountryScript 分支按钮原文。
func _btn(action_type: int, caption: String) -> Dictionary:
	return {"type": action_type, "caption": caption}


# ============================================================================
# 组装当前国家的互动列表（新版：编号目录驱动）
# 结构对齐现有 _current_actions：{text, conditions, effect_desc, effect}
# ============================================================================
func _build_actions_v2(country: CountryData) -> Array[Dictionary]:
	var w: WorldState = GameManager.world
	if w == null:
		return []
	var d := w
	var actions: Array[Dictionary] = []

	# 逐国链已把原版全部按钮（含剧情操作）按槽序产出；这里统一经目录解析。
	for entry in _build_country_numbers(w, country):
		var action_type: int = entry if entry is int else int(entry.get("type", -1))
		var branch_caption: String = "" if entry is int else String(entry.get("caption", ""))
		var def := _diplo_action_def(action_type, w, d, country)
		if def.is_empty():
			continue
		# 不因 dormant 过滤：原版 Show 仍显示按钮，条件不满足时点击无效；悬停显示未满足原因。
		var text: String = branch_caption if branch_caption != "" else String(def["caption"])
		actions.append({
			"text": text,
			"conditions": def["conditions"],
			"effect_desc": def["opis"],
			"effect": def["effect"],
		})

	if actions.size() > 4:
		actions.resize(4)
	return actions


# ── 工具方法 ──

func _make_action(text: String, conditions: Array, effect_desc: String, effect: Callable) -> Dictionary:
	return {"text": text, "conditions": conditions, "effect_desc": effect_desc, "effect": effect}


func _cond(desc: String, check: Callable) -> Dictionary:
	return {"desc": desc, "check": check}
