extends Control
## 启动加载屏 —— 学习 HOI4:进主菜单前轮播插画 + 进度条。
## 期间等待 GameManager 完成大地图解码/GPU 上传(其后台线程在 autoload _ready
## 即启动,早于本屏,故那次上传卡顿被藏在这里),并线程预热首个游戏场景(外交)。
## 布局在 启动加载.tscn,本脚本只做逻辑。

const CONFIG_PATH := "res://资产/数据/启动加载配置.tres"
const MAIN_MENU_UID := "uid://bydan4iqthbaa"
const DIPLOMACY_PATH := "res://场景/外交界面/外交.tscn"

# 进度权重:地图 60% + 预热资源 35% + 收尾 5%
const W_MAP := 0.60
const W_ASSETS := 0.35
const W_TAIL := 0.05

@onready var _bg: TextureRect = $背景图
@onready var _tip: Label = $提示语
@onready var _bar: ProgressBar = $进度条

var _config: LoadingScreenConfig
var _img_order: Array[int] = []
var _img_cursor := 0
var _img_timer := 0.0
var _tip_cursor := 0
var _tip_timer := 0.0
var _elapsed := 0.0

var _map_ready := false
var _warm_paths: Array[String] = [DIPLOMACY_PATH]
var _warm_refs: Array = []          # 持有已加载资源,防止被资源缓存回收
var _warm_taken: Dictionary = {}    # 已 load_threaded_get 过的路径,避免重复取回
var _finished := false


func _ready() -> void:
	_config = load(CONFIG_PATH) as LoadingScreenConfig
	if _config == null:
		_config = LoadingScreenConfig.new()   # 容错:无配置也能跑
	_bar.min_value = 0.0
	_bar.max_value = 100.0
	_bar.value = 0.0

	_setup_carousel()
	_setup_tips()

	# 地图:已就绪则直接标记,否则等信号(失败路径也会 emit,不会永久卡)
	if GameManager and GameManager.is_map_data_preloaded:
		_map_ready = true
	elif GameManager:
		GameManager.map_data_preloaded.connect(_on_map_ready, CONNECT_ONE_SHOT)
	else:
		_map_ready = true

	# 线程预热首个游戏场景(外交.tscn 会连带其 ~50 个依赖:UI/字体/gltf/地球.tres 等)
	for p in _warm_paths:
		ResourceLoader.load_threaded_request(p)

	# 政治家资源预热(best-effort;下一帧执行,先让加载屏首帧出画)
	call_deferred("_warm_politicians")


func _on_map_ready() -> void:
	_map_ready = true


func _warm_politicians() -> void:
	# 提前触发 new_game 会用到的政治家加载,预填资源缓存,使点「开始」时的
	# WorldFactory.create_world 内政治家加载命中缓存。PoliticianPool 是 class_name
	# 静态类,直接调用即可。持有返回值防止缓存回收。
	_warm_refs.append(PoliticianPool.load_initial())
	_warm_refs.append(PoliticianPool.load_reserve())


func _setup_carousel() -> void:
	_img_order.clear()
	for i in _config.images.size():
		_img_order.append(i)
	if _config.randomize_order:
		_img_order.shuffle()
	_img_cursor = 0
	_apply_current_image()


func _apply_current_image() -> void:
	if _config.images.is_empty():
		_bg.texture = null
		return
	var idx: int = _img_order[_img_cursor % _img_order.size()]
	_bg.texture = _config.images[idx]


func _setup_tips() -> void:
	_tip_cursor = 0
	_apply_current_tip()


func _apply_current_tip() -> void:
	if _config.tips.is_empty():
		_tip.text = ""
		return
	_tip.text = _config.tips[_tip_cursor % _config.tips.size()]


func _process(delta: float) -> void:
	_elapsed += delta
	_advance_carousel(delta)
	_advance_tips(delta)
	_update_progress(delta)
	_maybe_finish()


func _advance_carousel(delta: float) -> void:
	if _config.images.size() <= 1:
		return
	_img_timer += delta
	if _img_timer >= _config.seconds_per_image:
		_img_timer = 0.0
		_img_cursor += 1
		_apply_current_image()


func _advance_tips(delta: float) -> void:
	if _config.tips.size() <= 1:
		return
	_tip_timer += delta
	if _tip_timer >= _config.seconds_per_tip:
		_tip_timer = 0.0
		_tip_cursor += 1
		_apply_current_tip()


## 预热资源平均完成比(0~1);LOADED/FAILED 均计为完成,避免卡进度
func _asset_progress() -> float:
	if _warm_paths.is_empty():
		return 1.0
	var total := 0.0
	for p in _warm_paths:
		var pr: Array = []
		var st := ResourceLoader.load_threaded_get_status(p, pr)
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			total += 1.0
			_finalize_warm(p)
		elif st == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if pr.size() > 0:
				total += float(pr[0])
		else:
			# FAILED / INVALID:算完成(错误已由引擎打印),不卡死进度条
			total += 1.0
	return total / float(_warm_paths.size())


func _finalize_warm(path: String) -> void:
	if _warm_taken.has(path):
		return
	_warm_taken[path] = true
	var res := ResourceLoader.load_threaded_get(path)
	if res != null:
		_warm_refs.append(res)   # 持有引用,保证进主菜单/外交前不被回收
	if path == DIPLOMACY_PATH and res is PackedScene and GameManager:
		GameManager.cached_diplomacy_scene = res


func _update_progress(delta: float) -> void:
	var map_p := 1.0 if _map_ready else 0.0
	var asset_p := _asset_progress()
	var tail_p := 1.0 if (_map_ready and asset_p >= 0.999) else 0.0
	var target := (map_p * W_MAP + asset_p * W_ASSETS + tail_p * W_TAIL) * 100.0
	# 缓动逼近 + 只增不减:避免大图上传瞬间进度回跳
	var eased: float = lerpf(_bar.value, target, clampf(delta * 4.0, 0.0, 1.0))
	_bar.value = maxf(_bar.value, eased)


func _maybe_finish() -> void:
	if _finished:
		return
	var ready_all := _map_ready and _asset_progress() >= 0.999
	if ready_all and _elapsed >= _config.min_display_seconds and _bar.value >= 99.0:
		_finished = true
		print("[启动加载] 预热完成,进入主菜单")
		get_tree().change_scene_to_file(MAIN_MENU_UID)
