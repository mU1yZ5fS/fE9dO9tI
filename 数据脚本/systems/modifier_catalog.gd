class_name ModifierCatalog
extends RefCounted

## 从 res://资产/数据/修正/mod_XX.tres 加载修正图标；
## 名称/效果文案以 Unity 原作 ModifyButtonScript.cs + old_modify_text_ru.txt /
## old_modify_opis_ru.txt（language==0 中文分支）为唯一基准。
## 运行时激活状态仍看 WorldState.modifiers；本类负责定义与展示资源。

const MOD_DIR := "res://资产/数据/修正/"
const W = preload("res://数据脚本/world_state.gd")

## 跨系统注入（GameManager 设置）。
static var current_world: WorldState = null

static var _by_id: Dictionary = {}  # int -> ModifierDef
static var _loaded: bool = false


# ============================================================================
# 文案基准：old_modify_text_ru.txt（62 行，id 0-61）
# 说明：原版字符间空格为逐字排版格式，Godot 不再保留（既有约定）。
# ============================================================================
const NAME_ZH := {
	0: "低效的工业",
	1: "巴以争端",
	2: "服务业的发展进程",
	3: "文化大革命",
	4: "普遍的贫困",
	5: "与黑社会妥协",
	6: "毛主义的坚实壁垒",
	7: "黑猫白猫论",
	8: "经济联盟",
	9: "失去新疆",
	10: "失去西藏",
	11: "自动化雄心",
	12: "落后的经济",
	13: "蓬勃发展的中小企业",
	14: "1975年“全面整顿”的遗产",
	15: "农业的发展进程",
	16: "苏联禁运",
	17: "美国禁运",
	18: "十世班禅喇嘛",
	19: "十四世达赖喇嘛",
	20: "韩波喇嘛",
	21: "赛福鼎·艾则孜",
	22: "包尔汉·沙希迪",
	23: "艾尔肯·阿力普提肯",
	24: "山头林立的一党民主",
	25: "儒家的胜利",
	26: "法家的胜利",
	27: "东方罗马",
	28: "75宪法",
	29: "以20年代苏联为范的宪法",
	30: "左派市场宪法",
	31: "西式宪法",
	32: "红卫兵掌权",
	33: "军委会中的平民",
	34: "中国自然改造计划",
	35: "全中国铁路网",
	36: "国际专利体系成员",
	37: "赫尔辛基协议成员",
	38: "终身大总统",
	39: "驻美利坚华人黑帮",
	40: "回归农业文明",
	41: "“狩猎俱乐部”成员",
	42: "法国总统-瓦莱里·吉斯卡尔·德斯坦",
	43: "法国总统-弗朗西斯·密特朗",
	44: "法国总统-乔治·马歇",
	45: "法国总统-雅克·希拉克",
	46: "阿拉伯联合联邦",
	47: "特勤一体化协定",
	48: "军事一体化协定",
	49: "第四国际",
	50: "军事的发展进程",
	51: "黑金",
	52: "补贴盟国",
	53: "与史塔西合作",
	54: "美国国内各党影响力对比",
	55: "苏联共产党内各派影响力对比",
	56: "法国总统各大候选人声势对比",
	57: "英国工党内部力量对比",
	58: "东西伯利亚-太平洋管道计划",
	59: "我们的军事联盟",
	60: "祸结衅深",
	61: "国家象征",
	# 62-65 原版 old_modify_texts 数组只有 62 项，这些图标的标题取动态文案首行语义。
	62: "意大利1983大选结果预测",
	63: "文化洋跃进",
	# 64「最高领导人概况」已按主人要求停用：多数据源（faction/traits/LeaderAsset）未统一，暂不显示。
	65: "生财有道",
}


# ============================================================================
# 静态效果底稿：old_modify_opis_ru.txt（60 行，id 0-59）。
# 「|」沿用原版换行标记，输出时转换为 \n；<color> 走 Label BBCode。
# 带 {N} 的模板由下面 effect_zh() 按 ModifyButtonScript.cs:585-628 的同款
# 参数表动态填值（见 _fmt_context）。
# ============================================================================
const EFFECT_ZH := {
	0: "工业-0.5|每两周<color=red>|如何消除:</color>|研究“自研工业科技”",
	1: "{3}",
	2: "人民支持度-1，思想自由化+2|生活水平-1",
	3: "收入+0.6，特工网络+0.2，军队力量+0.5|<color=red>如果毛主席已逝世：</color>人民支持度+0.5，|思想自由化+1，生活水平-0.5，|与美国关系-0.5",
	4: "如果生活水平<20，则+0.2思想自由化，-0.3凝聚力，工业下降6.25%生活标准低于25.0|如果是鸟笼经济且生活水平<30，或是混合经济且生活水平<40，或是最低管控且生活水平<50，则+0.1腐败，-0.3支持度，工业下降6.25%生活标准低于阈值",
	5: "人民支持度-0.2，思想自由化+1，收入+0.2",
	6: "党内团结度+0.5，思想自由化-0.2，凝聚力+0.1，国际声誉+0.2，与苏联关系-0.4，与美国关系-0.2",
	7: "如果腐败>20，则-0.1腐败|如果自由化>80，则-0.3自由化|如果工业<50，则+0.3工业|如果服务业<50，则+0.3服务业|如果与美国关系<40，则与美国关系：+1%|如果凝聚力<40，则+0.3凝聚力",
	8: "与美国关系+0.2，与苏联关系+0.2，|思想自由化-1",
	9: "凝聚力-1|人民支持度增长速度减半|思想自由化速度增半",
	10: "凝聚力-1|人民支持度增长速度减四分之一|思想自由化速度加四分之一",
	11: "农业、工业和服务业+2|预算+2，生活水平+0.2，腐败-0.3|党内支持度-5.0|每两周",
	12: "出口-15%，特工网络-1.0，|凝聚力-0.3|每两周",
	13: "如果是鸟笼经济，则服务业和收入+0.2，生活水平+0.2%|如果是混合经济，则服务业和收入+0.4，生活水平+0.3%|如果是最低管控，则服务业和收入+0.3，生活水平+0.4%。",
	14: "扶持改革派和自由派",
	15: "根据农业发展情况获得效果",
	16: "我们将减少与苏联关系差额10%的收入|失去相当于与苏联关系差额5%的特工网络",
	17: "我们将减少与美国关系差额10%的收入|失去相当于与美国关系差额5%的特工网络",
	18: "思想自由化+0.2，特工网络+0.2",
	19: "爱国主义-0.2，与美国关系+0.5，思想自由化+0.2，收入+0.2",
	20: "与苏联关系+0.2，与美国关系-0.5，军队力量-0.2，收入+0.2",
	21: "与苏联关系+0.2，与美国关系-0.2，军队力量-0.2，科研点数+0.5",
	22: "思想自由化+0.2，爱国主义+0.2，特工网络+0.2，与苏联关系-0.5",
	23: "爱国主义-0.2，与美国关系+0.5，思想自由化+0.2，收入+0.2",
	24: "党内支持度+0.2，思想自由化+0.2，收入+0.2",
	25: "科研点数+0.2，人民支持度-0.2，思想自由化-0.2，腐败-0.2，收入-0.3",
	26: "党内支持度+0.5，思想自由化-0.5，人民支持度-0.5，腐败-0.5，生活水平-0.5",
	27: "军队力量+0.5，人民支持度-0.2，腐败-0.2，收入-0.2",
	28: "极左派、保守派+1，极左派、保守派力量+1，党内支持度-0.2，人民支持度+0.2，思想自由化-0.2，腐败-0.2，特工网络+0.2",
	29: "极左派、改革派、自由派-1，同时力量-1，服务业+0.2，工业+0.2，生活水平+0.5",
	30: "改革派+1，改革派力量+1，国际声誉-0.2，预算+0.5，与美国关系+0.5",
	31: "自由派+1，自由派力量+1，腐败-0.2，寡头力量-0.2，国际声誉-0.2，与美国关系+0.5",
	32: "极左派力量+1，其他派别力量-1|拥有“毛主义的坚实壁垒”：人民支持度+1，思想自由化-1；否则人民支持度-1，思想自由化+1.5|每完成下述一个议程，则额外提供每0.2点军队力量与0.2点特勤网络加成：|人权为自由境界|群众组织为踢开党委或大联合|中国为社会主义|革命国际主义运动已建立|生活水平高于110.0",
	33: "军力-0.5，人民支持度+0.2，生活水平+0.2，工业-0.2，服务业+0.2",
	34: "预算-0.5，农业+0.7，生活水平-0.5，服务业+0.5，凝聚力+0.2",
	35: "预算-0.5，生活水平+0.5，工业+0.5，凝聚力+0.2",
	36: "科研点数+5，与苏联关系+0.5，美国影响+0.5",
	37: "生活水平+0.5，服务业+0.2，腐败-0.2，思想自由化+0.5",
	38: "党内支持度+0.5，国际声望+0.1，民族情绪+0.1",
	39: "与美国关系不会降到15以下，美国影响力-0.5，与苏联关系-0.5，储备金+0.5",
	40: "农业下限锁定为40.0，工业与服务业上限锁定为50.0，军事实力上限锁定为200.0，民族主义+1，凝聚力+0.5，农业+0.4，腐败-0.5，思想自由化-1.0，外交声誉+0.2，极左派不会有补充人员",
	41: "<color=lime>特工网络+1.0;|</color><color=#9370DB>改革派+1;|改革派力量+1;|自由派+1;|自由派力量+1;|美国影响+0.1.</color>|<color=#DC143C>|如何消除:</color>|终止合作关系",
	42: "在党内路线比“强硬”更自由，未遭受美国禁运且与法国建立贸易关系时：<color=lime>|与美国关系+0.4;|预算+0.2;|国际声誉-0.1</color>||<color=#9370DB>美国影响+0.1.</color>",
	43: "在中国维持军事中立，国体为改良主义/自由主义且与法国建立贸易关系时：<color=lime>|预算+0.3;|科研点数+0.4</color>|",
	44: "在党内路线比“实用主义”更激进，未遭受苏联禁运且与法国建立贸易关系时：|<color=lime>|与苏联关系+0.4;|预算+0.2;|科研点数+0.2|</color>||<color=#9370DB>苏联影响+0.1.</color>",
	45: "在中国创立集体安全组织，中国全球影响力高于50.0且与法国建立贸易关系时：|<color=lime>预算+0.2;|干预点数+0.5;</color>|<color=#DC143C>与苏联和美国关系-0.3;</color>|<color=#9370DB>苏联与美国影响-0.1.</color>",
	46: "<color=lime>预算+0.6;|军队力量+0.5;|特工网络+0.5;</color>|<color=#DC143C>与苏联和美国关系-0.5;</color>|<color=#9370DB>苏联与美国影响-0.1.</color>",
	47: "<color=lime>特工网络+{0}</color>|<color=#DC143C>预算-{1:F1}</color>",
	48: "<color=lime>军队力量+{2}</color>|<color=#DC143C>预算-{1:F1}</color>",
	49: "<color=lime>干预点数+3.0;|特工网络+2.0|</color>|<color=#DC143C>与苏联和美国关系-2.0;</color>",
	50: "根据军事发展情况获得效果",
	51: "每桶油的价格为：{8}$（中国境内油价为：{34}$)|国内石油产量：{29}|国内石油用量：{30}|预算<color={32}>{33}{31:F1}</color>||<color=#9370DB>苏联影响：{39}{37}|美国影响：{40}{38}</color>",
	52: "月度变化：|<color=lime>{10}的影响力-1.0|中国影响力+0.5.</color>|<color=#DC143C>特工网络-{9}|预算-{9}|军队力量-{9}</color>|（每多补贴一个国家，多消耗0.1）",
	53: "<color=lime>特工网络+1.0;|</color><color=#9370DB>极左派+1;|极左派力量+1;|温和派+1;|温和派力量+1;|苏联影响+0.1.</color>|<color=#DC143C>|如何消除:</color>|终止合作关系",
	54: "共和党声势：{19}|民主党声势：{20}",
	55: "戈尔巴乔夫的势力：{11}|罗曼诺夫的势力：{12}|格里申的势力：{13}|谢尔比茨基的势力：{14}|{15}{16}|{17}{18}",
	56: "吉斯卡尔·德斯坦的支持度：{21}|弗朗西斯·密特朗的支持度：{22}|乔治·马歇的支持度：{23}|雅克·希拉克的支持度：{24}",
	57: "工党影响力：{25}|保守党影响力：{26}|社会民主党影响力：{27}|自由党影响力：{28}",
	58: "只有在与苏联关系高于50.0.的情况下，工程才会进行|<color=#DC143C>预算-0.5</color>|降低中国境内油价$15（但不会低于$10）|工期已完成：{35}/12|{36}",
	59: "测试",
}


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_by_id.clear()
	# 用 ResScan 以兼容导出包（.tres 会被重映射为 .tres.remap）
	for path in ResScan.list_files(MOD_DIR, [".tres"]):
		var res = load(path)
		if res is ModifierDef:
			var def := res as ModifierDef
			_by_id[def.id] = def
		elif res != null:
			push_warning("ModifierCatalog: 非 ModifierDef 资源 %s" % path)


static func get_def(id: int) -> ModifierDef:
	_ensure_loaded()
	return _by_id.get(id) as ModifierDef


## 已加载定义 id 列表（升序），供概览列出激活/未激活项
static func all_ids() -> Array[int]:
	_ensure_loaded()
	var ids: Array[int] = []
	for k in _by_id.keys():
		ids.append(int(k))
	ids.sort()
	return ids


static func name_zh(id: int) -> String:
	var w: WorldState = current_world
	if id == 63:
		if w != null and w.completed_event_ids.has("event_687"):
			return "“民族文化”复兴"
	if id == 46 and w != null and _mod_active(w, 46):
		# TimeScript.cs:617-619：埃及(30) 严格社会主义且 46 激活时改标题。
		var egypt := _country(w, 30)
		if egypt != null and w.is_socialism(egypt, true):
			return "阿拉伯革命社会主义共和国联盟"
	if id == 28:
		# TimeScript.cs:566-575：事件326选项0 + 文革 + 毛主义壁垒 + 一党制(6) 时改标题。
		return "无产阶级宪法" if _is_proletarian_constitution(w) else "75宪法"
	if NAME_ZH.has(id):
		return NAME_ZH[id]
	var def := get_def(id)
	if def != null and def.name_zh != "":
		return def.name_zh
	return "修正 #%d" % id


static func effect_zh(id: int, w: WorldState = null) -> String:
	if w == null:
		w = current_world
	match id:
		1:
			return _iraq_palestine_status(w)
		2:
			return _effect_services(w)
		11:
			return _effect_automation(w)
		13:
			return _effect_13(w)
		15:
			return _effect_agriculture(w)
		28:
			return _effect_constitution(w)
		44:
			return _effect_france_mod44(w)
		47:
			return _effect_integration(w, true)
		48:
			return _effect_integration(w, false)
		50:
			return _effect_military(w)
		51:
			return _effect_oil(w)
		52:
			return _effect_subsidy(w)
		54:
			return _effect_us_parties(w)
		55:
			return _effect_soviet_factions(w)
		56:
			return _effect_france_candidates(w)
		57:
			return _effect_uk_labour(w)
		58:
			return _effect_pipeline(w)
		60:
			# 原版 old_modify_opis 只有 0-59，60 号无底稿。
			return "效果未录入"
		61:
			return _effect_anthem(w)
		62:
			return _effect_italy(w)
		63:
			return _effect_culture(w)
		# 64 已停用：见 NAME_ZH 中注释。
		# 64:
		# 	return _effect_leader(w)
		65:
			return _effect_money(w)
	var def := get_def(id)
	if EFFECT_ZH.has(id):
		return EFFECT_ZH[id].replace("|", "\n")
	if def != null and def.effect_zh != "" and def.effect_zh != "效果未录入（仅图标已挂接）":
		return def.effect_zh.replace("|", "\n")
	return "效果未录入"


## 图标命名约定（与原版/资源目录一致）：
##   res://资产/修正图标/{id}_0.png = 激活
##   res://资产/修正图标/{id}_1.png = 未激活
const ICON_DIR := "res://资产/修正图标/"


static func _load_icon_file(id: int, active: bool) -> Texture2D:
	var suffix := "0" if active else "1"
	return _load_icon_named("%d_%s" % [id, suffix])


## 按文件名（不含扩展名）从 res://资产/修正图标/ 加载。
static func _load_icon_named(file_name: String) -> Texture2D:
	var path := "%s%s.png" % [ICON_DIR, file_name]
	if ResourceLoader.exists(path):
		var tex = load(path)
		if tex is Texture2D:
			return tex as Texture2D
	return null


## 按激活状态取图：优先 .tres 里配置的 icon_active/icon_inactive，否则按 {id}_0/{id}_1 约定加载。
## 特殊图按原版 ModifyButtonScript.ChangeIcon()（ChangeIcon 1348-1378）优先覆盖。
static func icon(id: int, is_active: bool = true) -> Texture2D:
	var w: WorldState = current_world
	# id44：南斯拉夫同意统一时，激活用 15_1、未激活用 55_1（ChangeIcon 1351-1354）。
	if id == 44 and w != null and w.get_flag("YugAgree"):
		return _load_icon_named("15_1" if is_active else "55_1")
	# id46：埃及（原版序号 30）政体==1 且激活时用 special[0]（ChangeIcon 1355-1358）。
	if id == 46 and is_active and w != null:
		var egypt := _country(w, 30)
		if egypt != null and egypt.government == 1:
			return _load_icon_named("46_special")
	# id28：75宪法换图条件（ChangeIcon 1359-1362）。
	if id == 28 and is_active and w != null \
			and _event_done(w, "event_326") and _event_result(w, "event_326", -1) == 0 \
			and _mod_active(w, 3) and _mod_active(w, 6) \
			and _raw(w.数值表, WorldState.I_RELIGION) <= 25 \
			and _raw(w.数值表, WorldState.I_PARTY_SYSTEM) == 6 \
			and _raw(w.数值表, WorldState.I_ECON_SYSTEM) <= 11:
		return _load_icon_named("28_special")
	var def := get_def(id)
	if is_active:
		if def != null and def.icon_active != null:
			return def.icon_active
		return _load_icon_file(id, true)
	if def != null and def.icon_inactive != null:
		return def.icon_inactive
	var off := _load_icon_file(id, false)
	if off != null:
		return off
	# 仅有激活图：返回激活图，由 UI 变暗表示未激活
	if def != null and def.icon_active != null:
		return def.icon_active
	var tex := _load_icon_file(id, true)
	if tex != null:
		return tex
	# 原版 ChangeIcon 1375-1378：任何缺失都回退到 7 号图。
	return _load_icon_file(7, is_active)


static func is_known(id: int) -> bool:
	_ensure_loaded()
	return _by_id.has(id)


## 编辑器/调试：已加载条数
static func count_loaded() -> int:
	_ensure_loaded()
	return _by_id.size()


# ============================================================================
# 动态效果（ModifyButtonScript.cs 的格式参数计算）
# ============================================================================

static func _raw(d: Array[int], idx: int) -> int:
	if d == null or idx < 0 or idx >= d.size():
		return 0
	return d[idx]


static func _country(w: WorldState, legacy_idx: int) -> CountryData:
	if w == null:
		return null
	return w.get_country_by_legacy_index(legacy_idx)


static func _tag_count(w: WorldState, tag: String) -> int:
	if w == null:
		return 0
	var n := 0
	for c in w.countries:
		if c != null and c.has_tag(tag):
			n += 1
	return n


static func _mod_active(w: WorldState, id: int) -> bool:
	if w == null or id < 0:
		return false
	if id < w.modifiers.size() and w.modifiers[id] != null:
		return w.modifiers[id].is_active
	for slot in w.modifiers:
		if slot != null and slot.id == id and slot.is_active:
			return true
	return false


static func _event_result(w: WorldState, event_id: String, default: int = 0) -> int:
	if w == null:
		return default
	if w.completed_event_ids.has(event_id):
		return int(w.completed_event_ids[event_id])
	if w.global_flags.has("result_" + event_id):
		return int(w.global_flags["result_" + event_id])
	return default


static func _event_done(w: WorldState, event_id: String) -> bool:
	if w == null:
		return false
	return w.completed_event_ids.has(event_id) or bool(w.global_flags.get("event_done_" + event_id, false))


static func _leader_support(w: WorldState, empire_idx: int, leader_idx: int) -> int:
	if w == null or w.empires.size() <= empire_idx:
		return 0
	var empire: EmpireData = w.empires[empire_idx]
	if empire == null or leader_idx < 0 or leader_idx >= empire.leaders.size():
		return 0
	var leader: EmpireLeader = empire.leaders[leader_idx]
	return leader.support if leader != null else 0


## 原版 {N} 格式参数表（ModifyButtonScript.cs:585-628）。
## 只计算 modifiers 面板实际用到的下标，避免无意义复制。
static func _fmt_context(w: WorldState) -> Dictionary:
	var d: Array[int] = w.数值表 if w != null else []
	var ussr: EmpireData = w.empires[1] if (w != null and w.empires.size() > 1) else null
	var okb := _tag_count(w, "okb")
	var ctx := {}
	# {0}/{1}/{2} —— 特勤/军事一体化协定
	ctx[0] = float(okb * 2) / 10.0
	ctx[1] = 1 if okb < 7 else (2 if okb < 14 else 3)
	ctx[2] = float(okb) / 10.0
	# {3} —— 巴以/伊拉克状态
	ctx[3] = _iraq_palestine_status(w)
	# {8}/{9}/{10} —— 石油价格、补贴对象、苏联领导层值
	ctx[8] = _raw(d, 143)
	ctx[9] = _subsidy_target_name(w)
	ctx[10] = _leader_support(w, EmpireData.USSR, 6)
	# {11}-{18} —— 苏联领导层（原版 template 与 args 顺序就是这样，忠实保留）
	ctx[11] = _leader_support(w, EmpireData.USSR, 4)
	ctx[12] = _leader_support(w, EmpireData.USSR, 5)
	ctx[13] = _leader_support(w, EmpireData.USSR, 1)
	if ussr != null and ussr.current_leader == 0:
		ctx[14] = "苏联对其他国家政治的影响力依然毋庸置疑。现在，是莫斯科为全球发展指明方向。"
		ctx[15] = str(_leader_support(w, EmpireData.USSR, 2))
		ctx[16] = "契尔年科的势力："
		ctx[17] = str(_leader_support(w, EmpireData.USSR, 3))
		ctx[18] = "安德罗波夫的势力："
	else:
		ctx[14] = ""
		ctx[15] = ""
		ctx[16] = ""
		ctx[17] = ""
		ctx[18] = ""
	# {19}-{24} —— 美法政治分
	var parties := _us_party_scores(w)
	ctx[19] = parties.rep
	ctx[20] = parties.dem
	var fr := _france_scores(w)
	ctx[21] = fr.giscard
	ctx[22] = fr.mitterrand
	ctx[23] = fr.marchais
	ctx[24] = fr.chirac
	# {25}-{28} —— 英国工党（动态模板改在 _effect_uk_labour 中直接生成）
	var uk := _uk_scores(w)
	ctx[25] = uk.left
	ctx[26] = uk.right
	ctx[27] = 0
	ctx[28] = 0
	# {29}/{30}/{31}/{32}/{33}/{34} —— 石油
	var oil := _oil_numbers(w)
	ctx[29] = oil.prod
	ctx[30] = oil.eat
	ctx[31] = oil.budget_delta
	ctx[32] = oil.color
	ctx[33] = oil.sign
	ctx[34] = oil.domestic_price
	# {35}/{36} —— 管道
	ctx[35] = "工程仍在进行" if _raw(d, 153) <= 0 else "项目大功告成"
	ctx[36] = oil.usa_influence_delta
	# {37}-{40} —— 石油对美苏影响
	ctx[37] = oil.soviet_influence_delta
	ctx[38] = oil.usa_influence_delta
	ctx[39] = oil.soviet_sign
	ctx[40] = oil.usa_sign
	return ctx


static func _iraq_palestine_status(w: WorldState) -> String:
	var d: Array[int] = w.数值表 if w != null else []
	var iraq := _country(w, 14)
	if iraq != null and iraq.parts.size() > 8 and iraq.parts[8]:
		return "大伊拉克的一部分"
	var pal := _raw(d, WorldState.I_PALESTINE_STATUS)
	match pal:
		3: return "已建成巴以联盟国家"
		2: return "巴勒斯坦建立阿拉伯国"
		1: return "阿拉伯人自治区"
	return "巴以问题尚未解决"


static func _effect_13(w: WorldState) -> String:
	var d: Array[int] = w.数值表 if w != null else []
	var living := _raw(d, WorldState.I_LIVING)
	var econ := _raw(d, WorldState.I_ECON_SYSTEM)
	var denom := 500
	if econ == 14:
		denom = 330
	elif econ == 15:
		denom = 250
	elif econ == 13:
		denom = 500
	else:
		return EFFECT_ZH[13].replace("|", "\n")
	@warning_ignore("integer_division")
	var whole := living / (denom * 10)
	@warning_ignore("integer_division")
	var frac := absi(living / denom % 10)
	return "预算收入约 +%d.%d（随生活水平）" % [whole, frac]


static func _effect_integration(w: WorldState, agents: bool) -> String:
	var okb := _tag_count(w, "okb")
	var bonus := float(okb * 2) / 10.0 if agents else float(okb) / 10.0
	var cost := 1 if okb < 7 else (2 if okb < 14 else 3)
	var what := "特工网络" if agents else "军队力量"
	return "<color=lime>%s+%s</color>\n<color=#DC143C>预算-%d.0</color>" % [what, _num(bonus), cost]


static func _effect_oil(w: WorldState) -> String:
	var oil := _oil_numbers(w)
	var d: Array[int] = w.数值表 if w != null else []
	var world_price := _raw(d, 143)
	return ("每桶油的价格为：%d$（中国境内油价为：%s$)\n" % [world_price, _num(oil.domestic_price)]) \
		+ ("国内石油产量：%s\n" % _num(oil.prod)) \
		+ ("国内石油用量：%s\n" % _num(oil.eat)) \
		+ ("预算<color=%s>%s%s</color>\n\n" % [oil.color, oil.sign, _num(oil.budget_delta)]) \
		+ ("<color=#9370DB>苏联影响：%s%s\n美国影响：%s%s</color>" % [
			oil.soviet_sign, _num(oil.soviet_influence_delta),
			oil.usa_sign, _num(oil.usa_influence_delta),
		])


static func _effect_subsidy(w: WorldState) -> String:
	var target := _subsidy_target_name(w)
	var d: Array[int] = w.数值表 if w != null else []
	# 原版 ModifyButtonScript 参数 {9} = data[146]/10（外援强度），
	# 不是“贸易同盟国家数 × 0.1”；两者在部分决策下会不同，按原文修正。
	var cost := float(_raw(d, WorldState.I_FOREIGN_AID)) / 10.0
	return ("月度变化：\n<color=lime>%s的影响力-1.0|中国影响力+0.5.</color>\n" % target) \
		+ ("<color=#DC143C>特工网络-%s|预算-%s|军队力量-%s</color>\n" % [_num(cost), _num(cost), _num(cost)]) \
		+ ("（每多补贴一个国家，多消耗0.1）")


static func _effect_us_parties(w: WorldState) -> String:
	var p := _us_party_scores(w)
	return "共和党声势：%d\n民主党声势：%d" % [p.rep, p.dem]


static func _effect_soviet_factions(w: WorldState) -> String:
	# id55 是“苏联共产党内各派影响力对比”。原版模板的 {N} 顺序与
	# leaders 数组错位（罗曼诺夫显示为格里申的值等），此处按 leaders 索引
	# 原意对齐：4=罗曼诺夫、5=格里申、1=谢尔比茨基、6=戈尔巴乔夫。
	return "戈尔巴乔夫的势力：%d\n罗曼诺夫的势力：%d\n格里申的势力：%d\n谢尔比茨基的势力：%d\n安德罗波夫的势力：%d\n契尔年科的势力：%d" % [
		_leader_support(w, EmpireData.USSR, 6),
		_leader_support(w, EmpireData.USSR, 4),
		_leader_support(w, EmpireData.USSR, 5),
		_leader_support(w, EmpireData.USSR, 1),
		_leader_support(w, EmpireData.USSR, 3),
		_leader_support(w, EmpireData.USSR, 2),
	]


static func _effect_france_candidates(w: WorldState) -> String:
	var f := _france_scores(w)
	return "吉斯卡尔·德斯坦的支持度：%d\n弗朗西斯·密特朗的支持度：%d\n乔治·马歇的支持度：%d\n雅克·希拉克的支持度：%d" % [
		f.giscard, f.mitterrand, f.marchais, f.chirac,
	]


static func _effect_uk_labour(w: WorldState) -> String:
	var uk := _uk_scores(w)
	if not _event_done(w, "event_404"):
		return "工党左派：%d\n工党右派：%d" % [uk.left, uk.right]
	var d: Array[int] = w.数值表 if w != null else []
	var brit_lost := w.get_flag("BritLost") if w != null else false
	var hk := _raw(d, WorldState.I_HK_MACAU_STATUS)
	var uk_country := _country(w, 92)
	var based := uk_country != null and uk_country.有驻军基地
	if brit_lost and uk.prediction_bonus >= 3 and hk > 0 and based:
		return "1983年大选最可能的结果是：\n<color=red>工党</color>"
	if based and brit_lost and hk > 0:
		return "1983年大选最可能的结果是：\n<color=yellow>自由党</color>与<color=green>社会民主党</color>的联盟"
	if brit_lost and hk > 0:
		return "1983年大选最可能的结果是：\n<color=red>工党</color>"
	if brit_lost or hk > 0:
		return "1983年大选最可能的结果是：\n<color=red>工党</color>、<color=yellow>自由党</color>与<color=green>社会民主党</color>联盟"
	return "1983年大选最可能的结果是：\n<color=blue>保守党</color>"


static func _effect_pipeline(w: WorldState) -> String:
	var oil := _oil_numbers(w)
	var d: Array[int] = w.数值表 if w != null else []
	var status := "工程仍在进行" if _raw(d, 153) <= 0 else "项目大功告成"
	return ("只有在与苏联关系高于50.0.的情况下，工程才会进行\n" \
		+ "<color=#DC143C>预算-0.5</color>\n" \
		+ "降低中国境内油价$15（但不会低于$10）\n" \
		+ "工期已完成：%s/12\n%s" % [status, _num(oil.soviet_influence_delta)])


static func _effect_anthem(w: WorldState) -> String:
	var d: Array[int] = w.数值表 if w != null else []
	var anthem := _raw(d, 185)
	var s := "<color=red>国歌：</color>"
	match anthem:
		0:
			s += "纯音乐版《义勇军进行曲》\n凝聚力+0.1"
		1:
			s += "改词版《义勇军进行曲》\n党内团结度+0.1"
			if _mod_active(w, 3) and _mod_active(w, 6):
				s += "，十二大时的力量对比更倾向于保守派"
		2:
			s += "《义勇军进行曲》\n凝聚力+0.2"
		3:
			s += "《东方红》\n人民支持度+0.1"
			if _mod_active(w, 3) and _mod_active(w, 6):
				s += "，十二大时的力量对比更倾向于激进派"
		4:
			s += "《国际歌》\n世界观-0.1，若世界观高于70.0时额外-0.3"
		5:
			s += "《歌唱祖国》"
		6:
			s += "《中国，鲜红的太阳永不落》\n若应用了先进的社会主义理论：思想自由化-0.2，外交声誉+0.2，世界观+0.4"
		_:
			s += "尚未确定"
	return s


static func _effect_italy(w: WorldState) -> String:
	var d: Array[int] = w.数值表 if w != null else []
	# 意大利事件链已移植（event_399 等直接写 data[172..182]）；
	# 结算分与当前分都读这些槽的当前值（world_factory 已初始化）。
	var dc := _raw(d, 175)
	var pci := _raw(d, 176)
	var msi := _raw(d, 177)
	var orthodox := _raw(d, 178)
	var renewal := _raw(d, 179)
	var berlinguer := _raw(d, 180)
	var reformist := _raw(d, 181)
	var workerist := _raw(d, 172)
	var ex_pci := _raw(d, 173)
	var maoist := _raw(d, 174)
	var dagger := _raw(d, 182)
	return ("注：前面的数字是事件结算后的分数，括号内的数字是当前分数\n" \
		+ "<color=blue>选举形势</color>\n" \
		+ "天主教民主党：%d（%d）\n意大利共产党：%d（%d）\n意大利社会运动：%d（%d）\n\n" \
		+ "<color=green>意共党内力量对比</color>\n" \
		+ "正统路线拥趸：%d（%d）\n革新共产党人：%d（%d）\n贝林格衣钵传承：%d（%d）\n“改进派”修正主义者：%d（%d）\n\n" \
		+ "<color=red>议会外左翼潮流</color>\n" \
		+ "工人主义者：%d（%d）\n前共产党-社会党强硬派：%d（%d）\n毛派：%d（%d）\n\n" \
		+ "<color=#9370DB>短剑行动渗透度：%d</color>") % [
		dc, dc, pci, pci, msi, msi,
		orthodox, orthodox, renewal, renewal, berlinguer, berlinguer, reformist, reformist,
		workerist, workerist, ex_pci, ex_pci, maoist, maoist,
		dagger,
	]


static func _effect_culture(w: WorldState) -> String:
	if w != null and w.completed_event_ids.has("event_687"):
		return "<color=red>“民族文化”复兴：</color>\n每两周思想自由化-3，世界观+1，保守派力量+1"
	return "<color=red>文化洋跃进：</color>\n每两周自由化+5，世界观-1.5，党内支持度-1，人民支持度+3"


static func _effect_leader(w: WorldState) -> String:
	var leader: PoliticianData = w.leader if w != null else null
	if leader == null:
		return "此处记录了我国最高领导人的概况\n尚未确定领导人"
	# 政治立场必须与政治界面同源：party_index()（显式 faction 优先），
	# 不能用 trait_personality 直接当派系索引——开局华国锋 faction=1=保守派，
	# 而 traits[0]=20 是「保守派」特质的 traits 表编号，两者不是同一张表。
	var party_label: String = leader.ideology_label()
	# 资产规模/公众形象/社会声望按原版 ModifyButtonScript.cs:1245-1280 计算。
	var asset_f := float(w.leader_asset) / 10.0
	var public_image := _leader_public_image(w.leader_asset)
	var social_prestige := _leader_social_prestige(w)
	var base := "此处记录了我国最高领导人的概况\n姓名：%s\n政治立场：%s\n资产规模：%s 亿\n公众形象：%s\n社会声望：%s\n任职年限：%d年" % [
		leader.name_display, party_label, String.num(asset_f, 1),
		public_image, social_prestige, leader.years_in_power,
	]
	return base + _leader_property_lines(w, leader)


static func _leader_public_image(asset: int) -> String:
	if asset <= 0:
		return " <color=lime>两袖清风</color>"
	if asset <= 500:
		return " <color=green>党管干部</color>"
	if asset <= 1500:
		return " <color=yellow>一方豪强</color>"
	if asset <= 3000:
		return " <color=orange>资本大鳄</color>"
	return " <color=red>当代傅满洲</color>"


static func _leader_social_prestige(w: WorldState) -> String:
	if w.money_level > 14:
		return " <color=red>“老大哥”</color>"
	if _raw(w.数值表, W.I_PEOPLE_SUPPORT) < 400:
		return " <color=orange>臭名昭著</color>"
	if _raw(w.数值表, W.I_PEOPLE_SUPPORT) < 700:
		return " <color=yellow>毁誉参半</color>"
	return " <color=lime>好评如潮</color>"


static func _leader_property_lines(w: WorldState, leader: PoliticianData) -> String:
	if w.money_level <= 0:
		return ""
	var s := ""
	if w.leader_property.size() > 1 and w.leader_property[1]:
		s += "\n<color=yellow>空中霸主，铁路帝王：</color>%s 先生在交通体系内打造的个人圈子当然不只限于个人享受那么简单——预算-1.0，与苏联关系-0.2，科研点+0.5，干预点数+1.0，可免费监视政治局内的政客" % leader.name_display
	if w.leader_property.size() > 2 and w.leader_property[2]:
		s += "\n<color=yellow>白道宗师，黑道救主：</color>%s 先生亲自领导并指挥的“各路诸侯”与“地下军队”令人印象深刻——预算-2.0；强化“破财消灾”决议的效果；与超级大国的关系不会跌破25.0；可无视外交声誉与非社会主义政权建立友好关系；可免费调查政治局内的政客；可在阴谋事件内无条件取得政治辩论胜利" % leader.name_display
	if w.leader_property.size() > 3 and w.leader_property[3]:
		s += "\n<color=yellow>志向高远，胸怀广阔：</color>预算-2.0，党内支持度+0.5；党内支持度不会跌破40.0；若在多党制环境下，思想自由化不会高于40.0；可以免费扶持政客；强化“破财消灾”决议的效果；与%s 同政治派系的政客，其出现病弱属性的阈值将变为88岁" % leader.name_display
	return s


static func _effect_money(w: WorldState) -> String:
	var level := w.money_level if w != null else 0
	var support_cost := 0.2 * float(level)
	var industry_cost := 0.4 * float(level)
	var living_cost := 0.5 * float(level)
	return "生财有道等级：%d级\n个人资产规模+%d\n人民支持度-%s\n思想自由化+%s\n人民生活水平-%s\n三大产业-%s\n腐败+%s" % [
		level, level, String.num(support_cost, 1), String.num(support_cost, 1),
		String.num(living_cost, 1), String.num(industry_cost, 1), String.num(support_cost, 1),
	]


# ============================================================================
# 双周结算动态文案（ModifiesInfuence.ModifiesChanges 同款条件拼接）
# ============================================================================

static func _sci(w: WorldState, idx: int) -> bool:
	return w != null and w.techs != null and idx >= 0 and idx < w.techs.unlocked.size() \
		and w.techs.unlocked[idx]


static func _is_proletarian_constitution(w: WorldState) -> bool:
	# TimeScript.cs:566-575：事件326选项0 + 修正3/6 激活 + 宗教<=25 + 一党制6 + 计划体制<=11。
	if w == null:
		return false
	var d := w.数值表
	return _event_done(w, "event_326") and _event_result(w, "event_326") == 0 \
		and _mod_active(w, 3) and _mod_active(w, 6) \
		and _raw(d, WorldState.I_RELIGION) <= 25 \
		and _raw(d, WorldState.I_PARTY_SYSTEM) == 6 \
		and _raw(d, WorldState.I_ECON_SYSTEM) <= 11


static func _effect_constitution(w: WorldState) -> String:
	if _is_proletarian_constitution(w):
		return "极左派+3，极左派力量+3，党内支持度-0.5，人民支持度+1.5，思想自由化-1.5，腐败-0.2，预算+0.3，特工网络+0.3"
	return EFFECT_ZH[28].replace("|", "\n")


static func _effect_automation(w: WorldState) -> String:
	if _mod_active(w, 11):
		# ModifiesInfuence.cs:1560-1570：激活时覆盖为 +5.0 版本。
		return "农业、工业和服务业+5.0|预算+5.0，生活水平+1.0，腐败-1.0|党内支持度-5.0|每两周"
	return EFFECT_ZH[11].replace("|", "\n")


static func _effect_france_mod44(w: WorldState) -> String:
	if w != null and w.get_flag("YugAgree"):
		# ModifiesInfuence.cs:2236-2239：南斯拉夫同意统一时改写条件与数值。
		return "在党内路线比“中式社会主义”更激进，未遭受苏联禁运且与法国建立贸易关系时：|<color=lime>|与苏联关系+0.5;|预算+0.3;|科研点数+0.3|</color>||<color=#9370DB>苏联影响+0.1.</color>"
	return EFFECT_ZH[44].replace("|", "\n")


static func _effect_agriculture(w: WorldState) -> String:
	var parts: Array[String] = ["根据农业发展情况获得效果"]
	var ev681 := _event_done(w, "event_681")
	var res681 := _event_result(w, "event_681")
	var ev682 := _event_done(w, "event_682")
	var res682 := _event_result(w, "event_682")
	# ModifiesInfuence.cs:1620-1660
	if not ev681 or res681 == 0:
		parts.append("<color=red>|“上山下乡”政策及其后果</color>|农业+0.1，科技点-1，思想自由化+0.4")
	elif res681 == 1:
		parts.append("<color=red>|社会转型阵痛</color>|生活水平-0.1，思想自由化+0.2")
	elif res681 == 2:
		parts.append("<color=red>|社会主义新农村</color>|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4")
	elif res681 == 3:
		parts.append("<color=red>|“牛棚”群岛</color>|预算+0.1，农业+0.1，特勤网络-0.2，思想自由化-0.2，外交声誉+0.4，科技点-1，与美国关系-1，与苏联关系-1")
	elif res681 == 4 and not ev682:
		parts.append("<color=red>|人心思变</color>|农业-0.1，思想自由化+0.3")
	elif res682 == 0:
		parts.append("<color=red>|乡村建设理论</color>|预算-0.6，农业+0.2，生活水平+0.2，思想自由化-0.4")
	elif res682 == 1:
		parts.append("<color=red>|长期乡建合同</color>|预算+0.2，农业+0.3，工业+0.1，服务业+0.1，生活水平+0.1，思想自由化+1.2，外交声誉-0.2，与美关系+0.2，美国国际影响力+0.1，中国国际影响力-0.1")
	elif res682 == 2:
		parts.append("<color=red>|“新”新村运动</color>|预算-0.4，农业+0.3，服务业+0.1，生活水平+0.1，特勤网络+0.1，思想自由化-0.1")
	elif res682 == 3:
		parts.append("<color=red>|新乔治主义社会</color>|预算+0.3，农业+0.5，工业-0.4，服务业-0.2，生活水平-0.1，思想自由化+0.2")
	elif res682 == 4:
		parts.append("<color=red>|社会主义新农村</color>|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4")
	elif res682 == 5:
		parts.append("<color=red>|水稻共和国</color>|预算+1，农业+0.3，工业+0.2，生活水平-0.6，人民支持度-1.0，思想自由化+1.0，与美关系+0.2，与苏关系+0.2，国际影响力-0.1")
	# ModifiesInfuence.cs:1662-1700
	var ev53 := _event_done(w, "agricultural_reform")
	var res53 := _event_result(w, "agricultural_reform")
	if (not ev53 or res53 == 0) and (not ev682 or res682 == 4):
		parts.append("<color=red>|缓慢推进集体化的公社：</color>|农业+0.1，工业+0.1，生活水平+0.2，预算+0.1")
	elif res53 == 1:
		parts.append("<color=red>|家庭联产承包责任制：</color>|预算+0.4，腐败+0.3|若福利投资低于20，则农业-0.2，生活水平-0.2，服务业-0.2|若福利投资高于20，则农业+0.2，生活水平+0.2，服务业+0.2")
	elif res53 == 2:
		parts.append("<color=red>|私人农场：</color>|农业-0.4，生活水平-0.4，预算+1.0，服务业+0.2，腐败+0.4，寡头+4")
	elif res53 == 3 and (not ev682 or res682 == 4):
		parts.append("<color=red>|快速推进集体化的公社：</color>|农业+0.4，工业+0.4，生活水平+0.4，预算+0.2")
	# ModifiesInfuence.cs:1702-1717
	if _sci(w, 3):
		parts.append("<color=red>|农业机械化：</color>|农业+0.6，工业+0.4")
	if _sci(w, 6):
		parts.append("<color=red>|普及化肥与杀虫剂：</color>|农业+0.3，生活水平+0.4")
	if _sci(w, 7):
		parts.append("<color=red>|转基因技术：</color>|农业+0.2，工业+0.2，生活水平+0.5，预算+0.3")
	return "\n".join(parts)


static func _effect_military(w: WorldState) -> String:
	var parts: Array[String] = ["根据军事发展情况获得效果"]
	if _event_done(w, "event_513") and _sci(w, 18):
		if _event_result(w, "event_513") == 0:
			parts.append("<color=red>|仿制苏械：</color>|军力+0.1")
		elif _event_result(w, "event_513") == 1:
			parts.append("<color=red>|自研军械：</color>|军力+0.2")
	if _event_done(w, "event_514") and _sci(w, 23):
		match _event_result(w, "event_514"):
			0:
				parts.append("<color=red>|新式军装：</color>|人民支持度+0.1，思想自由化-0.1，国际声望高于90/低于70时，国际声望-0.1/+0.1")
			1:
				parts.append("<color=red>|西式军装：</color>|人民支持度+0.1，思想自由化+0.1，国际声望-0.2")
			2:
				parts.append("<color=red>|65式军装：</color>|人民支持度+0.1，思想自由化-0.2，国际声望+0.2")
	if _event_done(w, "event_345"):
		if _event_result(w, "event_345") == 0:
			parts.append("<color=red>|没有军衔的军队：</color>|人民支持度+0.3，军力+0.2，干涉点数+0.2")
		elif _event_result(w, "event_345") == 1:
			parts.append("<color=red>|恢复军衔：</color>|军力+0.5，干涉点数+0.2，腐败+0.2，资金-0.1")
	if _event_done(w, "event_515") and _event_result(w, "event_515") == 0:
		parts.append("<color=red>|无人飞行器：</color>|军力+0.2，特工网络+0.1")
	if _event_done(w, "event_516"):
		if _event_result(w, "event_516") == 0:
			parts.append("<color=red>|改进坦克：</color>|军力+0.3，预算-0.1")
		elif _event_result(w, "event_516") == 1:
			parts.append("<color=red>|自研坦克：</color>|军力+0.6，预算-0.2，凝聚力+0.2")
	if _event_done(w, "event_517"):
		match _event_result(w, "event_517"):
			0:
				parts.append("<color=red>|新式歼击机：</color>|军力+0.3，人民支持度+0.2，预算-0.2，军武援助效果+1")
			1:
				parts.append("<color=red>|新式轰炸机：</color>|军力+0.5，预算-0.2，与美苏关系-0.2，军武援助效果+1")
			2:
				parts.append("<color=red>|新式歼击机与轰炸机：</color>|军力+1.0，人民支持度+0.2，预算-0.3，与美苏关系-0.2，军武援助效果+2")
	if _event_done(w, "event_518"):
		match _event_result(w, "event_518"):
			0:
				parts.append("<color=red>|隐身歼击机：</color>|军力+0.2，人民支持度+0.2，预算-0.2，干预点数+1.0")
			1:
				parts.append("<color=red>|隐身轰炸机：</color>|军力+0.3，预算-0.2，与美苏关系-0.1，干预点数+1.0")
			2:
				parts.append("<color=red>|隐身歼击机与轰炸机：</color>|军力+0.8，人民支持度+0.2，预算-0.3，与美苏关系-0.1，干预点数+2.0")
	if _event_done(w, "event_519"):
		match _event_result(w, "event_519"):
			0:
				parts.append("<color=red>|新型导弹驱逐舰：</color>|军力+1.8，人民支持度+0.5，预算-0.4")
			1:
				parts.append("<color=red>|改造导弹驱逐舰：</color>|军力+1.5，人民支持度+0.2，预算-0.3")
			2:
				parts.append("<color=red>|改造与新型导弹驱逐舰：</color>|军力+3.5，人民支持度+1.0，预算-0.5")
	if _event_done(w, "event_520"):
		match _event_result(w, "event_520"):
			0:
				parts.append("<color=red>|093核潜艇：</color>|军力+2.0，人民支持度+0.5，美苏关系-0.3")
			1:
				parts.append("<color=red>|094核潜艇与巨浪-2型潜射导弹：</color>|军力+4.0，人民支持度+0.8，美苏关系-0.4，预算-0.5")
			2:
				parts.append("<color=red>|092核潜艇：</color>|军力+1.0，人民支持度+1.0，美苏关系-0.2")
	if _event_done(w, "event_521"):
		match _event_result(w, "event_521"):
			0:
				parts.append("<color=red>|导弹驱逐舰：</color>|军力+3.0，人民支持度+1.0，影响力+0.5")
			1:
				parts.append("<color=red>|航空母舰：</color>|军力+3.0，干涉点数+2.0，人民支持度+1.0，影响力+0.5，军武支援效果+1")
			2:
				parts.append("<color=red>|导弹驱逐舰与航空母舰：</color>|军力+5.0，人民支持度+2.5，干涉点数+3.0，影响力+1.0，军武支援效果+2")
	if _event_done(w, "event_540"):
		if _event_result(w, "event_540") == 0:
			parts.append("<color=red>|自研直升机：</color>|军力+0.4，干涉点数+0.2")
		elif _event_result(w, "event_540") == 1:
			parts.append("<color=red>|法式直升机：</color>|军力+0.2，干涉点数+0.1")
	if _event_done(w, "event_544"):
		match _event_result(w, "event_544"):
			0:
				parts.append("<color=red>|核防御措施：</color>|军力+0.7，外交声誉-0.5")
			1:
				parts.append("<color=red>|核威慑措施：</color>|军力+2.0，美苏关系-0.2")
			2:
				parts.append("<color=red>|核防御与核威慑措施：</color>|军力+4.0，美苏关系-0.4，可禁运美苏")
	if _event_done(w, "event_545"):
		match _event_result(w, "event_545"):
			0:
				parts.append("<color=red>|军用运输机：</color>|军力+1.0，支援战争消耗的干涉点数-0.2")
			1:
				parts.append("<color=red>|民用运输机：</color>|生活水平+1.0，人民支持度+1.0，思想自由化-0.5")
			2:
				parts.append("<color=red>|军用与民用运输机：</color>|军力+2.0，生活水平+1.5，人民支持度+2.0，思想自由化-1.0，支援战争消耗的干涉点数-0.5")
	if _event_done(w, "event_685"):
		match _event_result(w, "event_685"):
			0:
				parts.append("<color=red>|参与SALT机制</color>|中美关系+0.2，中苏关系+0.2，军事实力-0.4，特勤网络+0.2，思想自由化+0.2，外交声誉高于90.0时：外交声誉-0.2，外交声誉低于50.0时：外交声誉+0.2，核战必定不会赢得胜利")
			1:
				parts.append("<color=red>|参与弱化的SALT机制</color>|中美关系+0.1，中苏关系+0.1，军事实力-0.2，外交声誉高于90.0时：外交声誉-0.1，外交声誉低于50.0时：外交声誉+0.1")
				parts.append("<color=red>|军备发展新方针：贯彻质量制胜</color>|预算-4.0，军力+2.0，人民支持度+1.0，生活水平+0.6，干涉点数+4.0，军武支援效果+2.0，外交声誉+0.1，科技点+10.0")
			2:
				parts.append("<color=red>|自行其是的世界第三极</color>|中美关系-1，中苏关系-1，外交声誉+0.2")
	if w != null and w.arms_purchase_agreement > 0:
		parts.append("<color=red>|T-72坦克军购协定：</color>|预算-0.6，军力+1.2，科技点数+0.5，中苏关系+0.8，苏联储备金+0.6，苏联国际影响力+0.1")
	if w != null and w.pmc > 0:
		parts.append("<color=red>|“第五纵队”：</color>|预算+1.0，军事实力-1.0，特勤网络+0.2，军事援助效果+2，特勤援助效果+2，人道援助效果+2，与美苏的关系下限为25.0，上限为75.0，腐败+0.2")
	var c16 := _country(w, 16)
	if c16 != null and c16.prc_influence != 0:
		parts.append("<color=red>|现代化的机械陆军：</color>|军力+0.5，特工网络+0.3，干涉点数+1.0，预算-0.8，科技点数-0.2，人民支持度+1.0")
	return "\n".join(parts)


static func _effect_services(w: WorldState) -> String:
	if w == null:
		return EFFECT_ZH[2].replace("|", "\n")
	var d: Array[int] = w.数值表 if w != null else []
	var parts: Array[String] = ["根据服务业的发展情况获得效果"]
	var oligarch := _raw(d, WorldState.I_OLIGARCH)
	if oligarch < 54:
		parts.append("<color=red>受到管控的私有制：</color>投机倒把的商人还影响不到我们")
	elif oligarch < 72:
		parts.append("<color=red>逐渐崛起的寡头：</color>人民支持度-0.5，思想自由化+1，生活水平-0.5")
	elif oligarch >= 72:
		parts.append("<color=red>寡头执政：</color>人民支持度-1，思想自由化+2，生活水平-1")
	var ev669 := _event_done(w, "event_669")
	var res669 := _event_result(w, "event_669")
	if not ev669:
		parts.append("<color=red>|无产阶级教育路线：</color>预算-0.1，工业+0.2，农业+0.2，人民支持度+0.2，科技点数+0.5")
	elif res669 == 0:
		parts.append("<color=red>|无产阶级教育路线：</color>预算-0.2，工业+0.3，农业+0.3，人民支持度+0.3，科技点数+1")
	elif res669 == 1:
		parts.append("<color=red>|正统社会主义教育路线：</color>预算-0.1，腐败+0.1，科技点数+1.5")
	elif res669 == 2:
		parts.append("<color=red>|混合式教育体制改革：</color>预算+0.2，寡头力量+0.1，腐败+0.2，科技点数+2")
	elif res669 == 3:
		parts.append("<color=red>|全民军事化教育：</color>军事力量+0.3，人民支持度+1，思想自由化-1，科技点数-2，凝聚力+0.5，民族情绪+0.5")
	var ev456 := _event_done(w, "event_456")
	var res456 := _event_result(w, "event_456")
	if ev456 and res456 == 0:
		parts.append("<color=red>|全国高校统一招生考试：</color>科技点数+2")
	elif ev456 and res456 == 1:
		parts.append("<color=red>|预科制度：</color>科技点数+1")
	elif not ev456 or res456 == 2:
		parts.append("<color=red>|无产阶级推荐制：</color>农业+0.3，工业+0.3")
	var ev646 := _event_done(w, "event_646")
	var res646 := _event_result(w, "event_646")
	if not ev646:
		parts.append("<color=red>|合作医疗：</color>预算-0.1，工业+0.2，农业+0.3，人民支持度+0.2，服务业+0.2")
	elif res646 == 0:
		parts.append("<color=red>|精进的合作医疗：</color>预算-0.2，工业+0.3，农业+0.4，人民支持度+0.2，服务业+0.3")
	elif res646 == 1:
		parts.append("<color=red>|市场化改革医疗：</color>预算+0.2，生活水平+0.1，寡头力量+0.1，服务业+0.1")
	# 原版 ModifiesInfuence.cs:1086-1093：data[16]==15 时票证制度自动废止。
	var phase_out := w.has_coupon_system_phase_out or _raw(d, WorldState.I_ECON_SYSTEM) == 15
	if not phase_out:
		parts.append("<color=red>|票证制度：</color>农业+0.1，党内支持度+0.2，不同经济模式下随着发展程度的不同有额外加成|<color=lime>当前额外加成：</color>" + _services_coupon_text(w, _raw(d, WorldState.I_ECON_SYSTEM), _raw(d, WorldState.I_INDUSTRY) + _raw(d, WorldState.I_AGRICULTURE)))
	else:
		parts.append("<color=red>|自由供应：</color>腐败-0.2，服务业+0.3，人民支持度+0.5，思想自由化+0.5，“普遍的贫困”的触发阈值生活水平提高10.0且效果翻倍")
	if w.planned_price_reduction > 0:
		parts.append("<color=red>|计划性降价：</color>预算-0.3，三大产业-0.3，生活水平+2.0，人民支持度+2.0，思想自由化-2.0，凝聚力+1.0")
	if w.austerity > 0:
		parts.append("<color=red>|自力更生：</color>预算+2.0，生活水平-1.0，人民支持度-1.0，思想自由化+1.0，凝聚力-1.0，服务业-1.0，外交声誉+0.1，人口-0.2百万，生活水平与人民支持度不会超过65.0")
	if w.developed_consumerism > 0:
		parts.append("<color=red>|发达消费主义：</color>预算-2.5，生活水平+1.0，人民支持度+1.0，思想自由化+1.0，工业+1.0，服务业+1.0，美国好感度+0.2")
	if w.new_era_commune_member > 0:
		parts.append("<color=red>|我们是新时代的公社社员！：</color>预算+0.5，党内团结度-2.5，人民支持度+1.0，腐败-1.0，凝聚力+0.5")
	if w.party_means_party > 0:
		parts.append("<color=red>|政党即派对：</color>预算-1，党内团结度+2.0，人民支持度-1.5，思想自由化+0.5，腐败+0.6，政客忠诚度+1，领导人个人资产规模+0.4")
	if w.party_subsidy > 0:
		parts.append("<color=red>|政党补助金：</color>预算-1.0，党内团结度+2.0，思想自由化-0.5，腐败+0.5，政客忠诚度+1，领导人个人资产规模+0.2，凝聚力+1.0")
	return "\n".join(parts)


static func _services_coupon_text(_w: WorldState, econ: int, sum: int) -> String:
	# ModifiesInfuence.cs:667-1196：票证制度按经济体制与工农产值分档。
	if econ <= 11:
		if sum < 400: return "人民支持度+0.3，凝聚力+0.3，预算+0.3"
		if sum < 700: return "人民支持度+0.2，凝聚力+0.2，预算+0.2"
		if sum < 900: return "人民支持度+0.1，凝聚力+0.1，预算+0.1"
		if sum < 1300: return "人民支持度-0.1，预算+0.1"
		if sum < 1500: return "人民支持度-0.2，预算+0.2"
		if sum < 1600: return "人民支持度-0.1，腐败+0.1"
		if sum < 1700: return "人民支持度-0.2，腐败+0.2"
		if sum < 1800: return "人民支持度-0.3，腐败+0.3，思想自由化+0.2"
		if sum < 1900: return "人民支持度-0.4，腐败+0.4，思想自由化+0.3"
		if sum < 2000: return "人民支持度-0.5，腐败+0.5，思想自由化+0.4，更容易引发人民不满"
		return "人民支持度-0.6，腐败+0.6，思想自由化+0.5，更容易引发人民不满"
	if econ <= 13:
		if sum < 400: return "党内支持度+0.3，凝聚力+0.3，思想自由化+0.3，预算+0.3"
		if sum < 700: return "党内支持度+0.2，凝聚力+0.2，思想自由化+0.2，预算+0.2"
		if sum < 900: return "党内支持度+0.1，凝聚力+0.1，思想自由化+0.1，预算+0.1"
		if sum < 1000: return "人民支持度-0.1，思想自由化+0.1，预算+0.1"
		if sum < 1100: return "生活水平-0.1，思想自由化+0.1"
		if sum < 1200: return "生活水平-0.2，思想自由化+0.2"
		if sum < 1300: return "生活水平-0.3，思想自由化+0.3"
		if sum < 1400: return "生活水平-0.4，思想自由化+0.4，人民支持度-0.1"
		if sum < 1500: return "生活水平-0.5，思想自由化+0.5，人民支持度-0.1"
		if sum < 1600: return "人民支持度-0.1，腐败+0.1，生活水平-0.5"
		if sum < 1700: return "人民支持度-0.2，腐败+0.2，生活水平-0.5，思想自由化+0.2"
		if sum < 1800: return "人民支持度-0.3，腐败+0.3，思想自由化+0.2"
		if sum < 1900: return "人民支持度-0.4，腐败+0.4，思想自由化+0.3"
		if sum < 2000: return "人民支持度-0.5，腐败+0.5，思想自由化+0.4，更容易引发人民不满"
		return "人民支持度-0.6，腐败+0.6，思想自由化+0.5，更容易引发人民不满"
	if econ == 14:
		if sum < 400: return "人民支持度-0.3，思想自由化+0.3"
		if sum < 700: return "人民支持度-0.2，思想自由化+0.2"
		if sum < 900: return "人民支持度-0.1，思想自由化+0.1"
		if sum < 1000: return "人民支持度-0.2，思想自由化+0.1，预算+0.1"
		if sum < 1100: return "生活水平-0.1，思想自由化+0.1"
		if sum < 1200: return "生活水平-0.2，思想自由化+0.2"
		if sum < 1300: return "生活水平-0.3，腐败+0.1"
		if sum < 1400: return "人民支持度-0.2"
		if sum < 1500: return "生活水平-0.4，腐败+0.2"
		if sum < 1600: return "人民支持度-0.1，腐败+0.1，生活水平-0.5"
		if sum < 1700: return "人民支持度-0.2，腐败+0.2，预算-0.1"
		if sum < 1800: return "人民支持度-0.3，腐败+0.3，思想自由化+0.2"
		if sum < 1900: return "人民支持度-0.4，腐败+0.4，+0.3思想自由化，预算-0.2"
		if sum < 2000: return "人民支持度-0.5，腐败+0.5，+0.4思想自由化，预算-0.3，更容易引发人民不满"
		return "人民支持度-0.6，腐败+0.6，+0.5思想自由化，预算-0.3，更容易引发人民不满"
	return "自由供应：腐败-0.2，服务业+0.3，人民支持度+0.5，思想自由化+0.5"


# ============================================================================
# 分数计算（ModifyButtonScript.cs 原样条件的 Godot 投影）
# ============================================================================

static func _us_party_scores(w: WorldState) -> Dictionary:
	var dem := 0
	var rep := 0
	if w == null:
		return {"dem": dem, "rep": rep}
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	var year := w.date.year if w.date != null else 1976
	if year < 1981:
		# ModifyButtonScript.cs:17-103（Event114 同款计分）
		if usa != null and ussr != null:
			if usa.power > ussr.power: rep += 1
			else: dem += 1
			if usa.power > w.influence_prc: rep += 1
			else: dem += 1
			if w.influence_prc > ussr.power: rep += 1
			else: dem += 1
		if w.get_flag("oar"):
			dem += 1
		var c15 := _country(w, 15)
		if c15 != null and c15.内战中:
			rep += 1
		var player := w.get_player_country()
		if player != null:
			if player.has_tag("asean"):
				rep += 1
			if player.has_tag("seato"):
				rep += 2  # 原版 55-62 行重复计两次
		var war5 := w.wars[5] if w.wars.size() > 5 else null
		if war5 != null and war5.is_going:
			dem += 1
		# ModifyButtonScript.cs:82：resultOfEvents[46]==2（匈牙利危机结果2）→ 民主党+1。
		if _event_result(w, "hungarian_crisis", 0) == 2:
			dem += 1
		var c84 := _country(w, 84)
		if c84 != null and c84.government == 0:
			dem += 1
		else:
			rep += 1
		var c8 := _country(w, 8)
		if c8 != null and (c8.government == 3 or c8.有驻军基地):
			rep += 1
		else:
			dem += 1
		# ModifyButtonScript.cs:86-102：伊朗人质危机（455）对共和党声势的影响
		# （event_done[455] && result==0 → +1；==1 → +2；==2 → -2；==3 → -1）。
		var res455 := _event_result(w, "event_455", 0)
		if _event_done(w, "event_455") and res455 == 0:
			rep += 1
		elif res455 == 1:
			rep += 2
		elif res455 == 2:
			rep -= 2
		elif res455 == 3:
			rep -= 1
	else:
		# ModifyButtonScript.cs:106-214
		if usa != null and usa.current_leader == 0:
			dem += 7
		if usa != null and ussr != null:
			if usa.power > ussr.power: rep += 1
			else: dem += 1
			if usa.power > w.influence_prc: rep += 1
			else: dem += 1
		var player2 := w.get_player_country()
		if player2 != null and player2.government == 3:
			rep += 1
		else:
			dem += 1
		for idx in [85, 92, 21, 84, 17]:
			var c := _country(w, idx)
			if c != null and c.has_tag("nato"):
				rep += 1
			else:
				dem += 1
		var player3 := w.get_player_country()
		if player3 == null or not player3.has_tag("sev"):
			rep += 1
		else:
			dem += 1
		if player3 == null or not player3.has_tag("ovd"):
			rep += 1
		else:
			dem += 1
		var c15b := _country(w, 15)
		if c15b != null and c15b.内战中:
			rep += 1
		if ussr != null and ussr.current_leader == 3:
			rep += 1
		if player3 != null and player3.has_tag("asean"):
			rep += 1
		var war5b := w.wars[5] if w.wars.size() > 5 else null
		if war5b != null and war5b.is_going:
			dem += 1
		var poland := _country(w, 2)
		if poland != null and poland.puppet_of == 7:
			dem += 1
		if player3 != null and player3.has_tag("seato"):
			rep += 1
	# id54 模板：共和党={19}=num4(rep)；民主党={20}=array[1]。
	var a1 := _american_score(w)
	return {"dem": a1, "rep": rep}


## array[1]（ModifyButtonScript.cs:268-318）：民主党显示分
static func _american_score(w: WorldState) -> int:
	if w == null:
		return 0
	var d: Array[int] = w.数值表
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	var s := 0
	if _raw(d, 132) == 2:
		s += 1
	var usa_country := _country(w, 51)
	if usa_country != null and usa_country.development > 0:
		s += 1
	var player := w.get_player_country()
	if player != null and player.has_tag("seato"):
		s += 1
	if player != null and player.has_tag("asean"):
		s += 1
	if _event_result(w, "afghan_civil_war", 0) == 4 or _event_result(w, "afghan_pakistan_border", 0) == 2:
		s += 1
	if player != null and player.has_tag("okb"):
		s += 1
	var iran := _country(w, 8)
	if iran != null and iran.government == 3:
		s += 1
	var afghan := _country(w, 12)
	if afghan != null and not afghan.has_tag("亲中") and afghan.government == 0:
		s += 1
	if usa != null and ussr != null and usa.power > ussr.power:
		s += 1
	if usa != null and usa.power > w.influence_prc:
		s += 1
	if _mod_active(w, 17):
		s += 1
	return s


## 法国四候选人：{21}=array[3]、{22}=array[0]、{23}=array[2]、{24}=num5
static func _france_scores(w: WorldState) -> Dictionary:
	if w == null:
		return {"giscard": 0, "mitterrand": 0, "marchais": 0, "chirac": 0}
	var d: Array[int] = w.数值表
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	var player := w.get_player_country()

	# array[0]（ModifyButtonScript.cs:215-267）
	var a0 := 0
	if _raw(d, WorldState.I_AFGHAN_PARCHAM) > _raw(d, WorldState.I_AFGHAN_KHALQ):
		a0 += 2
	if _event_result(w, "afghan_soviet_plot", 0) == 1:
		a0 += 1
	if _event_result(w, "afghan_civil_war", 0) == 3:
		a0 -= 1
	var poland := _country(w, 2)
	if poland != null and poland.puppet_of == 7:
		a0 -= 1
	var hungary := _country(w, 4)
	if hungary != null and hungary.government == 1:
		a0 += 1
	var greece := _country(w, 45)
	if greece != null and greece.government == 2:
		a0 += 1
	var iran := _country(w, 8)
	if iran != null and iran.government == 1:
		a0 += 1
	if player != null and player.has_tag("ovd"):
		a0 += 1
	if player != null and player.has_tag("sev"):
		a0 += 1
	if ussr != null and usa != null and ussr.power > usa.power:
		a0 += 1
	if ussr != null and ussr.power > w.influence_prc:
		a0 += 1
	if _mod_active(w, 16):
		a0 += 1

	# array[2]（ModifyButtonScript.cs:320-363）
	var a2 := 0
	if usa != null and ussr != null and w.influence_prc > usa.power and w.influence_prc > ussr.power:
		a2 += 1
	var yugo := _country(w, 15)
	if yugo != null and yugo.内战中:
		a2 += 1
	if iran != null and iran.有驻军基地 and iran.government == 0:
		a2 += 1
	if _mod_active(w, 3):
		a2 += 1
	var spain := _country(w, 87)
	if spain != null and spain.sub_government == 5:
		a2 += 1
	var italy := _country(w, 86)
	if italy != null and italy.government == 2:
		a2 += 1
	var vietnam := _country(w, 11)
	if vietnam != null and vietnam.has_tag("亲中"):
		a2 += 1
	var kampuchea := _country(w, 23)
	if kampuchea != null and kampuchea.has_tag("亲中"):
		a2 += 1
	if usa != null and usa.relations < 500:
		a2 += 1
	if player != null and (player.has_tag("sev") or player.has_tag("asean")):
		a2 -= 2

	# array[3]（ModifyButtonScript.cs:364-411）
	var a3 := 0
	if hungary != null and hungary.government == 2:
		a3 += 1
	if iran != null and iran.sub_government == 20:
		a3 += 1
	if player != null and not player.has_tag("okb") and not player.has_tag("ovd") and not player.has_tag("seato"):
		a3 += 1
	var war5 := w.wars[5] if w.wars.size() > 5 else null
	if war5 != null and war5.is_going:
		a3 += 1
	var usa_country := _country(w, 51)
	if usa_country != null and usa_country.sub_government == 12:
		a3 += 1
	for idx in [85, 87, 86]:
		var c := _country(w, idx)
		if c != null and c.sub_government == 6:
			a3 += 1
	var egypt := _country(w, 30)
	if egypt != null and w.is_authoritarian(egypt):
		a3 += 1
	var war3 := w.wars[3] if w.wars.size() > 3 else null
	if war3 != null and war3.is_going:
		a3 += 1
	if player != null and player.government == 2:
		a3 += 1

	# num5（ModifyButtonScript.cs:419-484）
	var num5 := 0
	var num8 := 0
	if usa != null and usa.current_leader == 1:
		num8 += 1
	var flag2 := _raw(d, WorldState.I_HK_MACAU_STATUS) > 0
	var brit_lost := w.get_flag("BritLost")
	if _event_result(w, "hungarian_crisis", 0) != 2 and _event_result(w, "polish_crisis", 0) != 3 \
			and (war5 == null or not war5.is_going):
		num8 += 1
	var num9 := 0
	for idx in [21, 85, 86, 87]:
		var c := _country(w, idx)
		if c != null and (c.government == 2 or c.government == 1):
			num9 += 1
	if num9 > 1:
		num8 += 1
	var uk_country := _country(w, 92)
	if uk_country != null and uk_country.有驻军基地:
		num5 += num8
		if flag2:
			num5 += 1
		if brit_lost:
			num5 += 1
	else:
		if flag2:
			num5 += 1
		if brit_lost:
			num5 += 1

	return {"giscard": a3, "mitterrand": a0, "marchais": a2, "chirac": num5}


static func _uk_scores(w: WorldState) -> Dictionary:
	if w == null:
		return {"left": 0, "right": 0, "prediction_bonus": 0}
	var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
	var ussr: EmpireData = w.empires[1] if w.empires.size() > 1 else null
	var left := 0
	var right := 0
	# num16（右派）：ModifyButtonScript.cs:630-667
	var hungary := _country(w, 4)
	if hungary != null and hungary.government == 2:
		right += 1
	var poland := _country(w, 2)
	if poland != null and poland.has_tag("亲苏"):
		right += 1
	var spain := _country(w, 86)
	if spain != null and spain.government == 2:
		right += 1
	var italy := _country(w, 85)
	if italy != null and italy.government == 2:
		right += 1
	var war5 := w.wars[5] if w.wars.size() > 5 else null
	if war5 != null and war5.is_going:
		right += 1
	var iran := _country(w, 8)
	if iran != null and iran.government == 3:
		right += 1
	if iran != null and iran.sub_government == 3:
		right += 2
	if usa != null and ussr != null and usa.power > ussr.power:
		right += 1
	var egypt := _country(w, 30)
	if egypt != null and egypt.sub_government == 20:
		right += 1
	# num15（左派）：ModifyButtonScript.cs:668-706
	var greece := _country(w, 45)
	if greece != null and greece.government == 2:
		left += 1
	var turkey := _country(w, 84)
	if turkey != null and turkey.government == 2:
		left += 1
	if poland != null and poland.government == 2:
		left += 1
	if hungary != null and hungary.government == 1:
		left += 1
	var c166 := _country(w, 166)
	if c166 != null and c166.parts.size() > 0 and c166.parts[0]:
		left += 2
	if poland != null and poland.puppet_of == 7:
		left -= 1
	if hungary != null and hungary.puppet_of == 7:
		left -= 1
	if war5 != null and war5.is_going:
		left -= 1
	if ussr != null and usa != null and ussr.power >= usa.power:
		left += 1
	if usa != null and usa.current_leader == 0:
		left -= 1
	# num17（ModifyButtonScript.cs:708-749）
	var prediction_bonus := 0
	if usa != null and usa.current_leader == 1:
		prediction_bonus += 1
	if (poland == null or poland.puppet_of != 7) and (hungary == null or hungary.puppet_of != 7) \
			and (war5 == null or not war5.is_going):
		prediction_bonus += 1
	var num18 := 0
	for idx in [21, 85, 86, 87]:
		var c := _country(w, idx)
		if c != null and (c.government == 2 or w.is_socialism(c, true)):
			num18 += 1
	for idx in [85, 86, 87]:
		var c := _country(w, idx)
		if c != null and w.is_authoritarian(c):
			num18 += 1
	if num18 > 1:
		prediction_bonus += 1
	return {"left": left, "right": right, "prediction_bonus": prediction_bonus}


static func _oil_numbers(w: WorldState) -> Dictionary:
	var d: Array[int] = w.数值表 if w != null else []
	var price := float(_raw(d, 143))
	if price <= 0.0:
		price = 12.0
	var domestic := price
	if _mod_active(w, 58) and not _mod_active(w, 16) and _raw(d, 153) <= 0:
		domestic -= 15.0
	for idx in [14, 8, 35, 40, 30, 83, 52]:
		var c := _country(w, idx)
		if c != null and c.has_tag("亲中"):
			domestic -= 1.0
	domestic = maxf(domestic, 10.0)
	# OilEat（权威值 w.oil_eat 由 _apply_modifier51_oil 按 ModifiesInfuence.cs:2362-2420 每双周更新；
	# 旧档/未结算时按 GameStartScript.cs:824-828 基础公式兜底，注意原版乘的是 data[5] 生活水平，不是人口）。
	var industry := float(_raw(d, WorldState.I_INDUSTRY))
	var agriculture := float(_raw(d, WorldState.I_AGRICULTURE))
	var services := float(_raw(d, WorldState.I_SERVICES))
	var army := float(_raw(d, WorldState.I_ARMY))
	var living := float(_raw(d, WorldState.I_LIVING))
	var oil_eat := w.oil_eat if (w != null and w.oil_eat > 0.0) else 0.0
	if oil_eat <= 0.0:
		oil_eat = industry * 0.4
		if industry >= 500.0:
			oil_eat += (industry - 499.0) * 0.4
		if industry >= 750.0:
			oil_eat += (industry - 749.0) * 0.4
		if agriculture >= 250.0:
			oil_eat += (agriculture - 249.0) * 0.35
		if agriculture >= 500.0:
			oil_eat += (agriculture - 499.0) * 0.35
		if agriculture >= 750.0:
			oil_eat += (agriculture - 749.0) * 0.35
		if services >= 500.0:
			oil_eat += (services - 499.0) * 0.34
		if services >= 750.0:
			oil_eat += (services - 749.0) * 0.34
		oil_eat += (1000.0 if army >= 2000.0 else army * 0.5)
		oil_eat += living * 0.05
	var oil_prod := w.oil_prod if w != null else 0.0  # 开局 GameStartScript.cs:90 置 850；事件可改写
	var num12 := 0.0
	if oil_eat - oil_prod > 0.0:
		num12 = domestic * 7.7 * (oil_eat - oil_prod) / 10000.0
	else:
		num12 = price * 7.7 * (oil_eat - oil_prod) / 10000.0
	var budget_delta := num12 / 10.0 * -1.0
	var budget_color := "lime" if budget_delta > 0.0 else "#DC143C"
	var budget_sign := "+" if budget_delta > 0.0 else ""
	# num13/num14（ModifyButtonScript.cs:563-584，C# 整数除法）
	var p := _raw(d, 143)
	var num13 := 0
	var num14 := 0
	if p - 50 > 0:
		@warning_ignore("integer_division")
		var t := (p - 10) / 3
		num13 -= t
		num14 += t
	elif p - 20 > 0 and p - 50 <= 0:
		@warning_ignore("integer_division")
		var t2 := (p - 10) / 3
		num13 += t2
		num14 += t2
	elif w != null and w.date != null and w.date.year < 1980:
		@warning_ignore("integer_division")
		var t3 := (p - 10) / 2
		num13 += t3
		num14 -= t3
	else:
		num13 += p - 10
		num14 -= (p - 10) * 2
	var sov_delta := float(num14) / 10.0
	var usa_delta := float(num13) / 10.0
	return {
		"price": price,
		"domestic_price": domestic,
		"prod": oil_prod,
		"eat": oil_eat,
		"budget_delta": budget_delta,
		"color": budget_color,
		"sign": budget_sign,
		"soviet_influence_delta": sov_delta,
		"usa_influence_delta": usa_delta,
		"soviet_sign": "+" if num14 > 0 else "",
		"usa_sign": "+" if num13 > 0 else "",
	}


static func _subsidy_target_name(w: WorldState) -> String:
	if w == null:
		return "苏联"
	var player := w.get_player_country()
	if player != null and player.has_tag("ovd"):
		var ussr := _country(w, 7)
		if ussr != null:
			return ussr.chinese_name if ussr.chinese_name != "" else ussr.name
		return "苏联"
	var usa := _country(w, 51)
	if usa != null:
		return usa.chinese_name if usa.chinese_name != "" else usa.name
	return "美国"


## 去掉 .0 尾数（原版 float.ToString() 风格）
static func _num(v: float) -> String:
	if absf(v - roundf(v)) < 0.001:
		return "%d" % int(roundf(v))
	return "%0.1f" % v
