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


## 从预备池抽一人实例。existing_party_slots 为在世政客的 party_index() 列表。
## 成功时从 reserve 移除模板并返回 make_instance()；失败返回 null。
static func pick_replacement(
	reserve: Array[PoliticianData],
	current_year: int,
	existing_party_slots: Array[int],
) -> PoliticianData:
	if reserve.is_empty():
		push_warning("PoliticianPool: 预备池为空")
		return null

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

	var candidates: Array[PoliticianData] = []
	for pd in reserve:
		if pd == null:
			continue
		if pd.entry_year <= current_year:
			candidates.append(pd)
	if candidates.is_empty():
		push_warning("PoliticianPool: 当前年份 %d 无可用候选人" % current_year)
		return null

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
