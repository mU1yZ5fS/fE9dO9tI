# -*- coding: utf-8 -*-
"""第二批修复（CSV 侧）：501 R1_I/J/K 值纠正 + 全表 nbsp 清理。幂等。"""
import csv as _csv
import io

P = "资产/本地化/events_zh_CN.csv"
BS = chr(92)

with io.open(P, encoding="utf-8-sig", newline="") as f:
    rows = list(_csv.reader(f))

fixes = {
    "event.script.event_501_western_81_exercise.txt_r1_i":
        "共同检阅了解放军和民兵，并发表了讲话。",
    "event.script.event_501_western_81_exercise.txt_r1_j":
        "中国共产党中央军事委员会主席兼最高领导人",
    "event.script.event_501_western_81_exercise.txt_r1_k":
        "检阅了解放军和民兵，并发表了讲话。",
}
n_fix = n_nbsp = 0
for r in rows[1:]:
    if not r or len(r) < 2:
        continue
    k, v = r[0].strip(), r[1]
    if k in fixes and v != fixes[k]:
        r[1] = fixes[k]
        n_fix += 1
    if "\u00a0" in v:
        r[1] = v.replace("\u00a0", " ")
        n_nbsp += 1

with io.open(P, "w", encoding="utf-8", newline="") as f:
    w = _csv.writer(f)
    w.writerows(rows)
print("值修正:", n_fix, " nbsp 清理:", n_nbsp)
