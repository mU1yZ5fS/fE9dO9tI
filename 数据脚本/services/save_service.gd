class_name SaveService
extends RefCounted

## 存档文件读写服务。
## 从 GameManager 拆出，只负责 WorldState 序列化、槽位文件与 meta 摘要。
## 读档后的迁移/运行时恢复仍由 GameManager 编排（涉及地图、事件、政治家等跨系统初始化）。


## 保存 WorldState 到指定路径。event_engine 可选，传入时先把运行时 pending/链队列导出到 world。
func save_game(world: WorldState, path: String, event_engine: Node = null) -> bool:
	if world == null:
		push_error("SaveService: 无活动游戏")
		return false
	# 写入前同步显示视图，避免读档后经济视图过期
	world.sync_economy()
	world.sync_rng_state()  # 镜像 RNG 流位置，保证读档精确续流
	if event_engine != null and event_engine.has_method("export_runtime_to_world"):
		event_engine.export_runtime_to_world(world)
	var err := ResourceSaver.save(world, path)
	if err != OK:
		push_error("SaveService: 保存失败 %d → %s" % [err, path])
		return false
	# 部分环境下 user:// 相对路径需 globalize 才能立刻 FileAccess 可见
	if not FileAccess.file_exists(path):
		var abs_path := ProjectSettings.globalize_path(path)
		push_warning("SaveService: FileAccess 暂未见 %s (abs=%s exists=%s)" % [
			path, abs_path, FileAccess.file_exists(abs_path)
		])
	print("SaveService: 已保存 %s size_hint ok" % path)
	return true


## 槽位保存：WorldState.res + meta.json 摘要。
## iron_override: -1=沿用 world.is_ironman；0/1=仅写 meta，不改运行时 world。
func save_to_slot(slot: int, world: WorldState, event_engine: Node = null, iron_override: int = -1) -> bool:
	if world == null:
		push_error("SaveService: 无活动游戏")
		return false
	if slot < 0:
		return false
	SaveCatalog.ensure_dir()
	var path := SaveCatalog.slot_path(slot)
	if not save_game(world, path, event_engine):
		return false
	if not FileAccess.file_exists(path):
		return false
	var meta := SaveCatalog.meta_from_world(world)
	if iron_override == 0:
		meta["is_ironman"] = false
	elif iron_override == 1:
		meta["is_ironman"] = true
	SaveCatalog.write_slot_meta(slot, meta)
	return true


func delete_save_slot(slot: int) -> bool:
	return SaveCatalog.delete_slot(slot)
