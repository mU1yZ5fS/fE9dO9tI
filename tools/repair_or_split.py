# -*- coding: utf-8 -*-
"""逆向修复：把被 '||'→真实换行 拆开的行还原回原样。

原理：对每个受损文件做 git diff（工作区 vs HEAD）。
凡删除块中的行包含 '||'，且其内容与插入块各行拼接后一致
（即 插入=删除行.replace('||','\n') 的结果），判定为本次损坏，
直接还原为 HEAD 原文（保留 '||' 原字面）。其他差异一律不动。
"""

import io
import os
import subprocess
import difflib

ROOT = os.getcwd()


def read_head(path):
    r = subprocess.run(["git", "-c", "core.quotepath=false", "show",
                        "HEAD:" + path], capture_output=True)
    return r.stdout.decode("utf-8")


def worktree(path):
    return io.open(path, encoding="utf-8", newline="").read()


def main():
    # 受损文件清单来自 check_all_scripts 输出
    bad = []
    cur = None
    for l in io.open("check_out.txt", encoding="utf-8", errors="replace"):
        l = l.rstrip("\n")
        if l.startswith("CHECK "):
            cur = l[6:]
        elif "Parse Error" in l and cur:
            rel = cur.replace("res://", "")
            if rel not in bad:
                bad.append(rel)
    print("受损文件:", len(bad))

    repaired = 0
    unchanged = []
    for rel in bad:
        p = os.path.join(ROOT, rel)
        head = read_head(rel)
        work = worktree(p)
        if "||" not in head:
            unchanged.append((rel, "HEAD 无 ||"))
            continue
        head_l = [x.rstrip("\r") for x in head.split("\n")]
        work_l = [x.rstrip("\r") for x in work.split("\n")]
        sm = difflib.SequenceMatcher(None, head_l, work_l, autojunk=False)
        out = []
        ok = True
        for tag, i1, i2, j1, j2 in sm.get_opcodes():
            if tag == "equal":
                out.extend(head_l[i1:i2])
                continue
            rem = head_l[i1:i2]
            ins = work_l[j1:j2]
            # 尝试判定：删除块整体替换 '||'->'\n' 后是否等于插入块拼接
            rem_joined = "\n".join(x.replace("||", "\n") for x in rem)
            ins_joined = "\n".join(ins)
            if rem_joined.rstrip("\n") == ins_joined.rstrip("\n") or \
               rem_joined == ins_joined:
                out.extend(rem)          # 还原 HEAD 原文
                continue
            # 无法判定的差异块：保守保留工作区现状
            ok = False
            out.extend(ins)
        if ok:
            io.open(p, "w", encoding="utf-8", newline="").write("\n".join(out))
            repaired += 1
        else:
            unchanged.append((rel, "存在非 || 类差异，需人工"))
    print("已还原:", repaired)
    for u in unchanged:
        print("  待人工:", u)


if __name__ == "__main__":
    main()
