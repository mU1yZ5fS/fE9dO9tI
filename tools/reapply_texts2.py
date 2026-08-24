# -*- coding: utf-8 -*-
"""还原后第二批文本修复：空常量指向 CSV 键、501 R1_I/J/K 纠正、残留 || 转义。"""
import io
import os

ROOT = os.getcwd()


def rd(p):
    return io.open(os.path.join(ROOT, p), encoding="utf-8").read()


def wr(p, t):
    io.open(os.path.join(ROOT, p), "w", encoding="utf-8", newline="").write(t)


BS = chr(92)

# ── 6a) 空常量指向已补全的 CSV 键 ──
const_fixes = [
    ("数据脚本/事件效果/event_307_convict_red_guards.gd",
     'const TXT_OPT2_DIS := ""',
     'const TXT_OPT2_DIS := "event.script.event_307_convict_red_guards.c2"'),
    ("数据脚本/事件效果/event_555_swords_to_ploughshares.gd",
     'const TXT_DESC := ""',
     'const TXT_DESC := "event.script.event_555_swords_to_ploughshares.c0"'),
    ("数据脚本/事件效果/event_591_homeland_or_death.gd",
     'const TXT_OPT2_DIS := ""',
     'const TXT_OPT2_DIS := "event.script.event_591_homeland_or_death.c0"'),
]
for path, old, new in const_fixes:
    t = rd(path)
    if new in t:
        print("skip(已有):", path)
        continue
    assert old in t, (path, old)
    wr(path, t.replace(old, new, 1))
    print("fixed:", path)

# ── 6b) 501 R1_I 空 + J/K 语义互换纠正 ──
p = "数据脚本/事件效果/event_501_western_81_exercise.gd"
t = rd(p)
fixes = [
    ('const TXT_R1_I := ""',
     'const TXT_R1_I := "共同检阅了解放军和民兵，并发表了讲话。"'),
    ('const TXT_R1_J := "共同检阅了解放军和民兵，并发表了讲话。"',
     'const TXT_R1_J := "中国共产党中央军事委员会主席兼最高领导人"'),
    ('const TXT_R1_K := "中国共产党中央军事委员会主席兼最高领导人"',
     'const TXT_R1_K := "检阅了解放军和民兵，并发表了讲话。"'),
]
for old, new in fixes:
    if new in t:
        continue
    assert old in t, (p, old[:40])
    t = t.replace(old, new, 1)
wr(p, t)
print("501 R1_I/J/K ✓")

# ── 6c) 残留 '||'（字符串内）→ \n 转义 ──
cnt_files = cnt = 0
for d in ["数据脚本/事件效果", "数据脚本/事件定义"]:
    for n in sorted(os.listdir(os.path.join(ROOT, d))):
        if not n.endswith(".gd"):
            continue
        p = os.path.join(d, n)
        t = rd(p)
        c = t.count("||")
        if c:
            t = t.replace("||", BS + "n")
            wr(p, t)
            cnt_files += 1
            cnt += c
print("|| 转义: %d 文件 / %d 处" % (cnt_files, cnt))
