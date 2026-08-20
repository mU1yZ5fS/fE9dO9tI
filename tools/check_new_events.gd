extends SceneTree

## 工具脚本：全量扫描事件目录，验证新增事件被 EventDef 加载器识别。
## 用法：Godot --headless --path . -s res://tools/check_new_events.gd

func _initialize() -> void:
	var paths := ResScan.list_files("res://场景/事件界面/events/", [".tres"])
	var count := 0
	var found: Array[String] = []
	var errors := 0
	for p in paths:
		var res = load(p)
		if res is EventDef:
			count += 1
			var eid := (res as EventDef).event_id
			if eid == "solomon_independence" or eid == "belize_independence":
				found.append(eid)
		else:
			errors += 1
			print("非 EventDef: %s" % p)
	print("事件总数=%d 非EventDef=%d 新增=%s" % [count, errors, str(found)])
	quit(0 if found.size() == 2 and errors == 0 else 1)
