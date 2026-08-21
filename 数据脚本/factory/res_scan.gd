class_name ResScan
extends RefCounted

## 在【编辑器】与【导出包】里都能正确枚举 res:// 目录下的资源文件。
##
## 为什么需要它：导出时 Godot 会把 .tres/.tscn 转成二进制、把 .png/.ogg 等
## 导入型资源重映射，DirAccess.get_next() 因此返回 "mod_18.tres.remap"、
## "song.ogg.remap"（或旧式 ".import"）而非原始文件名。若直接用
## fname.ends_with(".tres") 过滤，导出后一个都匹配不到 → 目录扫描全空。
## 依据本地文档 gdd_0147《Import process》：用 FileAccess/文件名访问导入资源
## "在编辑器可用，导出后必坏"，必须交给 ResourceLoader 按逻辑路径加载。
##
## 用法：
##   for path in ResScan.list_files("res://资产/数据/修正/", [".tres"]):
##       var res := load(path)   # load() 会自动解析 .remap，无需关心真实二进制名
##
## 返回的是【可直接 load() 的逻辑路径】（已剥离 .remap/.import 后缀）。


## 剥离导出重映射后缀，得到可被 load() 的逻辑文件名。
## "mod_18.tres.remap" -> "mod_18.tres"；"18_0.png.import" -> "18_0.png"；
## 无后缀时原样返回（编辑器场景）。
static func normalize_name(fname: String) -> String:
	if fname.ends_with(".remap") or fname.ends_with(".import"):
		return fname.get_basename()  # 仅去掉最后一段扩展名
	return fname


## 列出目录下匹配任一扩展名（大小写不敏感）的资源逻辑路径。
## exts 形如 [".tres"] 或 [".ogg", ".mp3", ".wav"]，需带点号。
static func list_files(dir_path: String, exts: PackedStringArray) -> PackedStringArray:
	var out := PackedStringArray()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("ResScan：无法打开目录 %s" % dir_path)
		return out
	var seen := {}  # 防止同一逻辑文件被重复登记
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir():
			var logical := normalize_name(fname)
			var lower := logical.to_lower()
			for e in exts:
				if lower.ends_with(e.to_lower()):
					var full := dir_path.path_join(logical)
					if not seen.has(full):
						seen[full] = true
						out.append(full)
					break
		fname = dir.get_next()
	dir.list_dir_end()
	out.sort()  # 稳定顺序，避免平台/导出差异导致加载次序漂移
	return out
