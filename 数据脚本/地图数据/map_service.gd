class_name MapService
extends RefCounted

## 地图运行时服务。
## 从 GameManager 拆出，负责：
##   - 地图底图/JSON 预加载
##   - 运行时区域归属缓存
##   - 持久化覆盖写入 WorldState.map_owner_overrides
##   - 调色板/纹理更新
## GameManager 保留公开代理字段/方法，UI 与 WarSystem 现有调用点暂不修改。

signal map_data_preloaded
signal map_changed

## 当前全局 MapService 实例。由 GameManager._ready 注入。
## 用于 WarSystem 等 static 系统在彻底改为构造注入前的过渡入口。
static var instance: MapService = null

## 当前 WorldState。由 GameManager 在 new_game/load_game 后注入。
var world: WorldState = null

var is_map_data_preloaded: bool = false

const REGION_MAP_PATH: String = "res://资产/地图/map_color.png"
## 优先加载 MapBuilder 生成的运行时资源；未生成时回退到直接解析 JSON。
const GENERATED_MAP_DATA_PATH: String = "res://资产/地图/generated/map_data.res"
var cached_map_meta: Dictionary = {}
var cached_map_regions: Dictionary = {}
var cached_map_countries: Dictionary = {}
var cached_region_owner: Dictionary = {}
var cached_initial_owner: Dictionary = {}

## 地图数据尚未预加载完成时，事件/外交请求的领土转移先挂在这里，等预加载完成后补执行。
var _pending_map_owner_changes: Array = []

var cached_region_map_image: Image = null
var cached_owner_palette_image: Image = null
var cached_color_palette_image: Image = null

var cached_region_map_tex: ImageTexture = null
var cached_owner_palette_tex: ImageTexture = null
var cached_color_palette_tex: ImageTexture = null

var _map_preload_thread: Thread = null

## 罗曼诺夫/土耳其海峡危机（Event375）：苏联吞并土耳其欧洲部分、海峡与
## 卡尔斯-阿尔特温-阿尔达汉，叙利亚拿回哈塔伊省。
const SOVIET_TURKISH_CLAIM_REGIONS: Array[int] = [
	242, 244, 928,      # 阿尔达汉 / 阿尔特温 / 卡尔斯（东北三省）
	514, 516, 2276, 2277, 2278, # 欧洲部分与博斯普鲁斯/达达尼尔海峡
]
const HATAY_REGION_ID := 986


## 统一“国家 parts 标志 → 地图归属变更”的规则表。
## 每一条表示：当 legacy 国家的 parts[part] 为 true 时，执行对应地图合并/区域转移。
## 这样避免结算逻辑设置 parts 后，地图层漏写规则（如阿尔巴尼亚/库尔德斯坦）。
## 目前只收录“纯 parts 条件”的规则；带额外条件的（OAR、中国征服、非洲之角等）
## 仍保留在 sync_map_merges() 的显式分支中，后续可逐步收编。
const PART_MERGE_RULES := [
	# 罗曼诺夫土耳其海峡危机：苏联 parts[0] 或 parts[2]（二者任一）→ 土耳其割让海峡/东北三省
	{"legacy": 7, "part": 0, "type": "regions", "regions": SOVIET_TURKISH_CLAIM_REGIONS},
	{"legacy": 7, "part": 2, "type": "regions", "regions": SOVIET_TURKISH_CLAIM_REGIONS},
	# 土耳其 parts[3]：哈塔伊省归还叙利亚
	{"legacy": 84, "part": 3, "type": "regions", "regions": [HATAY_REGION_ID], "target_legacy": 35},
	# 马来西亚吞并文莱
	{"legacy": 49, "part": 0, "type": "merge", "sources": [111]},
	# 越南印支联邦：吞并老挝/柬埔寨
	{"legacy": 11, "part": 0, "type": "merge", "sources": [22, 23]},
	# 也门统一（双向）
	{"legacy": 24, "part": 0, "type": "merge", "sources": [25]},
	{"legacy": 25, "part": 0, "type": "merge", "sources": [24]},
	# 危地马拉统一：吞并伯利兹
	{"legacy": 149, "part": 0, "type": "merge", "sources": [142]},
	# 爱尔兰统一：吞并北爱尔兰
	{"legacy": 29, "part": 0, "type": "merge", "sources": [166]},
	# 西撒哈拉并入摩洛哥（直接按地块转移，原 merge 18->54 因 18 无初始地块无效）
	{"legacy": 54, "part": 0, "type": "regions", "regions": [54, 55, 56, 57]},
	# 魁北克独立
	{"legacy": 167, "part": 0, "type": "regions", "regions": [1250]},
	# 南墨西哥独立：墨西哥 parts[1] → 恰帕斯/瓦哈卡划给南墨西哥(168)
	{"legacy": 140, "part": 1, "type": "regions", "regions": [1272, 2101], "target_legacy": 168},
	# 库尔德斯坦独立
	{"legacy": 157, "part": 0, "type": "regions", "regions": [
		381, 382, 384, 402, 403, 979, 980, 989, 990, 1408,
		1723, 4068, 4072, 4074, 4075, 4077, 4091, 4092, 4094,
	]},
	# 库尔德斯坦“北叙-北伊联邦”：伊拉克/叙利亚库尔德区
	{"legacy": 157, "part": 2, "type": "regions", "regions": [
		381, 384, 979, 989, 1408, 1723,
	]},
	# 欧加登：索马里获胜/大索马里时，欧加登（索马里州）划给索马里
	{"legacy": 42, "part": 0, "type": "regions", "regions": [29]},
	{"legacy": 42, "part": 2, "type": "regions", "regions": [29]},
	# 阿扎尼亚独立/建国：南非地块划给阿扎尼亚(153)
	{"legacy": 153, "part": 0, "type": "regions", "regions": [
		82, 1066, 1068, 1071, 1079, 1081, 1544, 1771, 3424,
	]},
	# 加丹加独立：加丹加省划给加丹加(163)
	{"legacy": 163, "part": 0, "type": "regions", "regions": [373]},
	# 尼日利亚分裂：豪萨兰（北部）划给 164
	{"legacy": 164, "part": 0, "type": "regions", "regions": [
		475, 477, 574, 1142, 1149, 1154, 1155, 1157, 1158,
		4082, 4085, 4186, 4187,
	]},
	# 尼日利亚分裂：约鲁巴兰（西南）划给 165
	{"legacy": 165, "part": 0, "type": "regions", "regions": [
		479, 480, 483, 484, 1915, 4088, 4185, 4087,
	]},
	# 阿尔巴尼亚对南斯拉夫战争胜利
	{"legacy": 20, "part": 0, "type": "regions", "regions": [
		704, 705, 4555, 4245, 4216, 871, 814, 873,
	]},
	# 阿尔巴尼亚对希腊战争胜利（大阿尔巴尼亚/查梅尼亚）
	{"legacy": 20, "part": 1, "type": "regions", "regions": [334]},
]


## 外东北/外西北：原清朝版图、1976 年归苏联的地块（map_baker 的 qing_province 非空子集）。
## 注意：这里按 war70 约定“外东北、外西北、唐努乌梁海、阿尔泰卓尔乌梁海”收窄，
## 不能把 qing_province 元数据里所有归属苏联的历史省界全收进来，
## 否则萨哈/克拉斯诺亚尔斯克/克麦罗沃/哈卡斯/布里亚特/外贝加尔等西伯利亚地区会被整片划给中国。
## 雪耻之战（war70）胜利后归中国 710，属于“事件后回归”而非开局领土。
const QING_LOST_TERRITORY_REGIONS: Array[int] = [
	# 外东北：阿穆尔/犹太自治/哈巴罗夫斯克/滨海/萨哈林
	952, 953, 954, 955, 2244,
	# 外西北：哈萨克东南部、吉尔吉斯、塔吉克等原清代新疆辖境
	96, 97, 260, 261, 262, 263, 253, 254, 255, 304, 331, 332, 3672, 4368,
	# 唐努乌梁海与阿尔泰卓尔乌梁海
	944, 116, 1389,
]


## 北爱尔兰 26 个地区（map_regions.json，1976 年属英国 200）。
## war86“北爱尔兰冲突”中爱尔兰武装/北爱一方获胜后，划给 166 号北爱尔兰实体（gwcode 9166）。
const NORTHERN_IRELAND_REGIONS: Array[int] = [
	315, 316, 317, 321, 322, 323,
	2260, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2268, 2269,
	3940, 3941, 3942, 3943, 3944, 3945, 3946, 3947, 3948, 3949,
]


func preload_region_map() -> void:
	if cached_region_map_image != null:
		return
	# 按原分辨率加载底图，不做 GPU 上限缩放/压缩。
	_map_preload_thread = Thread.new()
	_map_preload_thread.start(_decode_region_map)


## 当生成资源缺失或比任一源 JSON 旧时返回 false（需回退 JSON 并提示重建）。
func _generated_map_is_fresh() -> bool:
	if not FileAccess.file_exists(GENERATED_MAP_DATA_PATH):
		return false
	var res_time := FileAccess.get_modified_time(GENERATED_MAP_DATA_PATH)
	for fname in ["map_regions.json", "map_countries.json", "map_actors.json", "map_neighbors.json"]:
		var src_path: String = "res://资产/地图/" + str(fname)
		if FileAccess.file_exists(src_path):
			if FileAccess.get_modified_time(src_path) > res_time:
				return false
	return true


func _decode_region_map() -> void:
	var img: Image = null

	# 1. 检查底图资源是否存在并加载为 Image
	if ResourceLoader.exists(REGION_MAP_PATH):
		var tex = ResourceLoader.load(REGION_MAP_PATH)
		if tex is Texture2D:
			img = tex.get_image()

	if img == null:
		push_error("MapService: 无法预加载地图底图 " + REGION_MAP_PATH)
		call_deferred("_on_region_map_preloaded_failed")
		return

	# 按原分辨率加载，不缩放/压缩底图。

	# 2. 优先使用 MapBuilder 生成的运行时 Resource（仅当它比源 JSON 新）
	if _generated_map_is_fresh():
		var map_data: MapData = load(GENERATED_MAP_DATA_PATH)
		if map_data != null:
			var gd_regions_dict: Dictionary = {}
			var gd_countries_dict: Dictionary = {}
			var gd_region_owner_dict: Dictionary = {}
			var gd_initial_owner_dict: Dictionary = {}

			for rid in map_data.region_order:
				var rd: RegionDef = map_data.regions[rid]
				gd_regions_dict[rid] = {
					"name": rd.name,
					"name_zh": rd.name_zh,
					"owner_1976_gwcode": rd.base_owner_gwcode,
					"is_water": rd.is_water,
					"longitude": rd.center.x,
					"latitude": rd.center.y,
				}
				gd_region_owner_dict[rid] = rd.base_owner_gwcode
				gd_initial_owner_dict[rid] = rd.base_owner_gwcode

			for gw in map_data.countries:
				var cd: CountryDef = map_data.countries[gw]
				gd_countries_dict[gw] = {
					"gwcode": cd.gwcode,
					"name_1976": cd.name_1976,
					"name_zh": cd.name_zh,
					"regions": cd.region_ids,
				}

			# 3. 初始化调色板
			const GD_PALETTE_SIZE := 256
			var gd_owner_pal_img := Image.create(GD_PALETTE_SIZE, GD_PALETTE_SIZE, false, Image.FORMAT_RGB8)
			var gd_color_pal_img := Image.create(GD_PALETTE_SIZE, GD_PALETTE_SIZE, false, Image.FORMAT_RGB8)
			gd_owner_pal_img.fill(Color.BLACK)
			for r_id in gd_region_owner_dict:
				var val: int = gd_region_owner_dict[r_id]
				var col := Color8((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF)
				if r_id > 0:
					gd_owner_pal_img.set_pixel(r_id & 0xFF, (r_id >> 8) & 0xFF, col)
			gd_color_pal_img.fill(Color(0.46, 0.46, 0.46))

			call_deferred(
				"_on_region_map_preloaded",
				img,
				map_data.meta,
				gd_regions_dict,
				gd_countries_dict,
				gd_region_owner_dict,
				gd_initial_owner_dict,
				gd_owner_pal_img,
				gd_color_pal_img
			)
			return

	# 3. 回退：直接解析 JSON（res 缺失/过期/加载失败时）
	if FileAccess.file_exists(GENERATED_MAP_DATA_PATH):
		push_warning("MapService: map_data.res 已过期或不可用，已回退 JSON；请运行 res://tools/rebuild_map_data.gd 重建")
	const META_PATH := "res://资产/地图/map_meta.json"
	const REGIONS_PATH := "res://资产/地图/map_regions.json"
	const COUNTRIES_PATH := "res://资产/地图/map_countries.json"

	var meta := _load_json_async(META_PATH)
	var regions_raw := _load_json_async(REGIONS_PATH)
	var countries_raw := _load_json_async(COUNTRIES_PATH)

	# 4. 在后台子线程洗数据（把 key 转换为 int，构建归属字典，规避主线程 CPU 瓶颈）
	var regions_dict: Dictionary = {}
	var countries_dict: Dictionary = {}
	var region_owner_dict: Dictionary = {}
	var initial_owner_dict: Dictionary = {}

	for key in regions_raw:
		var r_id := int(key)
		var owner_gw := int(regions_raw[key].get("owner_1976_gwcode", 0))
		regions_dict[r_id] = regions_raw[key]
		region_owner_dict[r_id] = owner_gw
		initial_owner_dict[r_id] = owner_gw

	for key in countries_raw:
		countries_dict[int(key)] = countries_raw[key]

	# 5. 初始化 owner_palette 和 color_palette 图像（像素级填充在子线程完成）
	const PALETTE_SIZE := 256
	var owner_pal_img := Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)
	var color_pal_img := Image.create(PALETTE_SIZE, PALETTE_SIZE, false, Image.FORMAT_RGB8)

	owner_pal_img.fill(Color.BLACK)
	for r_id in region_owner_dict:
		var val: int = region_owner_dict[r_id]
		var col := Color8((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF)
		if r_id > 0:
			owner_pal_img.set_pixel(r_id & 0xFF, (r_id >> 8) & 0xFF, col)

	color_pal_img.fill(Color(0.46, 0.46, 0.46)) # 预填 BLOC_NEUTRAL

	# 6. 传回主线程生成 GPU 纹理与缓存更新
	call_deferred(
		"_on_region_map_preloaded",
		img,
		meta,
		regions_dict,
		countries_dict,
		region_owner_dict,
		initial_owner_dict,
		owner_pal_img,
		color_pal_img
	)


func _on_region_map_preloaded(
	img: Image,
	meta: Dictionary,
	regions: Dictionary,
	countries: Dictionary,
	region_owner: Dictionary,
	initial_owner: Dictionary,
	owner_pal_img: Image,
	color_pal_img: Image
) -> void:
	if _map_preload_thread != null:
		_map_preload_thread.wait_to_finish()
		_map_preload_thread = null

	cached_region_map_image = img
	cached_map_meta = meta
	cached_map_regions = regions
	cached_map_countries = countries
	cached_region_owner = region_owner
	cached_initial_owner = initial_owner

	cached_owner_palette_image = owner_pal_img
	cached_color_palette_image = color_pal_img

	# 在主线程安全创建 GPU 纹理
	cached_region_map_tex = ImageTexture.create_from_image(cached_region_map_image)
	cached_owner_palette_tex = ImageTexture.create_from_image(cached_owner_palette_image)
	cached_color_palette_tex = ImageTexture.create_from_image(cached_color_palette_image)

	# 预加载前排队的地图归属变更（如提前触发的事件）在此补执行。
	_flush_pending_map_owner_changes()
	# 读档/继续游戏时，地图数据刚重建，需把存档中持久化的归属覆盖重新套上，
	# 否则独立后的领土会显示回初始宗主国（例如吉布提又变法国）。
	_apply_map_owner_overrides()
	sync_map_merges()

	is_map_data_preloaded = true
	map_data_preloaded.emit()
	print("MapService: 地图底图、数据加载及纹理分配全部完成")


func _on_region_map_preloaded_failed() -> void:
	if _map_preload_thread != null:
		_map_preload_thread.wait_to_finish()
		_map_preload_thread = null
	# 地图数据不可用：排队的领土变更无法落地，直接丢弃并记录，避免永远悬挂。
	if not _pending_map_owner_changes.is_empty():
		push_warning("MapService: 地图预加载失败，丢弃 %d 条待补领土变更" % _pending_map_owner_changes.size())
		_pending_map_owner_changes.clear()
	is_map_data_preloaded = true
	map_data_preloaded.emit()


func _load_json_async(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("MapService: 找不到文件 %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}


func reset_runtime_state() -> void:
	if cached_initial_owner.size() > 0:
		cached_region_owner = cached_initial_owner.duplicate()
		if cached_owner_palette_image:
			cached_owner_palette_image.fill(Color.BLACK)
			for r_id in cached_region_owner:
				var val: int = cached_region_owner[r_id]
				var col = Color8((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF)
				if r_id > 0:
					cached_owner_palette_image.set_pixel(r_id & 0xFF, (r_id >> 8) & 0xFF, col)
			if cached_owner_palette_tex:
				cached_owner_palette_tex.update(cached_owner_palette_image)
	# 读档后先回到初始归属，再把存档中记录的领土变更覆盖回去。
	_apply_map_owner_overrides()
	print("MapService: 地图归属运行时状态与调色板已重置")


## 将世界存档中的地图归属覆盖应用到当前缓存。地图归属不是 WorldState 直接序列化的，
## 所以事件/外交改地图时必须写入 world.map_owner_overrides，读档/重建缓存后靠本方法恢复。
func _apply_map_owner_overrides() -> void:
	if world == null or world.map_owner_overrides.is_empty():
		return
	if cached_region_owner.is_empty():
		return
	var changed := false
	for raw in world.map_owner_overrides:
		var r_id := int(raw)
		if cached_region_owner.has(r_id):
			cached_region_owner[r_id] = int(world.map_owner_overrides[raw])
			changed = true
	if changed:
		_update_cached_owner_palette()


## 事件/外交领土变更后同步地图归属缓存。
## 世界地图渲染每次进入场景时从 cached_region_owner 复制，因此改这里即可让下次渲染生效。
func transfer_owner(from_gwcode: int, to_gwcode: int) -> void:
	if from_gwcode <= 0 or to_gwcode <= 0:
		return
	if cached_region_owner.is_empty():
		_pending_map_owner_changes.append({"kind": "transfer", "from": from_gwcode, "to": to_gwcode})
		return
	for r_id in cached_region_owner:
		if cached_region_owner[r_id] == from_gwcode:
			cached_region_owner[r_id] = to_gwcode
			_persist_owner_override(r_id, to_gwcode)
	_update_cached_owner_palette()
	map_changed.emit()


func set_region_owner(region_ids: Array, to_gwcode: int) -> void:
	if to_gwcode <= 0:
		return
	if cached_region_owner.is_empty():
		_pending_map_owner_changes.append({"kind": "regions", "ids": region_ids.duplicate(), "to": to_gwcode})
		# 地图尚未加载也要先记录到存档覆盖，避免加载后丢失。
		for raw in region_ids:
			_persist_owner_override(int(raw), to_gwcode)
		return
	for raw in region_ids:
		var r_id := int(raw)
		if cached_region_owner.has(r_id):
			cached_region_owner[r_id] = to_gwcode
			_persist_owner_override(r_id, to_gwcode)
	_update_cached_owner_palette()
	map_changed.emit()


func _persist_owner_override(r_id: int, to_gwcode: int) -> void:
	if world != null:
		world.map_owner_overrides[r_id] = to_gwcode


## 统一把原版 CountryScript.Repaint()/MapChangesScript 的“地图合并”规则同步到 Godot 地块归属。
## 原版通过 this_number 重映射 + parts 覆盖层显示合并；Godot 无覆盖层，等价为整国地块转移。
func sync_map_merges() -> void:
	var w := world
	if w == null:
		return
	# 朝鲜统一：data.korea_result 1=北胜（南并入北），2=南胜（北并入南）
	if w.korea_result == 1:
		_merge_legacy(w, 46, 10)
	elif w.korea_result == 2:
		_merge_legacy(w, 10, 46)
	# 台湾：completedDecisions[7] 或 taiwan_status==2 -> 台湾(38)并入中国(1)
	if (w.decisions != null and w.decisions.completed.size() > 7 and w.decisions.completed[7]) or w.taiwan_status == 2:
		_merge_legacy(w, 38, 1)
	# 金马澎：台海岛屿被解放军控制 -> 金门(2917)、澎湖(3088)归中国
	if w.taiwan_islands == 1:
		set_region_owner([2917, 3088], 710)
	# 藏南：arunachal_status>=2 -> 藏南地块(43)归中国
	if w.arunachal_status >= 2:
		set_region_owner([43], 710)
	# 雪耻之战（war70）胜利：外东北/外西北原清朝版图地块归中国
	if w.get_flag("is_gkchp") or w.ind_opp or w.get_flag("IndOpp"):
		set_region_owner(QING_LOST_TERRITORY_REGIONS, 710)
	# 北爱尔兰独立：166 号 parts[0] 成立时，北爱 26 区从英国划给北爱尔兰实体。
	var c166 := w.get_country_by_legacy_index(166)
	if c166 != null and _has_part(c166, 0):
		set_region_owner(NORTHERN_IRELAND_REGIONS, c166.gwcode)
	# 蒙古：mongolia_china_route==1 -> 蒙古(9)并入中国(1)
	if w.mongolia_china_route == 1:
		_merge_legacy(w, 9, 1)
	# 中国“解放/征服”路线：任何 parts[0] 且傀儡为中国（原版战争70-75等）→ 领土并入中国
	for c in w.countries:
		if c != null and c.parts.size() > 0 and c.parts[0] and c.puppet_of == GameConstants.LegacySlot.CHINA:
			_merge_legacy(w, c.原版序号, 1)
	# 阿拉伯革命共和国联盟（OAR）：completedDecisions[20] + 30.parts[0..2]
	if w.decisions != null and w.decisions.completed.size() > 20 and w.decisions.completed[20]:
		var c30 := w.get_country_by_legacy_index(30)
		if c30 != null and _has_part(c30, 0) and _has_part(c30, 1) and _has_part(c30, 2):
			for src in [54, 55, 18, 14, 35, 13, 40]:
				_merge_legacy(w, src, 30)
	# 吉布提：Event585 未发生 -> 仍属法国(21)；若非洲之角(41.parts[1])则并入 41
	if not w.event_done_num(585):
		_merge_legacy(w, 106, 21)
	var c41 := w.get_country_by_legacy_index(41)
	if c41 != null and (_has_part(c41, 0) or _has_part(c41, 1)):
		_merge_legacy(w, 42, 41)
		_merge_legacy(w, 106, 41)
	# 统一 parts 规则表：文莱/印支/也门/危地马拉/爱尔兰/西撒/魁北克/南墨西哥/库尔德斯坦/阿尔巴尼亚等
	_apply_part_merge_rules(w)


## 按 PART_MERGE_RULES 统一执行 parts 标志对应的地图变更。
func _apply_part_merge_rules(w: WorldState) -> void:
	if w == null:
		return
	for rule in PART_MERGE_RULES:
		var legacy_idx := int(rule.get("legacy", -1))
		var part_idx := int(rule.get("part", -1))
		var c := w.get_country_by_legacy_index(legacy_idx) if legacy_idx >= 0 else null
		if c == null or not _has_part(c, part_idx):
			continue
		match String(rule.get("type", "")):
			"merge":
				for src in rule.get("sources", []):
					_merge_legacy(w, int(src), legacy_idx)
			"regions":
				var target_gw := c.gwcode
				if rule.has("target_legacy"):
					var target_c := w.get_country_by_legacy_index(int(rule["target_legacy"]))
					if target_c == null:
						continue
					target_gw = target_c.gwcode
				set_region_owner(rule.get("regions", []), target_gw)


func _merge_legacy(w: WorldState, from_idx: int, to_idx: int) -> void:
	if from_idx == to_idx:
		return
	var from_c := w.get_country_by_legacy_index(from_idx)
	var to_c := w.get_country_by_legacy_index(to_idx)
	if from_c == null or to_c == null:
		return
	if from_c.gwcode == to_c.gwcode or from_c.gwcode <= 0 or to_c.gwcode <= 0:
		return
	transfer_owner(from_c.gwcode, to_c.gwcode)


func _has_part(c: CountryData, idx: int) -> bool:
	return c != null and idx >= 0 and idx < c.parts.size() and c.parts[idx]


## 旧档兼容：在地图归属持久化功能加入前，Event585 已让吉布提独立、Event589/1035 已成立
## 非洲之角联邦，但存档没有 map_owner_overrides，读档会回到初始归属。这里按国家状态识别补写。
func migrate_legacy_map_owner_overrides() -> void:
	if world == null:
		return
	const DJIBOUTI_REGION_IDS := [366, 367, 368, 370, 376, 2032]
	const SOMALIA_REGION_IDS := [30, 31, 32, 33, 34, 35, 45, 46, 1466, 2028, 2029, 2030, 2031, 4115]
	# 台湾全部地块（map_countries.json gwcode=713）。原版 CountryScript.cs:4881：
	# completedDecisions[7] 成立时把 38 号台湾地图对象重绘为中国(1)。
	const TAIWAN_REGION_IDS := [2058, 2059, 2060, 2061, 2062, 2063, 2064, 2065, 2066,
		2067, 2068, 2069, 2070, 2071, 2072, 2073, 3088, 3320, 3331, 3332]
	# 巴斯克四省 / 加泰罗尼亚四省（map_regions.json 中 owner_1976_gwcode=230 的对应省）。
	# 原作 Event426.cs:71-72 设 allcountries[86].parts[0/1]=true，由 MapChangesScript.ShowParts
	# 切换 country_basks.png / katalonia.png 覆盖层；Godot 无覆盖层，改用归属转移 + 9000+ 虚拟国。
	const BASQUE_REGION_IDS := [625, 626, 2521, 3415]
	const CATALONIA_REGION_IDS := [629, 637, 2500, 2501]
	# 吉布提独立（Event585）：吉布提区域从法国 220 改为 522。
	var c106 := world.get_country_by_legacy_index(106)
	if c106 != null and c106.puppet_of < 0 and c106.chinese_name == "吉布提共和国":
		for r_id in DJIBOUTI_REGION_IDS:
			if not world.map_owner_overrides.has(r_id):
				world.map_owner_overrides[r_id] = 522
	# 非洲之角联邦（Event589）：索马里区域并入埃塞俄比亚 530；若 1035 已推动，吉布提也并入 530。
	var c41 := world.get_country_by_legacy_index(41)
	if c41 != null and c41.parts.size() > 0 and c41.parts[0] and c41.sub_government == GameConstants.SubGovernment.MAOIST:
		c41.gov_names[1] = "非洲之角联邦"
		for gn_key in c41.gov_names:
			c41.gov_names[gn_key] = "非洲之角联邦"
		for r_id in SOMALIA_REGION_IDS:
			if not world.map_owner_overrides.has(r_id):
				world.map_owner_overrides[r_id] = 530
		if c41.parts.size() > 1 and c41.parts[1]:
			for r_id in DJIBOUTI_REGION_IDS:
				if not world.map_owner_overrides.has(r_id):
					world.map_owner_overrides[r_id] = 530
	# 台湾解放（Event643 启动的 75 号战争胜利 → completedDecisions[7]）：台湾地块归中国 710。
	if world.decisions != null and world.decisions.completed.size() > 7 and world.decisions.completed[7]:
		for r_id in TAIWAN_REGION_IDS:
			if not world.map_owner_overrides.has(r_id):
				world.map_owner_overrides[r_id] = 710
	# 西班牙内战漩涡（Event426）：巴斯克/加泰罗尼亚 parts 标记 → 转移对应省到 9109/9110。
	var spain := world.get_country_by_legacy_index(86)
	if spain != null:
		var basque_gw := 9109
		var catalonia_gw := 9110
		var basque_c := world.get_country_by_legacy_index(109)
		var catalonia_c := world.get_country_by_legacy_index(110)
		if basque_c != null and basque_c.gwcode > 0:
			basque_gw = basque_c.gwcode
		if catalonia_c != null and catalonia_c.gwcode > 0:
			catalonia_gw = catalonia_c.gwcode
		if spain.parts.size() > 0 and spain.parts[0]:
			for r_id in BASQUE_REGION_IDS:
				if not world.map_owner_overrides.has(r_id):
					world.map_owner_overrides[r_id] = basque_gw
		if spain.parts.size() > 1 and spain.parts[1]:
			for r_id in CATALONIA_REGION_IDS:
				if not world.map_owner_overrides.has(r_id):
					world.map_owner_overrides[r_id] = catalonia_gw


func _flush_pending_map_owner_changes() -> void:
	for change in _pending_map_owner_changes:
		var kind: String = change.get("kind", "")
		if kind == "transfer":
			transfer_owner(int(change.get("from", 0)), int(change.get("to", 0)))
		elif kind == "regions":
			set_region_owner(change.get("ids", []), int(change.get("to", 0)))
	_pending_map_owner_changes.clear()


func _update_cached_owner_palette() -> void:
	if cached_owner_palette_image == null:
		return
	cached_owner_palette_image.fill(Color.BLACK)
	for r_id in cached_region_owner:
		var val: int = cached_region_owner[r_id]
		var col = Color8((val >> 16) & 0xFF, (val >> 8) & 0xFF, val & 0xFF)
		if r_id > 0:
			cached_owner_palette_image.set_pixel(r_id & 0xFF, (r_id >> 8) & 0xFF, col)
	if cached_owner_palette_tex != null:
		cached_owner_palette_tex.update(cached_owner_palette_image)
