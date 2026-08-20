class_name PolicyService
extends RefCounted

## 政策/派系规则服务。
## 从 GameManager 拆出，包含政策检查、政策切换、派系禁用/解禁、毛状态、派系力量。
## 跨系统调用通过 gm.* 显式依赖，不再直接访问 GameManager 全局。

const W = preload("res://数据脚本/world_state.gd")

@warning_ignore_start("integer_division")

## 一党制(data.party_system≤7)下：政策目标值 → 允许的政治路线 data.political_line 集合。
## 对齐 Doctrine_button_script.cs 75-214。空数组 = 该项不施加路线限制。
const POLICY_LINE_REQ_ONEPARTY := {
	10: [0, 1], 11: [0, 1], 12: [1, 2], 13: [2, 3], 14: [3, 4], 15: [4],  # 经济 data.econ_system（原版 :42 id11=极左/保守0,1）
	6: [0], 7: [1, 2], 8: [3], 9: [4],                                # 党政 data.party_system
	16: [0, 1, 2, 3], 17: [0, 1, 2, 3, 4], 18: [2, 3, 4], 19: [3, 4],  # 人权 data.press_policy（16/17 按原版中文块 :85-94：16=data.political_line!=4、17=data.political_line<=4；旧值 [0,1]/[0,1,2,3] 系误抄俄语块，2026-08-14 主控亲验修正）
	20: [0, 1, 2, 3], 21: [2, 3], 22: [3, 4], 23: [4],                # 国家体制 data.territory_policy
	24: [0], 25: [0, 1], 26: [1, 2, 3], 27: [2, 3, 4], 28: [3, 4], 29: [4],  # 宗教 data.religion_policy
	30: [0], 31: [0, 1, 2], 32: [2, 3], 33: [3, 4],                   # 军事 data.military_doctrine
}

## 多党(data.party_system>7)下：政策目标值 → 允许的显示等级集合。
## 经济类(10-15)看 data.econ_display(34-37)，其余看 data.political_display(38-41)，均需联盟席位>66%。
## 对齐 Doctrine_button_script.cs 233-453。
const POLICY_DISPLAY_REQ_MULTIPARTY := {
	10: [34], 11: [34], 12: [34, 35], 13: [35, 36], 14: [36, 37], 15: [37],  # 经济 → data.econ_display（原版 :204 id11=社会主义34）
	6: [38, 39], 7: [39, 40], 8: [40, 41], 9: [41],                        # 党政 → data.political_display
	16: [38, 39], 17: [39, 40], 18: [40], 19: [41],                        # 人权 → data.political_display
	20: [38, 39], 21: [39, 40, 41], 22: [40, 41], 23: [41],                # 国家体制 → data.political_display
	24: [38], 25: [38, 39], 26: [39, 40], 27: [40, 41], 28: [39, 41], 29: [38, 39],  # 宗教 → data.political_display
	30: [38], 31: [38, 39], 32: [39, 40, 41], 33: [40, 41],                # 军事 → data.military_doctrine（原版 :232-233 一党制多党制共用 data.political_display? 此处按既有移植）
}

var gm: Node = null
var world: WorldState = null

func bind(gm_node: Node, ws: WorldState) -> void:
	gm = gm_node
	world = ws

func check_policy_change(category_idx: int, target_val: int) -> Dictionary:
	var res := {
		"can": false, "same": false,
		"budget_ok": false, "budget_need": 0,
		"party_ok": false, "party_need": 0,
		"leading_ok": false, "leading_text": "",
		"mao_ok": false,
	}
	if world == null:
		return res
	var d := world
	if category_idx < 0 or category_idx >= d.size() or d.size() <= W.I_STABILITY:
		return res
	var current_val: int = d.get_data_by_index(category_idx)
	if current_val == target_val:
		res.same = true
		res.can = true
		return res
	var diff := absi(target_val - current_val)
	res.budget_need = diff * 50
	res.budget_ok = (d.budget + d.reserve) >= res.budget_need
	res.party_need = diff * 300
	res.party_ok = d.party_support >= res.party_need
	var lead := _policy_leading_ok(category_idx, target_val, d)
	res.leading_ok = lead["ok"]
	res.leading_text = lead["text"]
	# 原版 uslovie_bool[3]：毛在世(data.stability<100)时恒为 false，不可切任何政策
	# （Doctrine_button_script.cs:446-455；number_uslovie==4 需 4 条件全满足，见 :894）
	res.mao_ok = is_mao_dead()
	# 原作 :456-461 modifies[6] 覆盖：mod6 激活且目标∈{9,14,15,22,23,28,29}
	# 或 (19 且 resultOfEvents[444]!=0) 时 uslovie_bool[3] 恒 false（"毛主席正看着你！"）。
	# 事件 444 未启用 → completed_event_ids.get(444,-1) 恒 -1（原版初始态）→ !=0 恒真。
	if gm._mod_active(world, 6) and (target_val in [9, 14, 15, 22, 23, 28, 29] \
			or (target_val == 19 and world.completed_event_ids.get(444, -1) != 0)):
		res.mao_ok = false
	res.can = res.budget_ok and res.party_ok and res.leading_ok and res.mao_ok
	return res


## uslovie[2]：派系/路线领导条件。返回 {ok, text}。
func _policy_leading_ok(_category_idx: int, target_val: int, d: WorldState) -> Dictionary:
	var party_sys: int = d.party_system
	if party_sys <= 7:
		# neutral_leading：满足现状者席位 ≥ 所有派系 → 中间派主导，任何政策都不可变
		if _satisfied_leads(d):
			return {"ok": false, "text": " 满 意 现 状 者 失 去 领 导"}
		var line: int = d.political_line
		var text: String = LEADING_TEXT_ONEPARTY.get(target_val, "")
		if text == "":
			return {"ok": true, "text": "无执政路线限制"}  # 未列出（如 OGAS 经济 11 在多态另处理）
		var req: Array = POLICY_LINE_REQ_ONEPARTY.get(target_val, [])
		var ok: bool = line in req
		# 经济 10/15：额外要求 data.party_system!=7（非人民民主专政）
		if target_val == 10 or target_val == 15:
			ok = ok and party_sys != 7
		# 宗教 29 特例：data.political_line==4 或 (威权 data.ideology==0 且 高民族主义 data.war_support≥700)
		elif target_val == 29:
			ok = ok or (d.ideology == 0 and d.war_support >= 700)
		return {"ok": ok, "text": text}
	else:
		# 多党：路线显示等级 + 联盟席位 > 66%
		var text: String = LEADING_TEXT_MULTIPARTY.get(target_val, "")
		if text == "":
			return {"ok": true, "text": "无执政路线限制"}
		text += MULTIPARTY_SEAT_SUFFIX
		var req2: Array = POLICY_DISPLAY_REQ_MULTIPARTY.get(target_val, [])
		var seat_ok := _multiparty_seat_majority(d)
		# 经济类(10-15)看 data.econ_display，其余看 data.political_display
		var econ_cat := target_val >= 10 and target_val <= 15
		var disp: int = d.econ_display if econ_cat else d.political_display
		var disp_ok: bool = disp in req2
		if target_val == 29:  # 政教协定多党特例：另需 data.econ_display∈{36,37}（原版 :402）
			disp_ok = disp_ok and (d.econ_display == 36 or d.econ_display == 37)
		return {"ok": disp_ok and seat_ok, "text": text}


## neutral_leading：满足现状者 data.satisfied ≥ 每个派系 support（原版 Doctrine 60）
func _satisfied_leads(d: WorldState) -> bool:
	if world == null:
		return false
	var sat: int = d.satisfied
	for f in world.factions:
		if sat < maxi(f.support, 0):
			return false
	return true


## 原版 summa_3_2>66：保守派+盟友(启用,非保守)席位 占 (全派系+满足现状者) 的比例
func _multiparty_seat_majority(d: WorldState) -> bool:
	if world == null:
		return false
	var allied := 0
	var total := 0
	for i in world.factions.size():
		var f: FactionData = world.factions[i]
		total += maxi(f.support, 0)
		if i == FactionData.CONSERVATIVE:
			allied += maxi(f.support, 0)
		elif f.is_ally and f.is_enabled:
			allied += maxi(f.support, 0)
	total += maxi(d.satisfied, 0)  # 原版 summa 含 data.satisfied
	if total <= 0:
		return false
	# 原版整数除法：player_numbeer*100/summa > 66（Doctrine_button_script.cs:192/:630）
	@warning_ignore("integer_division")
	return allied * 100 / total > 66


## 一党制 uslovie_text[2] 逐字文案（原版 Doctrine_button_script.cs:37-173，基于 data.political_line 派系，含原版空格/|排版）。
## 与 POLICY_LINE_REQ_ONEPARTY 判定一一对应；10/15 的“并非新民主主义制度”尾注见 _policy_leading_ok。
const LEADING_TEXT_ONEPARTY := {
	10: " 极 左 派/ 保 守 派 领 导\n 并 非 \" 新 民 主 主 义 制 度\"", 11: " 极 左 派/ 保 守 派 领 导",
	12: " 保 守 派/ 温 和 派 领 导", 13: " 温 和 派/ 改 革 派 领 导", 14: " 改 革 派/ 自 由 派 领 导",
	15: " 自 由 派 领 导\n 并 非 \" 新 民 主 主 义 制 度\"",
	6: " 极 左 派 领 导", 7: " 保 守 派/ 温 和 派 领 导", 8: " 改 革 派 领 导", 9: " 自 由 派 领 导",
	16: " 非 自 由 派 领 导", 17: " 任 意 派 领 导", 18: " 温 和 派/ 改 革 派/ 自 由 派 领 导", 19: " 改 革 派/ 自 由 派 领 导",
	20: " 极 左 派/ 保 守 派/ 温 和 派/ 改 革 派| 领 导", 21: " 温 和 派/ 改 革 派 领 导", 22: " 改 革 派/ 自 由 派 领 导", 23: " 自 由 派 领 导",
	24: " 极 左 派 领 导", 25: " 极 左 派/ 保 守 派 领 导", 26: " 保 守 派/ 温 和 派/ 改 革 派 领 导",
	27: " 温 和 派/ 改 革 派/ 自 由 派 领 导", 28: " 改 革 派/ 自 由 派 领 导", 29: " 自 由 派 领 导/| 威 权 主 义 且 民 族 主 义 高 涨",
	30: " 极 左 派 领 导", 31: " 极 左 派/ 保 守 派/ 温 和 派 领 导", 32: " 温 和 派/ 改 革 派 领 导", 33: " 改 革 派/ 自 由 派 领 导",
}

## 多党 uslovie_text[2] 逐字文案（原版 :195-443，基于 data.econ_display/data.political_display 路线，含原版空格排版）。
## 统一尾注“我 方 党 派 联 盟 …”见 MULTIPARTY_SEAT_SUFFIX，此处仅存路线前缀。
const LEADING_TEXT_MULTIPARTY := {
	10: " 党 派 路 线 ： 社 会 主 义  且", 11: " 党 派 路 线 ： 社 会 主 义  且", 12: " 党 派 路 线 ： 社 会 主 义/ 改 良 主 义  且",
	13: " 党 派 路 线 ： 改 良 主 义/ 实 用 主 义  且", 14: " 党 派 路 线 ： 实 用 主 义/ 市 场 主 义  且", 15: " 党 派 路 线 ： 市 场 主 义  且",
	6: " 党 派 路 线 ： 威 权/ 强 硬  且", 7: " 党 派 路 线 ： 强 硬/ 温 和  且", 8: " 党 派 路 线 ： 温 和/ 民 主  且", 9: " 党 派 路 线 ： 民 主  且",
	16: " 党 派 路 线 ： 威 权/ 强 硬  且", 17: " 党 派 路 线 ： 强 硬/ 温 和  且", 18: " 党 派 路 线 ： 温 和  且", 19: " 党 派 路 线 ： 民 主  且",
	20: " 党 派 路 线 ： 威 权/ 强 硬  且", 21: " 党 派 路 线 ： 强 硬/ 温 和/ 民 主  且", 22: " 党 派 路 线 ： 温 和/ 民 主  且", 23: " 党 派 路 线 ： 民 主  且",
	24: " 党 派 路 线 ： 威 权  且", 25: " 党 派 路 线 ： 威 权/ 强 硬  且", 26: " 党 派 路 线 ： 强 硬/ 温 和  且",
	27: " 党 派 路 线 ： 温 和/ 民 主  且", 28: " 党 派 路 线 ： 强 硬/ 民 主  且", 29: " 党 派 路 线 ： 威 权/ 强 硬 ，| 实 用 主 义/ 市 场 主 义  且",
	30: " 党 派 路 线 ： 威 权/ 强 硬  且", 31: " 党 派 路 线 ： 威 权/ 民 主  且", 32: " 党 派 路 线 ： 温 和/ 民 主  且", 33: " 党 派 路 线 ： 强 硬/ 温 和/ 民 主  且",
}
const MULTIPARTY_SEAT_SUFFIX := " 我 方 党 派 联 盟 在 全 国 人 大 中 保 有 66% 以 上 席 位"


func change_policy(category_idx: int, target_val: int) -> bool:
	if world == null:
		return false
	var chk := check_policy_change(category_idx, target_val)
	if chk["same"]:
		return true
	if not chk["can"]:
		return false
	var d := world
	var current_val: int = d.get_data_by_index(category_idx)
	var diff := absi(target_val - current_val)
	# 原版 Doctrine_button_script.cs:896-907：经济由计划转向市场（12→13+）时的特殊块。
	if category_idx == W.I_ECON_SYSTEM and current_val <= 12 and target_val >= 13:
		if d.reform_stage < 2:
			d.reform_stage = 2
		elif d.albania_break < 1:
			# 原版 allcountries[20] = 阿尔巴尼亚（Country_en 第21行）；Torg/proprc → 标签
			var albania := world.get_country_by_legacy_index(20)
			if albania:
				albania.set_tag("对华贸易", false)
				albania.set_tag("亲中", false)
	# 原版 :909-983：党政切换的派系重排（此处 current_val 仍旧值，与原版读旧 data.party_system 一致）
	if category_idx == W.I_PARTY_SYSTEM and world.factions.size() >= 5:
		if current_val >= 6 and current_val <= 7 and target_val >= 8 and target_val <= 9:
			# 一党 → 多党：解除异见联盟、未启用派系启用、异见席位逐次折半并入保守派
			var transferred := 0
			for i in world.factions.size():
				var f: FactionData = world.factions[i]
				if f.is_ally and i != FactionData.CONSERVATIVE:
					f.is_ally = false
				if f.ideology < 0:
					f.ideology = 0
				if f.is_enabled and i != FactionData.CONSERVATIVE and f.support > 0:
					transferred += f.support / 2
					f.support -= f.support / 2
					f.ideology -= f.support / 2
					transferred += f.support / 4
					f.support -= f.support / 4
					f.ideology -= f.support / 4
				elif not f.is_enabled:
					f.is_enabled = true
				d.party_ban_count = 0
			world.factions[FactionData.CONSERVATIVE].support += transferred
			world.factions[FactionData.CONSERVATIVE].ideology += transferred
			d.election_timer = 0  # 原版 data.election_timer（选举计时，Godot 未映射语义，保留槽位归零）
		elif current_val >= 8 and current_val <= 9 and target_val >= 6 and target_val <= 7:
			# 多党 → 一党：解除异见联盟、按基础意识形态复位席位
			for i in world.factions.size():
				var f2: FactionData = world.factions[i]
				if f2.is_ally and i != FactionData.CONSERVATIVE:
					f2.is_ally = false
				if not f2.is_enabled:
					f2.is_enabled = true
					if f2.support <= 5:
						var rv := randi_range(0, 9)
						f2.support = 10 + rv
						f2.ideology = f2.support
				else:
					f2.support = f2.ideology
			world.factions[FactionData.CONSERVATIVE].is_enabled = true
			world.factions[FactionData.MODERATE].is_enabled = true
			world.factions[FactionData.REFORMIST].is_enabled = true
			world.factions[0].support = 0
			world.factions[FactionData.CONSERVATIVE].support = 50
			world.factions[FactionData.MODERATE].support = 50
			world.factions[FactionData.REFORMIST].support = 500
			world.factions[FactionData.LIBERAL].support = 400
			if d.econ_display == 37:
				world.factions[FactionData.REFORMIST].support = 200
				world.factions[FactionData.LIBERAL].support = 700
			d.party_ban_count = 0
	d.budget -= diff * 50
	if category_idx == W.I_ECON_SYSTEM:
		d.living_standard -= diff * 50
	var delta := target_val - current_val
	# 意识形态漂移
	if category_idx == W.I_PARTY_SYSTEM or category_idx == W.I_ECON_SYSTEM:
		d.diplomatic_reputation -= delta * (60 if category_idx == W.I_PARTY_SYSTEM else 40)
	else:
		d.diplomatic_reputation -= delta * 20
	# 开放度变化
	if category_idx == W.I_ECON_SYSTEM:
		d.econ_openness += delta * 100
	elif category_idx == W.I_PARTY_SYSTEM:
		d.political_openness += delta * 100
	else:
		d.political_openness += delta * 50
	# 党支持与异见
	if d.party_system < 8:
		d.party_support -= diff * 30
		d.thought_freedom += diff * 10
	else:
		d.thought_freedom += diff * 20
	# 改革方向累计（原版 Doctrine_button_script.cs:1195-1198，军事学说 51 不计入；用旧值算 delta）
	if category_idx != W.I_MIL_DOCTRINE:
		d.reform_momentum += delta * 15
	# 政策切换对政治家忠诚的位移（原版 :988-1116，按 traits[0] 分派；须在覆写旧值前）
	_apply_policy_loyalty_shift(category_idx, target_val, delta)
	d.set_data_by_index(category_idx, target_val)
	# 原版 :1154-1185 切换后立即重算 data.econ_display/data.political_display 显示等级；:1199-1382 立即重算政体（hooray）
	gm._update_displays(d)
	gm._political_system_recalc(d, world)
	# TimeScript.cs:3786-3790：进入 data.party_system > 7 后，autosave<=0 时立即进入一次选举。
	# 年度 10 月 1 日选举仍由 _check_scheduled_events 单独处理。
	if category_idx == W.I_PARTY_SYSTEM and current_val <= 7 and target_val > 7:
		world.set_flag("election_due", true)
	# FAC-SAT：满足现状者仅在切政策成功时增长一次（对齐原版 Doctrine_button.OnMouseDown 1229/1253）
	gm._apply_policy_satisfied_growth(d, world)
	gm._notify_stats()
	return true


## 政策切换对全体政治家忠诚的位移。逐类照抄 Doctrine_button_script.cs:986-1117。
## delta = target - 旧值（升高为正）；原版 (data.get_data_by_index(X)-number)=-delta、(number-data.get_data_by_index(X))=+delta。
## 每类分三桶（按 trait_personality = 原版 traits[0]）：
##   a_set 恒 -delta*K（偏好更低值）；t_set 走门槛（target>=门槛 -delta，否则 +delta）；
##   其余（原版 else 分支，含自由派 3 与变体值）恒 +delta*K。
## 关键差异：改革(2) 在 政党15 属门槛桶、经济16/舆论17 属 else(+)、领土18/宗教50/军事51 属 a_set(-)。
func _apply_policy_loyalty_shift(category_idx: int, target_val: int, delta: int) -> void:
	if world == null or delta == 0:
		return
	# 每类：门槛 threshold、系数 k、a_set(恒-)、t_set(走门槛)。原版行号见注释。
	var threshold := 0
	var k := 50
	var a_set: Array[int] = [0]
	var t_set: Array[int] = [1]
	match category_idx:
		W.I_PARTY_SYSTEM:  # :986-1007
			threshold = 7
			k = 150
			t_set = [1, 2]
		W.I_ECON_SYSTEM:  # :1008-1029
			threshold = 13
			k = 150
		W.I_PRESS_POLICY:  # :1030-1051
			threshold = 18
		W.I_TERRITORY:  # :1052-1073
			threshold = 21
			a_set = [0, 2]
		W.I_RELIGION:  # :1074-1095
			threshold = 27
			a_set = [0, 2]
		W.I_MIL_DOCTRINE:  # :1096-1117
			threshold = 32
			a_set = [0, 2]
		_:
			return
	for p in world.politicians:
		if p == null:
			continue
		var t: int = p.trait_personality
		var shift := 0
		if t in a_set:
			shift = -delta * k
		elif t in t_set:
			shift = (-delta * k) if target_val >= threshold else (delta * k)
		else:  # 原版 else：自由派(3) 及变体值
			shift = delta * k
		p.loyalty += shift


func set_birth_policy(policy: int) -> void:
	if world == null:
		return
	var d := world
	# 原版 ChildScript：按钮 this_number=1/2/3，data.birth_policy 值域 1=一胎 2=二胎 3=无限制（开局=2）。
	# UI 槽位传 0/1/2，此处 +1 对齐原版（ChildScript.cs:12-19）。
	var target := policy + 1
	# data.people_support -= 50*(old-new)；data.budget -= 5*(4-new)
	if target < 1 or target > 3 or W.I_BIRTH_POLICY >= d.size():
		return
	var old_policy: int = d.birth_policy
	if old_policy == target:
		return
	d.people_support -= 50 * (old_policy - target)
	d.budget -= 5 * (4 - target)
	d.birth_policy = target
	gm._notify_stats()


func set_faction_ally(faction_idx: int, want_ally: bool) -> void:
	## 忠实移植原版 Party_ally_script.OnMouseDown()：
	## 一党制(≤7)：免费 toggle；多党(>7)：仅 data.party_system==8 时可结盟，按占比扣预算/特工等。
	if world == null or faction_idx >= world.factions.size():
		return
	var f: FactionData = world.factions[faction_idx]
	var d := world
	var total := 0
	for x in world.factions:
		total += maxi(x.support, 0)
	@warning_ignore("integer_division")
	var pct := int(float(f.support * 100) / float(total)) if total > 0 else 0

	if d.party_system > 7:
		# 原版：已结盟再点不会取消（OnMouseDown 多党分支只处理未结盟）
		if not f.is_ally and d.party_system == 8 and f.is_enabled \
				and d.agents >= pct and d.budget >= pct:
			f.is_ally = true
			if pct > 10:
				d.party_support -= pct * 5
				d.people_support -= pct
				d.diplomatic_reputation -= 10
				d.budget -= pct
				d.agents -= pct
				d.thought_freedom -= pct
			else:
				d.party_support -= 50
				d.people_support -= 10
				d.diplomatic_reputation -= 10
				d.budget -= 10
				d.agents -= 10
				d.thought_freedom -= 10
				if world.factions.size() > FactionData.CONSERVATIVE:
					world.factions[FactionData.CONSERVATIVE].support += f.support
				f.support = 0
	else:
		f.is_ally = want_ally if f.is_enabled else false
		# 点击支持后立即按 ideology 同步一次 support，避免派系界面要等下一个日块才看到变化。
		gm._sync_faction_numbers_from_ideology(d, world)
	# 原版每次点击后都按 party_number 重算执政路线 data.political_line
	gm._update_political_line(d, world)
	gm._notify_stats()


## 原版 Party_zapret 保护规则：领袖 traits[0]=0→保护0；=20→保护1；1..3→保护 traits[0]+1
func _faction_protected_by_leader(faction_idx: int) -> bool:
	if world == null or world.leader == null:
		return false
	var t: int = world.leader.trait_personality
	if t == 0:
		return faction_idx == 0
	if t == 20:
		return faction_idx == FactionData.CONSERVATIVE
	if t >= 1 and t <= 3:
		return faction_idx == t + 1
	return false


## 原版 Party_zapret 能否禁止判定
func _can_ban_faction(faction_idx: int) -> bool:
	if world == null or faction_idx >= world.factions.size():
		return false
	var f: FactionData = world.factions[faction_idx]
	var d := world
	if not f.is_enabled:
		return false
	if d.party_support <= 0 or d.party_ban_count >= 4 or d.party_system == 9:
		return false
	if _faction_protected_by_leader(faction_idx):
		return false
	if d.party_system > 7 and faction_idx == FactionData.CONSERVATIVE:
		return false
	return true


## 原版 Party_zapret 能否解除禁止判定：多党下保守派(1)不可解禁
func _can_unban_faction(faction_idx: int) -> bool:
	if world == null:
		return false
	var d := world
	return d.party_system <= 7 or faction_idx != FactionData.CONSERVATIVE


## UI 查询用的公开包装（不暴露下划线内部函数）
func can_ban_faction(faction_idx: int) -> bool:
	return _can_ban_faction(faction_idx)


func can_unban_faction(faction_idx: int) -> bool:
	return _can_unban_faction(faction_idx)


func set_faction_enabled(faction_idx: int, want_enabled: bool) -> void:
	## 忠实移植原版 Party_zapret.OnMouseDown() 的禁止/解禁语义。
	if world == null or faction_idx >= world.factions.size():
		return
	var f: FactionData = world.factions[faction_idx]
	if want_enabled == f.is_enabled:
		return
	if f.is_enabled:
		if _can_ban_faction(faction_idx):
			_ban_faction(faction_idx)
	else:
		if _can_unban_faction(faction_idx):
			_unban_faction(faction_idx)
	gm._update_political_line(world, world)
	gm._notify_stats()


func _ban_faction(faction_idx: int) -> void:
	var f: FactionData = world.factions[faction_idx]
	var d := world
	var total := 0
	for x in world.factions:
		total += maxi(x.support, 0)
	# 原版用 float 除法再转 int（截断），这里保持一致
	var pct := int(float(f.support * 100) / float(total)) if total > 0 else 0
	d.party_ban_count += 1
	f.is_enabled = false
	f.support = 0
	f.is_ally = false
	if d.party_system > 7:
		# 原版在此分支先置 ally=false 再判 ally，因此恒走 else：国际声望+10
		d.diplomatic_reputation += 10
		d.people_support -= pct * 20
		d.thought_freedom += pct * 30
		if d.party_ban_count >= 4:
			_force_party_system_reset(d)
	else:
		d.thought_freedom += pct * 20
		d.party_support -= pct * 30
		if f.ideology > 0:
			_transfer_ideology_forward(faction_idx)


func _unban_faction(faction_idx: int) -> void:
	var f: FactionData = world.factions[faction_idx]
	var d := world
	if d.party_system > 7:
		d.people_support += 40
		d.thought_freedom += 60
	else:
		d.party_support -= 150
		if f.ideology > 0:
			_transfer_ideology_backward(faction_idx)
	d.party_ban_count -= 1
	f.is_enabled = true
	f.support = f.ideology if (f.ideology > 0 and d.party_system <= 7) else 0


## Party_zapret 禁止时把本派基础意识形态转移到下一个启用派系
func _transfer_ideology_forward(faction_idx: int) -> void:
	for k in range(faction_idx + 1, world.factions.size()):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support += world.factions[faction_idx].ideology
			return
	for k in range(faction_idx - 1, -1, -1):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support += world.factions[faction_idx].ideology
			return


## Party_zapret 解禁时从下一启用派系扣回基础意识形态（下限=目标派系 ideology）
func _transfer_ideology_backward(faction_idx: int) -> void:
	var base: int = world.factions[faction_idx].ideology
	for k in range(faction_idx + 1, world.factions.size()):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support -= base
			if t.support < t.ideology:
				t.support = t.ideology
			return
	for k in range(faction_idx - 1, 0, -1):
		var t: FactionData = world.factions[k]
		if t.is_enabled:
			t.support -= base
			if t.support < t.ideology:
				t.support = t.ideology
			return


## Party_zapret.cs:110-122 第4次禁止后的政党制度复位块
func _force_party_system_reset(d: WorldState) -> void:
	if world.factions.size() < 5:
		return
	d.party_system = 6
	for i in world.factions.size():
		var f: FactionData = world.factions[i]
		if i != FactionData.CONSERVATIVE:
			f.is_ally = false
		if not f.is_enabled:
			f.is_enabled = true
			if f.support <= 5:
				var rv := randi_range(0, 9)
				f.support = 10 + rv
				f.ideology = f.support
	for i in world.factions.size():
		world.factions[i].is_enabled = true
	world.factions[0].support = 0
	world.factions[1].support = 50
	world.factions[2].support = 50
	world.factions[3].support = 500
	world.factions[4].support = 400
	if d.econ_display == 37:
		world.factions[3].support = 200
		world.factions[4].support = 700
	d.party_ban_count = 0
	world.event999_trigger_sentinel = 999


## 执政派系判定 — 原版 GameState.IsFactionLeadeng(num)：num == data.political_line
func is_faction_leading(faction_index: int) -> bool:
	if world == null or faction_index < 0:
		return false
	var d := world
	if d.size() <= W.I_POLITICAL_LINE:
		return false
	return d.political_line == faction_index


## 毛是否已逝——全项目唯一权威谓词。
## 语义标记走事件系统的 mao_dead flag（death_of_mao 各选项已 set_flag）。
## 内部 OR 一个 data.stability==100 兼容旧存档（毛死于 flag 机制加入前）：
## 这是原版把 data.stability 当“政治稳定”实为“毛死标记”的魔法数字，收编到此一处，
## 别处一律调用 is_mao_dead()，不要再写裸的 ==100 判断。
func is_mao_dead() -> bool:
	if world == null:
		return false
	if world.get_flag("mao_dead"):
		return true
	var d := world
	return d.size() > W.I_STABILITY and d.stability == 100


## POL-14：politics[0] 毛泽东在世时受保护（不可负向操作/击杀）
func is_mao_protected(pol_index: int) -> bool:
	if world == null or pol_index != 0:
		return false
	return not is_mao_dead()


## FAC-06：派内在世政客 power 合计
func faction_power_sum(faction_idx: int) -> int:
	if world == null or faction_idx < 0:
		return 0
	var total := 0
	for p in world.politicians:
		if p == null or p.name_display == "空位":
			continue
		if p.party_index() == faction_idx:
			total += maxi(p.power, 0)
	return total


## 自由派启用/禁用完全复刻原版 Party_zapret 手动解禁与事件路径；
## 原版不存在“改革路径自动解锁”规则，故此处不再提供任何自动解锁函数。


