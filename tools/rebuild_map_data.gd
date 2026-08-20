extends SceneTree

## 工具脚本：重建 res://资产/地图/generated/map_data.res。
## 用法（项目根目录）：
##   Godot_v4.7-stable_mono_win64.exe --headless --path . -s res://tools/rebuild_map_data.gd
## 地图 JSON（map_regions/map_countries/map_actors/...）改动后必须重建本资源，
## 否则 MapService 优先加载旧 generated 资源，JSON 改动不会生效。

func _initialize() -> void:
	var md := MapBuilder.build()
	if md != null:
		print("MapBuilder: OK regions=%d countries=%d" % [md.region_order.size(), md.countries.size()])
		quit(0)
	else:
		push_error("MapBuilder: 构建失败")
		quit(1)
