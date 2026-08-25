# -*- coding: utf-8 -*-
"""修复注释断裂：把被错误拆分的注释碎片行合并回上一条注释。

规则：
  - 上一输出行为注释（strip 后以 # 开头）
  - 当前行不是明显代码（不以 func/var/const/if/elif/else/for/while/return/
    match/extends/@/class/print/push_/pass/break/continue 等开头）
  满足则把当前行并入上一注释行（空格连接）。
"""

import io
import os
import sys

CODE_START = (
    "func ", "var ", "const ", "if ", "elif ", "else", "for ", "while ",
    "return", "match ", "extends ", "@", "class ", "print", "push_", "pass",
    "break", "continue", "preload", "assert ",
)

BAD_FILES = []


def load_bad(path="check_out.txt"):
    bad, cur = [], None
    for l in io.open(path, encoding="utf-8", errors="replace"):
        l = l.rstrip("\n")
        if l.startswith("CHECK "):
            cur = l[6:].replace("res://", "")
        elif ("Parse Error" in l or l.startswith("LOAD_NULL")) and cur:
            if rel_norm(cur) not in bad:
                bad.append(rel_norm(cur))
    return bad


def rel_norm(p):
    return p


def looks_like_code(s):
    st = s.lstrip()
    return any(st.startswith(k) for k in CODE_START)


def fix_file(p):
    t = io.open(p, encoding="utf-8", newline="").read()
    nl = "\r\n" if "\r\n" in t else "\n"
    lines = t.split(nl)
    out = []
    merged = 0
    for ln in lines:
        prev_is_comment = bool(out) and out[-1].lstrip().startswith("#")
        cur_stripped = ln.strip()
        if (prev_is_comment and cur_stripped != ""
                and not looks_like_code(cur_stripped)):
            out[-1] = out[-1].rstrip() + " " + cur_stripped
            merged += 1
            continue
        out.append(ln)
    if merged:
        io.open(p, "w", encoding="utf-8", newline="").write(nl.join(out))
    return merged


def main():
    bad = load_bad()
    print("待处理文件:", len(bad))
    total = 0
    touched = 0
    for rel in bad:
        if not os.path.exists(rel):
            continue
        m = fix_file(rel)
        if m:
            touched += 1
            total += m
    print("合并注释碎片 %d 处 / 触及 %d 文件" % (total, touched))


if __name__ == "__main__":
    main()
