# -*- coding: utf-8 -*-
"""精确撤销此前的"注释碎片合并"：凡插入块 == 删除块各行 strip 后空格连接，
即判定为合并产物，还原为删除块原样（多行）。其他差异不动。"""

import io
import os
import subprocess
import difflib

ROOT = os.getcwd()


def read_head(path):
    r = subprocess.run(["git", "-c", "core.quotepath=false", "show",
                        "HEAD:" + path], capture_output=True)
    return r.stdout.decode("utf-8")


def main():
    bad, cur = [], None
    for l in io.open("check_out.txt", encoding="utf-8", errors="replace"):
        l = l.rstrip("\n")
        if l.startswith("CHECK "):
            cur = l[6:].replace("res://", "")
        elif ("Parse Error" in l or l.startswith("LOAD_NULL")) and cur:
            if cur not in bad:
                bad.append(cur)

    undone = 0
    partial = []
    for rel in bad:
        p = os.path.join(ROOT, rel)
        if not os.path.exists(p):
            continue
        r = subprocess.run(["git", "-c", "core.quotepath=false", "show",
                            "HEAD:" + rel], capture_output=True)
        head = r.stdout.decode("utf-8")
        work = io.open(p, encoding="utf-8", newline="").read()
        hl = [x.rstrip("\r") for x in head.split("\n")]
        wl = [x.rstrip("\r") for x in work.split("\n")]
        sm = difflib.SequenceMatcher(None, hl, wl, autojunk=False)
        out = []
        n_undo = 0
        pending_undo = None
        for tag, i1, i2, j1, j2 in sm.get_opcodes():
            rem = hl[i1:i2]
            ins = wl[j1:j2]
            if pending_undo is not None:
                # 检查当前插入行是否是待还原删除块的延续
                if tag == "equal":
                    pass
            if tag != "replace":
                out.extend(rem if tag in ("delete", "equal") else ins)
                continue
            # 尝试两种还原：
            #  R1) 合并型：ins(1..N 行) == ' '.join(strip(rem)) 单行
            #  R2) 拆分型：ins == rem.replace('||','\n') 拆行（上轮 || 损坏）
            ins_join = " ".join(x.strip() for x in ins)
            rem_join_space = " ".join(x.strip() for x in rem)
            rem_nl = "\n".join(rem)
            ins_nl = "\n".join(ins)
            if len(ins) == 1 and ins_join == rem_join_space and \
                    any("#" in x for x in rem):
                out.extend(rem)
                n_undo += 1
            elif ins_nl == rem_nl.replace("||", "\n") or \
                    ins_nl.replace("\r", "") == rem_nl.replace("||", "\n"):
                out.extend(rem)
                n_undo += 1
            else:
                out.extend(ins)
        if n_undo:
            io.open(p, "w", encoding="utf-8", newline="").write("\n".join(wl[:0]) + "\n".join(out))
            undone += 1
            if n_undo > 0:
                pass
        else:
            partial.append(rel)
    print("完全撤销文件:", undone, " 未匹配需后续处理:", len(partial))


if __name__ == "__main__":
    main()
