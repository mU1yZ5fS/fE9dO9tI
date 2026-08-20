class_name FortnightSimulator
extends RefCounted

## 双周结算模拟服务。
## 从 GameManager 拆出：包含 _on_fortnight 及其双周专属规则函数。
## 通过 run(gm, world) 注入 GameManager 引用与 WorldState；跨系统调用走 gm.* 显式依赖。

const W = preload("res://数据脚本/world_state.gd")

var gm: Node = null
var world: WorldState = null

@warning_ignore_start("integer_division")

func run(gm_node: Node, ws: WorldState) -> void:
	gm = gm_node
	world = ws
	_on_fortnight()

func _fortnight_research_advance(d: Array[int], w: WorldState) -> void:
	if w.techs == null:
		return
	if w.techs.is_researching():
		d[W.I_SCIENCE] = w.techs.monthly_advance(d[W.I_SCIENCE])
		var completed: int = w.techs.get_completed_this_tick()
		if completed >= 0:
			gm._apply_tech(completed)
			gm.tech_completed.emit(completed)
	# 无研究时科研点上限 300（原版 5585-5587）
	if not w.techs.is_researching() and d[W.I_SCIENCE] > 300:
		d[W.I_SCIENCE] = 300


# ── 双周：已解锁科技持续加成（TimeScript 4974-5263行） ──
## 原版每双周对所有已解锁科技重复施加效果（非一次性）。
## 航天科技 27-33 本步补齐（原版 DLC02 内容，本移植按项目惯例无条件开放）。
## 原版 empires[0]=USA、empires[1]=USSR；relations 均为 ×10 存储。
## TimeScript.cs:11173-11717 TraitInfluence 逐字移植。
## 原版 dlc[0] 内的 gamerules[7]/[8] 分支因 gamerules 移植说明而跳过（项目既有裁决）。
func _fortnight_trait_influence(d: Array[int], w: WorldState) -> void:
	for i in w.politicians.size():
		var p: PoliticianData = w.politicians[i]
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if gm._mod_active(w, 14):
			if p.trait_personality == 2:
				p.power += 10
			elif p.trait_personality == 3 and _faction_leader_slot(w, i) != 4:
				p.power += 5
		if _faction_leader_slot(w, i) >= 0:
			p.power += 20
		# dlc[0] 块：gamerules 移植说明，跳过（TimeScript.cs:11208-11231）。
		if _in_central_office(w, i):
			_trait_influence_central(w, d, p)
		if _is_foreign_minister(w, i):
			_trait_influence_foreign(w, d, p, i)
		if _is_premier(w, i):
			_trait_influence_premier(w, d, p, i)
		if _is_chairman(w, i):
			_trait_influence_chairman(w, d, p, i)


## TraitInfluence 的 traits[3]/traits[1]/traits[2] 中央职务块（TimeScript.cs:11233-11695）。
func _trait_influence_central(w: WorldState, d: Array[int], p: PoliticianData) -> void:
	if p.trait_personality == 0:
		if _dv(d, 56) != 0:
			_addi(d, 1, -2)
		_addi(d, 5, 2)
		_add_empire_relation(w, 1, 2)
		_addi(d, 68, -1)
		_addi(d, 26, -2)
	elif p.trait_personality == 20:
		if _dv(d, 56) == 1:
			_addi(d, 1, 1)
		_addi(d, 4, 1)
		_addi(d, 5, 1)
		_add_empire_relation(w, 1, 3)
		_addi(d, 68, -1)
		_addi(d, 26, -1)
	elif p.trait_personality == 1:
		if _dv(d, 56) != 2:
			_addi(d, 1, 1)
		else:
			_addi(d, 1, 2)
		_addi(d, 4, 1)
		_addi(d, 5, 1)
	elif p.trait_personality == 2:
		if _dv(d, 56) != 3:
			_addi(d, 1, 4)
		else:
			_addi(d, 1, 5)
		_addi(d, 5, -2)
		_addi(d, 4, 2)
	elif p.trait_personality == 3:
		if _dv(d, 56) != 4:
			_addi(d, 1, 9)
		else:
			_addi(d, 1, 10)
		_addi(d, 5, -5)
		_addi(d, 4, 7)
	match p.trait_background:
		21:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_PEOPLE_SUPPORT, -1)
			_addi(d, W.I_THOUGHT_FREEDOM, -2)
			if p.trait_personality == 1 or p.trait_personality == 2:
				_addi(d, W.I_CORRUPTION, 1)
			elif p.trait_personality == 3:
				_addi(d, W.I_CORRUPTION, 2)
		22:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, 1)
			_addi(d, W.I_CORRUPTION, -1)
		23:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
			_addi(d, W.I_CORRUPTION, -1)
		24:
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			_addi(d, W.I_INDUSTRY, 1)
			_addi(d, W.I_AGRICULTURE, 1)
			_addi(d, W.I_SERVICES, 1)
			_addi(d, W.I_LIVING, -1)
		25:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, -2)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, -1)
			if p.trait_personality != 0:
				_addi(d, W.I_CORRUPTION, 1)
		26:
			_addi(d, W.I_LIVING, 1)
			_addi(d, W.I_SCIENCE, 1)
			if p.trait_personality == 0:
				_addi(d, W.I_PARTY_SUPPORT, -2)
				_addi(d, W.I_PEOPLE_SUPPORT, 2)
				_addi(d, W.I_THOUGHT_FREEDOM, -2)
			elif p.trait_personality == 20 or p.trait_personality == 1:
				_addi(d, W.I_PARTY_SUPPORT, 1)
				_addi(d, W.I_PEOPLE_SUPPORT, 1)
				_addi(d, W.I_THOUGHT_FREEDOM, 1)
			elif p.trait_personality == 2:
				_addi(d, W.I_PARTY_SUPPORT, 2)
				_addi(d, W.I_PEOPLE_SUPPORT, -2)
				_addi(d, W.I_THOUGHT_FREEDOM, 1)
			elif p.trait_personality == 3:
				_addi(d, W.I_PARTY_SUPPORT, 4)
				_addi(d, W.I_PEOPLE_SUPPORT, -4)
				_addi(d, W.I_THOUGHT_FREEDOM, 2)
		27:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, 2)
			_addi(d, W.I_SCIENCE, 6)
		28:
			_addi(d, W.I_PARTY_SUPPORT, -5)
			_addi(d, W.I_PEOPLE_SUPPORT, -3)
			_addi(d, W.I_THOUGHT_FREEDOM, -2)
			_addi(d, W.I_AGENTS, 3)
		43:
			_addi(d, W.I_SCIENCE, 5)
	match p.trait_alignment:
		4:
			_addi(d, W.I_CORRUPTION, -1)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_PARTY_SUPPORT, -2)
		5:
			_addi(d, W.I_PARTY_SUPPORT, 2)
		6:
			_addi(d, W.I_CORRUPTION, 1)
			_addi(d, W.I_THOUGHT_FREEDOM, 5)
			_addi(d, W.I_PARTY_SUPPORT, 5)
		7:
			_addi(d, W.I_SCIENCE, 2)
		29:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_PEOPLE_SUPPORT, -5)
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_add_empire_relation(w, 0, 2)
			if d.size() > W.I_SERVICES:
				d[W.I_SERVICES] += 1 if d[W.I_SERVICES] < 60 else -1
			if d.size() > W.I_LIVING:
				d[W.I_LIVING] += 2 if d[W.I_LIVING] < 50 else -2
		30:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_PEOPLE_SUPPORT, -5)
			_addi(d, W.I_MANPOWER, -3)
			match p.trait_personality:
				0: _addi(d, W.I_THOUGHT_FREEDOM, -5)
				20: _addi(d, W.I_THOUGHT_FREEDOM, -3)
				2: _addi(d, W.I_THOUGHT_FREEDOM, 3)
				3: _addi(d, W.I_THOUGHT_FREEDOM, 5)
			match p.trait_personality:
				0, 1: _addi(d, W.I_WAR_SUPPORT, 3)
				20: _addi(d, W.I_WAR_SUPPORT, 6)
				2: _addi(d, W.I_WAR_SUPPORT, -3)
				3: _addi(d, W.I_WAR_SUPPORT, -6)
		39:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, -1)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_INDUSTRY, -1)
			_addi(d, W.I_MANPOWER, -1)
		40:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_CORRUPTION, 1)
		41:
			_addi(d, W.I_PARTY_SUPPORT, 5)
			_addi(d, W.I_PEOPLE_SUPPORT, 2)
			_addi(d, W.I_BUDGET, -3)
			_addi(d, W.I_CORRUPTION, 1)
			if p.trait_personality == 0 or p.trait_personality == 20:
				_addi(d, W.I_THOUGHT_FREEDOM, -1)
			elif p.trait_personality == 3:
				_addi(d, W.I_THOUGHT_FREEDOM, 1)
		42:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_PEOPLE_SUPPORT, 3)
			if p.trait_personality == 0:
				_addi(d, W.I_THOUGHT_FREEDOM, -3)
	match p.trait_special:
		8:
			_addi(d, W.I_THOUGHT_FREEDOM, -10)
			_addi(d, W.I_PARTY_SUPPORT, -5)
		9:
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_addi(d, W.I_PARTY_SUPPORT, 3)
		10:
			_addi(d, W.I_PARTY_SUPPORT, -5)
			_addi(d, W.I_PEOPLE_SUPPORT, -5)
		11:
			_addi(d, W.I_BUDGET, 3)
		12:
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
			_addi(d, W.I_PARTY_SUPPORT, -4)
		13:
			_addi(d, W.I_PARTY_SUPPORT, 6)
		14:
			_addi(d, W.I_PARTY_SUPPORT, 3)
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_addi(d, W.I_WAR_SUPPORT, 6)
		15:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_THOUGHT_FREEDOM, 3)
			_addi(d, W.I_WAR_SUPPORT, -6)
		16:
			_addi(d, W.I_PARTY_SUPPORT, 4)
			_addi(d, W.I_AGENTS, 3)
		17:
			_addi(d, W.I_THOUGHT_FREEDOM, 2)
		18:
			_addi(d, W.I_CORRUPTION, 3)
			_addi(d, W.I_PARTY_SUPPORT, 5)
			_addi(d, W.I_BUDGET, -1)
		19:
			_addi(d, W.I_PARTY_SUPPORT, 1)
			_addi(d, W.I_THOUGHT_FREEDOM, 2)
		31:
			match p.trait_personality:
				0:
					_addi(d, W.I_PARTY_SUPPORT, -2)
					_addi(d, W.I_PEOPLE_SUPPORT, 5)
					_addi(d, W.I_THOUGHT_FREEDOM, -2)
				20:
					_addi(d, W.I_PARTY_SUPPORT, 1)
					_addi(d, W.I_PEOPLE_SUPPORT, 3)
					_addi(d, W.I_THOUGHT_FREEDOM, -1)
				1:
					_addi(d, W.I_PARTY_SUPPORT, 4)
					_addi(d, W.I_PEOPLE_SUPPORT, 1)
					_addi(d, W.I_THOUGHT_FREEDOM, 2)
				2:
					_addi(d, W.I_PARTY_SUPPORT, 5)
					_addi(d, W.I_PEOPLE_SUPPORT, -3)
					_addi(d, W.I_THOUGHT_FREEDOM, 3)
				3:
					_addi(d, W.I_PARTY_SUPPORT, -3)
					_addi(d, W.I_PEOPLE_SUPPORT, -5)
					_addi(d, W.I_THOUGHT_FREEDOM, 5)
		32:
			_addi(d, W.I_PEOPLE_SUPPORT, 6)
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
		33:
			_addi(d, W.I_PARTY_SUPPORT, 1)
			_add_empire_relation(w, 0, 1)
			_add_empire_relation(w, 1, 1)
		34:
			_addi(d, W.I_PARTY_SUPPORT, -3)
			_addi(d, W.I_PEOPLE_SUPPORT, -2)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_MANPOWER, -3)
		35:
			_addi(d, W.I_PARTY_SUPPORT, -5)
			_addi(d, W.I_PEOPLE_SUPPORT, -3)
			_addi(d, W.I_AGENTS, 3)
		36:
			_addi(d, W.I_PARTY_SUPPORT, -2)
			_addi(d, W.I_PEOPLE_SUPPORT, -2)
			_addi(d, W.I_THOUGHT_FREEDOM, -5)
			_addi(d, W.I_ARMY, 1)
			_addi(d, W.I_LIVING, -1)
		37:
			_addi(d, W.I_PARTY_SUPPORT, 3)
		38:
			_addi(d, W.I_PARTY_SUPPORT, 2)
			_addi(d, W.I_THOUGHT_FREEDOM, -3)
			_addi(d, W.I_LIVING, -1)


## TraitInfluence 外交部块（politics_dolshnost[2] == i，TimeScript.cs:11696-11717 之前）。
func _trait_influence_foreign(w: WorldState, d: Array[int], p: PoliticianData, i: int) -> void:
	if _is_foreign_minister(w, i):
		if p.trait_personality == 0:
			_add_empire_relation(w, 0, -10)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
			_add_ideology_share(w, 0, 666)
			_add_ideology_share(w, 1, 1000)
		elif p.trait_personality == 20:
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 2)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) > 1000:
				_addi(d, 6, -1)
			_add_ideology_share(w, 2, 1000)
			_add_ideology_share(w, 1, 333)
		elif p.trait_personality == 1:
			_add_empire_relation(w, 1, 10)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
			_add_ideology_share(w, 2, 333)
			_add_ideology_share(w, 3, 666)
			_add_ideology_share(w, 1, 2000)
		elif p.trait_personality == 2:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, 5)
			if _dv(d, 6) < 300:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 700:
				_addi(d, 6, -2)
			elif _dv(d, 6) > 500:
				_addi(d, 6, -1)
			_add_ideology_share(w, 3, 666)
			_add_ideology_share(w, 4, 666)
		elif p.trait_personality == 3:
			_add_empire_relation(w, 1, -10)
			_add_empire_relation(w, 0, 12)
			if _dv(d, 6) > 700:
				_addi(d, 6, -3)
			elif _dv(d, 6) > 500:
				_addi(d, 6, -2)
			elif _dv(d, 6) > 300:
				_addi(d, 6, -1)
			_add_ideology_share(w, 3, 666)
			_add_ideology_share(w, 4, 666)
		if p.trait_background == 21:
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 2)
			if _dv(d, 6) < 500:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
		elif p.trait_background == 22:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -8)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
		elif p.trait_background == 23:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -8)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
		elif p.trait_background == 24:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -5)
			if _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
		elif p.trait_background == 25:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) > 1000:
				_addi(d, 6, -1)
		elif p.trait_background == 26:
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -5)
				_add_empire_relation(w, 0, -5)
				_addi(d, 6, 1)
			elif p.trait_personality == 20:
				_add_empire_relation(w, 1, 4)
				_add_empire_relation(w, 0, 2)
			elif p.trait_personality == 1:
				_add_empire_relation(w, 1, 6)
				_add_empire_relation(w, 0, -2)
			elif p.trait_personality == 2:
				_add_empire_relation(w, 1, -3)
				_add_empire_relation(w, 0, 5)
				_addi(d, 6, -1)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 8)
				_addi(d, 6, -2)
		elif p.trait_background == 27:
			_addi(d, 11, 6)
		elif p.trait_background == 28:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_background == 43:
			_addi(d, 11, 5)
		if p.trait_alignment == 4:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_alignment == 5:
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 5)
			if _dv(d, 6) < 700:
				_addi(d, 6, 1)
			else:
				_addi(d, 6, -1)
		elif p.trait_alignment == 6:
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 6)
			if _dv(d, 6) > 600:
				_addi(d, 6, -1)
		elif p.trait_alignment == 7:
			_addi(d, 11, 2)
		elif p.trait_alignment == 29:
			_add_empire_relation(w, 0, 6)
			_addi(d, 6, -1)
		elif p.trait_alignment == 30:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 700:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
		elif p.trait_alignment == 39:
			_addi(d, 8, -1)
			if p.trait_personality == 0 or p.trait_personality == 20:
				_addi(d, 6, 2)
				_add_empire_relation(w, 1, 6)
				_add_empire_relation(w, 0, -6)
			elif p.trait_personality == 2 or p.trait_personality == 3:
				_addi(d, 6, -2)
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 6)
		elif p.trait_alignment == 40:
			if _rel(w, 1) < 400:
				_add_empire_relation(w, 1, -3)
			elif _rel(w, 1) > 600:
				_add_empire_relation(w, 1, 3)
			if _rel(w, 0) < 400:
				_add_empire_relation(w, 0, -3)
			elif _rel(w, 0) > 600:
				_add_empire_relation(w, 0, 3)
			if _dv(d, 6) > 900:
				_addi(d, 6, 1)
			elif _dv(d, 6) < 500:
				_addi(d, 6, -1)
		elif p.trait_alignment == 41:
			_addi(d, 8, -1)
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -4)
				_add_empire_relation(w, 0, -4)
				_addi(d, 6, 1)
			elif p.trait_personality == 20:
				_add_empire_relation(w, 0, -1)
			elif p.trait_personality == 1:
				_add_empire_relation(w, 0, -1)
			elif p.trait_personality == 2:
				_add_empire_relation(w, 0, 3)
				_addi(d, 6, -1)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -4)
				_add_empire_relation(w, 0, 3)
				_addi(d, 6, -2)
		elif p.trait_alignment == 42:
			_addi(d, 8, -1)
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, -6)
				_addi(d, 6, 5)
				_add_ideology_share(w, 0, 1000)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 6)
				_addi(d, 6, -5)
				_add_ideology_share(w, 4, 1000)
		if p.trait_special == 8:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 1000:
				_addi(d, 6, 1)
		elif p.trait_special == 9:
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
			if _dv(d, 6) > 700:
				_addi(d, 6, -1)
		elif p.trait_special == 10:
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, -6)
			_addi(d, 6, 2)
		elif p.trait_special == 11:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -2)
			_addi(d, 8, 2)
		elif p.trait_special == 12:
			_add_empire_relation(w, 1, -4)
			_add_empire_relation(w, 0, -4)
			_addi(d, 6, 1)
		elif p.trait_special == 13:
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 14:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			if _dv(d, 6) < 500:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 800:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 900:
				_addi(d, 6, -1)
		elif p.trait_special == 15:
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, 6)
			_addi(d, 6, -1)
		elif p.trait_special == 16:
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 17:
			_add_empire_relation(w, 1, -1)
			_add_empire_relation(w, 0, -1)
			_addi(d, 6, -1)
		elif p.trait_special == 18:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -2)
			_addi(d, 8, -1)
		elif p.trait_special == 19:
			_add_empire_relation(w, 1, -2)
			_add_empire_relation(w, 0, -2)
			_addi(d, 6, -1)
		elif p.trait_special == 31:
			if p.trait_personality == 0:
				_add_empire_relation(w, 1, -3)
				_add_empire_relation(w, 0, -3)
				_addi(d, 6, 1)
			elif p.trait_personality == 20:
				_add_empire_relation(w, 1, 3)
				_add_empire_relation(w, 0, 1)
			elif p.trait_personality == 1:
				_add_empire_relation(w, 1, 5)
				_add_empire_relation(w, 0, -1)
			elif p.trait_personality == 2:
				_add_empire_relation(w, 1, -2)
				_add_empire_relation(w, 0, 4)
				_addi(d, 6, -1)
			elif p.trait_personality == 3:
				_add_empire_relation(w, 1, -4)
				_add_empire_relation(w, 0, 6)
				_addi(d, 6, -2)
		elif p.trait_special == 32:
			_add_empire_relation(w, 1, -4)
			_add_empire_relation(w, 0, -4)
		elif p.trait_special == 33:
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 6)
			if _dv(d, 6) < 500:
				_addi(d, 6, 3)
			elif _dv(d, 6) < 700:
				_addi(d, 6, 2)
			elif _dv(d, 6) < 900:
				_addi(d, 6, 1)
			elif _dv(d, 6) > 1000:
				_addi(d, 6, -1)
		elif p.trait_special == 34:
			_add_empire_relation(w, 1, -5)
			_add_empire_relation(w, 0, -1)
		elif p.trait_special == 35:
			_addi(d, 6, -1)
			if _emp_pow(w, 1) > _emp_pow(w, 0):
				_add_empire_relation(w, 1, 5)
				_add_empire_relation(w, 0, -5)
			else:
				_add_empire_relation(w, 1, -5)
				_add_empire_relation(w, 0, 5)
		elif p.trait_special == 36:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, 1)
		elif p.trait_special == 37:
			_add_empire_relation(w, 1, 2)
			_add_empire_relation(w, 0, 2)
			_addi(d, 6, -1)
		elif p.trait_special == 38:
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, 1)


## TraitInfluence 的总理块 politics_dolshnost[1]（TimeScript.cs:12187-12658 逐字移植）。
func _trait_influence_premier(w: WorldState, d: Array[int], p: PoliticianData, i: int) -> void:
	if _is_premier(w, i):
		if p.trait_personality == 0:
			if _dv(d, 56) != 0:
				_addi(d, 1, -6)
			else:
				_addi(d, 1, -3)
			_addi(d, 5, 6)
			_add_empire_relation(w, 1, 3)
			_addi(d, 68, -1)
			_addi(d, 26, -2)
			_add_ideology_share(w, 0, 333)
			_add_ideology_share(w, 1, 500)
		elif p.trait_personality == 20:
			if _dv(d, 56) != 1:
				_addi(d, 1, 4)
			else:
				_addi(d, 1, 5)
			_addi(d, 5, 4)
			_addi(d, 4, 1)
			_addi(d, 26, -1)
			_add_empire_relation(w, 1, 5)
			_add_ideology_share(w, 2, 2000)
			_add_ideology_share(w, 1, 222)
		elif p.trait_personality == 1:
			if _dv(d, 56) != 2:
				_addi(d, 1, 5)
			else:
				_addi(d, 1, 6)
			_addi(d, 5, 2)
			_addi(d, 4, 3)
			_add_ideology_share(w, 2, 222)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 1, 2000)
		elif p.trait_personality == 2:
			if _dv(d, 56) != 3:
				_addi(d, 1, 6)
			else:
				_addi(d, 1, 7)
			_addi(d, 5, -3)
			_addi(d, 4, 5)
			_add_ideology_share(w, 3, 222)
			_add_ideology_share(w, 4, 333)
		elif p.trait_personality == 3:
			if _dv(d, 56) != 4:
				_addi(d, 1, 8)
			else:
				_addi(d, 1, 10)
			_addi(d, 5, -7)
			_addi(d, 4, 5)
			_addi(d, 8, 2)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 4, 222)
		if p.trait_background == 21:
			_addi(d, 1, 5)
			_addi(d, 3, -2)
			_addi(d, 4, -3)
			if p.trait_personality == 1  or  p.trait_personality == 2:
				_addi(d, 26, 1)
			elif p.trait_personality == 3:
				_addi(d, 26, 2)
		elif p.trait_background == 22:
			_addi(d, 1, -4)
			_addi(d, 3, 5)
			_addi(d, 22, 5)
			_addi(d, 5, 3)
			_addi(d, 26, -2)
		elif p.trait_background == 23:
			_addi(d, 1, -5)
			_addi(d, 4, -8)
			_addi(d, 22, -3)
			_addi(d, 26, -2)
		elif p.trait_background == 24:
			_addi(d, 1, -3)
			_addi(d, 3, 5)
			_addi(d, 12, 2)
			_addi(d, 13, 2)
			_addi(d, 68, 1)
			_addi(d, 5, -3)
		elif p.trait_background == 25:
			_addi(d, 1, 5)
			_addi(d, 4, -10)
			_addi(d, 22, 12)
			_addi(d, 5, -5)
		elif p.trait_background == 26:
			_addi(d, 22, -5)
			_addi(d, 5, 3)
			_addi(d, 11, 3)
			if p.trait_personality == 0:
				_addi(d, 1, -5)
				_addi(d, 3, 2)
				_addi(d, 4, -5)
			elif p.trait_personality == 20  or  p.trait_personality == 1:
				_addi(d, 1, 2)
				_addi(d, 3, 2)
				_addi(d, 4, 2)
			elif p.trait_personality == 2:
				_addi(d, 1, 4)
				_addi(d, 3, -4)
				_addi(d, 4, 4)
			elif p.trait_personality == 3:
				_addi(d, 1, 5)
				_addi(d, 3, -5)
				_addi(d, 4, 6)
		elif p.trait_background == 27:
			_addi(d, 1, 6)
			_addi(d, 3, 6)
			_addi(d, 22, 8)
			_addi(d, 5, 2)
			_addi(d, 11, 10)
		elif p.trait_background == 28:
			_addi(d, 1, -7)
			_addi(d, 3, -5)
			_addi(d, 4, -5)
			_addi(d, 9, 6)
		elif p.trait_background == 43:
			_addi(d, 11, 8)
		if p.trait_alignment == 4:
			_addi(d, 26, -1)
			_addi(d, 4, -7)
			_addi(d, 1, -3)
		elif p.trait_alignment == 5:
			_addi(d, 1, 3)
		elif p.trait_alignment == 6:
			_addi(d, 26, 1)
			_addi(d, 4, 7)
			_addi(d, 1, 7)
		elif p.trait_alignment == 7:
			_addi(d, 11, 3)
		elif p.trait_alignment == 29:
			_addi(d, 1, 6)
			_addi(d, 3, -8)
			_addi(d, 4, 6)
			_addi(d, 22, -6)
			if _dv(d, 68) < 60:
				_addi(d, 68, 2)
			else:
				_addi(d, 68, -2)
			if _dv(d, 5) < 50:
				_addi(d, 5, 4)
			else:
				_addi(d, 5, -4)
		elif p.trait_alignment == 30:
			_addi(d, 1, -6)
			_addi(d, 3, -8)
			_addi(d, 57, -5)
			if p.trait_personality == 0:
				_addi(d, 4, -8)
			elif p.trait_personality == 20:
				_addi(d, 4, -4)
			elif p.trait_personality == 2:
				_addi(d, 4, 4)
			elif p.trait_personality == 3:
				_addi(d, 4, 8)
			if p.trait_personality == 0  or  p.trait_personality == 1:
				_addi(d, 31, 5)
			elif p.trait_personality == 20:
				_addi(d, 31, 10)
			elif p.trait_personality == 2:
				_addi(d, 31, -5)
			elif p.trait_personality == 3:
				_addi(d, 31, -10)
		elif p.trait_alignment == 39:
			_addi(d, 1, -5)
			_addi(d, 3, -3)
			_addi(d, 4, -8)
			_addi(d, 22, 3)
			_addi(d, 9, 3)
			_addi(d, 57, -2)
			_addi(d, 8, -2)
		elif p.trait_alignment == 40:
			_addi(d, 1, 6)
			_addi(d, 3, -3)
			_addi(d, 26, 2)
			if _dv(d, 51) == 30:
				_addi(d, 22, 4)
				_addi(d, 8, -4)
			elif _dv(d, 51) == 31  or  _dv(d, 51) == 32:
				_addi(d, 22, 2)
				_addi(d, 8, -2)
			elif _dv(d, 51) == 33:
				_addi(d, 8, 3)
				_addi(d, 4, 5)
		elif p.trait_alignment == 41:
			_addi(d, 8, -5)
			_addi(d, 9, -4)
			_addi(d, 4, -4)
			_addi(d, 26, 3)
			if _dv(d, 71) < 300:
				_addi(d, 1, -8)
				_addi(d, 22, 4)
			else:
				_addi(d, 1, -5)
				_addi(d, 22, 8)
		elif p.trait_alignment == 42:
			_addi(d, 1, -8)
			_addi(d, 22, 3 + d[76] / 200)
			_addi(d, 9, -3)
			if p.trait_personality == 0:
				_add_ideology_share(w, 0, 500)
			elif p.trait_personality == 3:
				_add_ideology_share(w, 4, 500)
		if p.trait_special == 8:
			_addi(d, 4, -15)
			_addi(d, 1, -7)
			_addi(d, 22, 3)
		elif p.trait_special == 9:
			_addi(d, 4, 5)
			_addi(d, 1, 6)
			_addi(d, 22, -3)
		elif p.trait_special == 10:
			_addi(d, 1, -10)
			_addi(d, 3, -10)
			_addi(d, 22, 3)
		elif p.trait_special == 11:
			_addi(d, 8, 5)
			_addi(d, 22, -5)
		elif p.trait_special == 12:
			_addi(d, 4, -5)
			_addi(d, 1, -8)
			_addi(d, 22, -3)
		elif p.trait_special == 13:
			_addi(d, 1, 12)
		elif p.trait_special == 14:
			_addi(d, 1, 5)
			_addi(d, 4, 3)
			_addi(d, 22, 3)
			_addi(d, 31, 8)
		elif p.trait_special == 15:
			_addi(d, 1, -5)
			_addi(d, 4, 3)
			_addi(d, 22, -3)
			_addi(d, 31, -8)
		elif p.trait_special == 16:
			_addi(d, 1, 6)
			_addi(d, 9, 6)
			_addi(d, 22, 3)
		elif p.trait_special == 17:
			_addi(d, 4, 5)
			_addi(d, 22, -3)
		elif p.trait_special == 18:
			_addi(d, 26, 5)
			_addi(d, 1, 7)
			_addi(d, 8, -2)
			_addi(d, 22, -3)
		elif p.trait_special == 19:
			_addi(d, 1, 2)
			_addi(d, 4, 4)
			_addi(d, 22, -2)
		elif p.trait_special == 31:
			_addi(d, 22, 3)
			if p.trait_personality == 0:
				_addi(d, 1, -4)
				_addi(d, 3, 6)
				_addi(d, 4, -4)
			elif p.trait_personality == 20:
				_addi(d, 1, 2)
				_addi(d, 3, 4)
				_addi(d, 4, -2)
			elif p.trait_personality == 1:
				_addi(d, 1, 5)
				_addi(d, 3, 2)
				_addi(d, 4, 3)
			elif p.trait_personality == 2:
				_addi(d, 1, 6)
				_addi(d, 3, -3)
				_addi(d, 4, 4)
			elif p.trait_personality == 3:
				_addi(d, 1, -5)
				_addi(d, 3, -6)
				_addi(d, 4, 8)
		elif p.trait_special == 32:
			_addi(d, 3, 12)
			_addi(d, 4, -6)
			_addi(d, 22, 5)
		elif p.trait_special == 33:
			_addi(d, 1, -3)
			_addi(d, 22, -3)
		elif p.trait_special == 34:
			_addi(d, 1, -5)
			_addi(d, 3, -3)
			_addi(d, 4, -8)
			_addi(d, 22, 2)
			_addi(d, 57, -5)
		elif p.trait_special == 35:
			_addi(d, 1, -6)
			_addi(d, 3, -4)
			_addi(d, 9, 6)
			_addi(d, 22, -3)
		elif p.trait_special == 36:
			_addi(d, 1, 6)
			_addi(d, 4, -10)
			_addi(d, 22, 10)
			_addi(d, 5, -5)
		elif p.trait_special == 37:
			_addi(d, 1, 6)
			_addi(d, 4, 2)
			_addi(d, 22, 2)
		elif p.trait_special == 38:
			_addi(d, 1, 5)
			_addi(d, 4, -6)
			_addi(d, 22, 3)
			_addi(d, 5, -2)

## TraitInfluence 的主席块 politics_dolshnost[0]（TimeScript.cs:12659-13178 逐字移植）。
func _trait_influence_chairman(w: WorldState, d: Array[int], p: PoliticianData, i: int) -> void:
	if _is_chairman(w, i):
		if p.trait_personality == 0:
			if _dv(d, 56) != 0:
				_addi(d, 1, -9)
			else:
				_addi(d, 1, -3)
			_addi(d, 5, 5)
			_add_empire_relation(w, 1, 3)
			_add_empire_relation(w, 0, -12)
			_addi(d, 68, -2)
			_addi(d, 26, -4)
			_add_ideology_share(w, 0, 333)
			_add_ideology_share(w, 1, 500)
		elif p.trait_personality == 20:
			if _dv(d, 56) == 1:
				_addi(d, 1, 2)
			_addi(d, 5, 4)
			_addi(d, 4, 3)
			_addi(d, 26, -2)
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 2)
			_add_ideology_share(w, 2, 1000)
			_add_ideology_share(w, 1, 222)
		elif p.trait_personality == 1:
			if _dv(d, 56) != 2:
				_addi(d, 1, 5)
			else:
				_addi(d, 1, 7)
			_addi(d, 5, 3)
			_addi(d, 4, 7)
			_add_empire_relation(w, 1, 12)
			_add_empire_relation(w, 0, -3)
			_add_ideology_share(w, 2, 222)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 1, 1000)
		elif p.trait_personality == 2:
			if _dv(d, 56) != 3:
				_addi(d, 1, 13)
			else:
				_addi(d, 1, 15)
			_addi(d, 5, -7)
			_addi(d, 4, 8)
			_addi(d, 6, -1)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, 5)
			_add_ideology_share(w, 3, 222)
			_add_ideology_share(w, 4, 333)
		elif p.trait_personality == 3:
			if _dv(d, 56) != 4:
				_addi(d, 1, 27)
			else:
				_addi(d, 1, 30)
			_addi(d, 5, -15)
			_addi(d, 4, 22)
			_addi(d, 8, 4)
			_addi(d, 6, -2)
			_add_empire_relation(w, 1, -10)
			_add_empire_relation(w, 0, 12)
			_add_ideology_share(w, 3, 333)
			_add_ideology_share(w, 4, 222)
		if p.trait_background == 21:
			_addi(d, 1, 6)
			_addi(d, 3, -2)
			_addi(d, 4, -8)
			if p.trait_personality == 1  or  p.trait_personality == 2:
				_addi(d, 26, 2)
			elif p.trait_personality == 3:
				_addi(d, 26, 3)
		elif p.trait_background == 22:
			_addi(d, 1, -10)
			_addi(d, 3, 12)
			_addi(d, 22, 2)
			_addi(d, 5, 5)
			_addi(d, 26, -4)
		elif p.trait_background == 23:
			_addi(d, 1, -10)
			_addi(d, 4, -12)
			_addi(d, 26, -4)
		elif p.trait_background == 24:
			_addi(d, 1, -5)
			_addi(d, 3, 12)
			_addi(d, 12, 4)
			_addi(d, 13, 4)
			_addi(d, 68, 4)
			_addi(d, 5, -5)
		elif p.trait_background == 25:
			_addi(d, 1, -6)
			_addi(d, 3, -6)
			_addi(d, 4, -10)
			_addi(d, 22, 8)
			_addi(d, 5, -6)
			_add_empire_relation(w, 1, -5)
			_add_empire_relation(w, 0, -5)
			if p.trait_personality != 0:
				_addi(d, 26, 2)
		elif p.trait_background == 26:
			_addi(d, 5, 5)
			_addi(d, 11, 5)
			if p.trait_personality == 0:
				_addi(d, 1, -4)
				_addi(d, 3, 4)
				_addi(d, 4, -4)
			elif p.trait_personality == 20  or  p.trait_personality == 1:
				_addi(d, 1, 3)
				_addi(d, 3, 3)
				_addi(d, 4, 3)
			elif p.trait_personality == 2:
				_addi(d, 1, 6)
				_addi(d, 3, -6)
				_addi(d, 4, 6)
			elif p.trait_personality == 3:
				_addi(d, 1, 10)
				_addi(d, 3, -10)
				_addi(d, 4, 10)
		elif p.trait_background == 27:
			_addi(d, 1, 10)
			_addi(d, 3, 10)
			_addi(d, 22, 5)
			_addi(d, 5, 8)
			_addi(d, 11, 18)
		elif p.trait_background == 28:
			_addi(d, 1, -10)
			_addi(d, 3, -8)
			_addi(d, 4, -10)
			_addi(d, 9, 9)
			_add_empire_relation(w, 1, -5)
			_add_empire_relation(w, 0, -5)
		elif p.trait_background == 43:
			_addi(d, 11, 15)
		if p.trait_alignment == 4:
			_addi(d, 26, -2)
			_addi(d, 4, -15)
			_addi(d, 1, -7)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_alignment == 5:
			_addi(d, 1, 7)
			_add_empire_relation(w, 1, 5)
			_add_empire_relation(w, 0, 5)
		elif p.trait_alignment == 6:
			_addi(d, 26, 2)
			_addi(d, 4, 15)
			_addi(d, 1, 15)
			_add_empire_relation(w, 1, 6)
			_add_empire_relation(w, 0, 6)
			if _dv(d, 6) > 60:
				_addi(d, 6, -1)
		elif p.trait_alignment == 7:
			_addi(d, 11, 9)
		elif p.trait_alignment == 29:
			_addi(d, 1, 8)
			_addi(d, 3, -10)
			_addi(d, 4, 10)
			_add_empire_relation(w, 0, 10)
			if _dv(d, 68) < 60:
				_addi(d, 68, 4)
			else:
				_addi(d, 68, -4)
			if _dv(d, 5) < 50:
				_addi(d, 5, 6)
			else:
				_addi(d, 5, -6)
		elif p.trait_alignment == 30:
			_addi(d, 1, -8)
			_addi(d, 3, -10)
			_addi(d, 57, -6)
			if p.trait_personality == 0:
				_addi(d, 4, -10)
			elif p.trait_personality == 20:
				_addi(d, 4, -5)
			elif p.trait_personality == 2:
				_addi(d, 4, 5)
			elif p.trait_personality == 3:
				_addi(d, 4, 10)
			if p.trait_personality == 0  or  p.trait_personality == 1:
				_addi(d, 31, 6)
			elif p.trait_personality == 20:
				_addi(d, 31, 12)
			elif p.trait_personality == 2:
				_addi(d, 31, -6)
			elif p.trait_personality == 3:
				_addi(d, 31, -12)
		elif p.trait_alignment == 39:
			_addi(d, 1, -8)
			_addi(d, 3, -5)
			_addi(d, 4, -10)
			_addi(d, 8, -5)
			_addi(d, 12, -1)
			_addi(d, 13, -1)
			_addi(d, 68, 1)
			_addi(d, 57, -3)
		elif p.trait_alignment == 40:
			_addi(d, 1, 8)
			_addi(d, 8, -3)
			_addi(d, 12, -2)
			_addi(d, 13, -2)
			_addi(d, 68, -2)
			_addi(d, 26, 3)
			if _dv(d, 17) <= 17:
				_addi(d, 4, -5)
			else:
				_addi(d, 3, 5)
			if _dv(d, 18) > 20:
				_addi(d, 31, -3)
			if _dv(d, 50) > 27:
				_addi(d, 31, 3)
		elif p.trait_alignment == 41:
			_addi(d, 8, -8)
			_addi(d, 26, 5)
			_addi(d, 57, -5)
			_addi(d, 68, 3)
			if _dv(d, 75) < 100:
				_addi(d, 1, -10)
			else:
				_addi(d, 1, -6)
		elif p.trait_alignment == 42:
			_addi(d, 1, -12)
			_addi(d, 3, 8 + d[76] / 100)
			_addi(d, 8, -5)
			_addi(d, 12, -1)
			if p.trait_personality == 0:
				_addi(d, 4, -20)
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, -6)
				_add_ideology_share(w, 0, 333)
			elif p.trait_personality == 3:
				_addi(d, 4, -5)
				_add_empire_relation(w, 1, -6)
				_add_empire_relation(w, 0, 6)
				_add_ideology_share(w, 4, 333)
		if p.trait_special == 8:
			_addi(d, 4, -25)
			_addi(d, 1, -15)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, d[6] / 150)
		elif p.trait_special == 9:
			_addi(d, 4, 6)
			_addi(d, 1, 8)
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 10:
			_addi(d, 1, -16)
			_addi(d, 3, -16)
			_add_empire_relation(w, 1, -8)
			_add_empire_relation(w, 0, -8)
		elif p.trait_special == 11:
			_addi(d, 8, 8)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_special == 12:
			_addi(d, 4, -8)
			_addi(d, 1, -10)
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, -6)
		elif p.trait_special == 13:
			_addi(d, 1, 20)
		elif p.trait_special == 14:
			_addi(d, 1, 8)
			_addi(d, 4, 10)
			_addi(d, 31, 15)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
			_addi(d, 6, d[6] / 150)
		elif p.trait_special == 15:
			_addi(d, 1, -8)
			_addi(d, 4, 10)
			_addi(d, 31, -15)
			_add_empire_relation(w, 1, -6)
			_add_empire_relation(w, 0, 6)
			_addi(d, 6, -d[6] / 150)
		elif p.trait_special == 16:
			_addi(d, 1, 9)
			_addi(d, 9, 6)
			_add_empire_relation(w, 1, 4)
			_add_empire_relation(w, 0, 4)
		elif p.trait_special == 17:
			_addi(d, 4, 8)
			_add_empire_relation(w, 1, -1)
			_add_empire_relation(w, 0, -1)
		elif p.trait_special == 18:
			_addi(d, 26, 10)
			_addi(d, 1, 15)
			_addi(d, 8, -3)
		elif p.trait_special == 19:
			_addi(d, 1, 4)
			_addi(d, 4, 6)
			_addi(d, 8, -1)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_special == 31:
			if p.trait_personality == 0:
				_addi(d, 1, -5)
				_addi(d, 3, 8)
				_addi(d, 4, -6)
			elif p.trait_personality == 20:
				_addi(d, 1, 3)
				_addi(d, 3, 5)
				_addi(d, 4, -3)
			elif p.trait_personality == 1:
				_addi(d, 1, 6)
				_addi(d, 3, 3)
				_addi(d, 4, 3)
			elif p.trait_personality == 2:
				_addi(d, 1, 8)
				_addi(d, 3, -5)
				_addi(d, 4, 5)
			elif p.trait_personality == 3:
				_addi(d, 1, -8)
				_addi(d, 3, -10)
				_addi(d, 4, 10)
		elif p.trait_special == 32:
			_addi(d, 3, 20)
			_addi(d, 4, -10)
		elif p.trait_special == 33:
			_addi(d, 1, 5)
			_add_empire_relation(w, 0, 6)
			_add_empire_relation(w, 1, 6)
		elif p.trait_special == 34:
			_addi(d, 1, -10)
			_addi(d, 3, -8)
			_addi(d, 4, -15)
			_addi(d, 57, -6)
		elif p.trait_special == 35:
			_addi(d, 1, -8)
			_addi(d, 3, -6)
			_addi(d, 9, 6)
		elif p.trait_special == 36:
			_addi(d, 1, -4)
			_addi(d, 3, -4)
			_addi(d, 4, -10)
			_addi(d, 22, 6)
			_addi(d, 5, -5)
			_add_empire_relation(w, 1, -3)
			_add_empire_relation(w, 0, -3)
		elif p.trait_special == 37:
			_addi(d, 1, 8)
			_addi(d, 4, 3)
			_add_empire_relation(w, 1, 2)
			_add_empire_relation(w, 0, 2)
		elif p.trait_special == 38:
			_addi(d, 1, 6)
			_addi(d, 4, -8)
			_addi(d, 5, -4)

func _in_central_office(w: WorldState, idx: int) -> bool:
	for pos in [3, 4, 5, 6, 7]:
		if w.politics_positions.size() > pos and w.politics_positions[pos] == idx:
			return true
	return false


func _is_foreign_minister(w: WorldState, idx: int) -> bool:
	return w.politics_positions.size() > 2 and w.politics_positions[2] == idx

func _is_premier(w: WorldState, idx: int) -> bool:
	return w.politics_positions.size() > 1 and w.politics_positions[1] == idx


func _is_chairman(w: WorldState, idx: int) -> bool:
	return w.politics_positions.size() > 0 and w.politics_positions[0] == idx


func _faction_leader_slot(w: WorldState, idx: int) -> int:
	for fi in w.factions.size():
		if w.factions[fi] != null and w.factions[fi].leader_index == idx:
			return fi
	return -1


func _addi(d: Array, idx: int, delta: int) -> void:
	if d.size() > idx:
		d[idx] += delta


func _add_ideology(w: WorldState, idx: int, delta: int) -> void:
	if w.factions.size() > idx and w.factions[idx] != null:
		w.factions[idx].ideology += delta

func _ideology_total(w: WorldState) -> int:
	var total := 0
	for k in 5:
		if w.factions.size() > k and w.factions[k] != null:
			total += w.factions[k].ideology
	return total


@warning_ignore("integer_division")
func _add_ideology_share(w: WorldState, idx: int, divisor: int) -> void:
	if w.factions.size() > idx and w.factions[idx] != null:
		w.factions[idx].ideology += _ideology_total(w) / divisor


func _set_ideology(w: WorldState, idx: int, value: int) -> void:
	if w.factions.size() > idx and w.factions[idx] != null:
		w.factions[idx].ideology = value


func _count_tag(w: WorldState, tag: String) -> int:
	var count := 0
	for c in w.countries:
		if c != null and c.has_tag(tag):
			count += 1
	return count


## ModifiesInfuence.cs:2362-2530 的 51 号修正石油消费公式。
func _apply_modifier51_oil(d: Array, w: WorldState) -> void:
	var ind := _dv(d, W.I_INDUSTRY)
	var agr := _dv(d, W.I_AGRICULTURE)
	var srv := _dv(d, W.I_SERVICES)
	var army := _dv(d, W.I_ARMY)
	var oil := 0.0
	oil += float(ind) * 0.4
	oil += (float(ind - 499) * 0.4) if ind >= 500 else 0.0
	oil += (float(ind - 749) * 0.4) if ind >= 750 else 0.0
	oil += (float(agr - 249) * 0.35) if agr >= 250 else 0.0
	oil += (float(agr - 499) * 0.35) if agr >= 500 else 0.0
	oil += (float(agr - 749) * 0.35) if agr >= 750 else 0.0
	oil += (float(srv - 499) * 0.34) if srv >= 500 else 0.0
	oil += (float(srv - 749) * 0.34) if srv >= 750 else 0.0
	oil += 500.0 if army >= 1000 else float(army) * 0.5
	oil += float(_dv(d, W.I_LIVING)) * 0.05
	oil += float(w.army_power)
	for tech in [[2, 35.0], [3, 30.0], [6, 20.0], [7, 40.0], [8, 25.0], [10, -20.0], [11, -35.0], [13, -60.0], [14, -60.0]]:
		var tidx: int = tech[0]
		if w.techs != null and w.techs.unlocked.size() > tidx and w.techs.unlocked[tidx]:
			oil += float(tech[1])
	if oil <= 200.0:
		oil = 200.0
	w.oil_eat = oil
	var raw := float(_dv(d, 143))
	var price := raw
	if gm._mod_active(w, 58) and not gm._mod_active(w, 16) and _dv(d, 153) <= 0:
		price -= 15.0
	for idx in [14, 8, 35, 40, 30, 83, 52]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("亲中"):
			price -= 1.0
	if price < 10.0:
		price = 10.0
	if oil - w.oil_prod > 0.0:
		d[W.I_BUDGET] -= int(price * 7.7 * (oil - w.oil_prod) / 10000.0)
	else:
		d[W.I_BUDGET] -= int(raw * 7.7 * (oil - w.oil_prod) / 10000.0)
	var sov_price := raw
	for idx in [14, 8, 35, 40, 30, 83]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("亲苏"):
			sov_price -= 1.0
	if sov_price < 10.0:
		sov_price = 10.0
	var d160 := _dv(d, 160)
	if d160 > 0:
		w.empires[EmpireData.USSR].money += int(raw * 7.7 * float(d160) / 100000.0)
	else:
		w.empires[EmpireData.USSR].money += int(sov_price * 7.7 * float(d160) / 100000.0)
	var usa_price := raw
	for idx in [14, 8, 35, 40, 30, 83]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("亲美"):
			usa_price -= 1.0
	if usa_price < 10.0:
		usa_price = 10.0
	var d161 := _dv(d, 161)
	if d161 > 0:
		w.empires[EmpireData.USA].money += int(raw * 7.7 * float(d161) / 100000.0)
	else:
		w.empires[EmpireData.USA].money += int(usa_price * 7.7 * float(d161) / 100000.0)
	if raw - 50.0 > 0.0:
		WarSystem.add_empire_power(EmpireData.USA, -((int(raw) - 10) / 3))
		WarSystem.add_empire_power(EmpireData.USSR, (int(raw) - 10) / 3)
	elif raw - 20.0 > 0.0 and raw - 50.0 <= 0.0:
		WarSystem.add_empire_power(EmpireData.USA, (int(raw) - 10) / 3)
		WarSystem.add_empire_power(EmpireData.USSR, (int(raw) - 10) / 3)
	elif w.date.year < 1980:
		WarSystem.add_empire_power(EmpireData.USA, (int(raw) - 10) / 2)
		WarSystem.add_empire_power(EmpireData.USSR, -((int(raw) - 10) / 2))
	else:
		WarSystem.add_empire_power(EmpireData.USA, int(raw) - 10)
		WarSystem.add_empire_power(EmpireData.USSR, -((int(raw) - 10) * 2))


func _add_empire_relation(w: WorldState, idx: int, delta: int) -> void:
	if w.empires.size() > idx and w.empires[idx] != null:
		w.empires[idx].relations += delta

func _rel(w: WorldState, idx: int) -> int:
	if w.empires.size() > idx and w.empires[idx] != null:
		return w.empires[idx].relations
	return 0


func _emp_pow(w: WorldState, idx: int) -> int:
	if w.empires.size() > idx and w.empires[idx] != null:
		return w.empires[idx].power
	return 0


## TimeScript.cs:9871-9990 MutualRelationsChange 逐字移植（dlc[0] 恒 true 分支）。
func _fortnight_mutual_relations(d: Array[int], w: WorldState) -> void:
	var china := w.get_country_by_legacy_index(1)
	var science32: bool = w.techs != null and w.techs.unlocked.size() > 32 and w.techs.unlocked[32]
	var div45 := 45 if not science32 else 40
	var div40 := 40 if not science32 else 35
	var div30 := 30 if not science32 else 25
	var div15 := 15 if not science32 else 10
	var div20 := 20 if not science32 else 15
	var div25 := 25 if not science32 else 20
	var base := _dv(d, W.I_BUDGET_DIPLO)
	var usa := w.empires[0] if w.empires.size() > 0 else null
	var ussr := w.empires[1] if w.empires.size() > 1 else null
	if usa != null:
		if china != null and china.has_tag("ovd") and usa.relations > 650:
			usa.relations += base / div45
		elif china != null and (china.has_tag("sev") or china.has_tag("okb")) and usa.relations > 650:
			usa.relations += base / div40
		elif ussr != null and ussr.relations > 750 and not gm._mod_active(w, 17):
			usa.relations += base / div30
		elif usa.relations < 200 and gm._mod_active(w, 17):
			usa.relations += base / div15
		elif usa.relations < 400:
			usa.relations += base / div20
		else:
			usa.relations += base / div25
	if ussr != null:
		var usa_trade := w.get_country_by_legacy_index(51)
		if china != null and (china.has_tag("亲美") or (usa_trade != null and usa_trade.development == 1)) and ussr.relations > 650:
			ussr.relations += base / div45
		elif usa_trade != null and (usa_trade.has_tag("对华贸易") or (china != null and china.has_tag("okb"))) and ussr.relations > 650:
			ussr.relations += base / div40
		elif usa != null and usa.relations > 750 and not gm._mod_active(w, 17):
			ussr.relations += base / div30
		elif ussr.relations < 200 and gm._mod_active(w, 17):
			ussr.relations += base / div15
		elif ussr.relations < 400:
			ussr.relations += base / div20
		else:
			ussr.relations += base / div25
	# dlc[0] 恒 true → 只移植 else 分支（TimeScript.cs:9935-9975）。
	if usa != null and ussr != null:
		if usa.relations < 750 and usa.relations > 700 and ussr.relations > 300:
			ussr.relations -= 10
		elif usa.relations > 650:
			ussr.relations -= 5
		if ussr.relations < 750 and ussr.relations > 650 and usa.relations > 350:
			usa.relations -= 20
		elif ussr.relations < 750 and ussr.relations > 650:
			usa.relations -= 10
	if usa != null and usa.relations < 700:
		usa.relations += _dv(d, W.I_LOAN) / 20


## TimeScript.cs:3243-3247（双周块）：SOV_PRC_PartiesConnection>0 时
## empires[1].relations += SOV_PRC_PartiesConnection / 10。
## 端口映射：I_COMMUNICATIONS（data[30]，外交通信结构恢复度）。
func _fortnight_comms_relations(d: Array[int], w: WorldState) -> void:
	if w == null or w.empires.size() <= EmpireData.USSR or w.empires[EmpireData.USSR] == null:
		return
	var conn := _dv(d, W.I_COMMUNICATIONS)
	if conn <= 0:
		return
	@warning_ignore("integer_division")
	w.empires[EmpireData.USSR].relations += conn / 10


## TimeScript.cs:6200-6231 AfricanBotSupport 逐字移植（调用点 TimeScript.cs:1040，每日一次）：
## 外交支出 data[81] 对非洲亲中国家提供稳定/削弱美苏影响；支出不足时亲中势力回退。
func _african_bot_support(d: Array[int], w: WorldState) -> void:
	if w == null:
		return
	var science32: bool = w.techs != null and w.techs.unlocked.size() > 32 and w.techs.unlocked[32]
	var base := _dv(d, W.I_BUDGET_DIPLO)
	var usa := w.empires[0] if w.empires.size() > 0 else null
	var ussr := w.empires[1] if w.empires.size() > 1 else null
	for i in range(53, 109):
		if i >= 69 and i <= 105:
			continue
		var c := w.get_country_by_legacy_index(i)
		if c == null or c.禁用非洲机制:
			continue
		if c.has_tag("亲中"):
			@warning_ignore("integer_division")
			var bonus := base / 2 if science32 else base / 3
			if c.stab < 1000:
				c.stab += bonus
			if c.usa_power > 0:
				c.usa_power -= bonus
			if c.sov_power > 0:
				c.sov_power -= bonus
			if _dv(d, W.I_ARMY) > (ussr.money if ussr != null else 0) and c.stab < 1000:
				c.stab += 25
			if _dv(d, W.I_ARMY) > (usa.money if usa != null else 0) and c.stab < 1000:
				c.stab += 25
		elif base < 50 and c.prc_power >= 500 and not science32:
			c.prc_power -= 60 - base


## ModifiesInfuence.cs:510-1198 的 2 号修正「服务业的发展进程」逐字移植。
## 寡头三档 + 教育路线(669) + 高校招生(456) + 合作医疗(646) + 票证分档 + 六项国策。
func _apply_modifier2_services(d: Array[int], w: WorldState) -> void:
	var oligarch := _dv(d, W.I_OLIGARCH)
	if oligarch < 54:
		pass  # 投机倒把的商人还影响不到我们
	elif oligarch < 72:
		d[W.I_PEOPLE_SUPPORT] -= 5
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_LIVING] -= 5
		d[W.I_AGENTS] -= 2
	else:
		d[W.I_PEOPLE_SUPPORT] -= 10
		d[W.I_THOUGHT_FREEDOM] += 20
		d[W.I_LIVING] -= 10
		d[W.I_AGENTS] -= 2
	# 教育路线（Event669）
	if not w.event_done_num(669):
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_BUDGET] -= 1
		d[W.I_INDUSTRY] += 2
		d[W.I_AGRICULTURE] += 2
		d[W.I_SCIENCE] += 5
	elif w.result_of_event_num(669) == 0:
		d[W.I_PEOPLE_SUPPORT] += 3
		d[W.I_BUDGET] -= 2
		d[W.I_INDUSTRY] += 3
		d[W.I_AGRICULTURE] += 3
		d[W.I_SCIENCE] += 10
	elif w.result_of_event_num(669) == 1:
		d[W.I_BUDGET] -= 1
		d[W.I_CORRUPTION] += 1
		d[W.I_SCIENCE] += 15
	elif w.result_of_event_num(669) == 2:
		d[W.I_BUDGET] += 2
		d[W.I_OLIGARCH] += 1
		d[W.I_CORRUPTION] += 1
		d[W.I_SCIENCE] += 20
	elif w.result_of_event_num(669) == 3:
		d[W.I_ARMY] += 3
		d[W.I_PEOPLE_SUPPORT] += 1
		d[W.I_THOUGHT_FREEDOM] -= 1
		d[W.I_SCIENCE] -= 20
		d[W.I_MANPOWER] += 50
		d[W.I_WAR_SUPPORT] += 50
	# 高校招生（Event456）
	if w.event_done_num(456) and w.result_of_event_num(456) == 0:
		d[W.I_SCIENCE] += 20
	elif w.event_done_num(456) and w.result_of_event_num(456) == 1:
		d[W.I_SCIENCE] += 10
	elif not w.event_done_num(456) or w.result_of_event_num(456) == 2:
		d[W.I_AGRICULTURE] += 3
		d[W.I_INDUSTRY] += 3
	# 合作医疗（Event646）
	if not w.event_done_num(646):
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_BUDGET] -= 1
		d[W.I_INDUSTRY] += 2
		d[W.I_AGRICULTURE] += 3
		d[W.I_SERVICES] += 2
	elif w.result_of_event_num(646) == 0:
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_BUDGET] -= 2
		d[W.I_INDUSTRY] += 3
		d[W.I_AGRICULTURE] += 4
		d[W.I_SERVICES] += 3
	elif w.result_of_event_num(646) == 1:
		d[W.I_BUDGET] += 2
		d[W.I_LIVING] += 1
		d[W.I_OLIGARCH] += 1
		d[W.I_SERVICES] += 1
	# 票证制度自动废止（原版在 modifier2 块内，data16==15 时无需点决策40）
	if _dv(d, W.I_ECON_SYSTEM) == 15 \
			and (not w.has_coupon_system_phase_out
				or (w.decisions != null and w.decisions.completed.size() > 40 and not w.decisions.completed[40])):
		w.has_coupon_system_phase_out = true
		if w.decisions != null and w.decisions.completed.size() > 40:
			w.decisions.completed[40] = true
	if not w.has_coupon_system_phase_out:
		d[W.I_AGRICULTURE] += 1
		d[W.I_PARTY_SUPPORT] += 2
		_apply_coupon_tiers(d, w)
	else:
		d[W.I_CORRUPTION] -= 2
		d[W.I_SERVICES] += 3
		d[W.I_PEOPLE_SUPPORT] += 5
		d[W.I_THOUGHT_FREEDOM] += 5
	# 六项国策的取消条件（ModifiesInfuence.cs:1094-1130）
	if w.planned_price_reduction > 0 and (_dv(d, W.I_ECON_SYSTEM) > 11 or _dv(d, W.I_RESERVE) <= 0):
		w.planned_price_reduction = 0
		_set_decision_flag(w, 41, false)
	if w.austerity > 0 and (_dv(d, W.I_ECON_SYSTEM) > 13 or _dv(d, W.I_LOAN) <= 0):
		w.austerity = 0
		_set_decision_flag(w, 42, false)
	if w.developed_consumerism > 0 and (_dv(d, W.I_ECON_SYSTEM) <= 13 or _dv(d, W.I_RESERVE) <= 0):
		w.developed_consumerism = 0
		_set_decision_flag(w, 43, false)
	if w.new_era_commune_member > 0 and (_dv(d, W.I_BUDGET_ENVELOPE) > 0 or _dv(d, W.I_CORRUPTION) >= 50):
		w.new_era_commune_member = 0
		_set_decision_flag(w, 44, false)
	if w.party_means_party > 0 and (_dv(d, W.I_BUDGET_ENVELOPE) < 100 or _dv(d, W.I_PARTY_SYSTEM) == 9):
		w.party_means_party = 0
		_set_decision_flag(w, 45, false)
	if w.party_subsidy > 0 and (_dv(d, W.I_PARTY_SYSTEM) < 8 or _dv(d, W.I_RESERVE) <= 0):
		w.party_subsidy = 0
		_set_decision_flag(w, 46, false)
	# 六项国策结算（ModifiesInfuence.cs:1132-1198）
	if w.planned_price_reduction > 0:
		d[W.I_BUDGET] -= 3
		d[W.I_INDUSTRY] -= 3
		d[W.I_AGRICULTURE] -= 3
		d[W.I_SERVICES] -= 3
		d[W.I_LIVING] += 20
		d[W.I_PEOPLE_SUPPORT] += 20
		d[W.I_THOUGHT_FREEDOM] -= 20
		d[W.I_MANPOWER] += 10
	if w.austerity > 0:
		if d[W.I_PEOPLE_SUPPORT] > 650:
			d[W.I_PEOPLE_SUPPORT] = 650
		if d[W.I_LIVING] > 650:
			d[W.I_LIVING] = 650
		d[W.I_BUDGET] += 20
		d[W.I_LIVING] -= 10
		d[W.I_PEOPLE_SUPPORT] -= 10
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_MANPOWER] -= 10
		d[W.I_SERVICES] -= 10
		d[W.I_DIPLO] += 1
		d[W.I_POPULATION] -= 2
	if w.developed_consumerism > 0:
		d[W.I_BUDGET] -= 25
		d[W.I_LIVING] += 10
		d[W.I_PEOPLE_SUPPORT] += 10
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_INDUSTRY] += 10
		d[W.I_SERVICES] += 10
		_add_empire_relation(w, EmpireData.USA, 2)
	if w.new_era_commune_member > 0:
		d[W.I_BUDGET] += 5
		d[W.I_PARTY_SUPPORT] -= 25
		d[W.I_PEOPLE_SUPPORT] += 10
		d[W.I_CORRUPTION] -= 10
		d[W.I_MANPOWER] += 5
	if w.party_means_party > 0:
		d[W.I_BUDGET] -= 10
		d[W.I_PARTY_SUPPORT] += 20
		d[W.I_PEOPLE_SUPPORT] -= 15
		d[W.I_THOUGHT_FREEDOM] += 5
		d[W.I_CORRUPTION] += 6
		for p in w.politicians:
			if p != null and not PoliticianSystem.is_vacant_politician(p):
				p.loyalty += 10
	if w.party_subsidy > 0:
		d[W.I_BUDGET] -= 10
		d[W.I_PARTY_SUPPORT] += 20
		d[W.I_THOUGHT_FREEDOM] -= 5
		d[W.I_CORRUPTION] += 5
		d[W.I_MANPOWER] += 10
		for p in w.politicians:
			if p != null and not PoliticianSystem.is_vacant_politician(p):
				p.loyalty += 10


## 票证制度按经济体制与工农业产值分档结算（ModifiesInfuence.cs:670-1092）。
func _apply_coupon_tiers(d: Array[int], w: WorldState) -> void:
	var sum := _dv(d, W.I_INDUSTRY) + _dv(d, W.I_AGRICULTURE)
	var econ := _dv(d, W.I_ECON_SYSTEM)
	if econ <= 11:
		if sum < 400:
			d[W.I_PEOPLE_SUPPORT] += 3
			d[W.I_MANPOWER] += 3
			d[W.I_BUDGET] += 3
		elif sum < 700:
			d[W.I_PEOPLE_SUPPORT] += 2
			d[W.I_MANPOWER] += 2
			d[W.I_BUDGET] += 2
		elif sum < 900:
			d[W.I_PEOPLE_SUPPORT] += 1
			d[W.I_MANPOWER] += 1
			d[W.I_BUDGET] += 1
		elif sum < 1300:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_BUDGET] += 1
		elif sum < 1500:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_BUDGET] += 2
		elif sum < 1600:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_CORRUPTION] += 1
		elif sum < 1700:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_CORRUPTION] += 2
		elif sum < 1800:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 3
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1900:
			d[W.I_PEOPLE_SUPPORT] -= 4
			d[W.I_CORRUPTION] += 4
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 2000:
			d[W.I_PEOPLE_SUPPORT] -= 5
			d[W.I_CORRUPTION] += 5
			d[W.I_THOUGHT_FREEDOM] += 4
			if not w.event_done_num(5):
				gm.start_event("popular_discontent")
		else:
			d[W.I_PEOPLE_SUPPORT] -= 6
			d[W.I_CORRUPTION] += 6
			d[W.I_THOUGHT_FREEDOM] += 5
			if d[W.I_THOUGHT_FREEDOM] > 400 or not w.event_done_num(5):
				gm.start_event("popular_discontent")
	elif econ <= 13:
		if sum < 400:
			d[W.I_PARTY_SUPPORT] += 3
			d[W.I_MANPOWER] += 3
			d[W.I_BUDGET] += 3
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 700:
			d[W.I_PARTY_SUPPORT] += 2
			d[W.I_MANPOWER] += 2
			d[W.I_BUDGET] += 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 900:
			d[W.I_PARTY_SUPPORT] += 1
			d[W.I_MANPOWER] += 1
			d[W.I_BUDGET] += 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1000:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_BUDGET] += 1
		elif sum < 1100:
			d[W.I_LIVING] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1200:
			d[W.I_LIVING] -= 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1300:
			d[W.I_LIVING] -= 3
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 1400:
			d[W.I_LIVING] -= 4
			d[W.I_THOUGHT_FREEDOM] += 4
			d[W.I_PEOPLE_SUPPORT] -= 1
		elif sum < 1500:
			d[W.I_LIVING] -= 5
			d[W.I_THOUGHT_FREEDOM] += 5
			d[W.I_PEOPLE_SUPPORT] -= 1
		elif sum < 1600:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_CORRUPTION] += 1
			d[W.I_LIVING] -= 5
		elif sum < 1700:
			d[W.I_PEOPLE_SUPPORT] -= 2
			# 原版此处 data[26] += 2 出现两次、data[5] += 2（文案却写生活-0.5），逐字保留。
			d[W.I_CORRUPTION] += 4
			d[W.I_LIVING] += 2
		elif sum < 1800:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 3
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1900:
			d[W.I_PEOPLE_SUPPORT] -= 4
			d[W.I_CORRUPTION] += 4
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 2000:
			d[W.I_PEOPLE_SUPPORT] -= 5
			d[W.I_CORRUPTION] += 5
			d[W.I_THOUGHT_FREEDOM] += 4
			if not w.event_done_num(5):
				gm.start_event("popular_discontent")
		else:
			d[W.I_PEOPLE_SUPPORT] -= 6
			d[W.I_CORRUPTION] += 6
			d[W.I_THOUGHT_FREEDOM] += 5
			if d[W.I_THOUGHT_FREEDOM] > 400 or not w.event_done_num(5):
				gm.start_event("popular_discontent")
	elif econ == 14:
		if sum < 400:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_THOUGHT_FREEDOM] += 3
		elif sum < 700:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 900:
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1000:
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_BUDGET] += 1
		elif sum < 1100:
			d[W.I_LIVING] -= 1
			d[W.I_THOUGHT_FREEDOM] += 1
		elif sum < 1200:
			d[W.I_LIVING] -= 2
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1300:
			d[W.I_LIVING] -= 3
			d[W.I_CORRUPTION] += 1
		elif sum < 1400:
			d[W.I_PEOPLE_SUPPORT] -= 2
		elif sum < 1500:
			d[W.I_LIVING] -= 4
			d[W.I_CORRUPTION] += 2
		elif sum < 1600:
			# 原版此处没有 data[3] 扣减（文案写人民-0.1），逐字保留。
			d[W.I_CORRUPTION] += 1
			d[W.I_LIVING] -= 5
		elif sum < 1700:
			# 原版 data[3]-- 与 data[3] -= 2 连续执行（共 -3），无预算扣减。
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 2
		elif sum < 1800:
			d[W.I_PEOPLE_SUPPORT] -= 3
			d[W.I_CORRUPTION] += 3
			d[W.I_THOUGHT_FREEDOM] += 2
		elif sum < 1900:
			d[W.I_PEOPLE_SUPPORT] -= 4
			d[W.I_CORRUPTION] += 4
			d[W.I_THOUGHT_FREEDOM] += 3
			d[W.I_BUDGET] -= 2
		elif sum < 2000:
			d[W.I_PEOPLE_SUPPORT] -= 5
			d[W.I_CORRUPTION] += 5
			d[W.I_THOUGHT_FREEDOM] += 4
			d[W.I_BUDGET] -= 3
			if not w.event_done_num(5):
				gm.start_event("popular_discontent")
		else:
			d[W.I_PEOPLE_SUPPORT] -= 6
			d[W.I_CORRUPTION] += 6
			d[W.I_THOUGHT_FREEDOM] += 5
			d[W.I_BUDGET] -= 3
			if d[W.I_THOUGHT_FREEDOM] > 400 or not w.event_done_num(5):
				gm.start_event("popular_discontent")


## ModifiesInfuence.cs:1618-1720 的 15 号修正「农业的发展进程」逐字移植。
func _apply_modifier15_agriculture(d: Array[int], w: WorldState) -> void:
	var ev681 := w.event_done_num(681)
	var res681 := w.result_of_event_num(681)
	var ev682 := w.event_done_num(682)
	var res682 := w.result_of_event_num(682)
	if not ev681 or res681 == 0:
		d[W.I_AGRICULTURE] += 1
		d[W.I_SCIENCE] -= 10
		d[W.I_THOUGHT_FREEDOM] += 4
	elif res681 == 1:
		d[W.I_LIVING] -= 1
		d[W.I_THOUGHT_FREEDOM] += 2
	elif res681 == 2:
		d[W.I_BUDGET] -= 7
		d[W.I_PEOPLE_SUPPORT] += 4
		d[W.I_AGRICULTURE] += 4
		d[W.I_INDUSTRY] += 2
		d[W.I_SERVICES] += 2
		d[W.I_LIVING] += 4
	elif res681 == 3:
		d[W.I_BUDGET] += 1
		d[W.I_AGRICULTURE] += 1
		d[W.I_AGENTS] -= 2
		d[W.I_THOUGHT_FREEDOM] -= 2
		d[W.I_DIPLO] += 4
		d[W.I_SCIENCE] -= 10
		# 原版此处两行都是 empires[0].relations -= 10（美国扣两次，共 -20）。
		_add_empire_relation(w, EmpireData.USA, -20)
	elif res681 == 4 and not ev682:
		d[W.I_AGRICULTURE] -= 1
		d[W.I_THOUGHT_FREEDOM] += 3
	elif res682 == 0:
		d[W.I_BUDGET] -= 6
		d[W.I_AGRICULTURE] += 2
		d[W.I_LIVING] += 2
		d[W.I_THOUGHT_FREEDOM] -= 4
	elif res682 == 1:
		d[W.I_BUDGET] += 2
		d[W.I_AGRICULTURE] += 3
		d[W.I_INDUSTRY] += 1
		d[W.I_SERVICES] += 1
		d[W.I_LIVING] += 1
		d[W.I_THOUGHT_FREEDOM] += 12
		d[W.I_DIPLO] -= 2
		_add_empire_relation(w, EmpireData.USA, 2)
		WarSystem.add_empire_power(EmpireData.USA, 1)
		w.influence_prc -= 1
	elif res682 == 2:
		d[W.I_BUDGET] -= 4
		d[W.I_AGRICULTURE] += 3
		d[W.I_SERVICES] += 1
		d[W.I_LIVING] += 1
		d[W.I_AGENTS] += 1
		d[W.I_THOUGHT_FREEDOM] -= 1
	elif res682 == 3:
		d[W.I_BUDGET] += 3
		d[W.I_AGRICULTURE] += 5
		d[W.I_INDUSTRY] -= 4
		d[W.I_SERVICES] -= 2
		d[W.I_LIVING] -= 1
		d[W.I_THOUGHT_FREEDOM] += 2
	elif res682 == 4:
		d[W.I_BUDGET] -= 7
		d[W.I_PEOPLE_SUPPORT] += 4
		d[W.I_AGRICULTURE] += 4
		d[W.I_INDUSTRY] += 2
		d[W.I_SERVICES] += 2
		d[W.I_LIVING] += 4
	elif res682 == 5:
		d[W.I_BUDGET] += 10
		d[W.I_AGRICULTURE] += 3
		d[W.I_INDUSTRY] += 2
		d[W.I_LIVING] -= 6
		d[W.I_PEOPLE_SUPPORT] -= 10
		d[W.I_THOUGHT_FREEDOM] += 10
		_add_empire_relation(w, EmpireData.USA, 2)
		_add_empire_relation(w, EmpireData.USSR, 2)
		w.influence_prc -= 1
	# 公社路线（Event53 + Event682 交叉门控）
	var ev53 := w.event_done_num(53)
	var res53 := w.result_of_event_num(53)
	if (not ev53 or res53 == 0) and (not ev682 or res682 == 4):
		d[W.I_AGRICULTURE] += 1
		d[W.I_INDUSTRY] += 1
		d[W.I_LIVING] += 2
		d[W.I_BUDGET] += 1
	elif res53 == 1:
		d[W.I_BUDGET] += 4
		d[W.I_CORRUPTION] += 3
		if _dv(d, W.I_BUDGET_WELFARE) <= 200:
			d[W.I_AGRICULTURE] -= 2
			d[W.I_LIVING] -= 2
			d[W.I_SERVICES] -= 2
		if _dv(d, W.I_BUDGET_WELFARE) > 200:
			d[W.I_AGRICULTURE] += 2
			d[W.I_LIVING] += 2
			d[W.I_SERVICES] += 2
	elif res53 == 2:
		d[W.I_BUDGET] += 10
		d[W.I_CORRUPTION] += 4
		d[W.I_OLIGARCH] += 4
		d[W.I_AGRICULTURE] -= 4
		d[W.I_LIVING] -= 4
		d[W.I_SERVICES] += 2
	elif res53 == 3 and (not ev682 or res682 == 4):
		d[W.I_AGRICULTURE] += 4
		d[W.I_INDUSTRY] += 4
		d[W.I_LIVING] += 4
		d[W.I_BUDGET] += 2
	# 农业科技三件套
	if w.techs != null and w.techs.unlocked.size() > 3 and w.techs.unlocked[3]:
		d[W.I_AGRICULTURE] += 6
		d[W.I_INDUSTRY] += 4
	if w.techs != null and w.techs.unlocked.size() > 6 and w.techs.unlocked[6]:
		d[W.I_AGRICULTURE] += 3
		d[W.I_LIVING] += 4
	if w.techs != null and w.techs.unlocked.size() > 7 and w.techs.unlocked[7]:
		d[W.I_AGRICULTURE] += 2
		d[W.I_INDUSTRY] += 2
		d[W.I_LIVING] += 4
		d[W.I_BUDGET] += 3


func _set_decision_flag(w: WorldState, idx: int, value: bool) -> void:
	if w.decisions != null and idx >= 0 and idx < w.decisions.completed.size():
		w.decisions.completed[idx] = value


## ModifiesInfuence.cs:27-500 的 50 号修正「军事的发展进程」逐字移植。
## 依据事件 513-521/540/544/545/685 与军购/PMC/机械陆军等状态，每双周结算一次。
func _apply_modifier50_military(d: Array[int], w: WorldState) -> void:
	if not gm._mod_active(w, 50):
		return
	if w.event_done_num(513) and w.techs != null and w.techs.unlocked.size() > 18 and w.techs.unlocked[18]:
		if w.result_of_event_num(513) == 0:
			d[W.I_ARMY] += 1
		elif w.result_of_event_num(513) == 1:
			d[W.I_ARMY] += 2
	if w.event_done_num(514) and w.techs != null and w.techs.unlocked.size() > 23 and w.techs.unlocked[23]:
		match w.result_of_event_num(514):
			0:
				d[W.I_PEOPLE_SUPPORT] += 1
				d[W.I_THOUGHT_FREEDOM] -= 1
				if d[W.I_DIPLO] > 900:
					d[W.I_DIPLO] -= 1
				elif d[W.I_DIPLO] < 700:
					d[W.I_DIPLO] += 1
			1:
				d[W.I_PEOPLE_SUPPORT] += 1
				d[W.I_THOUGHT_FREEDOM] += 1
				d[W.I_DIPLO] -= 2
			2:
				d[W.I_PEOPLE_SUPPORT] += 1
				d[W.I_THOUGHT_FREEDOM] -= 2
				d[W.I_DIPLO] += 2
	if w.event_done_num(345):
		match w.result_of_event_num(345):
			0:
				d[W.I_PEOPLE_SUPPORT] += 3
				d[W.I_ARMY] += 2
				d[W.I_MIL_INTERVENTION] += 2
			1:
				d[W.I_BUDGET] -= 1
				d[W.I_ARMY] += 5
				d[W.I_MIL_INTERVENTION] += 2
				d[W.I_CORRUPTION] += 2
	if w.event_done_num(515) and w.result_of_event_num(515) == 0:
		d[W.I_AGENTS] += 1
		d[W.I_ARMY] += 2
	if w.event_done_num(516):
		match w.result_of_event_num(516):
			0:
				d[W.I_ARMY] += 3
				d[W.I_BUDGET] -= 1
			1:
				d[W.I_ARMY] += 6
				d[W.I_BUDGET] -= 2
				d[W.I_MANPOWER] += 2
	if w.event_done_num(517):
		match w.result_of_event_num(517):
			0:
				d[W.I_ARMY] += 3
				d[W.I_BUDGET] -= 2
				d[W.I_PEOPLE_SUPPORT] += 2
			1:
				d[W.I_ARMY] += 5
				d[W.I_BUDGET] -= 2
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
			2:
				d[W.I_ARMY] += 10
				d[W.I_PEOPLE_SUPPORT] += 3
				d[W.I_BUDGET] -= 3
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
	if w.event_done_num(518):
		match w.result_of_event_num(518):
			0:
				d[W.I_ARMY] += 2
				d[W.I_PEOPLE_SUPPORT] += 2
				d[W.I_BUDGET] -= 2
				d[W.I_MIL_INTERVENTION] += 10
			1:
				d[W.I_ARMY] += 3
				d[W.I_BUDGET] -= 2
				_add_empire_relation(w, 0, -1)
				_add_empire_relation(w, 1, -1)
				d[W.I_MIL_INTERVENTION] += 10
			2:
				d[W.I_ARMY] += 8
				d[W.I_PEOPLE_SUPPORT] += 2
				d[W.I_BUDGET] -= 3
				_add_empire_relation(w, 0, -1)
				_add_empire_relation(w, 1, -1)
				d[W.I_MIL_INTERVENTION] += 10
	if w.event_done_num(519):
		match w.result_of_event_num(519):
			0:
				d[W.I_ARMY] += 18
				d[W.I_PEOPLE_SUPPORT] += 5
				d[W.I_BUDGET] -= 4
			1:
				d[W.I_ARMY] += 15
				d[W.I_PEOPLE_SUPPORT] += 2
				d[W.I_BUDGET] -= 3
			2:
				d[W.I_ARMY] += 35
				d[W.I_PEOPLE_SUPPORT] += 10
				d[W.I_BUDGET] -= 5
	if w.event_done_num(520):
		match w.result_of_event_num(520):
			0:
				d[W.I_ARMY] += 20
				d[W.I_PEOPLE_SUPPORT] += 5
				_add_empire_relation(w, 0, -3)
				_add_empire_relation(w, 1, -3)
			1:
				d[W.I_ARMY] += 50
				d[W.I_BUDGET] -= 5
				d[W.I_PEOPLE_SUPPORT] += 8
				_add_empire_relation(w, 0, -4)
				_add_empire_relation(w, 1, -4)
			2:
				d[W.I_ARMY] += 10
				d[W.I_PEOPLE_SUPPORT] += 10
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
	if w.event_done_num(521):
		match w.result_of_event_num(521):
			0:
				d[W.I_ARMY] += 30
				d[W.I_PEOPLE_SUPPORT] += 10
				w.influence_prc += 5
			1:
				d[W.I_ARMY] += 30
				d[W.I_MIL_INTERVENTION] += 20
				d[W.I_PEOPLE_SUPPORT] += 10
				w.influence_prc += 5
			2:
				d[W.I_ARMY] += 50
				d[W.I_PEOPLE_SUPPORT] += 25
				d[W.I_MIL_INTERVENTION] += 30
				w.influence_prc += 10
	if w.event_done_num(540):
		match w.result_of_event_num(540):
			0:
				d[W.I_ARMY] += 4
				d[W.I_MIL_INTERVENTION] += 2
			1:
				d[W.I_ARMY] += 2
				d[W.I_MIL_INTERVENTION] += 2
	if w.event_done_num(544):
		match w.result_of_event_num(544):
			0:
				d[W.I_ARMY] += 7
				d[W.I_DIPLO] -= 5
			1:
				d[W.I_ARMY] += 20
				_add_empire_relation(w, 0, -2)
				_add_empire_relation(w, 1, -2)
			2:
				d[W.I_ARMY] += 40
				_add_empire_relation(w, 0, -4)
				_add_empire_relation(w, 1, -4)
	if w.event_done_num(545):
		match w.result_of_event_num(545):
			0:
				d[W.I_ARMY] += 10
			1:
				d[W.I_LIVING] += 10
				d[W.I_PEOPLE_SUPPORT] += 10
				d[W.I_THOUGHT_FREEDOM] -= 5
			2:
				d[W.I_ARMY] += 20
				d[W.I_LIVING] += 15
				d[W.I_PEOPLE_SUPPORT] += 15
				d[W.I_THOUGHT_FREEDOM] -= 10
	if w.event_done_num(685):
		match w.result_of_event_num(685):
			0:
				_add_empire_relation(w, 0, 2)
				_add_empire_relation(w, 1, 2)
				d[W.I_ARMY] -= 4
				d[W.I_AGENTS] += 2
				d[W.I_THOUGHT_FREEDOM] += 2
				if d[W.I_DIPLO] > 900:
					d[W.I_DIPLO] -= 2
				elif d[W.I_DIPLO] < 500:
					d[W.I_DIPLO] += 2
			1:
				_add_empire_relation(w, 0, 1)
				_add_empire_relation(w, 1, 1)
				d[W.I_ARMY] -= 2
				if d[W.I_DIPLO] > 900:
					d[W.I_DIPLO] -= 1
				elif d[W.I_DIPLO] < 500:
					d[W.I_DIPLO] += 1
				d[W.I_BUDGET] -= 40
				d[W.I_ARMY] += 20
				d[W.I_PEOPLE_SUPPORT] += 10
				d[W.I_LIVING] += 6
				d[W.I_MIL_INTERVENTION] += 40
				d[W.I_SCIENCE] += 100
			2:
				_add_empire_relation(w, 0, -1)
				_add_empire_relation(w, 1, -1)
				d[W.I_DIPLO] += 2
	# 军购协定 / PMC / 机械陆军 / 军力封顶（ModifiesInfuence.cs:433-500）
	# 433-442 取消分支：条件满足时清零协定/PMC 并撤销对应国策标记。
	if w.arms_purchase_agreement > 0:
		var ussr_c := w.get_country_by_legacy_index(7)
		var china := w.get_country_by_legacy_index(1)
		var usa_c := w.get_country_by_legacy_index(51)
		var ussr_e := w.empires[EmpireData.USSR] if w.empires.size() > EmpireData.USSR else null
		if ussr_c != null and ussr_c.sub_government != GameConstants.SubGovernment.RENEWAL_SOCIALIST \
				and (china != null and (china.government == GameConstants.Government.LIBERAL
					or (usa_c != null and usa_c.has_tag("对华贸易"))
					or (ussr_e != null and ussr_e.relations < 500))):
			w.arms_purchase_agreement = 0
			if w.decisions != null and w.decisions.completed.size() > 47:
				w.decisions.completed[47] = false
	if w.pmc > 0 and (d[W.I_ECON_SYSTEM] <= 13 or d[W.I_ARMY] < 50 or d[W.I_MIL_DOCTRINE] != 33):
		w.pmc = 0
		if w.decisions != null and w.decisions.completed.size() > 48:
			w.decisions.completed[48] = false
	if w.arms_purchase_agreement > 0:
		d[W.I_BUDGET] -= 6
		d[W.I_ARMY] += 12
		d[W.I_SCIENCE] += 5
		_add_empire_relation(w, 1, 8)
		if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR] != null:
			w.empires[EmpireData.USSR].money += 6
			w.empires[EmpireData.USSR].power += 1
	if w.pmc > 0:
		d[W.I_BUDGET] += 10
		d[W.I_ARMY] -= 10
		d[W.I_BUDGET] += 2
		d[W.I_CORRUPTION] += 2
		for ei in range(2):
			if w.empires.size() > ei and w.empires[ei] != null:
				if w.empires[ei].relations < 250:
					w.empires[ei].relations = 250
				elif w.empires[ei].relations > 750:
					w.empires[ei].relations = 750
	var c16 := w.get_country_by_legacy_index(16)
	if c16 != null and c16.prc_influence != 0:
		d[W.I_ARMY] += 5
		d[W.I_AGENTS] += 3
		d[W.I_MIL_INTERVENTION] += 10
		d[W.I_BUDGET] -= 8
		d[W.I_SCIENCE] -= 2
		d[W.I_PEOPLE_SUPPORT] += 10
	if d[W.I_ARMY] >= 2000:
		@warning_ignore("integer_division")
		var num41 := (d[W.I_ARMY] - 2000) / 100
		d[W.I_ARMY] -= 10 * num41
		d[W.I_BUDGET] += 2 * num41
		d[W.I_AGENTS] += 2 * num41
		d[W.I_RESERVE] += 2 * num41


func _apply_tech_periodic(w: WorldState) -> void:
	if w.techs == null:
		return
	var d := w.数值表
	var u := w.techs.unlocked
	if u.size() < w.techs.TECH_COUNT:
		return
	if u[0]: d[W.I_LIVING] += 2; d[W.I_AGRICULTURE] += 1
	if u[1]: d[W.I_AGRICULTURE] += 2
	if u[2]: d[W.I_LIVING] += 1; d[W.I_AGRICULTURE] += 1; d[W.I_BUDGET] += 1
	if u[3]: d[W.I_LIVING] += 2; d[W.I_AGRICULTURE] += 1
	if u[4]: d[W.I_LIVING] += 4; d[W.I_AGRICULTURE] += 5
	if u[5]: d[W.I_LIVING] += 2; d[W.I_SCIENCE] += 10
	if u[6]: d[W.I_LIVING] += 2; d[W.I_AGRICULTURE] += 1
	if u[7]: d[W.I_LIVING] += 2; d[W.I_BUDGET] += 1
	if u[8]: d[W.I_AGRICULTURE] += 2
	if u[9]: d[W.I_BUDGET] += 1; d[W.I_INDUSTRY] += 2
	if u[10]: d[W.I_BUDGET] += 1; d[W.I_ARMY] += 4; d[W.I_INDUSTRY] += 2
	if u[11]: d[W.I_LIVING] += 2
	if u[12]: d[W.I_BUDGET] += 2; d[W.I_INDUSTRY] += 1
	if u[13]: d[W.I_LIVING] += 3
	if u[14]: d[W.I_LIVING] += 2; d[W.I_BUDGET] += 1; d[W.I_INDUSTRY] += 2
	if u[15]: d[W.I_LIVING] += 2; d[W.I_BUDGET] += 2; d[W.I_INDUSTRY] += 1; d[W.I_AGRICULTURE] += 1
	if u[16]: d[W.I_LIVING] += 3; d[W.I_BUDGET] += 2; d[W.I_SCIENCE] += 5; d[W.I_MANPOWER] += 4
	if u[17]: d[W.I_LIVING] += 3; d[W.I_BUDGET] += 3
	if u[18]: d[W.I_ARMY] += 2
	if u[19]: d[W.I_AGENTS] += 3; d[W.I_THOUGHT_FREEDOM] -= 3
	if u[20]: d[W.I_AGENTS] += 2; d[W.I_THOUGHT_FREEDOM] -= 2; d[W.I_PEOPLE_SUPPORT] += 2
	if u[21]: d[W.I_ARMY] += 2; d[W.I_PARTY_SUPPORT] += 3; d[W.I_PEOPLE_SUPPORT] += 1
	if u[22]: d[W.I_PEOPLE_SUPPORT] += 2; d[W.I_THOUGHT_FREEDOM] -= 2; d[W.I_PARTY_SUPPORT] += 2
	if u[23]: d[W.I_ARMY] += 4
	if u[24]: d[W.I_ARMY] += 4; d[W.I_PEOPLE_SUPPORT] += 2
	if u[25]: d[W.I_AGENTS] += 2; d[W.I_THOUGHT_FREEDOM] -= 2; d[W.I_PARTY_SUPPORT] += 3
	if u[26]: d[W.I_ARMY] += 4; d[W.I_THOUGHT_FREEDOM] -= 2
	# 航天科技（TimeScript.cs:5201-5263 逐条）
	if u[27]: d[W.I_BUDGET] += 2; d[W.I_LIVING] += 2; d[W.I_PEOPLE_SUPPORT] += 2
	if u[28]: d[W.I_ARMY] += 5; d[W.I_AGENTS] += 5
	if u[29]:
		d[W.I_ARMY] += 10
		if w.empires.size() > 0:
			w.empires[0].relations -= 5
		if w.empires.size() > 1:
			w.empires[1].relations -= 5
	if u[30]:
		d[W.I_PEOPLE_SUPPORT] += 3
		# 原版不对称：美国 empire.power -1、苏联 empire.relations -1（照抄）
		if w.empires.size() > 0:
			w.empires[0].power -= 1
		if w.empires.size() > 1:
			w.empires[1].relations -= 1
	if u[31]: d[W.I_ARMY] += 5; d[W.I_SCIENCE] += 5
	if u[32]: d[W.I_AGRICULTURE] += 5; d[W.I_LIVING] += 5
	if u[33]:
		d[W.I_ARMY] += 5; d[W.I_INDUSTRY] += 5
		if w.empires.size() > 0:
			w.empires[0].relations -= 5
		if w.empires.size() > 1:
			w.empires[1].relations -= 5


# ── 双周：贷款利息（TimeScript 5512-5605行；外援 dota 在月块 2295-2318，见 _monthly_ejection_and_misc） ──
func _fortnight_loan_interest(d: Array[int], w: WorldState) -> void:
	var loan: int = d[W.I_LOAN]
	var year: int = w.date.year if w.date else 1976
	var pc := w.get_player_country()
	# 原版对苏关系惩罚都包在 allcountries[1].isSEV 内（中国加入经互会才扣）
	var china_in_sev := pc != null and pc.has_tag("sev")
	# 国债利息（与 UI「债务损耗」对齐）
	if loan > 0:
		var interest: int = loan / 40
		# 里根豁免（原版 TimeScript.cs:5514-5605）：empires[0].now_leader==3（=里根，1980 大选后）
		# 且奇数月(data[20]%2!=0)时免预算扣息，仅保留本金递减与对苏关系惩罚。
		# Godot 领导人索引 0=里根（world_factory.gd:1010-1011），原版 3=里根（Event402.cs:168）；
		# Godot current_leader 初始即 0，故开局即生效（原版需 1980 大选，领导人继任模型差异另记）。
		var usa: EmpireData = w.empires[0] if w.empires.size() > 0 else null
		if usa != null and usa.current_leader == 0 and w.date.month % 2 != 0:
			if interest <= 0:
				if loan > 10:
					d[W.I_LOAN] -= 1
				if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
					w.empires[1].relations -= 2
			else:
				if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
					w.empires[1].relations -= loan / 20
				if loan > 10:
					@warning_ignore("integer_division")
					d[W.I_LOAN] -= loan / 40 / 2 + 1
			return
		if interest <= 0:
			d[W.I_BUDGET] -= 1
			if year >= 1983:
				d[W.I_BUDGET] -= 2
			elif year >= 1980:
				d[W.I_BUDGET] -= 1
			if loan > 10:
				d[W.I_LOAN] -= 1
			if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
				w.empires[1].relations -= 2
		else:
			d[W.I_BUDGET] -= interest
			if year >= 1983:
				d[W.I_BUDGET] -= 1
			elif year >= 1980:
				# 反编译第二条件写作 >=1983（不可达冗余）；按原版语义应为 >=1980，
				# 1980-1982 年额外扣 2（与利息<=0 分支相反，照抄原作行为）。
				d[W.I_BUDGET] -= 2
			if china_in_sev and w.empires.size() > 1 and w.empires[1] != null:
				w.empires[1].relations -= loan / 20
			if loan > 10:
				d[W.I_LOAN] -= interest / 2 + 1


# ── 11项预算的完整月度效果 ──
# 移植自 TimeScript.cs InfluenceFromInvestments() 第 9764-9870 行（调用点 5264）

func _influence_from_investments(d: Array[int], year: int) -> void:
	# ─ 军费 ─
	var army_year_cost := (year - 1976 + 6) * 10
	# 军力：原版整数除法 (data[71]-(year-1976+6)*10)/10（TimeScript.cs:9766）；
	# 此前新增的 ind_mod（按工业缩放）在原版全库无出处，已移除。
	@warning_ignore("integer_division")
	d[W.I_ARMY] += (d[W.I_BUDGET_ARMY] - army_year_cost) / 10
	d[W.I_MANPOWER] += d[W.I_BUDGET_ARMY] / 150
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_ARMY] / 80
	d[W.I_CORRUPTION] += d[W.I_BUDGET_ARMY] / 50
	d[W.I_INDUSTRY] += d[W.I_BUDGET_ARMY] / 90
	if d[W.I_BUDGET_ARMY] < 80 and d[W.I_LIVING] < 500:
		d[W.I_LIVING] -= (90 - d[W.I_BUDGET_ARMY]) / 20
	if d[W.I_BUDGET_ARMY] < 80:
		d[W.I_INDUSTRY] -= (90 - d[W.I_BUDGET_ARMY]) / 20
	if d[W.I_LIVING] < 500:
		d[W.I_LIVING] += d[W.I_BUDGET_ARMY] / 50

	# ─ 国安部(MGB) ─
	d[W.I_AGENTS] += d[W.I_BUDGET_MGB] / 10
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_MGB] / 50 + d[W.I_BUDGET_MGB] / 90 * 2 \
		+ d[W.I_BUDGET_MGB] / 100 * 2
	d[W.I_PEOPLE_SUPPORT] -= d[W.I_BUDGET_MGB] / 90 * 2 + d[W.I_BUDGET_MGB] / 100
	d[W.I_PARTY_SUPPORT] -= d[W.I_BUDGET_MGB] / 90 * 2 + d[W.I_BUDGET_MGB] / 100
	if d[W.I_LIVING] < 500:
		d[W.I_LIVING] += d[W.I_BUDGET_MGB] / 80
	if d[W.I_BUDGET_MGB] >= d[W.I_AGENTS] and d[W.I_BUDGET_MGB] <= 150:
		d[W.I_CORRUPTION] -= d[W.I_BUDGET_MGB] / 50 + d[W.I_BUDGET_MGB] / 100
	elif d[W.I_AGENTS] > 0 and d[W.I_AGENTS] <= 150 and d[W.I_BUDGET_MGB] <= 150:
		d[W.I_CORRUPTION] -= d[W.I_AGENTS] / 50 + d[W.I_BUDGET_MGB] / 100
	elif d[W.I_AGENTS] > 0 and d[W.I_AGENTS] <= 150 and d[W.I_BUDGET_MGB] > 150:
		d[W.I_CORRUPTION] -= d[W.I_AGENTS] / 50 + 1
	elif d[W.I_BUDGET_MGB] > 150:
		d[W.I_CORRUPTION] -= 4

	# ─ 科研经费 ─
	# 科研点生成（data[11]+=data[73]/40）原版在日块（1457-1458行），已移至 _daily_science_gen
	d[W.I_CORRUPTION] += d[W.I_BUDGET_SCIENCE] / 50

	# ─ 行政支出 ─
	d[W.I_CORRUPTION] -= d[W.I_BUDGET_ADMIN] / 20
	d[W.I_PARTY_SUPPORT] += d[W.I_BUDGET_ADMIN] / 25
	d[W.I_LIVING] += d[W.I_BUDGET_ADMIN] / 70

	# ─ 高层福利(信封) ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_ENVELOPE] / 25
	d[W.I_PARTY_SUPPORT] += (d[W.I_BUDGET_ENVELOPE] - 61) / 5

	# ─ 宣传支出（原版 9818-9827 + 兵源 9777-9780）──
	d[W.I_CORRUPTION] -= d[W.I_BUDGET_PROPAGANDA] / 100   # 原版 :9818
	d[W.I_MANPOWER] += d[W.I_BUDGET_PROPAGANDA] / 150     # 原版 :9776/:9819
	d[W.I_CORRUPTION] += d[W.I_BUDGET_PROPAGANDA] / 150   # 原版 :9820
	d[W.I_THOUGHT_FREEDOM] -= d[W.I_BUDGET_PROPAGANDA] / 100  # 原版 :9821
	# 原版无条件：data[3] += (data[76]-70)/10（prop<70 时为负，扣民众支持）
	d[W.I_PEOPLE_SUPPORT] += (d[W.I_BUDGET_PROPAGANDA] - 70) / 10  # 原版 :9822
	if d[W.I_BUDGET_PROPAGANDA] < 50:
		d[W.I_CORRUPTION] += (50 - d[W.I_BUDGET_PROPAGANDA]) / 20   # 原版 :9825
		d[W.I_PEOPLE_SUPPORT] -= (50 - d[W.I_BUDGET_PROPAGANDA]) / 20  # 原版 :9826
		d[W.I_MANPOWER] -= (50 - d[W.I_BUDGET_PROPAGANDA]) / 20     # 原版 :9777-9780

	# ─ 农业支出 ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_AGRI] / 80
	d[W.I_AGRICULTURE] += d[W.I_BUDGET_AGRI] / 15
	d[W.I_LIVING] += d[W.I_BUDGET_AGRI] / 100
	if d[W.I_BUDGET_AGRI] < 40:
		d[W.I_AGRICULTURE] += (d[W.I_BUDGET_AGRI] - 40) / 10

	# ─ 工业支出 ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_INDUSTRY] / 80
	d[W.I_INDUSTRY] += d[W.I_BUDGET_INDUSTRY] / 10
	d[W.I_LIVING] += d[W.I_BUDGET_INDUSTRY] / 80
	if d[W.I_BUDGET_INDUSTRY] < 70:
		d[W.I_INDUSTRY] += (d[W.I_BUDGET_INDUSTRY] - 70) / 10

	# ─ 服务业支出 ─
	d[W.I_CORRUPTION] += d[W.I_BUDGET_SERVICES] / 50
	d[W.I_SERVICES] += d[W.I_BUDGET_SERVICES] / 10
	d[W.I_LIVING] += d[W.I_BUDGET_SERVICES] / 40
	if d[W.I_BUDGET_SERVICES] < 40:
		d[W.I_SERVICES] += (d[W.I_BUDGET_SERVICES] - 40) / 10

	# ─ 福利支出 ─
	d[W.I_LIVING] += (d[W.I_BUDGET_WELFARE] - 40) / 5
	d[W.I_PEOPLE_SUPPORT] += d[W.I_BUDGET_WELFARE] / 80
	if d[W.I_ECON_SYSTEM] < 13:
		d[W.I_CORRUPTION] += d[W.I_BUDGET_WELFARE] / 80
	else:
		d[W.I_CORRUPTION] += d[W.I_BUDGET_WELFARE] / 50

	# ─ 外交支出 ─
	if d[W.I_BUDGET_DIPLO] <= 0:
		d[W.I_DIPLO] -= 2
	elif d[W.I_BUDGET_DIPLO] < 60:
		d[W.I_DIPLO] -= 1
	# 每 5 点外交支出 +0.1 军事介入点（内部 ×10，显示 0.1 = 内部 1）
	@warning_ignore("integer_division")
	d[W.I_MIL_INTERVENTION] += d[W.I_BUDGET_DIPLO] / 5

	# ─ 腐败扣预算/生活水平（原版 8186-8187，投资块末尾，用投资后腐败值）──
	d[W.I_BUDGET] -= d[W.I_CORRUPTION] / 10
	d[W.I_LIVING] -= d[W.I_CORRUPTION] / 50


# ── 政治体制自动重算 ──

func _political_system_recalc(d: Array[int], w: WorldState) -> void:
	# 原版 TimeScript.cs 日块体制重算（num20=5 逐项修正体系，:1265-1445），
	# 2026-08 对齐审查重写：此前移植用 "score=(econ-9)+(party-5)+..." 数学公式与
	# 分支阈值（score<=6/9/11/15/20），与原版 num20<=0/3/6/9/12 体系完全不符；
	# 开局数据下两者恰都收敛到威权（num20=5-1-1-2-1=0 → 分支1），但政策变化后
	# 结果分歧。逐字重写如下（2026-08 补齐 DevelopedConsumerism 与事件 502/681/674/675 条件）。
	var num20 := 5
	if d[W.I_ECON_SYSTEM] == 10:
		num20 -= 1
	if d[W.I_ECON_SYSTEM] == 14 or d[W.I_ECON_SYSTEM] == 15:
		if d[W.I_PRESS_POLICY] > 17:
			num20 += 1
		else:
			num20 -= 1
	if d[W.I_PARTY_SYSTEM] == 6:
		num20 -= 1
	if d[W.I_PARTY_SYSTEM] == 8:
		num20 += 1
	if d[W.I_PARTY_SYSTEM] == 9:
		num20 += 2
	if d[W.I_PRESS_POLICY] == 16:
		num20 -= 1
	if d[W.I_PRESS_POLICY] == 18:
		num20 += 1
	if d[W.I_PRESS_POLICY] == 19:
		num20 += 3
	if d[W.I_RELIGION] == 24 or d[W.I_RELIGION] == 29:
		num20 -= 2
	if d[W.I_RELIGION] == 25 or d[W.I_RELIGION] == 28:
		num20 -= 1
	if d[W.I_RELIGION] == 27:
		num20 += 1
	if d[W.I_TERRITORY] == 20 and d[W.I_MIL_DOCTRINE] == 30:
		num20 -= 1
	if d[W.I_TERRITORY] >= 22 and d[W.I_MIL_DOCTRINE] == 33:
		num20 += 1
	if d[W.I_TERRITORY] == 23:
		num20 += 1
	# TimeScript.cs:1333-1336：DevelopedConsumerism > 0 → num20++。
	if w.developed_consumerism > 0:
		num20 += 1
	if gm._mod_active(w, 40):
		num20 -= 1
	if gm._mod_active(w, 38) and num20 > 0:
		num20 = 0
	# TimeScript.cs:1341-1349：event_done[502] && res502!=4 → num20-=3；
	# 且 data[15]==8（政党制度8）再 -3。
	if w.event_done_num(502) and w.result_of_event_num(502) != 4:
		num20 -= 3
		if d[W.I_PARTY_SYSTEM] == 8:
			num20 -= 3
	# TimeScript.cs:1350-1353：event_done[681] && res681==3 → num20--。
	if w.event_done_num(681) and w.result_of_event_num(681) == 3:
		num20 -= 1
	# TimeScript.cs:1354-1357：(res675==2 || res674==2) && num20>0 → num20=0。
	if (w.result_of_event_num(675) == 2 or w.result_of_event_num(674) == 2) and num20 > 0:
		num20 = 0

	var new_system: int
	var new_gosstroy: int
	if num20 <= 0:
		new_system = 0; new_gosstroy = 0
	elif num20 <= 3 and d[W.I_ECON_SYSTEM] <= 11:
		new_system = 1; new_gosstroy = 1
	elif num20 <= 6:
		if d[W.I_ECON_SYSTEM] <= 11:
			new_system = 2; new_gosstroy = 1
		elif d[W.I_ECON_SYSTEM] <= 13 and num20 <= 4:
			new_system = 2; new_gosstroy = 1
		else:
			new_system = 3; new_gosstroy = 2
	elif num20 <= 9:
		if d[W.I_ECON_SYSTEM] <= 13:
			if d[W.I_ECON_SYSTEM] <= 11:
				new_system = 2; new_gosstroy = 1
			else:
				new_system = 3; new_gosstroy = 2
		else:
			new_system = 4; new_gosstroy = 3
	elif num20 <= 12:
		if d[W.I_ECON_SYSTEM] <= 13:
			if d[W.I_ECON_SYSTEM] <= 11:
				new_system = 3; new_gosstroy = 2
			else:
				new_system = 4; new_gosstroy = 3
		else:
			new_system = 5; new_gosstroy = 3
	elif d[W.I_ECON_SYSTEM] > 12:
		new_system = 5; new_gosstroy = 3
	elif d[W.I_ECON_SYSTEM] > 11:
		new_system = 4; new_gosstroy = 3
	else:
		new_system = 3; new_gosstroy = 2

	d[W.I_IDEOLOGY] = new_system
	var pc := w.get_player_country()
	if pc:
		pc.government = new_gosstroy
	# 原版 1440-1444：modifies[40] 激活且 Gosstroy==1 时强制覆盖为 data[14]=3 / Gosstroy=2
	if gm._mod_active(w, 40) and pc != null and pc.government == GameConstants.Government.SOCIALIST:
		d[W.I_IDEOLOGY] = 3
		pc.government = GameConstants.Government.REFORMIST
	# 注意：data[56] 政治路线重算也在日块（tick 中先于本函数调用），不在此处


## 政治路线 data[56]：一党制(≤7)下每月跟随席位(support)最大的派系。
## 对齐原版 TimeScript 日块 1146-1226（幂等派生值，每日重算无副作用）。
## 注意：满足现状者 data[106] 的增长【不在这里】——原版月块完全不碰 data[106]，
##       它只在切政策 Doctrine_button.OnMouseDown 时 += 一次（见 change_policy →
##       _apply_policy_satisfied_growth）。之前放在月度导致每月暴涨，即本次修复的 bug。
func _update_political_line(d: Array[int], w: WorldState) -> void:
	## 原版 Party_ally_script / Party_zapret 点击后与日块重算 data[56] 的算法，逐分支照抄。
	if w.factions.is_empty() or d.size() <= W.I_POLITICAL_LINE:
		return
	var p0: int = w.factions[0].support if w.factions.size() > 0 else 0
	var p1: int = w.factions[1].support if w.factions.size() > 1 else 0
	var p2: int = w.factions[2].support if w.factions.size() > 2 else 0
	var p3: int = w.factions[3].support if w.factions.size() > 3 else 0
	var p4: int = w.factions[4].support if w.factions.size() > 4 else 0
	if d[W.I_PARTY_SYSTEM] <= 7:
		if p0 >= p1 and p0 >= p2 and p0 >= p3 and p0 >= p4:
			d[W.I_POLITICAL_LINE] = 0
		elif p0 <= p1 and p1 >= p2 and p1 >= p3 and p1 >= p4:
			d[W.I_POLITICAL_LINE] = 1
		elif p2 >= p1 and p0 <= p2 and p2 >= p3 and p2 >= p4:
			d[W.I_POLITICAL_LINE] = 2
		elif p3 >= p1 and p3 >= p2 and p0 <= p3 and p3 >= p4:
			d[W.I_POLITICAL_LINE] = 3
		elif p4 >= p1 and p4 >= p2 and p4 >= p3 and p0 <= p4:
			d[W.I_POLITICAL_LINE] = 4
		return
	# 多党(>7)：保守派支持 + 所有已结盟启用派系支持
	var coalition := p1
	for i in w.factions.size():
		var f: FactionData = w.factions[i]
		if i != FactionData.CONSERVATIVE and f.is_ally and f.is_enabled:
			coalition += f.support
	if coalition >= p0 and coalition >= p2 and coalition >= p3 and coalition >= p4:
		d[W.I_POLITICAL_LINE] = 1
	elif not w.factions[0].is_ally and w.factions[0].is_enabled and coalition <= p0 \
			and p0 >= p2 and p0 >= p3 and p0 >= p4:
		d[W.I_POLITICAL_LINE] = 0
	elif not w.factions[2].is_ally and w.factions[2].is_enabled and p2 >= p0 \
			and coalition <= p2 and p2 >= p3 and p2 >= p4:
		d[W.I_POLITICAL_LINE] = 2
	elif not w.factions[3].is_ally and w.factions[3].is_enabled and p3 >= p0 \
			and p3 >= p2 and coalition <= p3 and p3 >= p4:
		d[W.I_POLITICAL_LINE] = 3
	elif not w.factions[4].is_ally and w.factions[4].is_enabled and p4 >= p0 \
			and p4 >= p2 and p4 >= p3 and coalition <= p4:
		d[W.I_POLITICAL_LINE] = 4


## 每日：一党制下把 party_number(=support) 按 party_ideology(=ideology) 重算。
## 忠实移植原版 TimeScript.Repaint 日块（DLL 反编译 TimeScript.Repaint(bool)：
## data[53] 重算段 + party_number 重算段；旧 Assets/Scripts/TimeScript.cs:1113-1171
## 同源，但旧文本把 ref 写入误排成死局部变量，以 DLL 反编译语义为准）。
## 原版每次日块先把 data[53] 置为当前禁用派系数；多党下禁用>=4 时政党制度退回 6；
## 一党制：启用派系 support = ideology + 前方禁用派系转移额；负 ideology 归零。
func _sync_faction_numbers_from_ideology(d: Array[int], w: WorldState) -> void:
	if w == null or w.factions.is_empty() or d.size() <= W.I_PARTY_BAN_COUNT:
		return
	var disabled := 0
	for f in w.factions:
		if f != null and not f.is_enabled:
			disabled += 1
	d[W.I_PARTY_BAN_COUNT] = disabled
	if d[W.I_PARTY_SYSTEM] > 7 and disabled >= 4:
		d[W.I_PARTY_SYSTEM] = 6
	if d[W.I_PARTY_SYSTEM] > 7:
		return
	var transferred: Array[int] = [0, 0, 0, 0, 0]
	for i in w.factions.size():
		var f: FactionData = w.factions[i]
		if f == null:
			continue
		if f.ideology > 0 and not f.is_enabled:
			var found := false
			for k in range(i + 1, w.factions.size()):
				var t: FactionData = w.factions[k]
				if t != null and t.is_enabled and k < transferred.size():
					transferred[k] = f.ideology
					found = true
					break
			if not found:
				for k in range(i - 1, 0, -1):
					var t2: FactionData = w.factions[k]
					if t2 != null and t2.is_enabled:
						t2.support += f.ideology
						break
		elif f.ideology > 0 and f.is_enabled:
			f.support = f.ideology + (transferred[i] if i < transferred.size() else 0)
		elif f.ideology < 0:
			f.ideology = 0


## 每 7 天（原版 data[19] % 7 == 0）：一党制下每个已结盟派系
##   ideology += (五个派系 ideology 之和) / 100
##   预算 -1，特工网络 -2
## 出处：原版 TimeScript.Repaint 日块；DLL 反编译 TimeScript 中
## "if (this.global2.data[19] % 7 == 0) ... is_party_ally[num39]" 一段
## （旧 Assets/Scripts/TimeScript.cs:3155-3170 的 ref 写入被误排，以 DLL 为准）。
## 原版此段在 party_number 每日重算之后执行，所以本次增长下一日块才反映到 support。
func _weekly_ally_upkeep(d: Array[int], w: WorldState) -> void:
	if w == null or w.factions.is_empty() or d.size() <= W.I_AGENTS:
		return
	if d[W.I_PARTY_SYSTEM] > 7:
		return
	for f in w.factions:
		if f == null or not f.is_ally:
			continue
		var ideo_sum := 0
		for x in w.factions:
			if x != null:
				ideo_sum += x.ideology
		@warning_ignore("integer_division")
		var gain: int = ideo_sum / 100
		f.ideology += gain
		d[W.I_BUDGET] -= 1
		d[W.I_AGENTS] -= 2
	# 原版本次增长要等下一个日块重算才反映到 party_number；端口在此同步一次，
	# 让派系界面/饼图在同一个 tick 就能看到变化（不影响后续日块的幂等重算）。
	_sync_faction_numbers_from_ideology(d, w)


## 满足现状者 data[106] 增长——【仅切政策成功时】调用一次，对齐原版
## Doctrine_button_script.OnMouseDown（1229/1253）。放这里而非月度是本次修复关键。
##   一党制(≤7)：data[106] += 当前政治路线派系的 ideology/4，随后重算政治路线
##   多党(>7)：  data[106] += 保守派 support(party_number[1])/4
## party_ideology 我方以 FactionData.ideology 为准（influence 仅旧存档兼容，勿作增长源）。
## 顺序与原版一致：先用【旧】政治路线加 satisfied，再重算路线。
func _apply_policy_satisfied_growth(d: Array[int], w: WorldState) -> void:
	if w.factions.is_empty() or d.size() <= W.I_SATISFIED:
		return
	@warning_ignore("integer_division")
	if d[W.I_PARTY_SYSTEM] <= 7:
		var line: int = clampi(d[W.I_POLITICAL_LINE], 0, w.factions.size() - 1)
		var base_ideo: int = w.factions[line].ideology
		if base_ideo <= 0:
			base_ideo = w.factions[line].support
		d[W.I_SATISFIED] += base_ideo / 4
		_update_political_line(d, w)
	else:
		var cons: int = 0
		if w.factions.size() > FactionData.CONSERVATIVE:
			cons = w.factions[FactionData.CONSERVATIVE].support
		d[W.I_SATISFIED] += cons / 4
		# 原版 :1407-1438：多党分支同样在加完 data[106] 后重算 data[56]
		_update_political_line(d, w)
	d[W.I_SATISFIED] = maxi(0, d[W.I_SATISFIED])


# ── 双周：生活水平上限调整（原版 3749-3752，双周块）──
## 生活水平高于三产均值（扣除腐败）+20 时，向该上限回落 1/10。
func _fortnight_living_cap(d: Array[int]) -> void:
	@warning_ignore("integer_division")
	var output_avg := (d[W.I_INDUSTRY] + d[W.I_AGRICULTURE] + d[W.I_SERVICES] - d[W.I_CORRUPTION]) / 3
	if d[W.I_LIVING] > output_avg + 20:
		d[W.I_LIVING] -= (output_avg + 20) / 10


# ── 双周：allcountries[15] 内战压力（原版 3755-3779，生活上限之后、储备结算之前）──
## 国家 15 处于内战时：美苏关系向 700 靠拢、预算-2、外交声誉向 400-600 区间靠拢。
func _fortnight_cw_block(d: Array[int], w: WorldState) -> void:
	var cw_country := w.get_country_by_legacy_index(15)
	if cw_country == null or not cw_country.内战中:
		return
	if w.empires.size() > 1 and w.empires[1] != null and w.empires[1].relations < 700:
		w.empires[1].relations += 5
	if w.empires.size() > 0 and w.empires[0] != null and w.empires[0].relations < 700:
		w.empires[0].relations += 5
	d[W.I_BUDGET] -= 2
	if d[W.I_DIPLO] > 600:
		d[W.I_DIPLO] -= 2
	elif d[W.I_DIPLO] < 400:
		d[W.I_DIPLO] += 2


# ── 双周：威权+市场体制的腐败微降（原版 3780-3787）──
func _fortnight_ideology_corruption(d: Array[int]) -> void:
	if d[W.I_IDEOLOGY] >= 4 and d[W.I_ECON_SYSTEM] >= 14:
		d[W.I_CORRUPTION] -= 1


# ── 双周：储备金影响（原版 TimeScript.cs:3788-3912，双周块）──
## 除 UI 文案（经济.gd:_reserve_effect）外，原版还会真实结算：按年份/经济体制
## 降低腐败，并把三产与生活同时推向（或拉离）储备金锚点。
func _fortnight_reserve_effect(d: Array[int], year: int) -> void:
	var reserve := d[W.I_RESERVE]
	var econ := d[W.I_ECON_SYSTEM]
	var v := 0
	var corr := 0
	@warning_ignore("integer_division")
	if year < 1980:
		if econ == 13:
			corr = -(reserve / 400)
			v = 1 if reserve >= 600 else -(3 - reserve / 150)
		elif econ >= 14:
			corr = -(reserve / 200)
			v = 1 if reserve >= 750 else -(4 - reserve / 150)
	elif econ == 13:
		corr = -(reserve / 600)
		v = 1 if reserve >= 750 else -(4 - reserve / 150)
	elif econ == 14:
		corr = -(reserve / 400)
		v = 3 if reserve >= 1500 else -(7 - reserve / 150)
	elif econ == 15:
		corr = -(reserve / 200)
		v = -(13 - reserve / 150)
	elif econ == 12:
		corr = -(reserve / 200)
		v = 1 if reserve >= 600 else -(3 - reserve / 150)
	if corr != 0 or v != 0:
		d[W.I_CORRUPTION] += corr
		d[W.I_LIVING] += v
		d[W.I_SERVICES] += v
		d[W.I_INDUSTRY] += v


# ── 双周：人口超限特工惩罚（原版 TimeScript.cs:4538-4541，经济体制效果前）──
## 人口超过 9307 的部分，每 200 扣 1 特工。
func _fortnight_population_agent_penalty(d: Array[int]) -> void:
	@warning_ignore("integer_division")
	if (d[W.I_POPULATION] - 9307) / 200 > 0:
		d[W.I_AGENTS] -= (d[W.I_POPULATION] - 9307) / 200


# ── 双周：经济思想漂移（原版 TimeScript.cs:5311-5321，压力修正之后、工业衰减之前）──
## 计划经济体制（<=12）下，思想自由按年份不同速率向 1000 靠拢。
func _fortnight_econ_thought_drift(d: Array[int], year: int) -> void:
	@warning_ignore("integer_division")
	if d[W.I_ECON_SYSTEM] <= 11:
		if year < 1980:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 50
		else:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 40
	elif d[W.I_ECON_SYSTEM] == 12:
		if year < 1980:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 70
		else:
			d[W.I_THOUGHT_FREEDOM] += (1000 - d[W.I_LIVING]) / 60


# ── 双周：战后战争支持/兵源衰减（原版 TimeScript.cs:5878-5890，难度修正之后）──
## 用双周入口快照 array9[31]/array9[57] 回落当前超过 700 的战争支持/兵源。
func _fortnight_post_war_decay(d: Array[int], war_support_before: int, manpower_before: int) -> void:
	@warning_ignore("integer_division")
	if d[W.I_WAR_SUPPORT] >= 700:
		d[W.I_WAR_SUPPORT] -= war_support_before / 40
	if d[W.I_MANPOWER] >= 700:
		d[W.I_MANPOWER] -= manpower_before / 40


# ── 双周：预算增长回落（原版 TimeScript.cs:5903-5919，战后衰减之后）──
## 本轮预算比入口快照多 50 以上时，扣掉增长额的 1/4，再扣当前预算的 1/20。
## 原版内层 >50/>75/>100 为反编译不可达冗余（外层已 >50），只保留 /4 分支。
func _fortnight_budget_growth_fallback(d: Array[int], budget_before: int) -> void:
	@warning_ignore("integer_division")
	if d[W.I_BUDGET] - budget_before > 50:
		d[W.I_BUDGET] -= (d[W.I_BUDGET] - budget_before) / 4
		d[W.I_BUDGET] -= d[W.I_BUDGET] / 20


# ── 双周：人口预算加成（原版 TimeScript.cs:5928-5945，预算回落之后）──
## 市场经济体制 13/14/15 按人口规模分别以 /3000、/2000、/1000 给预算加成。
func _fortnight_population_budget_bonus(d: Array[int]) -> void:
	if d[W.I_ECON_SYSTEM] == 13:
		d[W.I_BUDGET] += int(round(float(d[W.I_POPULATION] - 9037) / 3000.0 + 1.0))
	elif d[W.I_ECON_SYSTEM] == 14:
		d[W.I_BUDGET] += int(round(float(d[W.I_POPULATION] - 9037) / 2000.0 + 1.0))
	elif d[W.I_ECON_SYSTEM] == 15:
		d[W.I_BUDGET] += int(round(float(d[W.I_POPULATION] - 9037) / 1000.0 + 1.0))


# ── 双周：经济体制效果（原版 4538-4715，双周块）──
## 含 data[52]/data[54] 显示等级条件副效果。
func _fortnight_econ_system_effect(d: Array[int]) -> void:
	var econ := d[W.I_ECON_SYSTEM]
	match econ:
		11:
			d[W.I_BUDGET] += 1
			d[W.I_THOUGHT_FREEDOM] -= 2
			d[W.I_LIVING] += 2
			d[W.I_INDUSTRY] += 2
			d[W.I_CORRUPTION] -= 2
			if d[W.I_ECON_DISPLAY] > 34:
				d[W.I_ECON_OPENNESS] -= 50
		10:
			d[W.I_LIVING] += 2
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_SERVICES] -= 1
			d[W.I_INDUSTRY] += 1
			d[W.I_CORRUPTION] += 1
			if d[W.I_ECON_DISPLAY] > 34:
				d[W.I_ECON_OPENNESS] -= 50
		12:
			d[W.I_AGRICULTURE] += 1
			d[W.I_BUDGET] += 1
			d[W.I_SERVICES] += 1
			d[W.I_LIVING] -= 2
			d[W.I_THOUGHT_FREEDOM] -= 2
			d[W.I_CORRUPTION] += 1
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 1
			if d[W.I_ECON_DISPLAY] > 35:
				d[W.I_ECON_OPENNESS] -= 20
			elif d[W.I_ECON_DISPLAY] < 35:
				d[W.I_ECON_OPENNESS] += 30
		13:
			d[W.I_BUDGET] += 2
			d[W.I_SERVICES] += 1
			d[W.I_LIVING] -= 4
			d[W.I_THOUGHT_FREEDOM] += 1
			d[W.I_CORRUPTION] += 1
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 2
			if d[W.I_ECON_DISPLAY] > 36:
				d[W.I_ECON_OPENNESS] -= 40
			elif d[W.I_ECON_DISPLAY] < 36:
				d[W.I_ECON_OPENNESS] += 30
		14:
			d[W.I_BUDGET] += 2
			d[W.I_SERVICES] += 2
			d[W.I_LIVING] -= 5
			d[W.I_THOUGHT_FREEDOM] += 2
			d[W.I_INDUSTRY] -= 1
			d[W.I_CORRUPTION] += 2
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 4
			if d[W.I_ECON_DISPLAY] < 37:
				d[W.I_ECON_OPENNESS] += 40
		15:
			d[W.I_AGRICULTURE] -= 1
			d[W.I_SERVICES] += 3
			d[W.I_LIVING] -= 7
			d[W.I_THOUGHT_FREEDOM] += 4
			d[W.I_INDUSTRY] -= 2
			d[W.I_CORRUPTION] += 2
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_CORRUPTION] += 5
			if d[W.I_ECON_DISPLAY] < 37:
				d[W.I_ECON_OPENNESS] += 50


# ============================================================================
# 双周 tick — 移植自 TimeScript.cs 每14天周期的核心模拟
# ============================================================================

func _on_fortnight() -> void:
	var w := world
	if w == null:
		return
	var d := w.数值表
	var year := w.date.year
	# TimeScript.cs:1224-1228：本次双周块入口快照，供 modifier[9/10]、战后衰减与预算回落使用。
	# 同一份入口快照也持久化给经济界面悬浮提示的 ±变化（data_old 语义）。
	w.记录入口快照()
	var support_before := d[W.I_PEOPLE_SUPPORT]
	var budget_before := d[W.I_BUDGET]
	var freedom_before := d[W.I_THOUGHT_FREEDOM]
	var war_support_before := d[W.I_WAR_SUPPORT]
	var manpower_before := d[W.I_MANPOWER]

	# 双周块按原版 TimeScript.cs 行序重排（本次审计对齐）：
	# 生活上限 3749 → 储备结算 3788 → 贸易 4135 → 战争支持漂移 4168 →
	# 领导人与军备资金 4318 → 人口特工惩罚/经济体制 4538 → 党政/舆论/领土漂移 4716 →
	# 军事学说 4897 → 科技持续 4974 → 投资效果 5264 → 压力修正 5266 → 经济思想漂移 5311 →
	# 工业 5323 → 服务业 5393 → 农业 5461 → 贷款 5512 → 科研 5608 → 难度 5757 →
	# 战后衰减 5878 → 预算回落 5903 → 人口预算加成 5928。
	# （TraitInfluence 4973 / MutualRelationsChange 5265 移植说明，见审计报告；modifier 周期块另算。）
	_fortnight_living_cap(d)
	_fortnight_cw_block(d, w)
	_fortnight_ideology_corruption(d)
	_fortnight_reserve_effect(d, year)
	_fortnight_trade_balance(d, w)
	_fortnight_satisfaction_drift(d, w)
	_fortnight_leader_effects(d, w)
	_fortnight_population_agent_penalty(d)
	_fortnight_econ_system_effect(d)
	_fortnight_political_drift(d, w)
	_fortnight_military_doctrine(d, w)
	_fortnight_trait_influence(d, w)
	_apply_tech_periodic(w)
	_influence_from_investments(d, year)
	_fortnight_mutual_relations(d, w)
	# TimeScript.cs:3243-3247（data[19]%14==0 双周块）：联络机构（沟通机构）规模
	# 每双周为两国修好提供苏联关系加成 —— 规模 ÷10（conn/10，10 规模 → +1）。
	_fortnight_comms_relations(d, w)
	# AfricanBotSupport 的调用点在原版日块 TimeScript.cs:1040，已移入 _daily_rim_and_alliance_checks。
	_update_modifier_population_industry_pressure(d, w)
	_fortnight_econ_thought_drift(d, year)
	_fortnight_industry_decay(d)
	_fortnight_services_decay(d)
	_fortnight_agriculture_decay(d)
	_fortnight_loan_interest(d, w)
	_fortnight_research_advance(d, w)
	_fortnight_difficulty_bonus(d, w)
	_fortnight_post_war_decay(d, war_support_before, manpower_before)
	# ModifiesChanges 原版在 5907（战后衰减 5878 之后、预算回落 5903 之前）调用；
	# Godot 只移植了其中 modifier 0-17 的可确认部分，移植说明项见审计报告。
	_fortnight_modifiers(d, w, support_before, budget_before, freedom_before)
	_apply_modifier50_military(d, w)
	# 原版 ModifiesInfuence.cs:502-508：每轮双周强制激活修正 1 与 50。
	# （Godot 改版 dlc[3]=true 全 DLC 免费，开局已激活 50；这里保留原版强制激活作双保险。）
	if w.modifiers.size() > 1 and not gm._mod_active(w, 1):
		w.modifiers[1].is_active = true
	if w.modifiers.size() > 50 and not gm._mod_active(w, 50):
		w.modifiers[50].is_active = true
	_fortnight_budget_growth_fallback(d, budget_before)
	_fortnight_population_budget_bonus(d)
	_check_coup(d, w)
	WarSystem.fortnight_wars(w)
	# 阴谋网也挂双周一次（原版 Death/Plot 在年/特定块；月结已跑，此处不重复击杀）
	if gm.current_event_id == "":
		_check_endings(d, w, year)

	w.flush_economy()
	# 原版 TimeScript.cs:5943-5953：双周结束时写 data_old = 当前值 - 入口 array9。
	# 结算一次后保持不变，期间玩家加减不再改动（与原版一致）。
	w.结算两周变化()


# ============================================================================
# 修正双周效果 — 对齐 TimeScript.cs:5266-5310（modifies[4] 人口/工业压力）
# 及 ModifiesInfuence.ModifiesChanges 的 modifier 周期块（原版 5907 调用）。
# 内部数值为原版 ×10 量级（如 -5 工业 = -0.5 显示）
# ============================================================================

## modifier[4] 在产业自然衰减之前计算，因此与其它修正分开以保持原作顺序。
func _update_modifier_population_industry_pressure(d: Array[int], w: WorldState) -> void:
	if w == null or w.modifiers.size() <= 4:
		return
	if d[W.I_LIVING] < 200:
		w.modifiers[4].is_active = true
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_MANPOWER] -= 3
		d[W.I_INDUSTRY] -= (250 - d[W.I_LIVING]) / 40
	elif d[W.I_ECON_SYSTEM] > 12 and d[W.I_LIVING] < (d[W.I_ECON_SYSTEM] - 10) * 100:
		w.modifiers[4].is_active = true
		d[W.I_INDUSTRY] -= ((d[W.I_ECON_SYSTEM] - 10) * 100 - d[W.I_LIVING]) / 40
		d[W.I_CORRUPTION] += 1
		d[W.I_MANPOWER] -= 3
	else:
		w.modifiers[4].is_active = false


func _fortnight_modifiers(
		d: Array[int],
		w: WorldState,
		support_before: int,
		_budget_before: int,
		freedom_before: int
) -> void:
	if w == null:
		return
	var player := w.get_player_country()

	# 0 工业技术依赖：原作在解除的当轮仍会扣一次工业。
	if gm._mod_active(w, 0):
		if w.techs and w.techs.unlocked.size() > 10 and w.techs.unlocked[10]:
			w.modifiers[0].is_active = false
		d[W.I_INDUSTRY] -= 5

	# 2 服务业发展进程（ModifiesInfuence.cs:510-1198：寡头/教育/高考/医疗/票证/国策，动态结算）。
	if gm._mod_active(w, 2):
		_apply_modifier2_services(d, w)

	# 3 后毛时代效应。
	if gm._mod_active(w, 3):
		# 深度改革则解除并冲击。解除当轮仍继续执行下方周期效果。
		if d[W.I_IDEOLOGY] >= 4 or d[W.I_ECON_SYSTEM] >= 14:
			w.modifiers[3].is_active = false
			d[W.I_THOUGHT_FREEDOM] += 200
			d[W.I_PEOPLE_SUPPORT] += 100
			d[W.I_PARTY_SUPPORT] -= 250
			d[W.I_DIPLO] -= 10
			for p in w.politicians:
				if PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.loyalty -= 100
				elif p.trait_personality > 1:
					p.loyalty += 100
		d[W.I_BUDGET] += 6
		d[W.I_AGENTS] += 2
		d[W.I_ARMY] += 5
		if gm.is_mao_dead():
			d[W.I_PEOPLE_SUPPORT] += 5
			d[W.I_THOUGHT_FREEDOM] += 10
			d[W.I_LIVING] -= 5
			if w.empires.size() > EmpireData.USA:
				w.empires[EmpireData.USA].relations -= 5

	# 5 市场改革冲击。
	if gm._mod_active(w, 5):
		d[W.I_PEOPLE_SUPPORT] -= 2
		d[W.I_THOUGHT_FREEDOM] += 10
		d[W.I_BUDGET] += 2

	# 6 意识形态动员。
	if gm._mod_active(w, 6):
		d[W.I_PARTY_SUPPORT] += 5
		d[W.I_THOUGHT_FREEDOM] -= 2
		d[W.I_MANPOWER] += 1
		d[W.I_DIPLO] += 2
		if w.empires.size() > EmpireData.USA:
			w.empires[EmpireData.USA].relations -= 2
		if w.empires.size() > EmpireData.USSR:
			w.empires[EmpireData.USSR].relations -= 4

	# 7 五年计划：条件动态激活/解除。
	var plan_condition := (
		d[W.I_IDEOLOGY] == 3
		and w.leader != null
		and w.leader.trait_alignment == 5
		and w.leader.trait_personality > 0
		and d[W.I_REFORM_STAGE] >= 3
		and player != null
		and not player.has_tag("sev")
		and not player.has_tag("ovd")
		and not player.has_tag("okb")
	)
	if gm._mod_active(w, 7):
		if d[W.I_CORRUPTION] > 200:
			d[W.I_CORRUPTION] -= 1
		if d[W.I_THOUGHT_FREEDOM] > 800:
			d[W.I_THOUGHT_FREEDOM] -= 3
		if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA].relations < 400:
			w.empires[EmpireData.USA].relations += (500 - w.empires[EmpireData.USA].relations) / 100
		if d[W.I_INDUSTRY] < 500:
			d[W.I_INDUSTRY] += 3
		if d[W.I_MANPOWER] <= 400:
			d[W.I_MANPOWER] += 3
		if not plan_condition:
			w.modifiers[7].is_active = false
	elif plan_condition:
		w.modifiers[7].is_active = true

	# 8 经济联盟身份：加入时激活，退出当轮施加一次余波后解除。
	if player != null and player.has_tag("econ"):
		w.modifiers[8].is_active = true
	elif gm._mod_active(w, 8):
		w.modifiers[8].is_active = false
		if w.empires.size() > EmpireData.USA:
			w.empires[EmpireData.USA].relations += 2
		if w.empires.size() > EmpireData.USSR:
			w.empires[EmpireData.USSR].relations += 2
		d[W.I_THOUGHT_FREEDOM] -= 10

	# 9/10 边疆文化政策：以本轮入口快照削弱支持/自由化涨幅。
	if not gm._mod_active(w, 9):
		if d[W.I_XINJIANG_POLICY] > 0:
			w.modifiers[9].is_active = true
	else:
		d[W.I_MANPOWER] -= 10
		if d[W.I_PEOPLE_SUPPORT] > support_before:
			d[W.I_PEOPLE_SUPPORT] -= (d[W.I_PEOPLE_SUPPORT] - support_before) / 2
		if freedom_before > d[W.I_THOUGHT_FREEDOM]:
			d[W.I_THOUGHT_FREEDOM] += (freedom_before - d[W.I_THOUGHT_FREEDOM]) / 2
	if not gm._mod_active(w, 10):
		if d[W.I_TIBET_POLICY] > 0:
			w.modifiers[10].is_active = true
	else:
		d[W.I_MANPOWER] -= 10
		if d[W.I_PEOPLE_SUPPORT] > support_before:
			d[W.I_PEOPLE_SUPPORT] -= (d[W.I_PEOPLE_SUPPORT] - support_before) / 4
		if freedom_before > d[W.I_THOUGHT_FREEDOM]:
			d[W.I_THOUGHT_FREEDOM] += (freedom_before - d[W.I_THOUGHT_FREEDOM]) / 4

	# 11 自动化计划经济（OGAS）。原版唯一激活入口 = 事件97选项0（Event97.cs:58：
	# data[1]=0/忠诚±/激活均为该事件的一次性副作用；触发需 science[17]+体制10/11，
	# TimeScript.cs:10810）。事件97移植说明 → 恒不激活。原版无「econ==11 自动激活」
	# 逻辑（开局 data[16]=11 即中式计划，此前误加致开局党内支持清零，已移除）。
	# ModifiesInfuence.cs:1558-1570：每两周 +50（显示+5.0）；解除只在 Event112.cs:148。
	if gm._mod_active(w, 11):
		d[W.I_INDUSTRY] += 50
		d[W.I_SERVICES] += 50
		d[W.I_AGRICULTURE] += 50
		d[W.I_BUDGET] += 50
		d[W.I_PARTY_SUPPORT] -= 50
		d[W.I_LIVING] += 10
		d[W.I_CORRUPTION] -= 10

	# 12 政治危机的动态激活条件与完整代价。
	var output_average := (d[W.I_INDUSTRY] + d[W.I_AGRICULTURE] + d[W.I_SERVICES] - d[W.I_CORRUPTION]) / 3
	w.modifiers[12].is_active = output_average < 500 and w.date.year >= 1980
	if gm._mod_active(w, 12):
		d[W.I_BUDGET] -= 10
		d[W.I_AGENTS] -= 10
		d[W.I_MANPOWER] -= 3

	# 预算增长过快回落已拆到 _fortnight_budget_growth_fallback（TimeScript.cs:5903-5919），
	# 在 _on_fortnight 中按原版位置（战后衰减之后、人口预算加成之前）单独调用。

	# 13 工业创收。原作激活后不在此处自动解除。
	if not gm._mod_active(w, 13):
		if d[W.I_ECON_SYSTEM] >= 13 and d[W.I_LIVING] >= 700:
			w.modifiers[13].is_active = true
	elif d[W.I_ECON_SYSTEM] == 13:
		d[W.I_BUDGET] += d[W.I_LIVING] / 500
	elif d[W.I_ECON_SYSTEM] == 14:
		d[W.I_BUDGET] += d[W.I_LIVING] / 330
	elif d[W.I_ECON_SYSTEM] == 15:
		d[W.I_BUDGET] += d[W.I_LIVING] / 250

	# 14 改革派声势：邓小平不再占据原 politics[12] 身份时解除。
	if gm._mod_active(w, 14):
		var deng_valid := false
		if w.politicians.size() > 12:
			var deng: PoliticianData = w.politicians[12]
			deng_valid = (
				deng != null
				and deng.name_first == 13
				and deng.name_last == 13
				and deng.trait_personality == 2
				and deng.trait_alignment == 5
				and deng.trait_special == 11
			)
		if not deng_valid:
			w.modifiers[14].is_active = false

	# 15 农业发展进程（ModifiesInfuence.cs:1618-1720：下乡/乡建/公社/农业科技，动态结算；
	# 无封顶、无科技解除——Godot 早期版本自造的“>700 封顶 + 科技2解除”在原版全库无出处，已删除）。
	if gm._mod_active(w, 15):
		_apply_modifier15_agriculture(d, w)

	# 16/17 对苏/对美关系受损。
	if gm._mod_active(w, 16):
		var ussr_relation := w.empires[EmpireData.USSR].relations if w.empires.size() > EmpireData.USSR else d[W.I_USSR_RELATIONS]
		if ussr_relation >= 500:
			w.modifiers[16].is_active = false
		else:
			d[W.I_BUDGET] -= (500 - ussr_relation) / 50
			d[W.I_AGENTS] -= (500 - ussr_relation) / 100
	if gm._mod_active(w, 17):
		var usa_relation := w.empires[EmpireData.USA].relations if w.empires.size() > EmpireData.USA else d[W.I_USA_RELATIONS]
		if usa_relation >= 500:
			w.modifiers[17].is_active = false
		else:
			d[W.I_BUDGET] -= (500 - usa_relation) / 50
			d[W.I_AGENTS] -= (500 - usa_relation) / 100

	# ── 18-42：ModifiesInfuence.cs:1866-2260 ──
	if gm._mod_active(w, 18):
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_AGENTS] += 2
	elif gm._mod_active(w, 19):
		d[W.I_MANPOWER] -= 2
		_add_empire_relation(w, 0, 5)
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_BUDGET] += 2
	elif gm._mod_active(w, 20):
		_add_empire_relation(w, 0, -5)
		_add_empire_relation(w, 1, 2)
		d[W.I_ARMY] -= 2
		d[W.I_BUDGET] += 2
	if gm._mod_active(w, 21):
		_add_empire_relation(w, 1, 2)
		_add_empire_relation(w, 0, -2)
		d[W.I_ARMY] -= 2
		d[W.I_SCIENCE] += 5
	elif gm._mod_active(w, 22):
		d[W.I_THOUGHT_FREEDOM] += 2
		_add_empire_relation(w, 1, -5)
		d[W.I_AGENTS] += 2
		d[W.I_MANPOWER] += 2
	elif gm._mod_active(w, 23):
		_add_empire_relation(w, 0, 5)
		d[W.I_MANPOWER] -= 2
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_BUDGET] += 2
	if gm._mod_active(w, 24):
		d[W.I_PARTY_SUPPORT] += 2
		d[W.I_THOUGHT_FREEDOM] += 2
		d[W.I_BUDGET] += 2
	elif gm._mod_active(w, 25):
		d[W.I_SCIENCE] += 2
		d[W.I_PEOPLE_SUPPORT] -= 2
		d[W.I_THOUGHT_FREEDOM] -= 2
		d[W.I_CORRUPTION] -= 2
		d[W.I_BUDGET] -= 3
	elif gm._mod_active(w, 26):
		d[W.I_PARTY_SUPPORT] += 5
		d[W.I_PEOPLE_SUPPORT] -= 5
		d[W.I_THOUGHT_FREEDOM] -= 5
		d[W.I_CORRUPTION] -= 5
		d[W.I_LIVING] -= 5
	elif gm._mod_active(w, 27):
		d[W.I_ARMY] += 5
		d[W.I_PEOPLE_SUPPORT] -= 2
		d[W.I_CORRUPTION] -= 2
		d[W.I_BUDGET] -= 2
	if gm._mod_active(w, 28):
		if w.event_done_num(326) and w.result_of_event_num(326) == 0 \
				and gm._mod_active(w, 3) and gm._mod_active(w, 6) \
				and d[W.I_RELIGION] <= 25 and d[W.I_PARTY_SYSTEM] == 6 and d[W.I_ECON_SYSTEM] <= 11:
			_add_ideology(w, 0, 3)
			d[W.I_PARTY_SUPPORT] -= 5
			d[W.I_PEOPLE_SUPPORT] += 15
			d[W.I_THOUGHT_FREEDOM] -= 15
			d[W.I_CORRUPTION] -= 5
			d[W.I_BUDGET] += 3
			d[W.I_AGENTS] += 3
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.power += 30
					p.loyalty += 30
		else:
			_add_ideology(w, 0, 1)
			_add_ideology(w, 1, 1)
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0 or p.trait_personality == 20:
					p.power += 10
					p.loyalty += 10
			d[W.I_PARTY_SUPPORT] -= 2
			d[W.I_PEOPLE_SUPPORT] += 2
			d[W.I_THOUGHT_FREEDOM] -= 2
			d[W.I_CORRUPTION] -= 2
			d[W.I_AGENTS] += 2
			if not gm._mod_active(w, 6):
				w.modifiers[28].is_active = false
	elif gm._mod_active(w, 29):
		_add_ideology(w, 0, -1)
		_add_ideology(w, 3, -1)
		_add_ideology(w, 4, -1)
		d[W.I_SERVICES] += 2
		d[W.I_INDUSTRY] += 2
		d[W.I_LIVING] += 5
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality != 1:
				p.power -= 5
		if d[W.I_PARTY_SYSTEM] > 7:
			w.modifiers[29].is_active = false
			w.modifiers[28].is_active = true
	elif gm._mod_active(w, 30):
		_add_ideology(w, 3, 1)
		d[W.I_BUDGET] += 5
		d[W.I_DIPLO] -= 2
		_add_empire_relation(w, 0, 5)
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 2:
				p.power += 10
		if d[W.I_ECON_SYSTEM] < 13:
			w.modifiers[30].is_active = false
			w.modifiers[28].is_active = true
	elif gm._mod_active(w, 31):
		_add_ideology(w, 4, 1)
		_add_empire_relation(w, 0, 5)
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 3:
				p.power += 10
		d[W.I_CORRUPTION] -= 2
		d[W.I_OLIGARCH] -= 2
		d[W.I_DIPLO] -= 2
		if d[W.I_ECON_SYSTEM] < 14 or d[W.I_PRESS_POLICY] < 17:
			w.modifiers[31].is_active = false
			w.modifiers[28].is_active = true
	if gm._mod_active(w, 32):
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 0:
				p.power += 10
			else:
				p.power -= 5
		if gm._mod_active(w, 6):
			d[W.I_PEOPLE_SUPPORT] += 10
			d[W.I_THOUGHT_FREEDOM] -= 10
			if w.event_done_num(670) and (w.result_of_event_num(670) == 0 or w.result_of_event_num(670) == 1):
				d[W.I_AGENTS] += 2
				d[W.I_ARMY] += 2
			if w.event_done_num(444) and w.result_of_event_num(444) == 0 and d[W.I_PRESS_POLICY] == 19:
				d[W.I_AGENTS] += 2
				d[W.I_ARMY] += 2
			# 复用函数开头声明的 player（w.get_player_country() 在同一轮内不变），
			# 避免内层重复声明触发 GDScript “There is already a variable named player” 解析错误。
			if player != null and player.has_tag("rim"):
				d[W.I_AGENTS] += 2
				d[W.I_ARMY] += 2
		else:
			d[W.I_PEOPLE_SUPPORT] -= 10
			d[W.I_THOUGHT_FREEDOM] += 15
		var china := w.get_player_country()
		if china != null and w.is_socialism(china, true):
			d[W.I_AGENTS] += 2
			d[W.I_ARMY] += 2
		if d[W.I_LIVING] > 1100:
			d[W.I_AGENTS] += 2
			d[W.I_ARMY] += 2
	if gm._mod_active(w, 33):
		d[W.I_PEOPLE_SUPPORT] += 2
		d[W.I_LIVING] += 2
		d[W.I_INDUSTRY] -= 2
		d[W.I_SERVICES] += 2
		d[W.I_ARMY] -= 5
	if gm._mod_active(w, 34):
		var r320 := w.result_of_event_num(320)
		if r320 == 1:
			d[W.I_AGRICULTURE] += 7
			d[W.I_INDUSTRY] += 2
			d[W.I_BUDGET] -= 3
			d[W.I_WAR_SUPPORT] += 2
			d[W.I_PEOPLE_SUPPORT] += 1
		elif r320 == 2:
			d[W.I_AGRICULTURE] += 3
			d[W.I_INDUSTRY] += 5
			d[W.I_BUDGET] -= 5
			d[W.I_MANPOWER] += 2
		elif r320 == 3:
			d[W.I_AGRICULTURE] += 7
			d[W.I_INDUSTRY] += 2
			d[W.I_BUDGET] -= 3
			d[W.I_WAR_SUPPORT] += 2
			d[W.I_PEOPLE_SUPPORT] += 1
			d[W.I_AGRICULTURE] += 3
			d[W.I_INDUSTRY] += 5
			d[W.I_BUDGET] -= 5
			d[W.I_MANPOWER] += 2
		elif r320 == 4:
			d[W.I_SERVICES] += 1
			d[W.I_INDUSTRY] += 1
			d[W.I_BUDGET] += 2
	if gm._mod_active(w, 35):
		d[W.I_BUDGET] -= 5
		d[W.I_INDUSTRY] += 5
		d[W.I_LIVING] += 5
		d[W.I_MANPOWER] += 2
	if gm._mod_active(w, 36):
		d[W.I_SCIENCE] += 5
		WarSystem.add_empire_power(EmpireData.USA, 5)
		WarSystem.add_empire_power(EmpireData.USSR, 5)
	if gm._mod_active(w, 37):
		d[W.I_CORRUPTION] -= 2
		d[W.I_SERVICES] += 2
		d[W.I_LIVING] += 5
		d[W.I_THOUGHT_FREEDOM] += 5
	if gm._mod_active(w, 38):
		d[W.I_PARTY_SUPPORT] += 5
		d[W.I_DIPLO] += 1
		d[W.I_WAR_SUPPORT] += 1
		if w.leader == null or w.leader.name_first != 32 or w.leader.name_last != 47:
			w.modifiers[38].is_active = false
	if gm._mod_active(w, 39):
		var usa_rel := w.empires[EmpireData.USA].relations if w.empires.size() > EmpireData.USA else 0
		if usa_rel < 150 and w.empires.size() > EmpireData.USA:
			w.empires[EmpireData.USA].relations = 150
		WarSystem.add_empire_power(EmpireData.USA, -5)
		_add_empire_relation(w, 1, -5)
		d[W.I_RESERVE] += 5
	if gm._mod_active(w, 40):
		if d[W.I_AGRICULTURE] < 400:
			d[W.I_AGRICULTURE] = 400
		if d[W.I_INDUSTRY] > 500:
			d[W.I_INDUSTRY] = 500
		if d[W.I_SERVICES] > 500:
			d[W.I_SERVICES] = 500
		if d[W.I_ARMY] > 2000:
			d[W.I_ARMY] = 2000
		_set_ideology(w, 0, 0)
		d[W.I_WAR_SUPPORT] += 10
		d[W.I_MANPOWER] += 5
		d[W.I_AGRICULTURE] += 4
		d[W.I_CORRUPTION] -= 5
		d[W.I_THOUGHT_FREEDOM] -= 10
		d[W.I_DIPLO] += 2
	if gm._mod_active(w, 41):
		_add_ideology(w, 3, 1)
		d[W.I_AGENTS] += 10
		WarSystem.add_empire_power(EmpireData.USA, 1)
		_add_ideology(w, 4, 1)
		for p in w.politicians:
			if p == null or PoliticianSystem.is_vacant_politician(p):
				continue
			if p.trait_personality == 2:
				p.power += 10

	# ── 42-51：ModifiesInfuence.cs:2228-2420 ──
	if gm._mod_active(w, 42):
		var c21 := w.get_country_by_legacy_index(21)
		if d[W.I_POLITICAL_DISPLAY] > 39 and not gm._mod_active(w, 17) \
				and c21 != null and c21.has_tag("对华贸易"):
			_add_empire_relation(w, 0, 4)
			d[W.I_BUDGET] += 2
			d[W.I_DIPLO] -= 1
		WarSystem.add_empire_power(EmpireData.USA, 1)
	if gm._mod_active(w, 43):
		var c21 := w.get_country_by_legacy_index(21)
		var china := w.get_player_country()
		if c21 != null and c21.has_tag("对华贸易") and china != null \
				and not china.has_tag("seato") and not china.has_tag("okb") and not china.has_tag("ovd") \
				and (china.government == GameConstants.Government.REFORMIST or china.government == GameConstants.Government.LIBERAL):
			d[W.I_BUDGET] += 3
			d[W.I_SCIENCE] += 4
	if gm._mod_active(w, 44):
		var c21 := w.get_country_by_legacy_index(21)
		if not w.get_flag("YugAgree"):
			if c21 != null and c21.has_tag("对华贸易") and d[W.I_ECON_DISPLAY] < 36 and not gm._mod_active(w, 16):
				_add_empire_relation(w, 1, 4)
				d[W.I_BUDGET] += 2
				d[W.I_SCIENCE] += 2
		else:
			if c21 != null and c21.has_tag("对华贸易") and d[W.I_IDEOLOGY] < 2 and not gm._mod_active(w, 16):
				_add_empire_relation(w, 1, 5)
				d[W.I_BUDGET] += 6
				d[W.I_SCIENCE] += 6
		WarSystem.add_empire_power(EmpireData.USSR, 1)
	var c21b := w.get_country_by_legacy_index(21)
	var chinab := w.get_player_country()
	if gm._mod_active(w, 44) and c21b != null and c21b.has_tag("对华贸易") \
			and chinab != null and chinab.has_tag("okb") and d[W.I_INFLUENCE] >= 500:
		d[W.I_MIL_INTERVENTION] += 5
		d[W.I_BUDGET] += 2
		_add_empire_relation(w, 0, -3)
		_add_empire_relation(w, 1, -3)
		WarSystem.add_empire_power(EmpireData.USA, -1)
		WarSystem.add_empire_power(EmpireData.USSR, -1)
	if gm._mod_active(w, 46):
		d[W.I_BUDGET] += 6
		d[W.I_ARMY] += 5
		d[W.I_AGENTS] += 5
		_add_empire_relation(w, 0, -5)
		_add_empire_relation(w, 1, -5)
		WarSystem.add_empire_power(EmpireData.USA, -1)
		WarSystem.add_empire_power(EmpireData.USSR, -1)
	if gm._mod_active(w, 47):
		var okb47 := _count_tag(w, "okb")
		if okb47 < 7:
			d[W.I_BUDGET] -= 10
		elif okb47 < 14:
			d[W.I_BUDGET] -= 20
		else:
			d[W.I_BUDGET] -= 30
		d[W.I_AGENTS] += okb47 * 2
	if gm._mod_active(w, 48):
		var okb48 := _count_tag(w, "okb")
		if okb48 < 7:
			d[W.I_BUDGET] -= 10
		elif okb48 < 14:
			d[W.I_BUDGET] -= 20
		else:
			d[W.I_BUDGET] -= 30
		d[W.I_ARMY] += okb48
	if gm._mod_active(w, 49):
		d[W.I_MIL_INTERVENTION] += 30
		d[W.I_AGENTS] += 20
		_add_empire_relation(w, 0, -20)
		_add_empire_relation(w, 1, -20)
		if w.event_done_num(691):
			d[W.I_BUDGET] -= 2
			d[W.I_PARTY_SUPPORT] += 2
			d[W.I_THOUGHT_FREEDOM] += 1
			if d[W.I_WAR_SUPPORT] > 200:
				d[W.I_WAR_SUPPORT] = 200
			if w.result_of_event_num(691) == 1:
				d[W.I_BUDGET] += 4
				d[W.I_PARTY_SUPPORT] += 1
				d[W.I_PEOPLE_SUPPORT] -= 1
				d[W.I_DIPLO] += 2
				d[W.I_THOUGHT_FREEDOM] += 4
			elif w.result_of_event_num(691) == 2:
				var ussr_leader := w.empires[EmpireData.USSR].current_leader if w.empires.size() > EmpireData.USSR else -1
				if ussr_leader == 6 or ussr_leader == 7:
					_add_empire_relation(w, 1, 1)
	if gm._mod_active(w, 51):
		_apply_modifier51_oil(d, w)

	# ── 53/58/59/61/63/65：ModifiesInfuence.cs:2556-2890 ──
	if gm._mod_active(w, 53):
		var c17 := w.get_country_by_legacy_index(17)
		if c17 != null and c17.parts.size() > 0 and not c17.parts[0]:
			_add_ideology(w, 0, 1)
			_add_ideology(w, 2, 1)
			d[W.I_AGENTS] += 10
			WarSystem.add_empire_power(EmpireData.USSR, 1)
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0 or p.trait_personality == 1:
					p.power += 10
		elif c17 != null and c17.parts.size() > 0 and c17.parts[0] \
				and c17.has_tag("亲中") and c17.government == GameConstants.Government.SOCIALIST:
			_add_ideology(w, 0, 1)
			d[W.I_AGENTS] += 15
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 0:
					p.power += 10
	if gm._mod_active(w, 58) and w.empires.size() > EmpireData.USSR \
			and w.empires[EmpireData.USSR].relations >= 500 and _dv(d, 153) > 0:
		d[153] -= 1
		d[W.I_BUDGET] -= 5
	var china59 := w.get_player_country()
	if not gm._mod_active(w, 59) and china59 != null and china59.has_tag("okb"):
		w.modifiers[59].is_active = true
	if gm._mod_active(w, 59):
		var okb59 := _count_tag(w, "okb")
		var au59 := 0
		var oar59 := _count_tag(w, "oar")
		var rim59 := _count_tag(w, "rim")
		for c in w.countries:
			if c != null and c.has_tag("au") and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL) \
					and w.event_done_num(500) and w.result_of_event_num(500) == 0:
				au59 += 1
		if okb59 > 0:
			d[W.I_ARMY] += okb59 * 3
			d[W.I_AGENTS] += okb59 * 2
			d[W.I_MIL_INTERVENTION] += okb59
		if au59 > 0:
			d[W.I_ARMY] += au59 * 3
			d[W.I_AGENTS] += au59 * 2
			d[W.I_MIL_INTERVENTION] += au59
		if oar59 > 0:
			d[W.I_ARMY] += oar59 * 3
			d[W.I_AGENTS] += oar59 * 2
			d[W.I_MIL_INTERVENTION] += oar59
		if rim59 > 0:
			d[W.I_ARMY] += rim59 * 6
			d[W.I_AGENTS] += rim59 * 4
			d[W.I_MIL_INTERVENTION] += rim59 * 2
	if gm._mod_active(w, 61):
		match _dv(d, 185):
			0:
				d[W.I_MANPOWER] += 1
			1:
				d[W.I_PARTY_SUPPORT] += 1
			2:
				d[W.I_MANPOWER] += 2
			3:
				d[W.I_PEOPLE_SUPPORT] += 1
			4:
				d[W.I_WAR_SUPPORT] -= 1
				if d[W.I_WAR_SUPPORT] > 700:
					d[W.I_WAR_SUPPORT] -= 3
			5:
				pass
			6:
				var china61 := w.get_player_country()
				if china61 != null and china61.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
					d[W.I_THOUGHT_FREEDOM] -= 2
					d[W.I_DIPLO] += 2
					d[W.I_WAR_SUPPORT] += 4
	if gm._mod_active(w, 63):
		if not w.event_done_num(687):
			d[W.I_THOUGHT_FREEDOM] += 50
			d[W.I_WAR_SUPPORT] -= 15
			d[W.I_PARTY_SUPPORT] -= 10
			d[W.I_PEOPLE_SUPPORT] += 30
		else:
			d[W.I_THOUGHT_FREEDOM] -= 30
			d[W.I_WAR_SUPPORT] += 10
			d[W.I_PARTY_SUPPORT] -= 10
			d[W.I_PEOPLE_SUPPORT] += 30
			for p in w.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == 20:
					p.power += 10
	if w.money_level > 0 and not gm._mod_active(w, 65):
		w.modifiers[65].is_active = true
	elif w.money_level <= 0 and gm._mod_active(w, 65):
		w.modifiers[65].is_active = false
	if gm._mod_active(w, 65):
		var ml := w.money_level
		w.leader_asset += 10 * ml
		d[W.I_PEOPLE_SUPPORT] -= 2 * ml
		d[W.I_THOUGHT_FREEDOM] += 2 * ml
		d[W.I_LIVING] -= 5 * ml
		d[W.I_INDUSTRY] -= 4 * ml
		d[W.I_AGRICULTURE] -= 4 * ml
		d[W.I_SERVICES] -= 4 * ml
		d[W.I_CORRUPTION] -= 2 * ml
		if w.leader_property.size() > 1 and w.leader_property[1]:
			d[W.I_BUDGET] -= 10
			d[W.I_SCIENCE] += 5
			d[W.I_MIL_INTERVENTION] += 10
			_add_empire_relation(w, 1, -2)
		if w.leader_property.size() > 2 and w.leader_property[2]:
			d[W.I_BUDGET] -= 20
			d[W.I_SCIENCE] += 5
			d[W.I_MIL_INTERVENTION] += 10
			if w.empires.size() > EmpireData.USSR and w.empires[EmpireData.USSR].relations < 250:
				w.empires[EmpireData.USSR].relations = 250
			if w.empires.size() > EmpireData.USA and w.empires[EmpireData.USA].relations < 250:
				w.empires[EmpireData.USA].relations = 250
		if w.leader_property.size() > 3 and w.leader_property[3]:
			d[W.I_BUDGET] -= 20
			d[W.I_PARTY_SUPPORT] += 5
			if d[W.I_PARTY_SUPPORT] < 400:
				d[W.I_PARTY_SUPPORT] = 400
			if d[W.I_PARTY_SYSTEM] > 7 and d[W.I_THOUGHT_FREEDOM] > 400:
				d[W.I_THOUGHT_FREEDOM] = 400
			d[W.I_MIL_INTERVENTION] += 10
			_add_empire_relation(w, 1, -2)
		if ml > 20 and d[W.I_MAO_MAUSOLEUM] != 9:
			gm.start_event("popular_discontent")

	gm._mirror_empires_to_data(world)


# ── 产业自然衰减（TimeScript 5323-5370行） ──

func _fortnight_industry_decay(d: Array[int]) -> void:
	var v := d[W.I_INDUSTRY]
	if v < 250:
		d[W.I_INDUSTRY] -= 2
		d[W.I_PARTY_SUPPORT] -= 10
		d[W.I_LIVING] -= 5
		d[W.I_ARMY] -= 5
	elif v < 410:
		d[W.I_INDUSTRY] -= 3
		d[W.I_PARTY_SUPPORT] -= 5
		d[W.I_LIVING] -= 2
		d[W.I_ARMY] -= 2
	elif v < 610:
		d[W.I_INDUSTRY] -= 8
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_INDUSTRY] -= 18
	elif v < 810:
		d[W.I_INDUSTRY] -= 25
	elif v < 1100:
		d[W.I_INDUSTRY] -= 40
		d[W.I_AGENTS] += 5
	else:
		d[W.I_INDUSTRY] -= 80
		d[W.I_AGENTS] += 10
	if d[W.I_ECON_SYSTEM] < 13:
		if d[W.I_AGRICULTURE] < 300:
			d[W.I_INDUSTRY] -= 4
		elif d[W.I_AGRICULTURE] < 500:
			d[W.I_INDUSTRY] -= 2
	d[W.I_BUDGET] += d[W.I_INDUSTRY] / 50


# ── 农业自然衰减（TimeScript 5461-5505行） ──

func _fortnight_agriculture_decay(d: Array[int]) -> void:
	var v := d[W.I_AGRICULTURE]
	if v < 250:
		d[W.I_AGRICULTURE] -= 2
		d[W.I_PARTY_SUPPORT] -= 10
		d[W.I_LIVING] -= 5
	elif v < 410:
		d[W.I_AGRICULTURE] -= 5
		d[W.I_PARTY_SUPPORT] -= 5
		d[W.I_LIVING] -= 2
	elif v < 610:
		d[W.I_AGRICULTURE] -= 9
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_AGRICULTURE] -= 19
	elif v < 810:
		d[W.I_AGRICULTURE] -= 26
	elif v < 1100:
		d[W.I_AGRICULTURE] -= 40
		d[W.I_ARMY] += 5
	else:
		d[W.I_AGRICULTURE] -= 80
		d[W.I_ARMY] += 10
	d[W.I_BUDGET] += d[W.I_AGRICULTURE] / 100


# ── 服务业自然衰减（TimeScript 5393-5438行） ──

func _fortnight_services_decay(d: Array[int]) -> void:
	var v := d[W.I_SERVICES]
	if v < 250:
		d[W.I_SERVICES] -= 1
		d[W.I_PARTY_SUPPORT] -= 10
		d[W.I_LIVING] -= 5
	elif v < 410:
		d[W.I_SERVICES] -= 3
		d[W.I_PARTY_SUPPORT] -= 5
		d[W.I_LIVING] -= 2
	elif v < 610:
		d[W.I_SERVICES] -= 8
		d[W.I_PARTY_SUPPORT] -= 1
	elif v < 710:
		d[W.I_SERVICES] -= 18
	elif v < 810:
		d[W.I_SERVICES] -= 25
	elif v < 1100:
		d[W.I_SERVICES] -= 40
		d[W.I_LIVING] += 5
	else:
		d[W.I_SERVICES] -= 80
		d[W.I_LIVING] += 10
	if d[W.I_ECON_SYSTEM] < 13:
		if d[W.I_AGRICULTURE] < 300:
			d[W.I_SERVICES] -= 5
		elif d[W.I_AGRICULTURE] < 500:
			d[W.I_SERVICES] -= 2
	d[W.I_BUDGET] += d[W.I_SERVICES] / 50


# ── 军事学说周期效果（TimeScript 4897-4969行） ──

func _fortnight_military_doctrine(d: Array[int], _w: WorldState) -> void:
	var pop_excess := d[W.I_POPULATION] - 9307
	match d[W.I_MIL_DOCTRINE]:
		30:
			if pop_excess > 99:
				d[W.I_BUDGET] -= pop_excess / 100
				d[W.I_ARMY] += pop_excess / 100
			if d[W.I_POLITICAL_DISPLAY] > 38:
				d[W.I_POLITICAL_OPENNESS] -= 10
		31:
			if pop_excess > 199:
				d[W.I_BUDGET] -= pop_excess / 200
				d[W.I_ARMY] += pop_excess / 200
		32:
			if pop_excess > 299:
				d[W.I_BUDGET] -= pop_excess / 300
				d[W.I_ARMY] += pop_excess / 300
		33:
			if pop_excess > 149:
				if d[W.I_LIVING] < 500:
					d[W.I_BUDGET] -= pop_excess / 150
					d[W.I_ARMY] += pop_excess / 250
				elif d[W.I_LIVING] < 700:
					d[W.I_BUDGET] -= pop_excess / 150
					d[W.I_ARMY] += pop_excess / 300
				else:
					d[W.I_BUDGET] -= pop_excess / 500
					d[W.I_ARMY] += pop_excess / 500
			if d[W.I_POLITICAL_DISPLAY] < 40:
				d[W.I_POLITICAL_OPENNESS] += 10
			if d[W.I_ECON_DISPLAY] < 36:
				d[W.I_ECON_OPENNESS] += 10


# ── 贸易平衡（TimeScript.cs:4135-4167，双周块；原注释 854-911/3247-3272 系错误出处） ──

## 出口规模重算（原版 TimeScript.ExportValue，13180 起）。
## 完整版约 400 行；此处先实现“按对华贸易/经济联盟/经互会成员数重算出口与伙伴数”的核心，
## 让概览出口规模随外交关系变化，后续可按原版逐国加成继续细化。
func _recalc_export_value(d: Array[int], w: WorldState) -> void:
	var pc := w.get_player_country()
	if pc == null:
		return
	d[W.I_TRADE_PARTNERS] = 0
	d[W.I_INCOME] = _dv(d, W.I_EXPORT_BASE)  # 原版 ExportValue：data[23] = data[70]
	for c in w.countries:
		if c == pc or c.gwcode <= 0:
			continue
		var linked := c.has_tag("对华贸易") \
			or (c.has_tag("econ") and pc.has_tag("econ")) \
			or (c.has_tag("sev") and pc.has_tag("sev"))
		if linked:
			d[W.I_TRADE_PARTNERS] += 1
			d[W.I_INCOME] += 10


func _fortnight_trade_balance(d: Array[int], w: WorldState) -> void:
	# 先按原版 ExportValue 重算出口规模与贸易伙伴数，再执行石油危机修正与顺逆差结算。
	# 注意：_recalc_export_value 已归零并统计完三类贸易伙伴，这里绝不能再叠加旧循环。
	_recalc_export_value(d, w)
	# 石油危机修正（原版 :4135-4139）：modifies[12] 激活时 data[23] -= data[23]/6
	if gm._mod_active(w, 12):
		d[W.I_INCOME] -= d[W.I_INCOME] / 6
	# 贸易平衡（原版 :4140-4155）：顺差 budget+=(23-24)/10、people+=(23-24)/15；
	# 逆差 budget-=(23-24)/10、people-=(23-24)/15、living-=(23-24)/20
	@warning_ignore("integer_division")
	var diff := d[W.I_INCOME] - d[W.I_IMPORT_NEEDS]
	if diff > 0:
		d[W.I_BUDGET] += diff / 10
		d[W.I_PEOPLE_SUPPORT] += diff / 15
	else:
		d[W.I_BUDGET] -= diff / 10
		d[W.I_PEOPLE_SUPPORT] -= diff / 15
		d[W.I_LIVING] -= diff / 20
	# 伙伴数效应（原版 :4156-4167）：≤10 → thought/agents -= (-9+data[25])；>18 → thought += data[25]-18
	if d[W.I_TRADE_PARTNERS] <= 10:
		d[W.I_THOUGHT_FREEDOM] -= -9 + d[W.I_TRADE_PARTNERS]
		d[W.I_AGENTS] -= -9 + d[W.I_TRADE_PARTNERS]
	elif d[W.I_TRADE_PARTNERS] > 18:
		d[W.I_THOUGHT_FREEDOM] += d[W.I_TRADE_PARTNERS] - 18


# ── 满意度/异见漂移（TimeScript 4168-4201行） ──

func _fortnight_satisfaction_drift(d: Array[int], w: WorldState) -> void:
	var ws := d[W.I_WAR_SUPPORT]
	if ws > 700:
		d[W.I_LIVING] -= (ws - 500) / 100
		d[W.I_PARTY_SUPPORT] += (ws - 500) / 100
		d[W.I_AGENTS] += (ws - 500) / 100
		if d[W.I_DIPLO] < 500:
			d[W.I_DIPLO] += 5
	elif ws < 400:
		d[W.I_THOUGHT_FREEDOM] += (500 - ws) / 100
		d[W.I_PARTY_SUPPORT] += (500 - ws) / 100
		d[W.I_AGENTS] += (500 - ws) / 100
		if w.empires.size() > 0:
			w.empires[0].relations += (500 - ws) / 100
		if w.empires.size() > 1:
			w.empires[1].relations += (500 - ws) / 100


# ── 双周：大国领导人与军备资金效果（TimeScript.cs:4318-4510） ──
## 原版外层 if(!dlc[0])：dlc 是 new bool[5]（GlobalScript.cs:221），无任何 =true 写入点，
## 默认 false → 该分支恒真。Godot 建模说明 DLC 系统，按恒真移植。
## now_leader 语义按 modify_choose.cs 显示索引（Event89.cs 也按 1=安德罗波夫/3=谢尔比茨基
## 写 now_leader），与 leaders[] 数组下标解耦。
func _fortnight_leader_effects(d: Array[int], w: WorldState) -> void:
	if w.empires.size() < 2 or w.empires[0] == null or w.empires[1] == null:
		return
	var usa: EmpireData = w.empires[0]
	var ussr: EmpireData = w.empires[1]
	var player := w.get_player_country()
	var china_in_sev: bool = player != null and player.has_tag("sev")
	var relres: bool = w.get_flag("relres")

	# data[69]>7 → 美国储备资金 += data[69]/7（TimeScript.cs:4318-4321）
	if d[W.I_LOAN] > 7:
		usa.money += d[W.I_LOAN] / 7

	# 苏联领导人双周效果（TimeScript.cs:4324-4443）
	match ussr.current_leader:
		0:
			ussr.money += 20
			if not relres and not china_in_sev:
				usa.relations += 5
				d[W.I_MANPOWER] -= 2
		1:
			if not relres and not china_in_sev:
				usa.relations += 5
			else:
				_politician_power_boost(w, [2])
		2:
			ussr.relations += 5
			if relres or china_in_sev:
				_politician_power_boost(w, [1])
		3:
			if not relres and not china_in_sev:
				usa.relations += 5
				d[W.I_MANPOWER] -= 2
			else:
				ussr.relations += 5
		4:
			if not relres and not china_in_sev:
				d[W.I_AGENTS] -= 5
			else:
				ussr.relations += 5
				d[W.I_AGENTS] += 5
		5:
			ussr.relations += 5
			if relres or china_in_sev:
				_politician_power_boost(w, [2])
		6:
			ussr.money -= 20
			ussr.relations += 5
			d[W.I_THOUGHT_FREEDOM] += 5
			_politician_power_boost(w, [3])
		8:
			ussr.money -= 20
			ussr.relations += 5
			d[W.I_THOUGHT_FREEDOM] += 5

	# 美国总统双周效果（TimeScript.cs:4444-4502）
	var year := d[W.I_YEAR] if d.size() > W.I_YEAR else w.date.year
	if year >= 1981 and usa.current_leader <= 0:
		usa.money += 5
		d[W.I_THOUGHT_FREEDOM] += 5
	elif usa.current_leader == 1 or (year >= 1977 and year < 1981):
		usa.relations += 10
	elif usa.current_leader == 2:
		usa.money += 5
		if player != null and not player.has_tag("ovd") and not player.has_tag("okb"):
			usa.relations += 5
	elif usa.current_leader == 3:
		usa.relations += 10
	elif usa.current_leader == 4:
		usa.money += 2
		usa.power -= 2
		ussr.power += 1
	elif usa.current_leader == 5:
		usa.power -= 4
		ussr.power += 2
		usa.relations += 2
		if player != null and player.government == GameConstants.Government.LIBERAL:
			usa.relations += 2
	elif usa.current_leader == 6:
		usa.money += 1
		usa.power -= 1
	elif usa.current_leader == 7:
		usa.money -= 2
		if player != null and player.government == GameConstants.Government.REFORMIST:
			usa.relations += 2
		_politician_power_boost(w, [2, 3])


## TimeScript 领导人效果里的 politics.traits[0]∈set 循环：对应 Godot trait_personality。
func _politician_power_boost(w: WorldState, personalities: Array[int]) -> void:
	for p in w.politicians:
		if p == null:
			continue
		if personalities.has(p.trait_personality):
			p.power += 5


# ── 政治满意度漂移（TimeScript 4716-4895行，党政/舆论/领土/宗教） ──

func _fortnight_political_drift(d: Array[int], _w: WorldState) -> void:
	var pd := d[W.I_POLITICAL_DISPLAY]
	match d[W.I_PARTY_SYSTEM]:
		6:
			if pd > 38: d[W.I_POLITICAL_OPENNESS] -= 10
		7:
			if pd > 39: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 39: d[W.I_POLITICAL_OPENNESS] += 20
		8:
			if pd > 40: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 40: d[W.I_POLITICAL_OPENNESS] += 20
		9:
			if pd < 41: d[W.I_POLITICAL_OPENNESS] += 30
	match d[W.I_PRESS_POLICY]:
		16:
			if pd > 38: d[W.I_POLITICAL_OPENNESS] -= 10
		17:
			if pd > 39: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 39: d[W.I_POLITICAL_OPENNESS] += 20
		18:
			if pd > 40: d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 40: d[W.I_POLITICAL_OPENNESS] += 20
		19:
			if pd < 41: d[W.I_POLITICAL_OPENNESS] += 30
	# ── 领土制度效果（TimeScript 3756-3805行） ──
	match d[W.I_TERRITORY]:
		20:
			d[W.I_BUDGET] -= 1
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] -= 4
			d[W.I_MANPOWER] += 1
			if pd > 39:
				d[W.I_POLITICAL_OPENNESS] -= 10
		21:
			d[W.I_PARTY_SUPPORT] -= 2
			d[W.I_THOUGHT_FREEDOM] -= 1
			if pd < 40:
				d[W.I_POLITICAL_OPENNESS] += 20
		22:
			d[W.I_PARTY_SUPPORT] -= 3
			d[W.I_PEOPLE_SUPPORT] -= 1
			d[W.I_THOUGHT_FREEDOM] += 2
			d[W.I_MANPOWER] -= 2
			if pd > 40:
				d[W.I_POLITICAL_OPENNESS] -= 20
			elif pd < 40:
				d[W.I_POLITICAL_OPENNESS] += 20
		23:
			d[W.I_MANPOWER] -= 4
			d[W.I_THOUGHT_FREEDOM] += 5
			d[W.I_PEOPLE_SUPPORT] -= 2
			d[W.I_PARTY_SUPPORT] -= 5
			if pd < 41:
				d[W.I_POLITICAL_OPENNESS] += 30
	# ── 宗教政策对政治开放度的漂移（原版 TimeScript.cs:4791-4815）──
	match d[W.I_RELIGION]:
		24, 25:
			if pd > 38:
				d[W.I_POLITICAL_OPENNESS] -= 15
		28:
			if pd < 40:
				d[W.I_POLITICAL_OPENNESS] += 10
		29:
			if pd > 39:
				d[W.I_POLITICAL_OPENNESS] -= 15



# ── 难度修正（TimeScript 5757-5853行） ──

func _fortnight_difficulty_bonus(d: Array[int], w: WorldState) -> void:
	match w.difficulty:
		0:
			d[W.I_PARTY_SUPPORT] += 5
			d[W.I_PEOPLE_SUPPORT] += 5
			d[W.I_THOUGHT_FREEDOM] -= 5
			d[W.I_LIVING] += 5
			d[W.I_BUDGET] += 50
			d[W.I_AGENTS] += 50
			if d[W.I_CORRUPTION] > 200:
				d[W.I_CORRUPTION] -= 30
			elif d[W.I_CORRUPTION] > 100:
				d[W.I_CORRUPTION] -= 20
			else:
				d[W.I_CORRUPTION] -= 10
		1:
			d[W.I_PARTY_SUPPORT] += 3
			d[W.I_PEOPLE_SUPPORT] += 3
			d[W.I_THOUGHT_FREEDOM] -= 3
			d[W.I_LIVING] += 3
			d[W.I_BUDGET] += 3
			d[W.I_AGENTS] += 3
		2:
			if d[W.I_CORRUPTION] < 50:
				d[W.I_CORRUPTION] += 8
			elif d[W.I_CORRUPTION] < 100:
				d[W.I_CORRUPTION] += 5
		3:
			d[W.I_PARTY_SUPPORT] -= 6
			d[W.I_PEOPLE_SUPPORT] -= 7
			d[W.I_THOUGHT_FREEDOM] += 7
			d[W.I_LIVING] -= 7
			d[W.I_BUDGET] -= 7
			d[W.I_AGENTS] -= 7
			if d[W.I_CORRUPTION] < 50:
				d[W.I_CORRUPTION] += 10
			elif d[W.I_CORRUPTION] < 100:
				d[W.I_CORRUPTION] += 6
			else:
				d[W.I_CORRUPTION] += 1
		4:
			d[W.I_PARTY_SUPPORT] -= d[W.I_IDEOLOGY] * 3
			d[W.I_PEOPLE_SUPPORT] -= d[W.I_IDEOLOGY] * 3
			if w.empires.size() > 0:
				w.empires[0].relations -= 5
			if w.empires.size() > 1:
				w.empires[1].relations -= 5
			if gm.is_mao_dead():
				for p in w.politicians:
					if p == null:
						continue
					if p.trait_personality == 0:
						p.power += 50
					else:
						p.loyalty -= 10


# ── 政变条件（TimeScript.PlotPlayer 100-113行） ──

func _check_coup(d: Array[int], w: WorldState) -> void:
	if not gm.is_mao_dead():
		return
	var disloyal_power := 0
	for p in w.politicians:
		if p == null:
			continue
		# 原版 traits[2] → trait_special；含 you_fall（POL-07）
		var special: int = p.trait_special
		var dominated := false
		if p.loyalty < 300 and special == 16:
			dominated = true
		elif p.you_fall:
			dominated = true
		elif p.loyalty < 150 and special != 9:
			dominated = true
		elif p.loyalty < 50 and special == 9:
			dominated = true
		if dominated and special != 17 and special != 19 and not p.is_under_investigation:
			disloyal_power += p.power
	if disloyal_power / 5 > d[W.I_PARTY_SUPPORT]:
		gm.start_event("congress_conspiracy")


## TimeScript.PlotPlayerCause（TimeScript.cs:250-266）：按不忠势力判断「针对你的阴谋」，
## 并把结果写到 leader.is_sagovor（本端口对应 leader.is_conspiracy）。
## 谓词与 _check_coup（PlotPlayer）不同：trait_background=28 阈值 1500、
## trait_alignment=41 阈值 1200、trait_special 16/35 阈值 300 等。
func _plot_player_cause(d: Array[int], w: WorldState) -> void:
	if w == null or w.leader == null:
		return
	var disloyal_power := 0
	for p in w.politicians:
		if p == null or p.is_under_investigation:
			continue
		if p.trait_special == 17 or p.trait_special == 19 or p.trait_alignment == 40:
			continue
		var dominated := false
		if p.trait_background == 28 and p.loyalty < 1500:
			dominated = true
		elif p.trait_alignment == 41 and p.loyalty < 1200:
			dominated = true
		elif p.loyalty < 300 and (p.trait_special == 16 or p.trait_special == 35):
			dominated = true
		elif p.you_fall:
			dominated = true
		elif p.loyalty < 150 and p.trait_special != 9 and p.trait_special != 37:
			dominated = true
		elif p.loyalty < 50 and (p.trait_special == 9 or p.trait_special == 37):
			dominated = true
		if dominated:
			disloyal_power += p.power
	@warning_ignore("integer_division")
	var threshold: int = d[W.I_PARTY_SUPPORT] / 4 * 3
	@warning_ignore("integer_division")
	w.leader.is_conspiracy = disloyal_power / 5 > threshold


## 顶栏「阴谋临近」提示图标判定（TimeScript.AlarmIconChange 45-49 行）：
## leader.is_sagovor（= leader.is_conspiracy）或党内支持-70 低于临界线时亮。
func plot_alert_active(ws: WorldState) -> bool:
	if ws == null or ws.leader == null:
		return false
	var d := ws.数值表
	var leader_threat: bool = ws.leader.is_conspiracy
	@warning_ignore("integer_division")
	var party_threat: bool = _dv(d, W.I_PARTY_SUPPORT) - 70 \
		<= 300 + _dv(d, W.I_THOUGHT_FREEDOM) / 5 - (_dv(d, W.I_PEOPLE_SUPPORT) - 500) / 5
	return leader_threat or party_threat


## TimeScript.cs:1453-1456：党内支持低于临界线时进入事件4（阴谋），每日判定。
func _check_daily_conspiracy(d: Array[int]) -> void:
	if gm.current_event_id != "":
		return
	if d[W.I_PARTY_SUPPORT] <= 300 + d[W.I_THOUGHT_FREEDOM] / 5 - (d[W.I_PEOPLE_SUPPORT] - 500) / 5:
		gm.start_event("congress_conspiracy")


## TimeScript.cs:289-294：政党制度达标后，每年 10 月 1 日直接进入选举。
func _check_scheduled_events(ws: WorldState) -> void:
	if ws == null or gm.current_event_id != "":
		return
	if ws.get_flag("election_due") and ws.数值表[W.I_PARTY_SYSTEM] > 7:
		ws.set_flag("election_due", false)
		gm.start_event("npc_elections")
		return
	if ws.date.day == 1 and ws.date.month == 10 and ws.数值表[W.I_PARTY_SYSTEM] > 7:
		gm.start_event("npc_elections")


func _dv(d: Array, idx: int) -> int:
	return d[idx] if d.size() > idx else 0


func _country_tag(w: WorldState, idx: int, tag: String) -> bool:
	var c := w.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)


func _country_dev_is(w: WorldState, idx: int, dev: int) -> bool:
	var c := w.get_country_by_legacy_index(idx)
	return c != null and c.development == dev


## TimeScript.cs 逐帧/逐块成就检查的移植子集（其余 9 个在 GameState.WarResult 各战争分支内，
## 待战争胜利特效批移植时同步接线）。
func _check_periodic_achievements(w: WorldState) -> void:
	if w == null:
		return
	var d := w.数值表
	# TimeScript.cs:5965：data[113..116] 全为 9 → Set(28)。
	if _dv(d, 113) == 9 and _dv(d, 114) == 9 and _dv(d, 115) == 9 and _dv(d, 116) == 9:
		Achievements.set_achievement(28)
	# TimeScript.cs:3220：data[131]==1 且 44.sub∈{7,9}、86.sub==9、85.sub==9、87.sub==7 → Set(131)。
	var c44 := w.get_country_by_legacy_index(44)
	var c85 := w.get_country_by_legacy_index(85)
	var c86 := w.get_country_by_legacy_index(86)
	var c87 := w.get_country_by_legacy_index(87)
	if _dv(d, 131) == 1 and c44 != null and (c44.sub_government == GameConstants.SubGovernment.NEO_FASCIST or c44.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN) \
			and c86 != null and c86.sub_government == GameConstants.SubGovernment.NEO_FASCIST \
			and c85 != null and c85.sub_government == GameConstants.SubGovernment.NEO_FASCIST \
			and c87 != null and c87.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		Achievements.set_achievement(131)
	# TimeScript.cs:3257：台湾路线2/决议7 且 51 内战中 且 data[157]>0 → Set(155)。
	var c51 := w.get_country_by_legacy_index(51)
	var dec7 := w.decisions != null and w.decisions.completed.size() > 7 and w.decisions.completed[7]
	if (_dv(d, W.I_TAIWAN_STATUS) == 2 or dec7) and c51 != null and c51.内战中 and _dv(d, 157) > 0:
		Achievements.set_achievement(155)
	# TimeScript.cs:3261/3265：data[143] <=10 / >=60 且 modifier51 激活 → Set(158)/Set(157)。
	var mod51 := w.modifiers.size() > 51 and w.modifiers[51] != null and w.modifiers[51].is_active
	if mod51 and _dv(d, 143) <= 10:
		Achievements.set_achievement(158)
	if mod51 and _dv(d, 143) >= 60:
		Achievements.set_achievement(157)
	# TimeScript.cs:3269：36/101/102/103/105 全亲中 → Set(156)。
	var all_proprc := true
	for idx in [36, 101, 102, 103, 105]:
		var cc := w.get_country_by_legacy_index(idx)
		if cc == null or not cc.has_tag("亲中"):
			all_proprc = false
			break
	if all_proprc:
		Achievements.set_achievement(156)


func _check_endings(d: Array[int], _w: WorldState, _year: int) -> void:
	# 原版自动结局只有 TimeScript.cs:705 的人口崩盘 ToEnding(4)。
	# 1993 强制结局与预算/派系两个分支在原版源码无对应（grep 全量 0 命中），
	# 属早期误植；正常终局走 1986-01-01 的 ending_choice 事件（in1992_script 语义）。
	if d[W.I_POPULATION] < 6671:
		gm._trigger_ending(4)
		return
