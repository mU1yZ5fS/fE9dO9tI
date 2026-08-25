# 美国选举计分自检（极性 + 编译 + 干预选项归属）
# 运行：
#   Godot控制台.exe --headless --path . --script res://tools/data_parity/test_us_election.gd
extends SceneTree


func _initialize() -> void:
	var wf: Object = load("res://数据脚本/factory/world_factory.gd")
	var MC: Object = load("res://数据脚本/systems/modifier_catalog.gd")
	var bad := 0

	# ── 1) _us_party_scores 极性：1976 开局手算 rep=2 / dem=3 ──
	var ws: Resource = wf.create_world(710, 2)
	var s: Dictionary = MC._us_party_scores(ws)
	print("1976 开局计分: 共和(rep)=", s.rep, " 民主(dem)=", s.dem)
	if int(s.rep) != 2 or int(s.dem) != 3:
		push_error("FAIL: 期望 rep=2 dem=3，实际 %s/%s" % [s.rep, s.dem])
		bad += 1

	# 抬升美国国力后第1条应转为 dem+1（usa>ussr 属民主党条目）
	ws.empires[0].power = 400
	s = MC._us_party_scores(ws)
	if int(s.rep) != 1 or int(s.dem) != 4:
		push_error("FAIL: 翻转检查期望 1/4，实际 %s/%s" % [s.rep, s.dem])
		bad += 1

	# ── 2) Event402 干预选项归属 ──
	# 构造势均力敌局面（卡特在任、无里根+7）：
	#   usa.power=400 → 美>苏/美>中 两条 num2+2；中国加东盟 num2+1；
	#   移除五国 nato（开局覆盖默认全有）→ 每国转 num+1。
	# 计分：num = 1(政体)+5(nato缺)-2(sev/ovd) = 4；num2 = 2(power)+1(asean) = 3
	#   无干预   → Bush(2)（4>3）
	#   opt=1    → 民主+1 → 4<=4 → 蒙代尔(3)
	#   opt=2    → 共和+1 → 5>3  → Bush(2)
	var ev_script: Script = load("res://数据脚本/事件效果/event_402_donkey_elephant_act2.gd")
	var expect := {-1: 2, 1: 3, 2: 2}
	for opt in [-1, 1, 2]:
		var w: Resource = wf.create_world(710, 2)
		w.date.year = 1984
		w.empires[0].current_leader = 1     # 卡特在任
		w.empires[0].power = 400
		w.get_country_by_legacy_index(1).tags["asean"] = true
		for cid in [85, 92, 17, 21, 84]:
			w.get_country_by_legacy_index(cid).tags.erase("nato")
		var ev: Object = ev_script.new()
		ev.exec_context = {"world": w}
		ev.execute({"option_index": opt})
		var got: int = int(w.empires[0].current_leader)
		print("opt=%s → current_leader=%d（期望 %s）" % [opt, got, expect[opt]])
		if got != int(expect[opt]):
			push_error("FAIL: opt=%s 结果 %d ≠ 期望 %s" % [opt, got, expect[opt]])
			bad += 1

	if bad == 0:
		print("US_ELECTION_SCORE_OK")
	else:
		print("US_ELECTION_SCORE_FAIL errors=%d" % bad)
	quit(bad)
