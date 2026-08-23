extends SceneTree

func _init() -> void:
	var ev_res := load("res://场景/事件界面/events/event_389_globalism_collapse.tres")
	if ev_res == null:
		print("FAIL: event load null")
		quit(1)
		return
	var ev: EventDef = ev_res
	var script := load("res://数据脚本/事件效果/event_389_globalism_collapse.gd")
	var inst: EventScriptBase = script.new()
	var opt: EventOption = ev.options[0]
	print("initial: ", opt.text)
	inst._disable(opt, "巧妇难为无米之炊，我们手头得有15支特工网络才能干活......")
	print("disabled_text: ", opt.disabled_text)
	print("after disable text: ", opt.text)
	inst._enable(opt, ev.options[0].text)
	print("after enable text: ", opt.text)
	quit(0)
