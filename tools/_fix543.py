# -*- coding: utf-8 -*-
"""一次性修复：event_543 内联文本中的 \\u00a0 转义残留。"""
import io

P = r"数据脚本/事件效果/event_543_eight_hundred_million_plays.gd"
t = io.open(P, encoding="utf-8").read()
needle = chr(92) + "u00a0"          # 字面反斜杠+u00a0
print("found:", t.count(needle))
t = t.replace(needle, " ")
# 压缩可能产生的双空格
while '"to  be' in t or 'be  or' in t:
    t = t.replace("to  be", "to be").replace("be  or", "be or").replace("not  to", "not to").replace("to  be\"", "to be\"")
old_frag = '“to be, or not to be”'
t2 = t.replace('“to be or not to be”', old_frag.replace(", or", ", or"))
io.open(P, "w", encoding="utf-8").write(t)
print("done; remaining:", t.count(needle))
