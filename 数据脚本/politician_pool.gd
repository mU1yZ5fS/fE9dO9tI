class_name PoliticianPool
extends RefCounted

const INITIAL_DIR := "res://数据脚本/政治家池/初始/"
const RESERVE_DIR := "res://数据脚本/政治家池/预备/"


static func load_initial() -> Array[PoliticianData]:
	return _load_dir(INITIAL_DIR, true)


static func load_reserve() -> Array[PoliticianData]:
	return _load_dir(RESERVE_DIR, false)


static func _load_dir(dir_path: String, sort_by_name: bool) -> Array[PoliticianData]:
	var result: Array[PoliticianData] = []
	var files := ResourceLoader.list_directory(dir_path)
	# 按文件名排序保证顺序确定（初始池用 00_/01_ 前缀控制顺序）
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


static func pick_replacement(
	reserve: Array[PoliticianData],
	current_year: int,
	existing_factions: Array[int],
) -> PoliticianData:
	if reserve.is_empty():
		push_warning("PoliticianPool: 预备池为空")
		return null

	# 统计现有派系人数
	var faction_count := {}
	for f in existing_factions:
		faction_count[f] = faction_count.get(f, 0) + 1

	# 找出人数最少的派系
	var min_count := 999
	var underrepresented: Array[int] = []
	for f_id in faction_count:
		if faction_count[f_id] < min_count:
			min_count = faction_count[f_id]
			underrepresented = [f_id]
		elif faction_count[f_id] == min_count:
			underrepresented.append(f_id)

	# 过滤符合年份条件的候选人
	var candidates: Array[PoliticianData] = []
	for pd in reserve:
		if pd.entry_year <= current_year:
			candidates.append(pd)
	if candidates.is_empty():
		push_warning("PoliticianPool: 当前年份 %d 无可用候选人" % current_year)
		return null

	# 按 pool_priority 降序
	candidates.sort_custom(func(a: PoliticianData, b: PoliticianData) -> bool:
		return a.pool_priority > b.pool_priority
	)

	# 优先选缺少派系的候选人
	for pd in candidates:
		if pd.trait_personality in underrepresented:
			reserve.erase(pd)
			return pd.make_instance()

	# 没有匹配派系的就取优先级最高的
	var picked := candidates[0]
	reserve.erase(picked)
	return picked.make_instance()
