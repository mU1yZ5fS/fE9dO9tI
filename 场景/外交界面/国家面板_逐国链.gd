## 逐国按钮链（CountryScript.cs 中文链完整镜像，list layer only）。
extends RefCounted


func _slots() -> Array:
	return [null, null, null, null]


func _btn(type: int, caption: String) -> Dictionary:
	return {"type": type, "caption": caption}


func _show(slots: Array, slot: int, type: int, caption: String) -> void:
	slots[slot] = _btn(type, caption)


func _hide_all(slots: Array) -> void:
	for i in range(4):
		slots[i] = null


func _finish(slots: Array) -> Array:
	var out: Array = []
	for i in range(4):
		if slots[i] != null:
			out.append(slots[i])
	return out

# ── 查询助手：所有 allcountries[N] 字段一律先判国家存在 ──

func _c(w: WorldState, idx: int) -> CountryData:
	return w.get_country_by_legacy_index(idx)


func _has(w: WorldState, idx: int, tag: String) -> bool:
	var c := _c(w, idx)
	return c != null and c.has_tag(tag)


func _sub(w: WorldState, idx: int) -> int:
	var c := _c(w, idx)
	if c == null:
		return -99
	return c.sub_government


func _gov(w: WorldState, idx: int) -> int:
	var c := _c(w, idx)
	if c == null:
		return -99
	return c.government


func _pup(w: WorldState, idx: int) -> int:
	var c := _c(w, idx)
	if c == null:
		return -99
	return c.puppet_of


func _part(w: WorldState, idx: int, i: int) -> bool:
	var c := _c(w, idx)
	return c != null and c.parts.size() > i and c.parts[i]


func _d(w: WorldState, idx: int) -> int:
	if idx >= 0 and idx < w.数值表.size():
		return w.数值表[idx]
	return 0


func _decision_done(w: WorldState, idx: int) -> bool:
	return w.decisions != null and idx >= 0 and idx < w.decisions.completed.size() and w.decisions.completed[idx]


func _dlc3(w: WorldState) -> bool:
	return w.dlc.size() > 3 and w.dlc[3]


func _soc(w: WorldState, idx: int, strict: bool) -> bool:
	return w.is_socialism(_c(w, idx), strict)


func _auth(w: WorldState, idx: int) -> bool:
	return w.is_authoritarian(_c(w, idx))

# ── revint 列表级守卫 ──
# 完整条件（CS L550 等）：
# ev548 && 中国.isRIM && (IsSocialism(true, N) || (sub==10 && is_gkchp))
# && sub∉{16,18} && !SEV && !OVD

func _revint_core_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	if not w.event_done_num(548) or not player.has_tag("rim"):
		return false
	if not (w.is_socialism(country, true) or (country.sub_government == 10 and w.get_flag("is_gkchp"))):
		return false
	if country.sub_government == 16 or country.sub_government == 18:
		return false
	if country.has_tag("sev") or country.has_tag("ovd"):
		return false
	return true


func _revint_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("亲中")


func _revint_econ_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("econ")


func _revint_torg_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("对华贸易")


func _revint_okb_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.has_tag("okb")


func _revint_noprosov_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and not country.has_tag("亲苏")


func _revint_puppet_ok(w: WorldState, country: CountryData) -> bool:
	return _revint_core_ok(w, country) and country.puppet_of < 0


# revint 无 IsSocialism/gkchp 变体（CS L1461）：
# ev548 && 中国.isRIM && sub∉{16,18} && !SEV && !OVD && 亲中
func _revint_nosoc_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	if not w.event_done_num(548) or not player.has_tag("rim"):
		return false
	if country.sub_government == 16 or country.sub_government == 18:
		return false
	if country.has_tag("sev") or country.has_tag("ovd"):
		return false
	return country.has_tag("亲中")


# revint sub==17 变体（CS L618/L2150）：ev548 && 中国.isRIM && sub==17 && !SEV && !OVD && 亲中
func _revint_sub17_ok(w: WorldState, country: CountryData) -> bool:
	var player := w.get_player_country()
	if player == null:
		return false
	return w.event_done_num(548) and player.has_tag("rim") \
		and country.sub_government == 17 \
		and not country.has_tag("sev") and not country.has_tag("ovd") and country.has_tag("亲中")


# AU 列表级守卫（CS L2739 等）：IsSocialism(true, N) && ev500 && res500==0
func _soc500_ok(w: WorldState, country: CountryData) -> bool:
	return w.is_socialism(country, true) and w.event_done_num(500) \
		and w.result_of_event_num(500) == 0

# ── 主入口 ──

func build(w: WorldState, country: CountryData) -> Array:
	var slots := _slots()
	_main_chain(w, country, slots)
	_tail_blocks(w, country, slots)
	# 块J (CS L3934)：中国未入革命国际 且 目标已入 → 全部隐藏并 return
	var player := w.get_player_country()
	if (player == null or not player.has_tag("rim")) and country.has_tag("rim"):
		return []
	# 块K (CS L3942)：event_done[713] → 仅槽0 发展贸易
	if _block_k_ok(w, country):
		return [_btn(9, " 发 展 贸 易")]
	return _finish(slots)


# ── 主链（CS L495-L3929 中文链）──

func _main_chain(w: WorldState, country: CountryData, slots: Array) -> void:
	var n := country.原版序号
	var player := w.get_player_country()
	if n == 7:
		# CS L497-523
		if country.has_tag("nato") or w.war_going(22) \
				or _d(w, 133) == 1 or _d(w, 133) == 3 \
				or w.modifier_active(49) or w.get_flag("is_gkchp") or w.ind_opp:
			return
		if not w.get_flag("relres"):  # 散落 bool relres 用 global_flags 建模
			_show(slots, 0, 4, "恢 复 关 系")
		else:
			_show(slots, 0, 81, "科 技 交 易")
		if (country.has_tag("对华贸易") or (player != null and player.has_tag("sev"))) and country.has_tag("sev"):
			_show(slots, 1, 5, "经 互 会")
		elif country.has_tag("sev"):
			_show(slots, 1, 74, "申 请 列 席")
		if country.has_tag("ovd"):
			_show(slots, 2, 6, "华 沙 条 约")
		_show(slots, 3, 7, "两 国 修 好")
	elif n == 2 or n == 4 or n == 98:
		# CS L524-556
		if country.puppet_of < 0:
			var c4 := _c(w, 4)
			var sov := _c(w, 7)
			if (sov != null and sov.has_tag("nato") and country.has_tag("ovd") and not w.war_going(17)) \
					or (n != 4 and c4 != null and c4.sub_government == 19):
				_show(slots, 0, 103, " 影 响 力")
				_show(slots, 1, 104, " 一 体 化")
				_show(slots, 2, 105, " 建 立 军 事 基 地")
				_show(slots, 3, 106, " 军 事 联 盟")
			elif sov != null and not sov.has_tag("nato") and not w.war_going(17) \
					and player != null and not player.has_tag("sev") and country.has_tag("sev"):
				if player == null or not player.has_tag("asean"):
					_show(slots, 0, 1, "扶 持 极 左 派")
				else:
					_show(slots, 2, 123, " 自 由 派")
				_show(slots, 1, 24, "发 展 贸 易")
			else:
				_show(slots, 0, 24, "发 展 贸 易")
				if _revint_ok(w, country):
					_show(slots, 1, 5000, "革 命 国 际")
	elif n == 5:
		# CS L557-588
		if not country.has_tag("fxseu") and not country.has_tag("nazimao") and country.puppet_of < 0:
			var sov := _c(w, 7)
			if sov != null and sov.has_tag("nato") and country.has_tag("ovd") and not w.war_going(17):
				_show(slots, 0, 103, " 影 响 力")
				_show(slots, 1, 104, " 一 体 化")
				_show(slots, 2, 105, " 建 立 军 事 基 地")
				_show(slots, 3, 106, " 军 事 联 盟")
			elif sov != null and not sov.has_tag("nato") and not w.war_going(17) \
					and player != null and not player.has_tag("sev") and country.has_tag("sev"):
				if player == null or not player.has_tag("asean"):
					_show(slots, 0, 1, "扶 持 极 左 派")
				else:
					_show(slots, 0, 123, " 自 由 派")
				_show(slots, 1, 24, "发 展 贸 易")
			else:
				_show(slots, 0, 24, "发 展 贸 易")
				if _revint_ok(w, country):
					_show(slots, 1, 5000, "革 命 国 际")
	elif n == 6:
		# CS L590-623
		var c4 := _c(w, 4)
		var sov := _c(w, 7)
		if (sov != null and sov.has_tag("nato") and country.has_tag("ovd") and not w.war_going(17)) \
				or (c4 != null and c4.sub_government == 19):
			_show(slots, 0, 103, " 影 响 力")
			_show(slots, 1, 104, " 一 体 化")
			_show(slots, 2, 105, " 建 立 军 事 基 地")
			_show(slots, 3, 106, " 军 事 联 盟")
		elif sov != null and not sov.has_tag("nato") and not w.war_going(17) \
				and player != null and not player.has_tag("sev") and country.has_tag("sev"):
			if player == null or not player.has_tag("asean"):
				_show(slots, 0, 1, "扶 持 极 左 派")
			else:
				_show(slots, 2, 123, " 自 由 派")
			_show(slots, 1, 24, "发 展 贸 易")
		else:
			_show(slots, 0, 24, "发 展 贸 易")
			if country.sub_government == 17:
				_show(slots, 2, 10, "经 济 合 作")
				_show(slots, 3, 19, "军 事 同 盟")
				if _revint_sub17_ok(w, country):
					_show(slots, 1, 5000, "革 命 国 际")
	elif n == 1:
		# CS L625-644
		if _dlc3(w):
			_show(slots, 2, 114, " 联 系 总 参 谋 部")
			_show(slots, 3, 115, " 联 系 总 情 报 局")
		if player != null and (player.has_tag("sev") or player.has_tag("asean")):
			_show(slots, 0, 124, " 退 出 联 盟")
		if w.event_done_num(464) and w.result_of_event_num(464) == 2:
			_show(slots, 1, 1008, " 东 方 申 根 协 定")
		if w.event_done_num(464) and w.result_of_event_num(464) != 2:
			var france := _c(w, 21)
			var gdr := _c(w, 16)
			var frg := _c(w, 17)
			if france != null and france.has_tag("okb") \
					and ((gdr != null and gdr.has_tag("okb")) or (frg != null and frg.has_tag("okb"))):
				_show(slots, 1, 1063, " 合 作")
	elif n == 3:
		# CS L645-670
		var sov := _c(w, 7)
		if _dlc3(w) and sov != null and not sov.has_tag("nato"):
			_show(slots, 0, 100, " 组 织 反 对 派")
		if player == null or not player.has_tag("asean"):
			_show(slots, 1, 1, "扶 持 极 左 派")
		else:
			_show(slots, 1, 123, " 自 由 派")
		_show(slots, 2, 24, "发 展 贸 易")
		if _revint_ok(w, country):
			_show(slots, 3, 5000, "革 命 国 际")
		var c4 := _c(w, 4)
		if c4 != null and c4.sub_government == 19:
			_show(slots, 0, 103, " 影 响 力")
			_show(slots, 1, 104, " 一 体 化")
			_show(slots, 2, 105, " 建 立 军 事 基 地")
			_show(slots, 3, 106, " 军 事 联 盟")
	elif n == 8:
		# CS L672-704
		if not country.has_tag("fxseu") and not country.has_tag("nazimao"):
			if country.prc_power != 1000:
				if not w.event_done_num(58):
					_show(slots, 0, 8, "支 持 友 方 派 系")
				_show(slots, 1, 9, "发 展 贸 易")
			elif country.has_tag("econ"):
				_show(slots, 1, 9, "发 展 贸 易")
				_show(slots, 2, 10, "经 济 合 作")
				_show(slots, 3, 19, "军 事 同 盟")
				if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
					_show(slots, 3, 5000, "革 命 国 际")
			else:
				_show(slots, 1, 9, "发 展 贸 易")
				_show(slots, 2, 10, "经 济 合 作")
				_show(slots, 3, 19, "军 事 同 盟")
				if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
					_show(slots, 3, 5000, "革 命 国 际")
	elif n == 9:
		# CS L706-721
		var sov := _c(w, 7)
		if not w.war_going(22) and _d(w, 133) != 1 and _d(w, 133) != 3 \
				and sov != null and not sov.has_tag("nato") and not country.has_tag("ovd") \
				and w.result_of_event_num(62) != 2:
			_show(slots, 0, 11, "联 络 反 对 派")
			_show(slots, 1, 9, "发 展 贸 易")
			_show(slots, 2, 10, "经 济 合 作")
			if _revint_ok(w, country):
				_show(slots, 3, 5000, "革 命 国 际")
		elif sov != null and sov.has_tag("nato") and _has(w, 2, "okb") \
				and _has(w, 4, "okb") and _has(w, 5, "okb") and _has(w, 98, "okb") \
				and country.has_tag("eu"):
			_show(slots, 0, 1052, "特 别 军 事 行 动")
	elif n == 10:
		# CS L723-764
		if w.result_of_event_num(495) != 1:
			if not country.has_tag("econ") and not country.has_tag("sev"):
				_show(slots, 0, 13, "经 济 合 作")
			else:
				_show(slots, 0, 19, "军 事 同 盟")
			if _d(w, 158) <= 0 and not _part(w, 10, 0) and country.puppet_of < 0:
				_show(slots, 1, 14, "实 施 制 裁")
			if (country.has_tag("seato") or country.has_tag("ovd") or country.has_tag("okb")) \
					and not _part(w, 10, 0) and not _part(w, 46, 0):
				_show(slots, 0, 15, "挑 起 战 争")
				if not w.get_flag("guns"):  # 散落 bool guns 用 global_flags 建模
					_show(slots, 1, 16, "提 供 军 援")
				elif _d(w, 158) <= 0 and not _part(w, 10, 0) and country.puppet_of < 0:
					_show(slots, 1, 14, "实 施 制 裁")
				if _revint_core_ok(w, country) and not country.has_tag("亲苏") and country.puppet_of < 0:
					_show(slots, 3, 5000, "革 命 国 际")
			elif not _part(w, 10, 0) and not _part(w, 46, 0):
				_show(slots, 2, 15, "挑 起 战 争")
				_show(slots, 3, 16, "提 供 军 援")
		else:
			_show(slots, 0, 10, "经 济 合 作")
	elif n == 11:
		# CS L766-803
		if not w.event_done_num(454):
			if country.has_tag("亲苏") and country.has_tag("sev") and (player == null or not player.has_tag("ovd")):
				_show(slots, 0, 17, "发 展 贸 易")
				_show(slots, 1, 18, "经 济 合 作")
			elif not w.event_done_num(535) or w.result_of_event_num(535) == 0:
				if country.has_tag("econ") and country.puppet_of < 0:
					_show(slots, 0, 1000, "组 织 政 变")
					_show(slots, 1, 18, "经 济 合 作")
					_show(slots, 2, 19, "军 事 同 盟")
				elif w.war_state <= 0:  # 原版 war 状态由 Godot war_state 字段建模
					_show(slots, 0, 17, "发 展 贸 易")
					if w.event_done_num(43):
						_show(slots, 1, 18, "经 济 合 作")
						_show(slots, 2, 19, "军 事 同 盟")
			elif w.event_done_num(535) and w.result_of_event_num(535) == 1:
				_show(slots, 0, 80, "整 饬 内 政")
				_show(slots, 1, 18, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
	elif n == 12:
		# CS L805-813
		_show(slots, 0, 9, "发 展 贸 易")
		_show(slots, 1, 68, "经 济 合 作")
		_show(slots, 2, 19, "军 事 同 盟")
		if _revint_ok(w, country):
			_show(slots, 3, 5000, "革 命 国 际")
	elif n == 13:
		# CS L815-839
		if w.is_socialism(country, true):
			_show(slots, 0, 9, "发 展 贸 易")
			_show(slots, 1, 10, "经 济 合 作")
			_show(slots, 2, 19, "军 事 同 盟")
			if _revint_core_ok(w, country) and country.has_tag("okb") and country.has_tag("亲中"):
				_show(slots, 2, 5000, "革 命 国 际")
			if w.oar:
				_show(slots, 3, 67, "阿 拉 伯 联 合")
		elif country.government != 3 and country.sub_government != 7:
			_show(slots, 0, 22, "支 持 卡 扎 菲")
			_show(slots, 1, 23, "联 络 反 对 派")
			if w.oar:
				_show(slots, 2, 67, "阿 拉 伯 联 合")
	elif n == 14:
		# CS L841-892
		var c36 := _c(w, 36)
		if _dlc3(w) and c36 != null and c36.内战中 and country.puppet_of < 0:
			_show(slots, 0, 133, " 海 湾 入 侵")
		if not w.event_done_num(36):
			_show(slots, 0, 1078, "影 响")
		if w.event_done_num(36) and w.result_of_event_num(36) == 2 and not w.event_done_num(566) \
				and country.puppet_of < 0 and country.sub_government == 10:
			_show(slots, 0, 56, "支 持 革 命 者")
		if w.event_done_num(36) and w.result_of_event_num(36) == 3 and not w.event_done_num(708) \
				and country.puppet_of < 0 and country.sub_government == 10:
			_show(slots, 0, 56, "达 瓦 党")
		elif w.oar:
			_show(slots, 0, 25, "阿 拉 伯 联 合")
		elif (player != null and player.sub_government == 19) and country.sub_government == 10:
			_show(slots, 0, 70, "巴 比 伦 之 狮")
		if country.puppet_of < 0 and country.sub_government == 20:
			_show(slots, 1, 24, "发 展 贸 易")
		if country.has_tag("亲中"):
			_show(slots, 1, 24, "发 展 贸 易")
			_show(slots, 2, 53, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
			if _revint_core_ok(w, country) and country.has_tag("okb") and country.puppet_of < 0:
				_show(slots, 3, 5000, "革 命 国 际")
		elif c36 != null and c36.puppet_of < 0 and w.result_of_event_num(36) != 2 \
				and w.result_of_event_num(36) != 3:
			_show(slots, 1, 24, "发 展 贸 易")
			_show(slots, 2, 53, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
		if (country.has_tag("亲中") or country.has_tag("亲美")) and player != null and player.has_tag("asean"):
			_show(slots, 1, 24, "发 展 贸 易")
			_show(slots, 2, 119, " 经 济 合 作")
			_show(slots, 3, 120, " 军 事 联 盟")
	elif n == 15:
		# CS L894-924
		_show(slots, 0, 26, "签 署 友 好 协 定")
		var spain := _c(w, 85)
		if spain == null or not spain.has_tag("soc_eu"):
			_show(slots, 1, 27, "支 持 共 产 主 义")
		else:
			_show(slots, 1, 27, "促 进 欧 洲 团 结")
		var sov := _c(w, 7)
		if sov != null and not sov.has_tag("nato") and not _has(w, 2, "okb") \
				and not _has(w, 4, "okb") and not _has(w, 5, "okb") and not _has(w, 98, "okb"):
			if not country.内战中:
				_show(slots, 2, 72, "不 结 盟 运 动")
			else:
				_show(slots, 2, 73, "退 出")
		else:
			_show(slots, 2, 10, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
			if _revint_noprosov_ok(w, country):
				_show(slots, 1, 5000, "革 命 国 际")
	elif n == 16:
		# CS L926-948
		var sov := _c(w, 7)
		if _dlc3(w) and not country.has_tag("nato"):
			_show(slots, 0, 135, " 史 塔 西")
		elif not _dlc3(w):
			_show(slots, 0, 24, "发 展 贸 易")
		if _dlc3(w) and sov != null and not sov.has_tag("nato"):
			_show(slots, 1, 116, " 统 一")
		if country.has_tag("亲中") and _part(w, 16, 0):
			_show(slots, 2, 10, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
			if w.event_done_num(548) and (player != null and player.has_tag("rim")) \
					and country.sub_government == 2 and not country.has_tag("sev") \
					and not country.has_tag("ovd") and country.has_tag("亲中"):
				_show(slots, 1, 5000, "革 命 国 际")
	elif n == 17:
		# CS L950-984
		if not _part(w, 17, 0):
			if player == null or not player.has_tag("asean"):
				_show(slots, 0, 1, "扶 持 极 左 派")
			var sov := _c(w, 7)
			if _dlc3(w) and sov != null and not sov.has_tag("nato"):
				_show(slots, 1, 116, " 统 一")
				if country.government != 1 and country.government != 2:
					_show(slots, 2, 137, " 禁 运")
					_show(slots, 3, 138, " 煽 动")
		elif w.is_socialism(country, true):
			_show(slots, 0, 135, " 安 全 局")
			_show(slots, 1, 24, "发 展 贸 易")
			_show(slots, 2, 10, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
			if _revint_core_ok(w, country) and country.has_tag("okb") and country.has_tag("亲中"):
				_show(slots, 3, 5000, "革 命 国 际")
		elif (country.sub_government == 9 or country.sub_government == 22) \
				and (player != null and (player.sub_government == 7 or player.sub_government == 9)):
			_show(slots, 1, 24, "发 展 贸 易")
			_show(slots, 2, 10, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
	elif n == 18:
		# CS L986-1000
		if _dlc3(w):
			_show(slots, 0, 10, "经 济 合 作")
			_show(slots, 1, 19, "军 事 同 盟")
			if w.oar:
				_show(slots, 2, 67, "阿 拉 伯 联 合")
			if _revint_ok(w, country):
				_show(slots, 3, 5000, "革 命 国 际")
	elif n == 19:
		# CS L1002-1035
		if (not w.event_done_num(72) or w.result_of_event_num(72) == 0) \
				and not _decision_done(w, 14):  # CountryScript completedDecisions[14]
			_show(slots, 0, 28, "扶 持 纳 萨 尔 派")
			_show(slots, 1, 29, "重 建 外 交 关 系")
			if w.war_state != 2 and not country.has_tag("亲中"):  # 原版 war 状态由 Godot war_state 字段建模
				_show(slots, 2, 30, "策 动 边 界 战 争")
			else:
				_show(slots, 2, 71, "增 兵 助 战")
		elif (country.has_tag("亲中") and (country.has_tag("okb") or country.has_tag("ovd"))) \
				or (w.result_of_event_num(72) == 1 and country.has_tag("econ")):
			_show(slots, 2, 89, "投 资 换 领 土")
		if country.has_tag("亲中") or w.result_of_event_num(72) == 1:
			if not country.has_tag("sev") and not country.has_tag("econ"):
				_show(slots, 3, 10, "经 济 合 作")
			elif w.result_of_event_num(72) != 1:
				_show(slots, 3, 19, "军 事 同 盟")
			if w.event_done_num(548) and (player != null and player.has_tag("rim")) \
					and country.sub_government == 17 and not country.has_tag("sev") \
					and not country.has_tag("ovd") and country.has_tag("econ") \
					and country.has_tag("okb") and country.has_tag("亲中"):
				_show(slots, 3, 5000, "革 命 国 际")
	elif n == 20:
		# CS L1037-1048
		if not _part(w, 20, 1):
			_show(slots, 0, 31, "经 济 合 作")
			_show(slots, 1, 19, "军 事 同 盟")
			_show(slots, 2, 32, "复 交 苏 联")
			if _revint_ok(w, country):
				_show(slots, 3, 5000, "革 命 国 际")
	elif n == 21:
		# CS L1050-1106
		if not w.event_done_num(483):
			if not _dlc3(w):
				_show(slots, 0, 33, "签 署 友 好 协 定")
			elif not country.has_tag("对华贸易"):
				_show(slots, 0, 33, "签 署 友 好 协 定")
			elif _d(w, 131) == 3:
				_show(slots, 0, 127, " 戴 高 乐 派")
			else:
				_show(slots, 0, 33, "签 署 友 好 协 定")
			_show(slots, 1, 34, "吸 引 该 国 投 资")
			if player == null or not player.has_tag("asean"):
				if country.social_stability < 40:
					_show(slots, 2, 1009, "法 共 正 统 派")
				else:
					_show(slots, 2, 1010, "党 内 政 变")
			if _dlc3(w):
				if country.government != 1:
					_show(slots, 3, 107, " 狩 猎 俱 乐 部")
				if country.government == 1:
					_show(slots, 2, 10, "经 济 合 作")
		else:
			_show(slots, 0, 24, "发 展 贸 易")
			if country.sub_government == 17 or country.sub_government == 22 or country.sub_government == 19 \
					or (player != null and (player.sub_government == 9 or player.sub_government == 7) \
					and country.sub_government == 9):
				_show(slots, 1, 10, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
			if w.event_done_num(548) and (player != null and player.has_tag("rim")) \
					and w.is_socialism(country, true) and country.sub_government != 1 \
					and country.sub_government != 18 and not country.has_tag("sev") \
					and not country.has_tag("ovd") and country.has_tag("亲中"):
				_show(slots, 3, 5000, "革 命 国 际")
	elif n == 22:
		# CS L1108-1135
		if (player != null and player.has_tag("sev")) and country.puppet_of == 11:
			_show(slots, 0, 24, "发 展 贸 易")
			_show(slots, 1, 10, "经 济 合 作")
			_show(slots, 2, 19, "军 事 同 盟")
		elif not w.event_done_num(454):
			if player == null or not player.has_tag("seato"):
				_show(slots, 0, 35, "关 系")
			else:
				_show(slots, 0, 126, " 反 对 派")
			if country.puppet_of < 0:
				_show(slots, 1, 36, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
	elif n == 23 and not country.has_tag("亲苏"):
		# CS L1137-1145
		_show(slots, 0, 24, "发 展 贸 易")
		_show(slots, 1, 10, "经 济 合 作")
		_show(slots, 2, 19, "军 事 同 盟")
		if _revint_ok(w, country):
			_show(slots, 3, 5000, "革 命 国 际")
	elif n == 24 or n == 25:
		# CS L1147-1173
		_show(slots, 0, 102, "发 展 贸 易")
		_show(slots, 1, 121, "经 济 合 作")
		if country.has_tag("亲中"):
			_show(slots, 2, 19, "军 事 同 盟")
			if _revint_core_ok(w, country) and country.has_tag("okb") \
					and w.result_of_event_num(437) == 0:
				_show(slots, 2, 5000, "革 命 国 际")
		if _part(w, n, 0) and w.oar:
			if not country.has_tag("oar"):
				_show(slots, 3, 67, "阿 拉 伯 联 合")
			else:
				_show(slots, 3, 1021, "重 建 阿 湾 人 阵")
		if w.is_authoritarian(country) and w.event_done_num(709) and _sub(w, 14) == 19:
			_show(slots, 3, 1079, "新 秩 序")
	elif n == 26:
		# CS L1175-1213
		_show(slots, 0, 50, "发 展 贸 易")
		var spain := _c(w, 85)
		var france := _c(w, 21)
		if (spain == null or not spain.has_tag("soc_eu")) and (france == null or not france.has_tag("fxseu")) \
				and (france == null or not france.has_tag("nazimao")):
			if country.有驻军基地 and ((player != null and player.has_tag("sev")) or w.get_flag("is_gkchp")):
				if player == null or not player.has_tag("asean"):
					_show(slots, 1, 1, "扶 持 极 左 派")
				else:
					_show(slots, 1, 123, " 自 由 派")
			if country.有驻军基地 and (player == null or not player.has_tag("sev")) \
					and not w.get_flag("is_gkchp") and _sub(w, 4) != 19:
				_show(slots, 2, 148, " 欧 洲 左 派")
				_show(slots, 3, 149, " 欧 洲 右 派")
				_show(slots, 1, 53, " 经 济 合 作")
			if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
				_show(slots, 3, 5000, "革 命 国 际")
		elif france != null and france.has_tag("fxseu"):
			_show(slots, 1, 148, " 支 持 主 权 欧 洲")
		elif france != null and france.has_tag("nazimao"):
			_show(slots, 1, 148, " 支 持 民 族 欧 洲")
		elif spain != null and spain.has_tag("soc_eu"):
			_show(slots, 1, 148, " 促 进 欧 洲 团 结")
	elif n != 29:
		# CS L1215-3708 嵌套链
		if n == 30:
			# CS L1217-1232
			if not w.oar:
				_show(slots, 0, 38, "支 持 纳 赛 尔 派")
			_show(slots, 1, 24, "发 展 贸 易")
			_show(slots, 2, 39, "经 济 合 作")
			if w.is_socialism(country, true):
				_show(slots, 3, 19, "军 事 同 盟")
				if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 31:
			# CS L1234-1241
			_show(slots, 0, 40, "经 济 合 作")
			_show(slots, 1, 41, "军 事 同 盟")
			if _revint_ok(w, country):
				_show(slots, 3, 5000, "革 命 国 际")
		elif n == 32 or n == 42:
			# CS L1243-1256
			if country.puppet_of < 0:
				_show(slots, 0, 10, "经 济 合 作")
				if n == 32:
					_show(slots, 1, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 32:
			# CS L1258-1265（原版死分支：前面 32||42 已捕获 32，仅 42 会走到这里？否，此分支永远不可达）
			# 忠实保留结构但不产生输出；原版条件恒 false（32 已被前一分支处理）。
			_show(slots, 0, 10, "经 济 合 作")
			_show(slots, 1, 19, "军 事 同 盟")
			if _revint_ok(w, country):
				_show(slots, 3, 5000, "革 命 国 际")
		elif n == 33:
			# CS L1267-1289
			if w.result_of_event_num(55) != 2 and not country.has_tag("亲中"):
				_show(slots, 0, 42, "支 持 反 对 派")
				if w.result_of_event_num(662) != 1 and country.influence_china > 0 \
						and country.sub_government != 11 and not w.event_done_num(663):
					_show(slots, 1, 1061, "缅 甸 共 产 党")
					if w.result_of_event_num(662) == 2:
						_show(slots, 1, 1061, "民 族 团 结 联 盟")
			if country.has_tag("亲中") and (player == null or not player.has_tag("asean")):
				if _revint_sub17_ok(w, country):
					_show(slots, 1, 5000, "革 命 国 际")
				_show(slots, 2, 10, "经 济 合 作")
				_show(slots, 3, 19, "军 事 同 盟")
		elif n == 34:
			# CS L1291-1300
			_show(slots, 0, 43, "泰 国 共 产 党")
			_show(slots, 1, 9, "发 展 贸 易")
			_show(slots, 2, 44, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
			if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
				_show(slots, 3, 5000, "革 命 国 际")
		elif n == 35:
			# CS L1302-1325
			if not w.event_done_num(564):
				_show(slots, 0, 1016, "联 络 反 对 派")
			else:
				if w.oar:
					_show(slots, 0, 45, "阿 拉 伯 联 合")
				_show(slots, 1, 24, "发 展 贸 易")
				_show(slots, 2, 53, "经 济 合 作")
				_show(slots, 3, 19, "军 事 同 盟")
				var c93 := _c(w, 93)
				if w.get_flag("Israellost") or (c93 != null and c93.puppet_of == 37):  # 散落 bool Israellost 用 global_flags 建模
					_show(slots, 1, 1001, "组 织 谈 判")
				if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 37:
			# CS L1327-1343
			if _d(w, 85) == 3 and w.oar:
				_show(slots, 0, 45, "阿 拉 伯 联 合")
			else:
				_show(slots, 0, 46, "协 商 巴 以 问 题")
			_show(slots, 1, 24, "发 展 贸 易")
			_show(slots, 2, 10, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
			if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
				_show(slots, 3, 5000, "革 命 国 际")
		elif n == 38:
			# CS L1345-1364
			if (player == null or not player.has_tag("asean")) and not w.event_done_num(461):
				_show(slots, 0, 48, "解 放 金 马 澎")
				if w.event_done_num(460) and w.result_of_event_num(460) != 2 \
						and not _decision_done(w, 6) \
						and (w.result_of_event_num(116) == 0 or not w.event_done_num(116)) \
						and (player != null and player.sub_government != 9 and player.sub_government != 7 \
						and player.sub_government != 10 and player.sub_government != 12 \
						and player.sub_government != 13):
					_show(slots, 1, 1005, "施 压")
			elif w.event_done_num(461) and country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				_show(slots, 1, 19, "军 事 同 盟")
			else:
				_show(slots, 0, 119, " 经 济 合 作")
				_show(slots, 1, 120, " 军 事 联 盟")
		elif n == 39:
			# CS L1366-1393
			if w.is_socialism(country, false):
				_show(slots, 0, 49, "拨 款 海 外 账 户")
			else:
				_show(slots, 0, 49, "信 用 合 作 社")
			var spain := _c(w, 85)
			var france := _c(w, 21)
			var c17 := _c(w, 17)
			var c16 := _c(w, 16)
			var c27 := _c(w, 27)
			if (spain == null or not spain.has_tag("soc_eu")) and (france == null or not france.has_tag("fxseu")) \
					and (france == null or not france.has_tag("nazimao")) \
					and (france == null or not france.has_tag("亲苏")) \
					and not (c17 != null and c17.development == 3 and c16 != null and c16.has_tag("亲苏")) \
					and (spain == null or not spain.has_tag("亲苏")) \
					and (c27 == null or not c27.has_tag("亲苏")):
				_show(slots, 2, 148, " 欧 洲 左 派")
				_show(slots, 3, 149, " 欧 洲 右 派")
				_show(slots, 1, 53, " 经 济 合 作")
			elif france != null and france.has_tag("fxseu"):
				_show(slots, 1, 148, " 支 持 主 权 欧 洲")
			elif france != null and france.has_tag("nazimao"):
				_show(slots, 1, 148, " 支 持 民 族 欧 洲")
			elif spain != null and spain.has_tag("soc_eu"):
				_show(slots, 1, 148, " 促 进 欧 洲 团 结")
		elif n == 40:
			# CS L1395-1433
			if country.sub_government == 20:
				_show(slots, 0, 1019, "联 络 反 对 派")
				if country.内战中:
					_show(slots, 0, 1020, "煽 动 反 对 派")
			if country.sub_government == 10:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if w.oar:
					_show(slots, 2, 45, "阿 拉 伯 联 合")
			if country.sub_government != 7 and w.event_done_num(563):
				if country.sub_government != 1:
					_show(slots, 1, 10, "经 济 合 作")
				else:
					_show(slots, 1, 10, "经 济 合 作")
					_show(slots, 2, 19, "军 事 同 盟")
					if w.oar:
						_show(slots, 3, 45, "阿 拉 伯 联 合")
					if _revint_ok(w, country):
						_show(slots, 0, 5000, "革 命 国 际")
		elif n == 41:
			# CS L1435-1474
			_show(slots, 0, 9, "发 展 贸 易")
			if w.result_of_event_num(403) == 0 and w.event_done_num(403) and not w.war_going(24):
				_show(slots, 2, 101, " 经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 3, 5001, " 非 洲 联 盟")
				_show(slots, 0, 110, " 埃 人 阵")
				_show(slots, 1, 111, " 民 主 联 盟")
				if _revint_ok(w, country):
					_show(slots, 1, 5000, "革 命 国 际")
			elif country.has_tag("亲中"):
				if country.government == 1 or country.sub_government == 0:
					_show(slots, 1, 10, "经 济 合 作")
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 2, 5001, " 非 洲 联 盟")
					if _revint_nosoc_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
				else:
					_show(slots, 1, 10, "经 济 合 作")
					if country.sub_government == 10 and (player != null and player.sub_government == 19) \
							and not _part(w, 42, 0) and w.event_done_num(376):
						_show(slots, 3, 70, " 马 里 亚 姆 王 朝")
		elif n == 43 or n == 96 or n == 97:
			# CS L1476-1487
			if country.puppet_of != 1:
				_show(slots, 0, 97, " 外 交 施 压")
				_show(slots, 1, 98, " 经 济 合 作")
				_show(slots, 2, 99, " 军 事 联 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 44:
			# CS L1489-1529
			if w.event_done_num(522) and w.result_of_event_num(522) == 2:
				_show(slots, 0, 1014, "支 持 亲 华 派")
			if w.event_done_num(523) and w.result_of_event_num(523) == 0 and not w.event_done_num(538):
				if w.event_done_num(532) and w.result_of_event_num(532) == 0:
					_show(slots, 0, 51, "支 援 革 命")
				else:
					_show(slots, 0, 51, "支 持 赤 军")
			_show(slots, 1, 52, "发 展 贸 易")
			if w.event_done_num(532) and w.result_of_event_num(532) == 0 and country.sub_government == 6:
				_show(slots, 1, 1015, "发 动 革 命")
			if country.has_tag("亲中") and not country.has_tag("soc_eu"):
				if player != null and player.has_tag("asean"):
					_show(slots, 2, 119, " 经 济 合 作")
				else:
					_show(slots, 2, 53, "经 济 合 作")
				if w.is_socialism(country, true):
					_show(slots, 3, 19, "军 事 同 盟")
					if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
						_show(slots, 3, 5000, "革 命 国 际")
		elif n == 45:
			# CS L1531-1552
			var c94 := _c(w, 94)
			if (not w.war_going(19) or not w.is_authoritarian(country)) \
					and (c94 == null or not c94.内战中):
				_show(slots, 0, 9, "发 展 贸 易")
				if not country.has_tag("soc_eu") and country.government != 1 \
						and not country.has_tag("eu") and not country.内战中:
					_show(slots, 1, 54, "经 济 合 作")
				elif w.is_socialism(country, true):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						_show(slots, 2, 19, "军 事 同 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 46:
			# CS L1554-1581
			if not _part(w, 46, 0):
				if not w.event_done_num(31):
					_show(slots, 0, 55, "外 交 施 压")
				else:
					_show(slots, 0, 1013, "和 平 统 一")
			if not country.has_tag("seato"):
				if not w.event_done_num(31):
					_show(slots, 0, 55, "外 交 施 压")
				else:
					_show(slots, 0, 1013, "和 平 统 一")
			elif not _has(w, 10, "asean") and country.has_tag("asean"):
				_show(slots, 1, 122, " 战 争")
		elif n == 47:
			# CS L1583-1595
			if player == null or not player.has_tag("asean"):
				_show(slots, 0, 56, "扶 持 毛 派")
				if _revint_ok(w, country):
					_show(slots, 0, 5000, "革 命 国 际")
			_show(slots, 1, 9, "发 展 贸 易")
			_show(slots, 2, 44, "经 济 合 作")
			_show(slots, 3, 19, "军 事 同 盟")
		elif n == 48:
			# CS L1597-1607
			_show(slots, 0, 9, "发 展 贸 易")
			if country.government != 3:
				_show(slots, 1, 10, "经 济 合 作")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 52:
			# CS L1609-1629
			if w.event_done_num(497) or country.sub_government == 0:
				_show(slots, 0, 24, "发 展 贸 易")
				if w.result_of_event_num(497) != 2:
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, "非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 49:
			# CS L1631-1645
			_show(slots, 0, 24, "发 展 贸 易")
			if w.is_socialism(country, true):
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中"):
					_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 50:
			# CS L1647-1665
			if country.sub_government != 9:
				_show(slots, 0, 58, "实 施 制 裁")
				if country.has_tag("亲中"):
					_show(slots, 2, 10, "经 济 合 作")
					if w.is_socialism(country, true):
						_show(slots, 3, 19, "军 事 同 盟")
						if _revint_core_ok(w, country) and country.has_tag("okb"):
							_show(slots, 3, 5000, "革 命 国 际")
				_show(slots, 1, 24, "发 展 贸 易")
		elif n == 128:
			# CS L1667-1678
			if w.is_socialism(country, true):
				_show(slots, 1, 10, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			_show(slots, 0, 24, "发 展 贸 易")
		elif n >= 2 and n <= 6 and n != 3 and (player == null or not player.has_tag("sev")) \
				and country.has_tag("sev"):
			# CS L1680-1693
			var sov := _c(w, 7)
			if sov != null and not sov.has_tag("nato") and not w.war_going(17):
				_show(slots, 0, 24, "发 展 贸 易")
				if player == null or not player.has_tag("asean"):
					_show(slots, 1, 1, "扶 持 极 左 派")
				else:
					_show(slots, 2, 123, " 自 由 派")
		elif n == 51:
			# CS L1695-1717
			var sov := _c(w, 7)
			if sov != null and not sov.has_tag("nato") and not w.modifier_active(49):
				if not country.has_tag("对华贸易"):
					_show(slots, 0, 60, "签 署 友 好 协 定")
				elif _dlc3(w):
					_show(slots, 0, 117, " 东 盟")
				_show(slots, 1, 34, "吸 引 该 国 投 资")
				if country.development <= 0:
					_show(slots, 2, 61, "中 央 情 报 局")
				elif _dlc3(w):
					_show(slots, 2, 118, " 东 约 组 织")
				_show(slots, 3, 75, "科 技 交 易")
		elif n == 53:
			# CS L1719-1746
			if not w.event_done_num(499):
				_show(slots, 0, 1058, "反 抗")
				_show(slots, 1, 1059, "复 兴 主 义")
				_show(slots, 2, 1060, "世 界 第 三 理 论")
			if w.event_done_num(499) and country.has_tag("亲中") and not w.is_authoritarian(country):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true):
					_show(slots, 1, 19, "军 事 同 盟")
				if w.oar:
					_show(slots, 2, 67, "阿 拉 伯 联 合")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			if w.event_done_num(499) and w.oar \
					and (not w.is_authoritarian(country) or country.puppet_of == 13):
				_show(slots, 2, 67, "阿 拉 伯 联 合")
		elif n == 150:
			# CS L1748-1761
			if w.event_done_num(499) and country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 151:
			# CS L1763-1776
			if w.event_done_num(499) and country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 54:
			# CS L1778-1801
			_show(slots, 0, 9, "发 展 贸 易")
			if w.is_authoritarian(country) and not w.event_done_num(560):
				_show(slots, 2, 1006, "摩 人 盟")
				_show(slots, 3, 1007, "西 撒 人 阵")
			else:
				_show(slots, 1, 10, "经 济 合 作")
				if country.sub_government != 11 and country.government != 3:
					_show(slots, 2, 19, "军 事 同 盟")
					if _revint_core_ok(w, country) and country.has_tag("亲中") and country.has_tag("okb"):
						_show(slots, 2, 5000, "革 命 国 际")
					if w.oar:
						_show(slots, 3, 67, "阿 拉 伯 联 合")
		elif n == 55:
			# CS L1803-1826
			_show(slots, 0, 9, "发 展 贸 易")
			if country.has_tag("亲中"):
				_show(slots, 1, 10, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if w.oar:
					_show(slots, 3, 67, "阿 拉 伯 联 合")
				if _revint_core_ok(w, country) and country.has_tag("okb"):
					_show(slots, 2, 5000, "革 命 国 际")
			elif country.government == 2:
				_show(slots, 0, 10, "经 济 合 作")
				if w.oar:
					_show(slots, 1, 67, "阿 拉 伯 联 合")
		elif n == 56:
			# CS L1828-1850
			_show(slots, 0, 9, "发 展 贸 易")
			if country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
			else:
				_show(slots, 1, 1024, "萨 瓦 巴")
				if country.内战中:
					_show(slots, 1, 1032, "革 命")
		elif n == 57:
			# CS L1852-1869
			if country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_puppet_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
			elif w.war_going(80):
				_show(slots, 0, 1056, "维 和 与 革 命 行 动")
		elif n == 58:
			# CS L1871-1895
			if not w.event_done_num(458):
				if not country.has_tag("亲中"):
					_show(slots, 0, 1003, "三 人 集 团")
			elif country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
			if w.result_of_event_num(458) == 0 and _sub(w, 61) == 7 \
					and (player != null and player.sub_government == 19):
				_show(slots, 3, 1004, "人 民 民 主 化")
		elif n == 59:
			# CS L1897-1937
			if country.sub_government == 15 and not country.内战中:
				_show(slots, 0, 1032, "敦 促 改 革")
			elif w.is_socialism(country, true):
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中") and w.is_socialism(country, true) \
						and w.event_done_num(500) and w.result_of_event_num(500) == 0:
					_show(slots, 2, 5001, " 非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			elif country.sub_government == 7:
				if not country.内战中:
					_show(slots, 0, 1043, "毛 塔 民 主 联 盟")
					_show(slots, 1, 1044, "世 界 第 三 理 论")
					_show(slots, 2, 1045, "复 兴 党")
			elif country.sub_government == 10 or country.government == 2:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if country.内战中 and w.oar:
					_show(slots, 3, 67, "阿 拉 伯 联 合")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 60:
			# CS L1939-1965
			_show(slots, 2, 9, "发 展 贸 易")
			var c164 := _c(w, 164)
			if w.result_of_event_num(653) == 3 and (c164 == null or not _part(w, 164, 0)):
				_show(slots, 0, 1054, "援 助 革 命 派")
				if w.event_done_num(500) and w.result_of_event_num(500) == 0:
					_show(slots, 1, 1045, "志 愿 军")
			if country.内战中:
				_show(slots, 0, 1054, "援 助 扬 塔 特 斯 尼")
			if country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 61:
			# CS L1967-1980
			if country.has_tag("亲中") and country.puppet_of < 0:
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 62:
			# CS L1982-1995
			if country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 63 and country.禁用非洲机制:
			# CS L1997-2010
			if country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 64:
			# CS L2012-2033
			if not country.has_tag("亲中"):
				_show(slots, 0, 1032, "推 翻")
				if _has(w, 21, "对华贸易") and _d(w, 16) > 12:
					_show(slots, 3, 9, "发 展 贸 易")
			else:
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 65:
			# CS L2035-2056
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中"):
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 2, 5001, "非 洲 联 盟")
					if _revint_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
				if country.sub_government == 10 and (player != null and player.sub_government == 19):
					_show(slots, 3, 70, "输 出 革 命 经 验")
		elif n == 66:
			# CS L2058-2087
			if not w.event_done_num(617) or (country.sub_government != 7 and country.sub_government != 8):
				_show(slots, 0, 9, "发 展 贸 易")
				if not w.event_done_num(618) and country.sub_government == 7:
					_show(slots, 1, 1032, "支 持 反 对 派")
				if not w.event_done_num(617) and w.event_done_num(680) \
						and w.result_of_event_num(680) == 0 and w.result_of_event_num(618) != 1 \
						and w.result_of_event_num(618) != 2 and country.sub_government == 7:
					_show(slots, 1, 1024, "支 持 喀 人 盟")
					if w.event_done_num(500) and w.result_of_event_num(500) == 0:
						_show(slots, 3, 1045, "志 愿 军")
				elif country.has_tag("亲中") or w.result_of_event_num(618) == 1:
					_show(slots, 2, 10, "经 济 合 作")
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 3, 5001, "非 洲 联 盟")
					if _revint_ok(w, country):
						_show(slots, 1, 5000, "革 命 国 际")
		elif n == 68:
			# CS L2089-2110
			if not country.has_tag("亲美"):
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中"):
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 2, 5001, "非 洲 联 盟")
					if _revint_core_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 69 or n == 70:
			# CS L2112-2117
			_show(slots, 0, 76, "经 济 帮 扶")
			_show(slots, 1, 77, "组 织 政 变")
			_show(slots, 2, 78, "建 立 军 事 基 地")
			_show(slots, 3, 79, "实 现 再 统 一")
		elif ((n >= 53 and n < 69) or (n > 105 and n < 109) or (n > 111 and n < 134)) \
				and n != 55 and n != 54 and not country.禁用非洲机制 \
				and (_d(w, 103) != 15 or n != 61) \
				and not country.has_tag("fxseu") and not country.has_tag("nazimao"):
			# CS L2119-2134
			_show(slots, 0, 62, "扶 持 亲 中 派")
			if not country.has_tag("亲中"):
				_show(slots, 1, 63, "勾 结 苏 联")
				_show(slots, 2, 64, "勾 结 美 国")
			if country.has_tag("亲中") and not country.has_tag("亲苏") and not country.has_tag("亲美"):
				_show(slots, 3, 66, "资 源 开 发 区")
			else:
				_show(slots, 3, 65, "组 织 政 变")
		elif n >= 71 and n <= 83:
			# CS L2136-2153
			if not country.has_tag("亲中"):
				_show(slots, 0, 82, " 策 动 革 命")
				_show(slots, 1, 85, " 引 发 骚 乱")
				_show(slots, 2, 84, " 挑 起 动 荡")
			else:
				_show(slots, 0, 86, " 帮 助 盟 友")
				_show(slots, 1, 87, " 发 展 贸 易")
				_show(slots, 2, 88, " 经 济 合 作")
			if n == 80 and _revint_sub17_ok(w, country):
				_show(slots, 3, 5000, "革 命 国 际")
		elif ((n > 142 and n < 149) or n == 139) and n != 145 and n != 147:
			# CS L2155-2180
			if not country.has_tag("亲中"):
				_show(slots, 0, 1036, "煽 动")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
			if n == 139 and (player != null and player.sub_government == 19):
				if country.sub_government != 19:
					_show(slots, 3, 70, "施 展 巫 术")
				else:
					_show(slots, 3, 70, "黑 人 民 权 运 动")
		elif n == 84:
			# CS L2182-2211
			if _dlc3(w):
				if _d(w, 21) < 1981 and not w.event_done_num(367):
					_show(slots, 0, 91, " 联 系 极 左 派")
					_show(slots, 1, 92, " 联 系 极 右 派")
				if country.government == 2 \
						or (country.government == 3 and _d(w, 21) > 1983) \
						or w.is_socialism(country, true):
					_show(slots, 0, 9, "发 展 贸 易")
					if not country.has_tag("soc_eu") and w.event_done_num(489):
						_show(slots, 1, 10, "经 济 合 作")
						if country.has_tag("亲中"):
							_show(slots, 2, 19, "军 事 同 盟")
							if _revint_ok(w, country):
								_show(slots, 2, 5000, "革 命 国 际")
				if _d(w, 124) > 0:
					_show(slots, 2, 94, " 谈 判")
		elif n == 85:
			# CS L2213-2260
			if _dlc3(w):
				if country.内战中 and not country.has_tag("亲中"):
					if not w.event_done_num(556):
						_show(slots, 3, 1017, "左 翼 激 进 派")
					if country.has_tag("亲中"):
						_show(slots, 1, 10, "经 济 合 作")
						_show(slots, 2, 19, "军 事 同 盟")
				elif country.政变中 and not country.has_tag("亲中"):
					_show(slots, 3, 108, "恐 怖 组 织")
				elif country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					_show(slots, 2, 19, "军 事 同 盟")
					if _revint_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
				if (country.sub_government == 22 or country.sub_government == 0 \
						or (country.sub_government == 9 and player != null \
						and (player.sub_government == 9 or player.sub_government == 7))) \
						and w.event_done_num(481):
					_show(slots, 2, 53, "经 济 合 作")
					_show(slots, 3, 19, "军 事 同 盟")
				elif (w.event_done_num(398) and w.result_of_event_num(398) < 3) \
						or (w.event_done_num(401) and w.result_of_event_num(401) < 3):
					_show(slots, 1, 10, "经 济 合 作")
					_show(slots, 2, 19, "军 事 同 盟")
				else:
					_show(slots, 0, 9, "发 展 贸 易")
				if (country.内战中 or country.政变中) and not country.has_tag("亲中"):
					_show(slots, 0, 1018, "破 坏 稳 定")
		elif n == 86:
			# CS L2262-2280
			if _dlc3(w):
				_show(slots, 0, 136, "联 系 分 离 分 子")
				_show(slots, 1, 9, "发 展 贸 易")
				if country.government == 1:
					_show(slots, 2, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						_show(slots, 3, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 0, 5000, "革 命 国 际")
		elif n == 87:
			# CS L2282-2323
			if _d(w, 65) == 0:
				_show(slots, 0, 2, "特 别 军 事 行 动")
				if not country.has_tag("亲美") or country.government != 0:
					if _d(w, 65) != 2 and (player == null or not player.has_tag("sev")):
						_show(slots, 1, 3, "组 织 统 一 谈 判")
					if _dlc3(w):
						_show(slots, 2, 128, " 破 坏 政 治 稳 定")
						_show(slots, 3, 9, "发 展 贸 易")
			elif not country.has_tag("亲美") or country.government != 0:
				if not w.event_done_num(420) and not w.event_done_num(419):
					_show(slots, 0, 128, " 破 坏 政 治 稳 定")
					_show(slots, 1, 9, "发 展 贸 易")
				else:
					_show(slots, 0, 9, "发 展 贸 易")
					if country.has_tag("对华贸易") and (w.is_socialism(country, true) \
							or (w.is_authoritarian(country) and not country.has_tag("亲美") \
							and player != null and (player.sub_government == 7 or player.sub_government == 9))):
						_show(slots, 1, 10, "经 济 合 作")
						if country.has_tag("亲中"):
							_show(slots, 2, 19, "军 事 同 盟")
							if _revint_ok(w, country):
								_show(slots, 3, 5000, "革 命 国 际")
		elif n == 92:
			# CS L2325-2389
			if w.result_of_event_num(673) != 3:
				if _d(w, 65) == 0:
					_show(slots, 0, 2, "特 别 军 事 行 动")
					if country.government != 0 and _dlc3(w):
						if w.result_of_event_num(677) != 5 and w.event_done_num(677) \
								and _d(w, 166) < 100 and _d(w, 162) < 100 and _d(w, 163) < 100 \
								and _d(w, 164) < 100 and _d(w, 165) < 100 \
								and not _part(w, 29, 0) and not _part(w, 166, 0):
							_show(slots, 1, 1066, "支 援")
						elif not country.has_tag("对华贸易"):
							_show(slots, 1, 9, "发 展 贸 易")
						elif _d(w, 65) != 2 and (player == null or not player.has_tag("sev")):
							_show(slots, 1, 3, "组 织 统 一 谈 判")
						if not w.event_done_num(404):
							_show(slots, 3, 113, " 打 入 主 义")
						elif _d(w, 147) == 3:
							_show(slots, 2, 1065, "落 实 政 治 纲 领")
				elif not w.is_authoritarian(country):
					_show(slots, 1, 9, "发 展 贸 易")
					if not w.event_done_num(404):
						_show(slots, 3, 113, " 打 入 主 义")
					elif _d(w, 147) == 3:
						_show(slots, 3, 1065, "落 实 政 治 纲 领")
					if w.is_socialism(country, true) and country.has_tag("对华贸易") \
							and country.sub_government != 18:
						_show(slots, 1, 10, "经 济 合 作")
						_show(slots, 2, 19, "军 事 同 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
					if w.result_of_event_num(677) != 5 and w.event_done_num(677) \
							and _d(w, 166) < 100 and _d(w, 162) < 100 and _d(w, 163) < 100 \
							and _d(w, 164) < 100 and _d(w, 165) < 100 \
							and not _part(w, 29, 0) and not _part(w, 166, 0):
						_show(slots, 0, 1066, "支 援")
					if country.sub_government == 18:
						_show(slots, 0, 10000, "重 建 第 四 国 际")
				if country.sub_government == 12 and w.event_done_num(404):
					_show(slots, 3, 1064, "刺 杀")
		elif n == 93:
			# CS L2391-2417
			if not country.has_tag("fxseu") and not country.has_tag("nazimao") and _dlc3(w):
				_show(slots, 0, 93, " 发 展 贸 易")
				var c35 := _c(w, 35)
				if (w.get_flag("Israellost") and not w.event_done_num(440)) \
						or w.result_of_event_num(440) == 2:  # 散落 bool Israellost 用 global_flags 建模
					_show(slots, 1, 1002, "谈 判 结 束 内 战")
				if c35 != null and c35.puppet_of == 14:
					_show(slots, 1, 1079, "新 秩 序")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					_show(slots, 2, 19, "军 事 同 盟")
					if _revint_core_ok(w, country) and country.has_tag("okb"):
						_show(slots, 2, 5000, "革 命 国 际")
				if w.oar:
					_show(slots, 3, 67, "阿 拉 伯 联 合")
		elif n == 94:
			# CS L2419-2441
			if not country.内战中:
				_show(slots, 0, 9, "发 展 贸 易")
			_show(slots, 1, 95, " 谈 判")
			if _d(w, 127) < 100:
				_show(slots, 2, 1075, " 承 认KKTC")
			var spain := _c(w, 85)
			if country.government == 2 and spain != null and spain.has_tag("soc_eu"):
				_show(slots, 3, 1074, " 促 进 欧 洲 团 结")
			else:
				_show(slots, 3, 53, "经 济 合 作")
			if _revint_core_ok(w, country) and country.has_tag("亲中") \
					and country.has_tag("econ") and not country.内战中:
				_show(slots, 3, 5000, "革 命 国 际")
		elif n == 95:
			# CS L2443-2454
			if _dlc3(w):
				_show(slots, 0, 96, " 发 展 贸 易")
				_show(slots, 1, 53, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif (n == 36 or (n > 100 and n < 106 and n != 104)) and w.modifier_active(51):
			# CS L2456-2510
			if n == 101 and (w.is_authoritarian(_c(w, 101)) or _gov(w, 101) == 3) \
					and not w.is_authoritarian(_c(w, 102)) and not w.is_authoritarian(_c(w, 36)):
				_show(slots, 0, 1023, "发 起 革 命")
			elif n == 101 and not w.event_done_num(569) and not w.is_authoritarian(country):
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if w.oar:
					_show(slots, 3, 67, "阿 拉 伯 联 合")
			if w.event_done_num(567) and n > 101 and n < 106 and n != 104:
				if _c(w, 24) != null and _c(w, 24).prc_power < 100:
					_show(slots, 0, 1022, "支 持 阿 湾 人 阵")
				else:
					_show(slots, 0, 1022, "发 起 革 命")
			elif not w.event_done_num(568) and not w.event_done_num(709) \
					and w.is_authoritarian(country):
				if not country.has_tag("亲中"):
					_show(slots, 0, 142, " 武 器 援 助")
					_show(slots, 1, 143, " 联 络 王 朝")
					_show(slots, 2, 144, " 投 资 油 井")
				else:
					_show(slots, 0, 145, " 抬 高 石 油 价 格")
					_show(slots, 1, 146, " 降 低 石 油 价 格")
					_show(slots, 2, 143, " 联 络 王 朝")
					_show(slots, 3, 144, " 投 资 油 井")
			if w.event_done_num(709) and _sub(w, 14) == 19:
				_show(slots, 0, 1079, "新 秩 序")
				if country.puppet_of == 14:
					_show(slots, 2, 145, " 抬 高 石 油 价 格")
					_show(slots, 3, 146, " 降 低 石 油 价 格")
			if _revint_ok(w, country):
				_show(slots, 2, 5000, "革 命 国 际")
		elif n == 99:
			# CS L2512-2542
			if country.puppet_of < 0:
				var c99 := _c(w, 99)
				var cond_first: bool = (c99 == null or (not c99.有驻军基地 and not w.war_going(26))) \
						or (c99 != null and (c99.has_tag("econ") or c99.has_tag("sev") \
						or (c99.sub_government == 10 and not w.war_going(26)) \
						or (c99.sub_government == 7 and not w.war_going(26))))
				if cond_first:
					_show(slots, 2, 101, " 经 济 合 作")
					_show(slots, 0, 110, " 厄 人 阵")
					_show(slots, 1, 111, " 厄 解 阵")
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 3, 5001, " 非 洲 联 盟")
					if _revint_econ_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
				elif country.has_tag("亲中"):
					_show(slots, 0, 10, "经 济 合 作")
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 1, 5001, " 非 洲 联 盟")
					if _revint_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
		elif n == 100:
			# CS L2544-2574
			var c99 := _c(w, 99)
			if c99 != null and c99.puppet_of < 0:
				var c100 := _c(w, 100)
				var cond_first: bool = (c100 == null or (not c100.有驻军基地 and not w.war_going(25))) \
						or (c99 != null and (c99.has_tag("econ") or c99.has_tag("sev") \
						or (c100 != null and c100.government == 3 and not w.war_going(25)) \
						or (c100 != null and c100.government == 1 and not w.war_going(25))))
				if cond_first:
					_show(slots, 2, 101, " 经 济 合 作")
					_show(slots, 0, 110, " 左 翼")
					_show(slots, 1, 111, " 右 翼")
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 3, 5001, " 非 洲 联 盟")
					if _revint_econ_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
				elif country.has_tag("亲中"):
					_show(slots, 0, 10, "经 济 合 作")
					if country.government == 1 and country.has_tag("亲中") \
							and w.event_done_num(500) and w.result_of_event_num(500) == 0:
						_show(slots, 3, 5001, " 非 洲 联 盟")
					if _revint_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
		elif n == 104 and _dlc3(w):
			# CS L2576-2598
			_show(slots, 0, 9, " 建 立 外 交 关 系")
			if not w.is_authoritarian(country) or country.puppet_of == 14:
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中") and country.puppet_of < 0:
					_show(slots, 2, 19, "军 事 同 盟")
					if _revint_core_ok(w, country) and country.has_tag("okb"):
						_show(slots, 2, 5000, "革 命 国 际")
					if w.oar:
						_show(slots, 3, 67, "阿 拉 伯 联 合")
			if w.is_authoritarian(country) and w.event_done_num(709) and _sub(w, 14) == 19:
				_show(slots, 3, 1079, "新 秩 序")
		elif n == 106:
			# CS L2600-2618
			if country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				_show(slots, 3, 9, "发 展 贸 易")
				if _revint_torg_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
				if _part(w, 41, 0) and _sub(w, 41) == 17:
					_show(slots, 2, 1035, "非 洲 之 角")
		elif n == 107:
			# CS L2620-2638
			if country.has_tag("亲中"):
				_show(slots, 0, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 1, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
				_show(slots, 3, 9, "发 展 贸 易")
			elif country.sub_government != 10:
				_show(slots, 0, 1053, "革 命 左 翼")
		elif n == 108:
			# CS L2640-2662
			_show(slots, 0, 9, "发 展 贸 易")
			if not country.has_tag("亲中"):
				_show(slots, 1, 1032, "制 裁")
			else:
				_show(slots, 1, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 2, 5001, "非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			if player != null and player.sub_government == 19 and country.sub_government != 19:
				_show(slots, 1, 70, "革 命")
		elif n == 109 or n == 110:
			# CS L2664-2667
			_show(slots, 0, 9, "发 展 贸 易")
			_show(slots, 1, 10, "经 济 合 作")
		elif n == 119 and country.禁用非洲机制:
			# CS L2669-2689
			if country.sub_government != 9:
				_show(slots, 0, 1032, "协 助 左 派")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 112:
			# CS L2691-2727
			if not w.event_done_num(616):
				_show(slots, 0, 9, "发 展 贸 易")
				if country.level_of_instability < 1000 and w.result_of_event_num(615) == 2:
					_show(slots, 1, 1024, "支持极左翼")
					if w.event_done_num(500) and w.result_of_event_num(500) == 0:
						_show(slots, 2, 1045, "志 愿 军")
				else:
					_show(slots, 1, 1032, "发动革命")
			elif not w.is_authoritarian(country):
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 113 and country.禁用非洲机制:
			# CS L2729-2749
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 114:
			# CS L2751-2771
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 115:
			# CS L2773-2817
			if not country.has_tag("fxseu") and not country.has_tag("nazimao"):
				_show(slots, 0, 9, "发 展 贸 易")
				if country.sub_government == 9:
					_show(slots, 0, 9, "发 展 贸 易")
					if country.has_tag("亲中"):
						_show(slots, 1, 10, "经 济 合 作")
					else:
						_show(slots, 1, 1032, "特 别 解 放 行 动")
					if player != null and player.sub_government == 19 and w.event_done_num(621):
						_show(slots, 3, 70, " 邀 请 学 习 经 验")
				else:
					_show(slots, 0, 9, "发 展 贸 易")
					if country.has_tag("亲中"):
						_show(slots, 1, 10, "经 济 合 作")
						if country.has_tag("亲中"):
							if w.is_socialism(country, true) and w.event_done_num(500) \
									and w.result_of_event_num(500) == 0:
								_show(slots, 2, 5001, " 非 洲 联 盟")
							if _revint_ok(w, country):
								_show(slots, 3, 5000, "革 命 国 际")
					else:
						_show(slots, 1, 1032, "特 别 解 放 行 动")
		elif n == 116:
			# CS L2819-2845
			_show(slots, 0, 9, "发 展 贸 易")
			if not country.has_tag("亲美") and country.puppet_of < 0 and w.event_done_num(619):
				_show(slots, 1, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 2, 5001, " 非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			else:
				if not country.内战中:
					_show(slots, 1, 1024, " 支 持 反 对 派")
				else:
					_show(slots, 1, 1044, " 训 练")
				_show(slots, 2, 1032, " 制 裁")
		elif n == 117:
			# CS L2847-2891
			if not country.has_tag("fxseu") and not country.has_tag("nazimao"):
				if country.sub_government != 9:
					if not _part(w, 163, 0):
						_show(slots, 0, 9, "发 展 贸 易")
					if country.has_tag("亲中"):
						_show(slots, 1, 10, "经 济 合 作")
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
						if (country.sub_government == 9 or country.sub_government == 7) \
								and player != null and player.sub_government == 19:
							_show(slots, 3, 70, " 扎 伊 尔 化")
					elif country.sub_government != 10:
						if w.result_of_event_num(613) == 0:
							_show(slots, 1, 1041, "施 压")
						_show(slots, 2, 1042, "掀 起 革 命")
				elif country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					_show(slots, 2, 19, "军 事 同 盟")
					if player != null and player.sub_government == 19:
						_show(slots, 3, 70, " 扎 伊 尔 化")
		elif n == 118:
			# CS L2893-2926
			if w.event_done_num(659) and not w.event_done_num(661):
				if w.result_of_event_num(659) == 1:
					_show(slots, 0, 1057, "民 族 解 放 军")
				if w.result_of_event_num(659) == 2:
					_show(slots, 0, 1057, "全 国 抵 抗 军")
				if w.result_of_event_num(659) == 3:
					_show(slots, 0, 1057, "阿 明 残 军")
				if w.result_of_event_num(659) == 4:
					_show(slots, 0, 1057, " 布 干 达 武 装")
			elif country.has_tag("亲中") and not w.is_authoritarian(country):
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 2, 5001, " 非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 122:
			# CS L2928-2952
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.government != 0 and country.government != 3 \
						and w.event_done_num(598) and not w.war_going(53):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 123:
			# CS L2954-2998
			if country.puppet_of < 0 or country.puppet_of == 117:
				_show(slots, 0, 9, "发 展 贸 易")
				if not w.event_done_num(638):
					_show(slots, 1, 1047, "支 持 毛 派")
					_show(slots, 2, 1048, "阿 尔 维 斯 集 团")
					_show(slots, 3, 1049, "下 注")
				elif not country.内战中 and not w.war_going(68):
					_show(slots, 1, 142, "出 售 军 火")
					_show(slots, 2, 143, "资 金 援 助")
					_show(slots, 3, 144, "打 压 对 手")
				elif not w.war_going(68):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if country.has_tag("对华贸易"):
							_show(slots, 0, 1080, "开 采 石 油")
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
				if country.sub_government == 8 and player != null and player.sub_government == 19:
					_show(slots, 1, 70, "复 辟")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 124:
			# CS L3000-3024
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.government != 0 and country.government != 3 and w.event_done_num(581):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 125:
			# CS L3026-3051
			if country.puppet_of < 0:
				if w.is_authoritarian(country):
					_show(slots, 0, 9, "发 展 贸 易")
					_show(slots, 1, 1032, "施 压")
				else:
					_show(slots, 0, 9, "发 展 贸 易")
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 126:
			# CS L3053-3082
			if w.event_done_num(623):
				if _part(w, 126, 0):
					_show(slots, 0, 1043, "支 持 莫 解 阵")
					_show(slots, 1, 1044, "支 持 莫 抵 运")
					if w.event_done_num(500):
						_show(slots, 2, 1045, "志 愿 军")
				elif country.sub_government != 9:
					_show(slots, 0, 9, "发 展 贸 易")
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 127:
			# CS L3084-3108
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.government != 0 and country.government != 3:
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
						elif country.sub_government == 15 and player != null and player.sub_government == 19:
							_show(slots, 3, 70, " “ 快 车 道 ”")
		elif n == 129:
			# CS L3110-3148
			if not country.has_tag("亲中") and country.puppet_of < 0 and country.sub_government != 7:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 1043, "左 派")
				_show(slots, 2, 1044, "训 练")
				_show(slots, 3, 1045, "起 义")
			elif country.has_tag("亲中"):
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if w.is_socialism(country, true) and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 2, 5001, " 非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			elif country.puppet_of < 0 and country.sub_government == 7:
				_show(slots, 0, 62, "扶 持 亲 中 派")
				if not country.has_tag("亲中"):
					_show(slots, 1, 63, "勾 结 苏 联")
					_show(slots, 2, 64, "勾 结 美 国")
				if country.has_tag("亲中") and not country.has_tag("亲苏") and not country.has_tag("亲美"):
					_show(slots, 3, 66, "资 源 开 发 区")
				else:
					_show(slots, 3, 65, "组 织 政 变")
		elif n == 130:
			# CS L3150-3171
			if not country.内战中:
				_show(slots, 0, 1038, "推 翻 君 主 制")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中"):
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 2, 5001, " 非 洲 联 盟")
					if _revint_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
		elif n == 131:
			# CS L3173-3211
			if not country.内战中:
				_show(slots, 1, 57, "支 持 抗 议 运 动")
			if country.sub_government != 9:
				if country.sub_government != 7:
					_show(slots, 0, 9, "发 展 贸 易")
				if w.is_authoritarian(country) and country.sub_government != 19:
					if country.内战中:
						_show(slots, 1, 57, "促 使 激 进 化")
				elif country.government != 3:
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
				if country.sub_government == 19:
					_show(slots, 3, 70, " “ 博 莱 斯 ” 行 动")
		elif n == 132:
			# CS L3213-3238
			_show(slots, 0, 9, "发 展 贸 易")
			if not country.内战中:
				_show(slots, 1, 1037, " 援 助 阿 扎 尼 亚 派")
			else:
				_show(slots, 1, 1037, " 援 助 毛 派")
			if country.puppet_of < 0:
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中"):
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 2, 5001, " 非 洲 联 盟")
					if _revint_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
		elif n == 153:
			# CS L3240-3262
			_show(slots, 0, 9, "发 展 贸 易")
			if country.government == 2:
				_show(slots, 2, 1039, "支 持 左 翼")
				_show(slots, 3, 1040, "支 持 右 翼")
			else:
				_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中"):
					if w.is_socialism(country, true) and w.event_done_num(500) \
							and w.result_of_event_num(500) == 0:
						_show(slots, 2, 5001, " 非 洲 联 盟")
					if _revint_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
		elif n == 133:
			# CS L3264-3278
			_show(slots, 0, 9, "发 展 贸 易")
			_show(slots, 1, 10, "经 济 合 作")
			if country.has_tag("亲中"):
				if country.government == 1 and w.event_done_num(500) \
						and w.result_of_event_num(500) == 0:
					_show(slots, 2, 5001, " 非 洲 联 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 134:
			# CS L3280-3314
			var c135 := _c(w, 135)
			var c50 := _c(w, 50)
			if c135 != null and (c135.has_tag("亲中") or c135.has_tag("亲苏")):
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 1024, " 推 动 改 革")
				if country.puppet_of < 0:
					_show(slots, 2, 10, "经 济 合 作")
					if c135.has_tag("亲中"):
						_show(slots, 3, 19, "军 事 同 盟")
						if _revint_okb_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
			if c50 != null and w.is_socialism(c50, true) and (c135 == null or not c135.has_tag("亲美")):
				_show(slots, 1, 1025, " 巴 布 亚")
				if country.puppet_of < 0:
					_show(slots, 2, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						_show(slots, 3, 19, "军 事 同 盟")
						if _revint_okb_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
		elif n == 135:
			# CS L3316-3333
			_show(slots, 0, 9, "发 展 贸 易")
			if not country.has_tag("亲美"):
				if country.has_tag("亲中") or (country.government != 3 and country.government != 0):
					_show(slots, 1, 10, "经 济 合 作")
				if country.has_tag("亲中"):
					_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif n == 136:
			# CS L3335-3350
			_show(slots, 1, 9, "发 展 贸 易")
			if not _has(w, 51, "nato"):
				if country.has_tag("亲中"):
					_show(slots, 2, 10, "经 济 合 作")
					_show(slots, 3, 19, "军 事 同 盟")
					if _revint_okb_ok(w, country):
						_show(slots, 3, 5000, "革 命 国 际")
				_show(slots, 0, 1024, " 支 持")
		elif n == 137:
			# CS L3352-3363
			if country.sub_government != 7:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				_show(slots, 2, 1076, "魁 北 克 问 题")
				if not w.event_done_num(704):
					_show(slots, 3, 1077, "筹 备 经 济 封 锁")
		elif n == 167:
			# CS L3365-3378
			if not country.has_tag("nato"):
				_show(slots, 0, 9, "发 展 贸 易")
				if w.is_socialism(country, true):
					_show(slots, 1, 10, "经 济 合 作")
					if _revint_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
		elif n == 138:
			# CS L3380-3415
			var sov := _c(w, 7)
			if sov != null and not sov.has_tag("nato") and not w.get_flag("is_gkchp"):
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("对华贸易"):
					_show(slots, 0, 49, "进 口 雪 茄")
				if not country.has_tag("亲中"):
					if not country.has_tag("亲苏") and not country.has_tag("亲美") and country.sub_government != 7:
						_show(slots, 1, 1033, " 援 助 古 巴")
					if player != null and player.has_tag("seato"):
						_show(slots, 2, 1034, " 协 助 入 侵")
				elif country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if _revint_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
				if country.内战中 and (country.has_tag("亲苏") or country.has_tag("亲美")):
					_hide_all(slots)
		elif n == 140:
			# CS L3417-3432
			if not country.has_tag("亲中"):
				_show(slots, 0, 1026, " 支 持 左 翼 反 对 派")
				_show(slots, 1, 1027, " 支 持 右 翼 反 对 派")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
			if _revint_ok(w, country):
				_show(slots, 2, 5000, "革 命 国 际")
		elif n == 141:
			# CS L3434-3448
			_show(slots, 0, 9, "发 展 贸 易")
			if _part(w, 141, 1):
				_show(slots, 1, 1062, " 运 河")
			else:
				_show(slots, 1, 10, "经 济 合 作")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 145:
			# CS L3450-3466
			if not country.内战中:
				_show(slots, 0, 1028, " 支 持 霍 查 派")
				_show(slots, 1, 1029, " 支 持 毛 派")
				_show(slots, 2, 1030, " 支 持 正 统 派")
				_show(slots, 3, 1031, " 支 持 托 派")
			else:
				_show(slots, 0, 10, "经 济 合 作")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
		elif n == 147:
			# CS L3468-3497
			if not w.is_socialism(country, true) and country.government != 2:
				if country.level_of_instability < 1000 and country.level_of_instability > 0:
					_show(slots, 0, 1043, " 桑 解 阵")
				else:
					_show(slots, 0, 9, "发 展 贸 易")
			elif country.level_of_instability < 1000 and country.level_of_instability > 0:
				_show(slots, 0, 1043, " 桑 解 阵")
				_show(slots, 1, 1044, " 康 特 拉")
			elif w.result_of_event_num(637) != 3:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if _revint_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
		elif n == 149:
			# CS L3499-3534
			if not w.is_socialism(country, true) and country.government != 2:
				if country.level_of_instability < 1000 and country.level_of_instability > 0:
					_show(slots, 0, 1043, " 左 翼 游 击 队")
					_show(slots, 1, 1044, " 镇 压 左 翼")
				else:
					_show(slots, 0, 9, "发 展 贸 易")
			elif country.level_of_instability < 1000 and country.level_of_instability > 0:
				_show(slots, 0, 1043, "镇 压 右 翼")
				_show(slots, 1, 9, "发 展 贸 易")
				if not _part(w, 149, 0) and not w.war_going(66):
					_show(slots, 3, 1045, "特 别 军 事 行 动")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 10, "经 济 合 作")
				if _revint_ok(w, country):
					_show(slots, 2, 5000, "革 命 国 际")
				if not _part(w, 149, 0) and not w.war_going(66):
					_show(slots, 3, 1045, "特 别 军 事 行 动")
		elif n == 152:
			# CS L3536-3554
			if not w.is_authoritarian(country):
				_show(slots, 3, 49, "邀 请 乐 队")
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中") and not w.is_socialism(country, true):
					_show(slots, 0, 1032, "学 习 古 巴")
				elif country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if _revint_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
		elif n == 154:
			# CS L3556-3582
			if not country.has_tag("fxseu") and not country.has_tag("nazimao"):
				if not w.event_done_num(630):
					_show(slots, 0, 1032, "F L N K S")
					if w.modifier_active(42) or w.modifier_active(43) or w.modifier_active(44):
						_show(slots, 1, 1046, "“ 风 暴 ”")
				elif country.puppet_of < 0:
					_show(slots, 0, 9, "发 展 贸 易")
					if country.has_tag("亲中"):
						_show(slots, 1, 10, "经 济 合 作")
						_show(slots, 2, 19, "军 事 同 盟")
						if _revint_okb_ok(w, country):
							_show(slots, 2, 5000, "革 命 国 际")
					_show(slots, 3, 49, "度 假")
		elif n == 155:
			# CS L3584-3608
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 157:
			# CS L3610-3625
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				_show(slots, 1, 53, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 158:
			# CS L3627-3651
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					if country.has_tag("亲中"):
						if w.is_socialism(country, true) and w.event_done_num(500) \
								and w.result_of_event_num(500) == 0:
							_show(slots, 2, 5001, " 非 洲 联 盟")
						if _revint_ok(w, country):
							_show(slots, 3, 5000, "革 命 国 际")
			else:
				_show(slots, 0, 9, "发 展 贸 易")
		elif n == 159:
			# CS L3653-3673
			if country.puppet_of < 0:
				_show(slots, 0, 9, "发 展 贸 易")
				if country.has_tag("亲中"):
					_show(slots, 1, 10, "经 济 合 作")
					_show(slots, 2, 19, "军 事 同 盟")
					if _revint_okb_ok(w, country):
						_show(slots, 2, 5000, "革 命 国 际")
					_show(slots, 3, 1045, "F L N K S")
			elif not w.event_done_num(629):
				_show(slots, 0, 1043, "瓦 努 阿 库 党")
				_show(slots, 1, 1044, "援 助")
		elif n == 160:
			# CS L3675-3690
			_show(slots, 0, 1050, "左 翼")
			if country.has_tag("亲中"):
				_show(slots, 1, 10, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			if w.is_authoritarian(player):
				_show(slots, 3, 1051, "复 辟")
		elif n == 161:
			# CS L3692-3707
			_show(slots, 0, 1050, "马 西 纳 运 动")
			if country.has_tag("亲中"):
				_show(slots, 1, 10, "经 济 合 作")
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
			if country.government == 3:
				_show(slots, 3, 1051, "支 持 政 府")


# ── 主链之后的独立块（CS L3710-L3932）──

func _tail_blocks(w: WorldState, country: CountryData, slots: Array) -> void:
	var _n := country.原版序号
	var player := w.get_player_country()
	_block_dlc_west(w, country, slots)
	_block_29(w, country, slots)
	_block_166(w, country, slots)
	_block_asean_extra(w, country, slots)
	_block_seato_extra(w, country, slots)
	_block_seato_loop(w, country, slots)
	if player != null and player.has_tag("ovd") and _dlc3(w):
		_block_ovd_loop(w, country, slots)
	else:
		_block_africa_h(w, country, slots)
	_block_zhengchi(w, country, slots)


func _block_dlc_west(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3710-3765
	var n := country.原版序号
	if not (n == 27 or n == 88 or n == 0 or n == 89 or n == 90 or n == 91 or n == 28) \
			or not _dlc3(w):
		return
	if (n > 87 and n < 92) or n == 0:
		_show(slots, 0, 9, "发 展 贸 易")
	else:
		_show(slots, 0, 50, "发 展 贸 易")
	var spain := _c(w, 85)
	var france := _c(w, 21)
	var sov := _c(w, 7)
	var c4 := _c(w, 4)
	var player := w.get_player_country()
	var no_alt_europe: bool = (spain == null or not spain.has_tag("soc_eu")) \
			and (france == null or (not france.has_tag("fxseu") and not france.has_tag("nazimao")))
	if no_alt_europe:
		if w.event_done_num(686) and w.result_of_event_num(686) == 0 \
				and not country.有驻军基地 \
				and (not country.has_tag("econ") or not country.has_tag("okb")):
			_show(slots, 0, 1069, "扶 持 亲 中 势 力")
			_show(slots, 1, 1070, "遏 制 苏 联 集 团")
			_show(slots, 2, 1071, "形 成 经 济 联 盟")
			_show(slots, 3, 1072, "签 署 安 保 协 定")
		elif w.event_done_num(686) and country.has_tag("econ") \
				and country.has_tag("okb") and not country.有驻军基地:
			if _revint_ok(w, country):
				_show(slots, 3, 5000, "革 命 国 际")
		elif w.event_done_num(686) and country.有驻军基地 \
				and ((sov != null and sov.has_tag("sev")) or w.get_flag("is_gkchp") \
				or (c4 != null and c4.sub_government == 19)):
			if player == null or not player.has_tag("asean"):
				_show(slots, 1, 1, "扶 持 极 左 派")
			else:
				_show(slots, 1, 123, " 自 由 派")
		if country.有驻军基地 and (sov == null or not sov.has_tag("sev")) \
				and not w.get_flag("is_gkchp") \
				and (c4 == null or c4.sub_government != 19):
			_show(slots, 2, 148, " 欧 洲 左 派")
			_show(slots, 3, 149, " 欧 洲 右 派")
			_show(slots, 1, 53, " 经 济 合 作")
	elif france != null and france.has_tag("fxseu"):
		_show(slots, 1, 148, " 支 持 主 权 欧 洲")
	elif france != null and france.has_tag("nazimao"):
		_show(slots, 1, 148, " 支 持 民 族 欧 洲")
	elif spain != null and spain.has_tag("soc_eu"):
		_show(slots, 1, 148, " 促 进 欧 洲 团 结")


func _block_29(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3767-3807
	var n := country.原版序号
	var _player := w.get_player_country()
	if n == 29 and _d(w, 169) != 1 \
			and (country.sub_government != 10 or not _part(w, 29, 0)):
		var spain := _c(w, 85)
		var france := _c(w, 21)
		if (spain == null or not spain.has_tag("soc_eu")) \
				and (france == null or not france.has_tag("fxseu")) \
				and (france == null or not france.has_tag("nazimao")):
			if _sub(w, 166) == 1 and _has(w, 166, "亲中"):
				_show(slots, 2, 1068, " 反 帝 广 泛 阵 线")
			_show(slots, 0, 9, " 发 展 贸 易")
			_show(slots, 1, 10, " 经 济 合 作")
			if _part(w, 29, 0) and w.is_socialism(country, true):
				_show(slots, 2, 19, "军 事 同 盟")
				if _revint_ok(w, country):
					_show(slots, 3, 5000, "革 命 国 际")
		elif france != null and france.has_tag("fxseu"):
			_show(slots, 2, 148, " 支 持 主 权 欧 洲")
		elif france != null and france.has_tag("nazimao"):
			_show(slots, 2, 148, " 支 持 民 族 欧 洲")
		elif spain != null and spain.has_tag("soc_eu"):
			_show(slots, 2, 1068, "  建 立 民 主 社 会")
	elif n == 29 and _has(w, 85, "soc_eu") and _d(w, 169) == 0:
		_show(slots, 1, 1068, "  建 立 民 主 社 会")
	elif n == 29 and country.sub_government == 10 and _part(w, 29, 0):
		_show(slots, 0, 9, " 发 展 贸 易")
		_show(slots, 1, 10, " 经 济 合 作")
		_show(slots, 2, 19, "军 事 同 盟")


func _block_166(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3809-3811
	if country.原版序号 == 166 and _sub(w, 166) == 1 and _has(w, 166, "亲中"):
		_show(slots, 0, 1067, " 推 进 统 一")


func _block_asean_extra(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3813-3830
	var player := w.get_player_country()
	if player == null or not player.has_tag("asean"):
		return
	var n := country.原版序号
	if n == 31 or n == 32:
		_show(slots, 0, 119, " 经 济 合 作")
	elif n == 43 or n == 96 or n == 97 or n == 12 or n == 11 or n == 23 or n == 49 or n == 33 \
			or (n == 22 and (country.has_tag("亲中") or country.has_tag("亲美"))) or n == 95:
		_show(slots, 1, 119, " 经 济 合 作")
	elif n == 34 or n == 47 or n == 50 \
			or (n == 35 and _sub(w, 8) != 35) \
			or (n == 8 and _sub(w, 8) != 20) \
			or n == 37 or n == 46 or (n == 93 and _pup(w, 93) == 37):
		_show(slots, 2, 119, " 经 济 合 作")
	elif n == 19:
		_show(slots, 3, 119, " 经 济 合 作")


func _block_seato_extra(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3832-3849
	var player := w.get_player_country()
	if player == null or not player.has_tag("seato"):
		return
	var n := country.原版序号
	if n == 31 or n == 32:
		_show(slots, 1, 120, " 军 事 联 盟")
	elif n == 43 or n == 96 or n == 97 or n == 12 or n == 11 or n == 23 or n == 49 or n == 33 \
			or (n == 22 and (country.has_tag("亲中") or country.has_tag("亲美"))) or n == 95:
		_show(slots, 2, 120, " 军 事 联 盟")
	elif n == 34 or n == 44 or n == 47 or n == 46 or n == 50 \
			or (n == 35 and not country.has_tag("oar")) \
			or (n == 8 and _sub(w, 8) != 20) \
			or n == 37 or (n == 93 and _pup(w, 93) == 37):
		_show(slots, 3, 120, " 军 事 联 盟")
	elif n == 19 and country.has_tag("asean"):
		_show(slots, 3, 120, " 军 事 联 盟")


func _block_seato_loop(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3851-3879
	var player := w.get_player_country()
	var n := country.原版序号
	if player == null or not player.has_tag("seato"):
		return
	if not country.has_tag("seato") or n < 2 or n == 51 or n == 8 or n == 11:
		return
	if not country.has_tag("亲中"):
		_show(slots, 2, 131, " 支 持")
		_show(slots, 3, 125, " 政 变")
	else:
		if not country.has_tag("贸易同盟"):
			_show(slots, 2, 134, " 资 助")
		else:
			_show(slots, 2, 134, " 取 消")
		_show(slots, 3, 132, " 政 变")


func _block_ovd_loop(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3881-3912
	var n := country.原版序号
	if not country.has_tag("ovd"):
		return
	if not ((n == 11 and not _part(w, 11, 0)) or n == 12 or n == 31 or n == 32 \
			or n == 96 or n == 97 or n == 98):
		return
	if not country.has_tag("亲中"):
		_show(slots, 2, 130, " 支 持")
		_show(slots, 3, 125, " 政 变")
	else:
		if not country.has_tag("贸易同盟"):
			_show(slots, 2, 134, " 资 助")
		else:
			_show(slots, 2, 134, " 取 消")
		_show(slots, 3, 132, " 政 变")


func _block_africa_h(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3914-3928
	var n := country.原版序号
	var in_range: bool = (n > 53 and n < 69) or (n > 105 and n < 109) \
			or (n > 111 and n < 134) or n == 42
	if not in_range or n == 55 or n == 54 or n == 106:
		return
	if not country.has_tag("亲中") or country.禁用非洲机制:
		return
	_show(slots, 0, 10, "经 济 合 作")
	if (country.government == 1 or country.sub_government == 0) \
			and w.event_done_num(500) and w.result_of_event_num(500) == 0:
		_show(slots, 1, 5001, "非 洲 联 盟")
	if _revint_ok(w, country):
		_show(slots, 2, 5000, "革 命 国 际")
	if ((n > 53 and n < 69) or (n > 105 and n < 109)) \
			and (_d(w, 103) != 15 or n != 61):
		_show(slots, 3, 66, "资 源 开 发 区")


func _block_zhengchi(w: WorldState, country: CountryData, slots: Array) -> void:
	# CS L3930-3932
	var n := country.原版序号
	var in_range: bool = (n > 53 and n < 69 and n != 54 and n != 55 and not country.禁用非洲机制) \
			or (n >= 106 and n < 109 and not country.禁用非洲机制)
	if country.has_tag("econ") and (n != 30 or not w.oar) and not country.has_tag("oar") \
			and (n == 19 or n == 48 or n == 96 or n == 49 or n == 47 or n == 46 \
			or n == 22 or n == 23 or n == 34 or n == 32 or n == 97 or n == 43 \
			or n == 31 or n == 12 or in_range):
		_show(slots, 0, 80, "整 饬 内 政")


func _block_k_ok(w: WorldState, country: CountryData) -> bool:
	# CS L3942-3948
	if not w.event_done_num(713) or country.原版序号 == 1:
		return false
	if country.puppet_of >= 0:
		return false
	if not w.is_socialism(country, true) or country.sub_government == 16 or country.sub_government == 18:
		return false
	if country.has_tag("亲苏") or country.has_tag("亲美") or country.has_tag("sev") \
			or country.has_tag("ovd") or country.has_tag("nato") or country.has_tag("eu") \
			or country.has_tag("seato") or country.has_tag("sento"):
		return false
	return true

## 自检结果（Python 静态检查，未 headless 运行 Godot）
# utf8: PASS
# tab缩进/行首空格: PASS (0)
# 括号平衡（代码，去注释）: PASS
# build返回: PASS
# Show槽位/文案/type 多重集: PASS (C#=864, GD=864)
# 国别覆盖: PASS (C# 显式==编号 139 个 + 区间展开，合计 161 个编号全部出现)
# 函数定义重复: PASS (共 38 个函数)
# 建模说明（行号=文件行号）:
#   L184 if not w.get_flag("relres"):  # 散落 bool relres 用 global_flags 建模
#   L341 if not w.get_flag("guns"):  # 散落 bool guns 用 global_flags 建模
#   L363 elif w.war_state <= 0:  # 原版 war 状态由 Godot war_state 字段建模
#   L504 if w.war_state != 2 and not country.has_tag("亲中"):  # 原版 war 状态由 Godot war_state 字段建模
#   L693 if w.get_flag("Israellost") or (c93 != null and c93.puppet_of == 37):  # 散落 bool Israellost 用 global_flags 建模
#   L1338 or w.result_of_event_num(440) == 2:  # 散落 bool Israellost 用 global_flags 建模
# 已消除近似：L501/L717 的 completedDecisions[14]/[6] 已改用 w.decisions.completed 真实字段。
