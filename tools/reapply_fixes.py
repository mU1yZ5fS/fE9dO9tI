# -*- coding: utf-8 -*-
"""HEAD 还原后，重新套用本轮全部必要修改（幂等：重复执行安全）。"""
import io
import os
import re

ROOT = os.getcwd()


def rd(p):
    return io.open(os.path.join(ROOT, p), encoding="utf-8").read()


def wr(p, t):
    io.open(os.path.join(ROOT, p), "w", encoding="utf-8", newline="").write(t)


def edit(path, pairs, must=True):
    t = rd(path)
    changed = False
    for old, new in pairs:
        if new in t:
            continue                      # 已应用（幂等）
        if old not in t:
            if must:
                print("!! 未找到锚点:", path, repr(old[:60]))
            continue
        t = t.replace(old, new, 1)
        changed = True
    if changed:
        wr(path, t)
    return changed


total = 0

# ── 1) 543 哈姆雷特引文转义残留 ──
p = "数据脚本/事件效果/event_543_eight_hundred_million_plays.gd"
t = rd(p)
n = t.count("\\u00a0")
if n:
    t = t.replace("\\u00a0", " ")
    while "to  be" in t or "not  to" in t:
        t = t.replace("to  be", "to be").replace("not  to", "not to")
    wr(p, t)
print("543 转义清理:", n)

# ── 2) 517/521 死常量删除 ──
for path, consts in [
    ("数据脚本/事件效果/event_517_blue_sky_of_homeland.gd",
     ['const TXT_R0_C := "event.script.event_517_blue_sky_of_homeland.c5"\n',
      'const TXT_R0_F := "event.script.event_517_blue_sky_of_homeland.c8"\n']),
    ("数据脚本/事件效果/event_521_project_840.gd",
     ['const TXT_R1_E := "event.script.event_521_project_840.c5"\n',
      'const TXT_R2_E := "event.script.event_521_project_840.c11"\n']),
]:
    t = rd(path)
    before = t
    for c in consts:
        t = t.replace(c, "")
    if t != before:
        wr(path, t)
        print("死常量清理:", path)

# ── 3) event_018 war39 动态判边 + war87 专用分支 ──
p = "数据脚本/事件效果/event_018_war_is_over.gd"
t = rd(p)
if "polisario_is_side1" not in t:
    old = '''func _war39_result_text(war: WarData) -> String:
	var polisario := ws.get_country_by_legacy_index(18) if ws != null else null
	var is_cw: bool = polisario != null and polisario.内战中
	if war.infl2 >= 900:'''
    new = '''func _war39_result_text(war: WarData) -> String:
	var polisario := ws.get_country_by_legacy_index(18) if ws != null else null
	var is_cw: bool = polisario != null and polisario.内战中
	var polisario_is_side1: bool = String(war.side1).contains("西撒") \\
			or String(war.side1).contains("人阵") or String(war.side1).contains("波利萨里奥")
	var polisario_win: bool = (war.infl1 >= 900) if polisario_is_side1 else (war.infl2 >= 900)
	if polisario_win:'''
    assert old in t, "war39 锚点缺失"
    t = t.replace(old, new, 1)
    print("018: war39 动态判边 ✓")
if "\t\t87:" not in t:
    anchor = '''		86:
			txt = _war86_result_text_from_table(entry, war)'''
    add87 = anchor + '''
		87:
			# 爱尔兰统一战争：side1=北爱尔兰、side2=爱尔兰共和国。
			# a=南方吞并北方；b=北方空降都柏林获胜。默认 a/b 顺序与实际胜方相反。
			if war.infl1 >= 900:
				txt = _t(entry, "b")
			elif war.infl2 >= 900:
				txt = _t(entry, "a")
			else:
				txt = _t(entry, "draw")'''
    assert anchor in t, "87 锚点缺失"
    t = t.replace(anchor, add87, 1)
    print("018: war87 分支 ✓")
wr(p, t)

# ── 4) war_system war16/war0 国名对齐修复（若被还原）──
p = "数据脚本/systems/war_system.gd"
t = rd(p)
changed = False
if 'north.name = "朝鲜民主主义人民共和国"' in t:
    # war16 处（带 _war16_korea_name 的完整块）
    old16 = '''				north.name = "朝鲜民主主义人民共和国"
				north.chinese_name = "朝鲜民主主义人民共和国"'''
    new16 = '''				var kname := _war16_korea_name(china)
				north.name = kname
				north.chinese_name = kname'''
    if old16 in t:
        t = t.replace(old16, new16, 1)
        changed = True
    old0 = '''			north.name = "朝鲜民主主义人民共和国"
			north.chinese_name = "朝鲜民主主义人民共和国"'''
    new0 = '''			north.name = "朝鲜"
			north.chinese_name = "朝鲜"'''
    if old0 in t:
        t = t.replace(old0, new0, 1)
        changed = True
if "_war16_korea_name" not in t:
    helper = '''## war16 战后朝鲜国名：原版按玩家中国政体从 new_events_text[840..843] 四选一
## （GameState.cs:905-918）。短名 840..843；结算文案长名另为 846..849。
static func _war16_korea_name(china: CountryData) -> String:
	var names := ["朝鲜国", "社会主义朝鲜", "朝鲜人民共和国", "朝鲜联盟"]
	var gov := china.government if china != null else GameConstants.Government.SOCIALIST
	match gov:
		GameConstants.Government.AUTHORITARIAN:
			return names[0]
		GameConstants.Government.SOCIALIST:
			return names[1]
		GameConstants.Government.REFORMIST:
			return names[2]
		_:
			return names[3]


'''
    anchor = "## 战争 29 号结算：GameState.cs:1532-1610。"
    assert anchor in t
    t = t.replace(anchor, helper + anchor, 1)
    changed = True
# 战争结算后的地图自检钩子
hook_old = '''	if MapService.instance != null:
		MapService.instance.sync_map_merges()'''
hook_new = '''	if MapService.instance != null:
		MapService.instance.sync_map_merges()
		MapService.instance.assert_map_consistent("war_end_%d" % id)'''
if hook_new not in t and hook_old in t:
    t = t.replace(hook_old, hook_new, 1)
    changed = True
if changed:
    wr(p, t)
print("war_system 修复:", changed)

# ── 5) game_manager 月度自检钩子 ──
p = "数据脚本/game_manager.gd"
t = rd(p)
old = '''	if _map_service != null:
		_map_service.sync_map_merges()
	date_changed.emit(world.date)'''
new = '''	if _map_service != null:
		_map_service.sync_map_merges()
		_map_service.assert_map_consistent("monthly_%d-%d" % [world.date.year, world.date.month])
	date_changed.emit(world.date)'''
if new not in t and old in t:
    t = t.replace(old, new, 1)
    wr(p, t)
    print("game_manager 钩子 ✓")

# ── 6) map_service 自检/告警/审计函数（若被还原）──
p = "数据脚本/地图数据/map_service.gd"
t = rd(p)
need = []
if "func assert_map_consistent" not in t:
    need.append("assert_map_consistent")
if "_warn_once" not in t:
    need.append("_warn_once")
if need:
    print("!! map_service 缺少运行时治理函数，需要从备份恢复:", need)

print("reapply 完成")
