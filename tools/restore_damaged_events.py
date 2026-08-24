# -*- coding: utf-8 -*-
"""恢复受损事件脚本：备份现场 -> 从 HEAD 还原 108 个解析损坏的文件。
后续由 reapply_fixes 重新套用本轮所有必要修改（迁移/文案/转义）。
"""

import io
import os
import shutil
import subprocess

ROOT = os.getcwd()
BACKUP = os.path.join(os.getcwd(), "_backup_corrupted_")


def read_bad():
    """从 check_out.txt 提取解析失败文件清单（res:// -> 相对路径）。"""
    import json
    bad, cur = [], None
    for l in io.open("check_out.txt", encoding="utf-8", errors="replace"):
        l = l.rstrip("\n")
        if l.startswith("CHECK "):
            cur = l[6:].replace("res://", "")
        elif ("Parse Error" in l or l.startswith("LOAD_NULL")) and cur:
            if cur not in bad:
                bad.append(cur)
    return bad


def main():
    bad = read_bad()
    print("待还原:", len(bad))

    # 1) 备份当前损坏现场（保留一切可能性）
    if os.path.exists(BACKUP):
        shutil.rmtree(BACKUP)
    os.makedirs(BACKUP)
    for rel in bad:
        p = os.path.join(ROOT, rel)
        dst = os.path.join(BACKUP, rel.replace("/", os.sep))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.exists(p):
            shutil.copy2(p, dst)
    # 备份当前 JSON 与本地化表
    for f in ["资产/数据/war_result_texts.json", "资产/本地化/events_zh_CN.csv"]:
        dst = os.path.join(BACKUP, f.replace("/", os.sep))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(os.path.join(ROOT, f), dst)
    print("备份完成 ->", BACKUP)

    # 2) 从 HEAD 还原
    env = dict(os.environ)
    r = subprocess.run(["git", "-c", "core.quotepath=false", "checkout",
                        "HEAD", "--"] + bad, cwd=ROOT, env=env,
                       capture_output=True)
    print("checkout exit=", r.returncode, r.stderr.decode("utf-8", "replace")[:200])


if __name__ == "__main__":
    main()
