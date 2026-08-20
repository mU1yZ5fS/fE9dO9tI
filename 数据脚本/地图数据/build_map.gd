extends SceneTree

## 命令行工具：生成地图运行时资源。
## 用法：
##   godot --headless --path . --script res://数据脚本/地图数据/build_map.gd

func _init() -> void:
	print("MapBuilder: 开始生成 map_data.res ...")
	var md := MapBuilder.build()
	if md != null:
		print("MapBuilder: 完成，regions=%d countries=%d" % [md.region_order.size(), md.countries.size()])
	else:
		printerr("MapBuilder: 生成失败")
	quit()
