# -*- coding: utf-8 -*-
"""修复：字符串字面量内的真实换行 → 转义序列。

背景：此前用环境受限的方式批量替换 '||' 时，反斜杠被吞，
导致 \\n 以真实控制字符形式写入了 JSON 与 GDScript。

修复策略：
  - JSON：逐字符扫描，处于字符串内时把原始 \\r\\n / \\n / \\r / \\t 转义为 \\n、\\t。
  - GDScript：单引号字符串内不允许裸换行 → 同样转义；
    三引号字符串允许多行，保持原样不动。
"""

import io
import os
import sys


def fix_json_text(t):
    out = []
    in_str = False
    esc = False
    changed = 0
    for ch in t:
        if in_str:
            if esc:
                esc = False
                out.append(ch)
                continue
            if ch == "\\":
                esc = True
                out.append(ch)
                continue
            if ch == '"':
                in_str = False
                out.append(ch)
                continue
            if ch == "\n":
                out.append("\\n")
                changed += 1
                continue
            if ch == "\r":
                changed += 1
                continue  # 直接丢弃 \r（\n 已单独处理成对出现）
            out.append(ch)
        else:
            if ch == '"':
                in_str = True
            out.append(ch)
    return "".join(out), changed


def fix_gd_text(t):
    """三引号块原样保留；单引号字符串内的裸换行转义为 \\n。"""
    out = []
    i = 0
    n = len(t)
    in_triple = False
    in_str = False
    esc = False
    changed = 0
    while i < n:
        ch = t[i]
        if in_triple:
            if t.startswith('"""', i):
                in_triple = False
                out.append('"""')
                i += 3
                continue
            out.append(ch)
            i += 1
            continue
        if in_str:
            if esc:
                esc = False
                out.append(ch)
                i += 1
                continue
            if ch == "\\":
                esc = True
                out.append(ch)
                i += 1
                continue
            if ch == '"':
                in_str = False
                out.append(ch)
                i += 1
                continue
            if ch == "\r":
                i += 1
                continue
            if ch == "\n":
                out.append("\\n")
                changed += 1
                i += 1
                continue
            out.append(ch)
            i += 1
            continue
        # 普通代码区
        if t.startswith('"""', i):
            in_triple = True
            out.append('"""')
            i += 3
            continue
        if ch == '"':
            in_str = True
            out.append(ch)
            i += 1
            continue
        if ch == "#":  # 注释原样到行尾
            j = t.find("\n", i)
            j = n if j < 0 else j
            out.append(t[i:j])
            i = j
            continue
        out.append(ch)
        i += 1
    return "".join(out), changed


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "json"
    path = sys.argv[2]
    t = io.open(path, encoding="utf-8", newline="").read()
    if mode == "json":
        fixed, changed = fix_json_text(t)
    else:
        fixed, changed = fix_gd_text(t)
    io.open(path, "w", encoding="utf-8", newline="").write(fixed)
    print("%s: %s -> escaped %d newlines" % (mode, path, changed))


if __name__ == "__main__":
    main()
