class_name PoliticianPool
extends RefCounted

## 跨系统注入（GameManager 设置）。
static var current_world: WorldState = null

const INITIAL_DIR := "res://数据脚本/政治家池/初始/"
const RESERVE_DIR := "res://数据脚本/政治家池/预备/"

## 随机生成新政治家的中文姓名池（避免与历史人物池重复）。
const RANDOM_SURNAMES := [
	"李", "王", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴",
	"徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗",
	"梁", "宋", "郑", "谢", "韩", "唐", "冯", "于", "董", "萧",
	"程", "曹", "袁", "邓", "许", "傅", "沈", "曾", "彭", "吕",
	"苏", "卢", "蒋", "蔡", "贾", "丁", "魏", "薛", "叶", "阎",
	"余", "潘", "杜", "戴", "夏", "钟", "汪", "田", "任", "姜",
	"范", "方", "石", "姚", "谭", "廖", "邹", "熊", "金", "陆",
	"郝", "孔", "白", "崔", "康", "毛", "邱", "秦", "江", "史",
	"顾", "侯", "邵", "孟", "龙", "万", "段", "钱", "汤", "尹",
	"黎", "易", "常", "武", "乔", "贺", "赖", "龚", "文", "欧",
]
const RANDOM_GIVEN_NAMES := [
	"建国", "建军", "志强", "国栋", "永刚", "春生", "国庆", "学军",
	"卫东", "红军", "向东", "立新", "文革", "跃进", "援朝", "抗美",
	"红卫", "忠", "华", "明", "伟", "勇", "军", "杰", "涛", "斌",
	"强", "磊", "洋", "艳", "敏", "静", "丽", "娟", "芳", "秀英",
	"桂英", "玉兰", "秀兰", "桂芳", "丽华", "建华", "国华", "新华",
	"志华", "学文", "德明", "永明", "光明", "胜利", "和平", "卫平",
	"国平", "志平", "文军", "武军", "海涛", "江涛", "洪涛", "林",
	"森", "松", "柏", "楠", "桦", "梅", "兰", "竹", "菊",
]

## 各派系 traits[0] 取值（faction → trait_personality）。
const FACTION_PERSONALITY := [0, 20, 1, 2, 3]

## 合法 traits 池（对应 WorldFactory.TRAIT_LABELS_ZH 的取值）。
## 出身/身份池（第二栏）：34 托派移入本槽（原版改版 GeneratePolitic identity 表），
## 27 科学家不进池 —— 由 1/50 彩蛋单独刷出，43 特异人士仅历史人物专用。
const BACKGROUND_POOL := [21, 22, 23, 24, 25, 26, 28, 34]
## 作风池（第三栏）。
const ALIGNMENT_POOL := [4, 5, 6, 7, 29, 30, 39, 40, 41, 42]
## 特质池（第四栏）：不含 19 病弱（只随年龄刷出）与 34 托派（已移入身份槽）。
const SPECIAL_POOL := [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 31, 32, 33, 35, 36, 37, 38]

## 随机生成永不使用的特殊姓名（史实要人，即便不在政治家池中也不该被随机人顶替）。
const SPECIAL_BANNED_NAMES := [
	"毛泽东", "周恩来", "朱德", "刘少奇", "任弼时", "林彪", "彭德怀", "刘伯承",
	"陈毅", "贺龙", "聂荣臻", "徐向前", "林伯渠", "董必武", "康生", "陈伯达",
	"邓小平", "陈云", "华国锋", "叶剑英", "李先念", "汪东兴", "江青", "张春桥",
	"姚文元", "王洪文", "纪登奎", "吴德", "陈锡联", "苏振华", "罗瑞卿", "杨得志",
	"胡耀邦", "赵紫阳", "万里", "习仲勋", "薄一波", "李鹏", "江泽民", "胡锦涛",
	"温家宝", "习近平", "李克强", "粟裕", "许世友", "杨尚昆",
]


static func load_initial() -> Array[PoliticianData]:
	return _load_dir(INITIAL_DIR, true)


static func load_reserve() -> Array[PoliticianData]:
	return _load_dir(RESERVE_DIR, false)


static func _load_dir(dir_path: String, sort_by_name: bool) -> Array[PoliticianData]:
	var result: Array[PoliticianData] = []
	var files := ResourceLoader.list_directory(dir_path)
	if sort_by_name:
		files.sort()
	for file_name in files:
		if not file_name.ends_with(".tres"):
			continue
		var path := dir_path + file_name
		var res := ResourceLoader.load(path)
		if res is PoliticianData:
			result.append(res)
		else:
			push_warning("PoliticianPool: %s 不是 PoliticianData" % path)
	return result


## 点名补员：按姓名固定抽取预备池模板（如舵手逝世后固定补毛远新）。
## 成功时从 reserve 移除并返回实例；该人已入场/未到年份/池中无此人时返回 null，
## 调用方应回退到 pick_replacement 的常规规则。
static func pick_named(
	reserve: Array[PoliticianData],
	name: String,
	current_year: int,
	existing_names: Dictionary,
) -> PoliticianData:
	for pd in reserve:
		if pd == null or pd.name_display != name:
			continue
		if pd.entry_year > current_year or existing_names.has(pd.name_display):
			return null
		reserve.erase(pd)
		return pd.make_instance()
	return null


## 从预备池抽一人实例；若池不足/无可用候选则随机生成新政治家。
## existing_party_slots 为在世政客的 party_index() 列表。
## 成功时从 reserve 移除模板并返回实例；随机生成不消耗池。
static func pick_replacement(
	reserve: Array[PoliticianData],
	current_year: int,
	existing_party_slots: Array[int],
) -> PoliticianData:
	var faction_count := {}
	for f in existing_party_slots:
		faction_count[f] = faction_count.get(f, 0) + 1
	# 保证 0..4 都有键，便于找最少派系
	for f_id in range(5):
		if not faction_count.has(f_id):
			faction_count[f_id] = 0

	var min_count := 999
	var underrepresented: Array[int] = []
	for f_id in faction_count:
		var c: int = faction_count[f_id]
		if c < min_count:
			min_count = c
			underrepresented = [f_id]
		elif c == min_count:
			underrepresented.append(f_id)

	# 防重名：事件可能已把预备池里的历史人物（如陈永贵）写入政坛，
	# 若预备池还留有同名模板，死亡补员时会再拉一个同名者。
	var existing_names := {}
	if current_world != null:
		for p in current_world.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p) or p.name_display == "":
				continue
			existing_names[p.name_display] = true

	# ── 事件241“全都要”后续人物：先于普通预备池补入 ──
	# 原版 GameState.BalancePolitic -> GeneratePolitic：result0 依次补孙健/吴桂贤，
	# result1 依次补孙健/吴桂贤/王秀珍/马天水。
	var wave := _try_event241_spawn(current_year, existing_names)
	if wave != null:
		return wave

	# ── 9.9 动态特殊人物：池子为空/无候选时作为历史人物生成 ──
	var special := _try_random_special_spawn(current_year, existing_names)
	if special != null:
		return special

	# 池不足：直接随机生成（名称/特质/无肖像）。
	if reserve.is_empty():
		return generate_random_politician(current_year, faction_count, existing_names)

	var candidates: Array[PoliticianData] = []
	for pd in reserve:
		if pd == null:
			continue
		if pd.entry_year <= current_year and not existing_names.has(pd.name_display):
			candidates.append(pd)
	if candidates.is_empty():
		push_warning("PoliticianPool: 当前年份 %d 无可用且不重名的候选人，改为随机生成" % current_year)
		return generate_random_politician(current_year, faction_count, existing_names)

	candidates.sort_custom(func(a: PoliticianData, b: PoliticianData) -> bool:
		return a.pool_priority > b.pool_priority
	)

	for pd in candidates:
		if pd.party_index() in underrepresented:
			reserve.erase(pd)
			return pd.make_instance()

	var picked := candidates[0]
	reserve.erase(picked)
	return picked.make_instance()


# ============================================================================
# 原版 GeneratePolitic 特殊历史人物生成（GameState.cs 6500-7070）
# ============================================================================

## 原版 Event241 结果后补入的四人顺序表。
static func _event241_defs() -> Array[Dictionary]:
	return [
		{"name": "孙健", "first": 30, "last": 50, "personality": 20, "background": 24, "alignment": 5, "special": 9, "birth": 1936, "power": 500},
		{"name": "吴桂贤", "first": 11, "last": 67, "personality": 0, "background": 24, "alignment": 5, "special": 11, "birth": 1938, "power": 500},
		{"name": "王秀珍", "first": 3, "last": 52, "personality": 0, "background": 24, "alignment": 6, "special": 16, "birth": 1935, "power": 500},
		{"name": "马天水", "first": 31, "last": 53, "personality": 0, "background": 21, "alignment": 5, "special": 8, "birth": 1911, "power": 500},
	]

## 9.9 随机特殊历史人物表（原版 GeneratePolitic 的 num13 分支；不含已由预备池负责的人）。
static func _random_special_defs() -> Array[Dictionary]:
	return [
		{"name": "钱学森", "first": 51, "last": 75, "personality": 0, "background": 27, "alignment": 7, "special": 13, "birth": 1911, "power": 500},
		{"name": "曾培洪", "first": 52, "last": 76, "personality": 1, "background": 27, "alignment": 7, "special": 11, "birth": 1905, "power": 500},
		{"name": "谢静宜", "first": 36, "last": 77, "personality": 0, "background": 26, "alignment": 42, "special": 38, "birth": 1935, "power": 500, "requires_wenge_pair": true},
		{"name": "孙玉国", "first": 30, "last": 78, "personality": 0, "background": 25, "alignment": 4, "special": 32, "birth": 1941, "power": 500, "requires_wenge_pair": true},
		{"name": "宋平", "first": 37, "last": 33, "personality": 1, "background": 21, "alignment": 5, "special": 31, "birth": 1917, "power": 500},
		{"name": "任仲夷", "first": 55, "last": 81, "personality": 2, "background": 21, "alignment": 6, "special": 11, "birth": 1914, "power": 500},
		{"name": "吴敬琏", "first": 11, "last": 83, "personality": 3, "background": 26, "alignment": 5, "special": 11, "birth": 1930, "power": 500},
		{"name": "厉以宁", "first": 57, "last": 84, "personality": 3, "background": 26, "alignment": 6, "special": 11, "birth": 1930, "power": 500},
		{"name": "乌兰夫", "first": 58, "last": 85, "personality": 1, "background": 21, "alignment": 41, "special": 9, "birth": 1906, "power": 500},
	]


static func _try_event241_spawn(current_year: int, existing_names: Dictionary) -> PoliticianData:
	if current_world == null:
		return null
	if not current_world.event_done_num(241):
		return null
	var result := current_world.result_of_event_num(241)
	if result >= 2:
		return null
	var defs := _event241_defs()
	# 原版：result0 只补孙健、吴桂贤；result1 补满四人
	var limit := 2 if result == 0 else 4
	for i in limit:
		var d: Dictionary = defs[i]
		var pd := _make_named_politician(d, current_year, existing_names)
		if pd != null:
			return pd
	return null


static func _try_random_special_spawn(current_year: int, existing_names: Dictionary) -> PoliticianData:
	if current_world == null:
		return null
	# 原版 10%*1/12 命中分支；这里复刻一次随机判定，避免每空必刷特殊人物。
	var rng: RandomNumberGenerator = current_world.ensure_rng()
	if rng.randi_range(0, 9) >= 3:
		return null
	var defs := _random_special_defs()
	var idx := rng.randi_range(0, defs.size() - 1)
	if idx >= defs.size():
		return null
	var d: Dictionary = defs[idx]
	# 谢静宜/孙玉国需 resultOfEvents[25]==2 且 resultOfEvents[26]==2
	if d.has("requires_wenge_pair") and bool(d["requires_wenge_pair"]):
		if current_world.result_of_event_num(25) != 2 or current_world.result_of_event_num(26) != 2:
			return null
	return _make_named_politician(d, current_year, existing_names)


static func _make_named_politician(
	d: Dictionary,
	current_year: int,
	existing_names: Dictionary,
) -> PoliticianData:
	var name: String = d["name"]
	var first: int = d["first"]
	var last: int = d["last"]
	if existing_names.has(name):
		return null
	if PoliticianSystem.has_politician(name, first, last):
		return null
	var pd := PoliticianData.new()
	pd.is_historical = true
	pd.entry_year = 1976
	pd.exit_year = 9999
	pd.faction = -1
	pd.wanted_position = 3
	pd.pool_priority = 60
	PoliticianSystem.apply_historical_profile(
		pd,
		name,
		first,
		last,
		int(d["personality"]),
		int(d["background"]),
		int(d["alignment"]),
		int(d["special"]),
		clampi(current_year - int(d["birth"]), 30, 99),
		int(d.get("power", 500)),
		800
	)
	existing_names[name] = true
	return pd


## 池子耗尽时的兜底：随机生成一位新政治家（名称、特质、无肖像）。
## 特质生成逐条对齐原版改版 GeneratePolitic（用户提供的 identity/style/other 三段
## do-while 拒绝式重抽），拒绝上限仅为防死锁兜底，正常情况下必在数抽内收敛。
static func generate_random_politician(
	current_year: int,
	faction_count: Dictionary,
	existing_names: Dictionary,
) -> PoliticianData:
	var rng: RandomNumberGenerator
	if current_world != null:
		rng = current_world.ensure_rng()
	else:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	# 选当前人数最少的派系作为新人生成方向
	var min_count := 999
	var underrepresented: Array[int] = []
	for f_id in range(5):
		var c: int = faction_count.get(f_id, 0)
		if c < min_count:
			min_count = c
			underrepresented = [f_id]
		elif c == min_count:
			underrepresented.append(f_id)
	var faction_id := underrepresented[rng.randi_range(0, underrepresented.size() - 1)]

	var pd := PoliticianData.new()
	pd.name_display = _random_name(rng, existing_names)
	pd.is_historical = false
	pd.entry_year = current_year
	pd.exit_year = 9999
	pd.faction = faction_id
	pd.trait_personality = FACTION_PERSONALITY[faction_id]

	# ── 特质三连卷（身份/作风/特质）──
	var traits := roll_trait_set(rng, pd.trait_personality)
	pd.trait_background = traits["background"]
	pd.trait_alignment = traits["alignment"]
	pd.trait_special = traits["special"]

	# ── 年龄：群众领袖/学生小将 40-59，其余 50-79（Random.Range 上界开区间）──
	if pd.trait_background == GameConstants.PoliticianBackground.MASS_LEADER \
			or pd.trait_background == GameConstants.PoliticianBackground.STUDENT_REBEL:
		pd.age = rng.randi_range(40, 59)
	else:
		pd.age = rng.randi_range(50, 79)

	# ── 兵源不足时的强征特质（原版 GeneratePolitic 尾段 data[57]<500）──
	if current_world != null and current_world.size() > WorldState.I_MANPOWER \
			and _dv(current_world, WorldState.I_MANPOWER) < 500:
		if rng.randi_range(0, 49) % 6 == 0:
			pd.trait_special = GameConstants.PoliticianSpecial.ADVISER
		elif rng.randi_range(0, 49) % 6 == 0:
			pd.trait_special = GameConstants.PoliticianSpecial.ARROGANT

	pd.power = rng.randi_range(100, 600)
	pd.loyalty = rng.randi_range(300, 800)
	pd.portrait = null
	return pd


## 特质三连卷（公共入口）：身份 →（1/50 科学家彩蛋）→ 作风 → 特质。
## 所有随机生成的政治家（含事件补员兜底）都必须经过此卷轴。
static func roll_trait_set(rng: RandomNumberGenerator, personality: int) -> Dictionary:
	var background: int = _roll_background(rng, personality)
	if rng.randi_range(0, 49) == 5:
		background = GameConstants.PoliticianBackground.SCIENTIST  # 1/50 刷出科学家
	var alignment: int = GameConstants.PoliticianAlignment.TECH  # 科学家的作风必定为重视技术
	if background != GameConstants.PoliticianBackground.SCIENTIST:
		alignment = _roll_alignment(rng, personality, background)
	var special := _roll_special(rng, personality, alignment, background)
	return {"background": background, "alignment": alignment, "special": special}


## 身份拒绝条件（改版 GeneratePolitic identity do-while）：
##   群众领袖/学生小将 → 仅极左/保守派，且仅红色政体；
##   工农劳模 → 仅极左/保守/温和派，且仅红色政体；
##   野心家 → 极左派不刷；托派 → 仅第四国际（托线）在线时刷。
static func _roll_background(rng: RandomNumberGenerator, personality: int) -> int:
	var socialist_regime := _china_is_socialist()
	var fourth_intl: bool = current_world != null \
			and current_world.modifier_active(GameConstants.Modifier.FOURTH_INTERNATIONAL)
	for _attempt in 200:
		var t3: int = BACKGROUND_POOL[rng.randi_range(0, BACKGROUND_POOL.size() - 1)]
		if (t3 == GameConstants.PoliticianBackground.MASS_LEADER or t3 == GameConstants.PoliticianBackground.STUDENT_REBEL) \
				and ((personality != GameConstants.PoliticianPersonality.FAR_LEFT and personality != GameConstants.PoliticianPersonality.CONSERVATIVE) \
					or not socialist_regime):
			continue
		if t3 == GameConstants.PoliticianBackground.WORKER_MODEL \
				and (personality == GameConstants.PoliticianPersonality.REFORMIST \
					or personality == GameConstants.PoliticianPersonality.LIBERAL \
					or not socialist_regime):
			continue
		if t3 == GameConstants.PoliticianBackground.AMBITIOUS and personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			continue
		if t3 == GameConstants.PoliticianSpecial.TROTSKYITE and not fourth_intl:
			continue
		return t3
	return GameConstants.PoliticianBackground.PARTY_CADRE


## 作风拒绝条件（改版 GeneratePolitic style do-while）：
##   漫长的革命(444)结果0后不再刷墙头草；
##   踢开党委(670)结果0且文革+毛堡并存、或漫长的革命结果0后，不再刷一方诸侯；
##   政治挂帅仅自由派与（文革+毛堡并存下的）极左派可刷；
##   野心家与墙头草不兼容。
static func _roll_alignment(rng: RandomNumberGenerator, personality: int, background: int) -> int:
	var ev444_r0: bool = current_world != null and current_world.event_done_num(444) \
			and current_world.result_of_event_num(444) == 0
	var ev670_r0: bool = current_world != null and current_world.event_done_num(670) \
			and current_world.result_of_event_num(670) == 0
	var wenge_bulwark: bool = current_world != null \
			and current_world.modifier_active(GameConstants.Modifier.CULTURAL_REVOLUTION) \
			and current_world.modifier_active(GameConstants.Modifier.MAOIST_BULWARK)
	for _attempt in 200:
		var t1: int = ALIGNMENT_POOL[rng.randi_range(0, ALIGNMENT_POOL.size() - 1)]
		if ev444_r0 and t1 == GameConstants.PoliticianAlignment.FENCE_SITTER:
			continue
		if ((ev670_r0 and wenge_bulwark) or ev444_r0) and t1 == GameConstants.PoliticianAlignment.LOCAL_WARLORD:
			continue
		if (personality != GameConstants.PoliticianPersonality.FAR_LEFT or not wenge_bulwark) \
				and personality != GameConstants.PoliticianPersonality.LIBERAL \
				and t1 == GameConstants.PoliticianAlignment.POLITICS_FIRST:
			continue
		if background == GameConstants.PoliticianBackground.AMBITIOUS and t1 == GameConstants.PoliticianAlignment.FENCE_SITTER:
			continue
		return t1
	return GameConstants.PoliticianAlignment.PRAGMATIST


## 特质拒绝条件（改版 GeneratePolitic other do-while）：
##   新时代公社社员 buff 下不刷贪污；
##   军队将领/野心家不与和平兼容；宽容不与苛刻、小暴君兼容；
##   治军有方/平易近人仅军队将领可刷；人民之友仅极左/保守/温和派可刷；
##   极左派不刷投机分子；不屈不挠仅硬汉/政治挂帅可刷。
static func _roll_special(rng: RandomNumberGenerator, personality: int, alignment: int, background: int) -> int:
	var commune: bool = current_world != null and current_world.new_era_commune_member > 0
	for _attempt in 200:
		var t2: int = SPECIAL_POOL[rng.randi_range(0, SPECIAL_POOL.size() - 1)]
		if commune and t2 == GameConstants.PoliticianSpecial.CORRUPT:
			continue
		if (background == GameConstants.PoliticianBackground.MILITARY_GENERAL or background == GameConstants.PoliticianBackground.AMBITIOUS) \
				and t2 == GameConstants.PoliticianSpecial.PEACE:
			continue
		if background == GameConstants.PoliticianBackground.AMBITIOUS \
				and t2 == GameConstants.PoliticianSpecial.AFFABLE:
			continue  # 平易近人与野心家不会同时出现
		if alignment == GameConstants.PoliticianAlignment.TOLERANT \
				and (t2 == GameConstants.PoliticianSpecial.HARSH or t2 == GameConstants.PoliticianSpecial.TYRANT):
			continue
		if background != GameConstants.PoliticianBackground.MILITARY_GENERAL \
				and (t2 == GameConstants.PoliticianSpecial.MILITARY_TALENT or t2 == GameConstants.PoliticianSpecial.AFFABLE):
			continue
		if (personality == GameConstants.PoliticianPersonality.REFORMIST or personality == GameConstants.PoliticianPersonality.LIBERAL) \
				and t2 == GameConstants.PoliticianSpecial.PEOPLES_FRIEND:
			continue
		if personality == GameConstants.PoliticianPersonality.FAR_LEFT and t2 == GameConstants.PoliticianSpecial.OPPORTUNIST:
			continue
		if alignment != GameConstants.PoliticianAlignment.HARDLINER and alignment != GameConstants.PoliticianAlignment.POLITICS_FIRST \
				and t2 == GameConstants.PoliticianSpecial.INDOMITABLE:
			continue
		return t2
	return GameConstants.PoliticianSpecial.ECONOMIST


## 原版 IsSocialism(true, 1)：中国 Gosstroy==1 或 SubGosstroy==0。
static func _china_is_socialist() -> bool:
	if current_world == null:
		return false
	var china := current_world.get_player_country()
	if china == null:
		return false
	return current_world.is_socialism(china, true)


static func _dv(w: WorldState, idx: int) -> int:
	return w.get_data_by_index(idx) if w.size() > idx else 0


## 史实/特殊姓名黑名单缓存：初始池 + 预备池全部模板、事件补员与随机特殊人物、
## 以及 SPECIAL_BANNED_NAMES。随机生成永不与之撞名。
static var _banned_name_cache: Dictionary = {}

static func _banned_names() -> Dictionary:
	if not _banned_name_cache.is_empty():
		return _banned_name_cache
	var banned := {}
	for pd in load_initial():
		if pd != null and pd.name_display != "":
			banned[pd.name_display] = true
	for pd in load_reserve():
		if pd != null and pd.name_display != "":
			banned[pd.name_display] = true
	for d in _event241_defs():
		banned[d["name"]] = true
	for d in _random_special_defs():
		banned[d["name"]] = true
	for n in SPECIAL_BANNED_NAMES:
		banned[n] = true
	_banned_name_cache = banned
	return banned


static func _random_name(rng: RandomNumberGenerator, existing_names: Dictionary) -> String:
	var forbidden := _banned_names()
	for _attempt in 100:
		var surname: String = RANDOM_SURNAMES[rng.randi_range(0, RANDOM_SURNAMES.size() - 1)]
		var given: String = RANDOM_GIVEN_NAMES[rng.randi_range(0, RANDOM_GIVEN_NAMES.size() - 1)]
		var name: String = surname + given
		if not forbidden.has(name) and not existing_names.has(name):
			existing_names[name] = true
			return name
	var fallback := "同志" + str(rng.randi_range(1000, 9999))
	while forbidden.has(fallback) or existing_names.has(fallback):
		fallback = "同志" + str(rng.randi_range(1000, 9999))
	existing_names[fallback] = true
	return fallback
