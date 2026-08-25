extends MainLoop

# 无头全量脚本语法检查器（-s 工具，MainLoop 模式，_process 返回 true 即退出）。
# 用法：godot --headless --path . -s res://tools/check_all_scripts.gd > check_out.txt 2>&1
# 输出：每个文件打一行 CHECK <path>；紧随其后的 Parse Error 行即归属该文件。
# 注意：本模式无 autoload，"Identifier not found: GameManager/EventEngine" 属环境噪音。

var _queue: Array[String] = []
var _started := false


func _initialize() -> void:
	for d in ["res://数据脚本/事件效果", "res://数据脚本/事件定义",
			"res://数据脚本/systems", "res://场景"]:
		_enqueue(d)


func _enqueue(dir: String) -> void:
	var da := DirAccess.open(dir)
	if da == null:
		print("ENQUEUE_FAIL ", dir)
		return
	da.list_dir_begin()
	var n := da.get_next()
	while n != "":
		var p := dir.path_join(n)
		if da.current_is_dir():
			if not n.begins_with("."):
				_enqueue(p)
		elif n.ends_with(".gd"):
			_queue.append(p)
		n = da.get_next()


func _process(_delta: float) -> bool:
	if not _started:
		_started = true
		print("CHECK_TOTAL ", _queue.size())
	while not _queue.is_empty():
		var p: String = _queue.pop_front()
		print("CHECK ", p)
		var res := ResourceLoader.load(p)
		if res == null:
			print("LOAD_NULL ", p)
	return true
