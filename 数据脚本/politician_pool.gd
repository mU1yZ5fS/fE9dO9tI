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
const BACKGROUND_POOL := [21, 22, 23, 24, 25, 26, 27, 28, 43]
const ALIGNMENT_POOL := [4, 5, 6, 7, 29, 30, 39, 40, 41, 42]
const SPECIAL_POOL := [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 31, 32, 33, 34, 35, 36, 37, 38]


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


## 池子耗尽时的兜底：随机生成一位新政治家（名称、特质、无肖像）。
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
	pd.trait_background = BACKGROUND_POOL[rng.randi_range(0, BACKGROUND_POOL.size() - 1)]
	pd.trait_alignment = ALIGNMENT_POOL[rng.randi_range(0, ALIGNMENT_POOL.size() - 1)]
	pd.trait_special = SPECIAL_POOL[rng.randi_range(0, SPECIAL_POOL.size() - 1)]
	pd.age = rng.randi_range(35, 62)
	pd.power = rng.randi_range(100, 600)
	pd.loyalty = rng.randi_range(300, 800)
	pd.portrait = null
	return pd


static func _random_name(rng: RandomNumberGenerator, existing_names: Dictionary) -> String:
	for _attempt in 100:
		var surname: String = RANDOM_SURNAMES[rng.randi_range(0, RANDOM_SURNAMES.size() - 1)]
		var given: String = RANDOM_GIVEN_NAMES[rng.randi_range(0, RANDOM_GIVEN_NAMES.size() - 1)]
		var name: String = surname + given
		if not existing_names.has(name):
			existing_names[name] = true
			return name
	var fallback := "同志" + str(rng.randi_range(1000, 9999))
	while existing_names.has(fallback):
		fallback = "同志" + str(rng.randi_range(1000, 9999))
	existing_names[fallback] = true
	return fallback
