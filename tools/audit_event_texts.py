# -*- coding: utf-8 -*-
"""事件本地化审计：找出"代码引用了但 CSV 里没有"的键 + 占位/可疑文案。

用法（项目根目录）：
    python tools/audit_event_texts.py            # 汇总报告
    python tools/audit_event_texts.py --detail   # 逐条列出缺失键

检查内容：
  1. 数据脚本/事件效果/*.gd 与 数据脚本/事件定义/*.gd 中引用的
     `event.script.<name>.<key>` 键是否存在于 资产/本地化/events_zh_CN.csv
  2. CSV 中值为空、与键相同、或疑似占位符（TODO/FIXME/待补）的条目
  3. .gd 内联文本中的残留转义序列（\\uXXXX）——会在游戏里原样显示或变成 nbsp
"""

import argparse
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(ROOT, "资产", "本地化", "events_zh_CN.csv")
SCAN_DIRS = [
    os.path.join(ROOT, "数据脚本", "事件效果"),
    os.path.join(ROOT, "数据脚本", "事件定义"),
]

RE_KEY = re.compile(r'event\.script\.[A-Za-z0-9_.]+')
RE_UESCAPE = re.compile(r'\\u[0-9a-fA-F]{4}')
PLACEHOLDER_HINTS = ("todo", "fixme", "待补", "占位", "placeholder", "tbd")


def list_gd_files(directory):
    """glob 在本机对非 ASCII 路径失效，用 listdir 兜底。"""
    try:
        names = os.listdir(directory)
    except FileNotFoundError:
        return []
    return [os.path.join(directory, n) for n in sorted(names) if n.endswith(".gd")]


def load_csv_keys():
    """返回 (keys:set, empty_keys:set, placeholder_keys:set)。容忍引号内换行的标准 CSV。"""
    import csv as _csv
    keys, empty, ph = set(), set(), set()
    with io.open(CSV_PATH, "r", encoding="utf-8-sig", newline="") as f:
        reader = _csv.reader(f)
        header = next(reader, None)
        for row in reader:
            if not row or not row[0].strip():
                continue
            k = row[0].strip()
            v = row[1].strip() if len(row) > 1 else ""
            keys.add(k)
            if v == "":
                empty.add(k)
            elif v.lower() in PLACEHOLDER_HINTS or k.strip().lower() == v.lower():
                ph.add(k)
            else:
                low = v.lower()
                if any(h in low for h in PLACEHOLDER_HINTS) and len(v) < 30:
                    ph.add(k)
    return keys, empty, ph


def scan_gd_references():
    """扫描 gd 源码里引用的 event.script.* 键 -> {key: [出处]}"""
    refs = {}
    for d in SCAN_DIRS:
        for path in list_gd_files(d):
            with io.open(path, "r", encoding="utf-8") as f:
                text = f.read()
            rel = os.path.relpath(path, ROOT)
            for m in RE_KEY.finditer(text):
                key = m.group(0).rstrip(".")
                refs.setdefault(key, []).append(rel)
    return refs


def scan_inline_escapes():
    """找内联文本里的 \\uXXXX 转义残留"""
    hits = []
    for path in list_gd_files(SCAN_DIRS[0]):
        with io.open(path, "r", encoding="utf-8") as f:
            for i, line in enumerate(f, 1):
                if RE_UESCAPE.search(line):
                    hits.append((os.path.relpath(path, ROOT), i, line.strip()[:80]))
    return hits


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--detail", action="store_true")
    args = ap.parse_args()

    keys, empty, ph = load_csv_keys()
    refs = scan_gd_references()
    escapes = scan_inline_escapes()

    missing = sorted(k for k in refs if k not in keys)

    print("=" * 72)
    print("事件本地化审计")
    print("=" * 72)
    print("CSV 条目: %d   代码引用的 script 键: %d (涉及文件见 --detail)" % (len(keys), len(refs)))
    print("")
    print("[缺失] 代码引用但 CSV 无此键: %d 个" % len(missing))
    by_event = {}
    for k in missing:
        ev = k.split(".")[2] if k.count(".") >= 3 else "?"
        by_event.setdefault(ev, []).append(k)
    for ev in sorted(by_event):
        print("  - %s: 缺 %d 键 %s" % (ev, len(by_event[ev]),
              ("如 " + ", ".join(sorted(by_event[ev])[:3]) + ("…" if len(by_event[ev]) > 3 else ""))))
    print("")
    print("[空值] CSV 存在但值为空: %d 个" % len(empty))
    print("[占位?] 疑似占位/待补: %d 个" % len(ph))
    for k in sorted(ph)[:10]:
        print("  -", k)
    print("")
    print("[转义] .gd 内联文本含 \\uXXXX 转义残留: %d 处" % len(escapes))
    for rel, ln, frag in escapes[:15]:
        print("  - %s:%d  %s" % (rel, ln, frag))

    if args.detail and missing:
        print("")
        print("── 全部缺失键 ──")
        for k in missing:
            print("  %s    <- %s" % (k, refs[k][0]))

    verdict = "PASS" if not (missing or empty or escapes) else "FAIL"
    print("")
    print("结果: %s (missing=%d, empty=%d, escape=%d)"
          % (verdict, len(missing), len(empty), len(escapes)))
    sys.exit(0 if verdict == "PASS" else 1)


if __name__ == "__main__":
    main()
