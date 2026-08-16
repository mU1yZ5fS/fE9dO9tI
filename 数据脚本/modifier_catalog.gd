class_name ModifierCatalog
extends RefCounted

## 从 res://资产/数据/修正/mod_XX.tres 加载修正图标；
## 名称/效果文案以 Unity 原作 ModifyButtonScript.cs + old_modify_text_ru.txt /
## old_modify_opis_ru.txt（language==0 中文分支）为唯一基准。
## 运行时激活状态仍看 WorldState.modifiers；本类负责定义与展示资源。

const MOD_DIR := "res://资产/数据/修正/"

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
	28: "保守派+1，极左派力量+1，思想自由化-0.2，腐败-0.2，特工网络+0.2",
	29: "极左派、改革派、自由派-1，同时力量-1，服务业+0.2，工业+0.2，生活水平+0.5",
	30: "改革派+1，改革派力量+1，国际声誉-0.2，预算+0.5，与美国关系+0.5",
	31: "自由派+1，自由派力量+1，腐败-0.2，寡头力量-0.2，国际声誉-0.2，与美国关系+0.5",
	32: "极左派力量+1，其余派别力量-1，人民支持度-0.5，思想自由化-0.5，军队力量+0.2，特工网络+0.2",
	33: "军力-0.5，人民支持度+0.2，生活水平+0.2，工业-0.2，服务业+0.2",
	34: "预算-0.5，农业+0.7，生活水平-0.5，服务业+0.5，凝聚力+0.2",
	35: "预算-0.5，生活水平+0.5，工业+0.5，凝聚力+0.2",
	36: "科研点数+5，与苏联关系+0.5，美国影响+0.5",
	37: "生活水平+0.5，服务业+0.2，腐败-0.2，思想自由化+0.5",
	38: "党内支持度+0.5，贫困度+0.1，民族情绪+0.1",
	39: "与美国关系不会降到15以下，美国影响力-0.5，与苏联关系-0.5，储备金+0.5",
	40: "工业无法提升至15以上，民族主义+0.5，凝聚力+0.5，军力无法提升至200以上，农业与服务业+0.2，腐败-0.5，党内支持度-0.5，极左派不会有补充人员",
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
	if id == 63:
		var w: WorldState = GameManager.world
		if w != null and w.completed_event_ids.has("event_687"):
			return "“民族文化”复兴"
	if NAME_ZH.has(id):
		return NAME_ZH[id]
	var def := get_def(id)
	if def != null and def.name_zh != "":
		return def.name_zh
	return "修正 #%d" % id


static func effect_zh(id: int, w: WorldState = null) -> String:
	if w == null:
		w = GameManager.world
	match id:
		1:
			return _iraq_palestine_status(w)
		13:
			return _effect_13(w)
		47:
			return _effect_integration(w, true)
		48:
			return _effect_integration(w, false)
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
	var w: WorldState = GameManager.world
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
	var n := _tag_count(w, "贸易同盟")  # 原版 allcountries[i].dota
	var cost := float(n) * 0.1
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
	# 原版“事件结算分”由意大利事件链累计；Godot 未移植该事件链，
	# 结算分与当前分都读 data[172..182] 的当前值（world_factory 已初始化）。
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
	# LeaderAsset/MoneyLevel/ServeRMB 在原版 ModifyButtonScript.cs:1329 是独立字段，
	# 本工程尚未建模（event_304/094 等均已注释跳过），不能拿 power 冒充资产规模。
	return "此处记录了我国最高领导人的概况\n姓名：%s\n政治立场：%s\n资产规模：未建模（原版 LeaderAsset）\n公众形象：未建模\n社会声望：未建模\n任职年限：%d年" % [
		leader.name_display, party_label, leader.years_in_power,
	]


static func _effect_money(_w: WorldState) -> String:
	# Godot 无 MoneyLevel/LeaderAsset（event_094 注释已声明跳过），按 0 级显示。
	var level := 0
	var support_cost := 0.0
	var industry_cost := 0.0
	var living_cost := 0.0
	return "生财有道等级：%d级\n个人资产规模+%d\n人民支持度-%s\n思想自由化+%s\n人民生活水平-%s\n三大产业-%s\n腐败+%s" % [
		level, level, _num(support_cost), _num(support_cost),
		_num(living_cost), _num(industry_cost), _num(support_cost),
	]


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
	# OilEat（GameStartScript.cs:824-828）
	var industry := float(_raw(d, WorldState.I_INDUSTRY))
	var agriculture := float(_raw(d, WorldState.I_AGRICULTURE))
	var services := float(_raw(d, WorldState.I_SERVICES))
	var army := float(_raw(d, WorldState.I_ARMY))
	var population := float(_raw(d, WorldState.I_POPULATION))
	var oil_eat := industry * 0.4
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
	oil_eat += population * 0.05
	var oil_prod := 0.0  # OilProd 未建模（原版默认 0，只有极少数事件增加）
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
