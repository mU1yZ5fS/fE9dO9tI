extends Node

## 临时场景脚本：运行项目时生成 map_data.res 后自动退出。

func _ready() -> void:
	print("MapBuilder: 开始生成 map_data.res ...")
	var md := MapBuilder.build()
	if md != null:
		print("MapBuilder: 完成，regions=%d countries=%d" % [md.region_order.size(), md.countries.size()])
	else:
		printerr("MapBuilder: 生成失败")
	get_tree().quit()
