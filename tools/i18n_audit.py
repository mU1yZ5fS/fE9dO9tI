# -*- coding: utf-8 -*-
"""多语言(i18n)覆盖审计：统计尚未接入本地化键值的中文文案。

用法：
    python tools/i18n_audit.py            # 按区域汇总
    python tools/i18n_audit.py --top 30   # 每区列出最多的前 N 个文件

判定：
  - .gd：抽取字符串字面量（含三引号），值含 CJK 即计为"中文串"；
    其中以 event.script. 开头的是键引用（已本地化），不计；
    长度<2 的纯符号忽略。
  - .tres/.json：扫描常见单语字段（name_zh / text_zh / desc 等）或任意含 CJK 的字符串值。
  - .tscn：text = "..." 属性含 CJK。
输出按 目录/类别 汇总量级，并列 Top 文件，用于排期。
"""

import argparse
import io
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RE_CJK = re.compile(r"[\u3400-\u9fff]")
RE_STR1 = re.compile(r'"(?:\\.|[^"\\])*"')
RE_STR3 = re.compile(r'"""[\s\S]*?"""')
RE_DECL_KEY = re.compile(r"event\.script\.")
RE_TSCN_TEXT = re.compile(r'^(\w+) = "(.*)"$', re.M)

GD_DIRS = [
    "数据脚本",
    "场景",
    "tools",
]
DATA_FILES = [
    "资产/数据/war_result_texts.json",
    "资产/数据/初始/country_identity.json",
]
DATA_DIRS = ["资产/数据", "资产/地图"]


def iter_files(ext, dirs):
    for d in dirs:
        full = os.path.join(ROOT, d)
        if not os.path.isdir(full):
            continue
        for base, _dirs, files in os.walk(full):
            # 跳过生成物
            if ".godot" in base:
                continue
            for n in files:
                if n.endswith(ext) and not n.endswith(".uid"):
                    yield os.path.join(base, n)


def gd_scan(path):
    """返回 (n_cjk_literals, n_chars_cjk, n_keys)。"""
    t = io.open(path, encoding="utf-8").read()
    n_lit = n_keys = 0
    cjk_chars = 0
    for m in RE_STR3.finditer(t):
        v = m.group(0)[3:-3]
        if RE_CJK.search(v):
            n_lit += 1
            cjk_chars += len(v)
    for m in RE_STR1.finditer(t):
        v = m.group(0)[1:-1]
        if not RE_CJK.search(v):
            continue
        if RE_DECL_KEY.match(v.lstrip()) or v.startswith("res://"):
            n_keys += 1
            continue
        n_lit += 1
        cjk_chars += len(v)
    return n_lit, cjk_chars, n_keys


def data_scan(path):
    """JSON/tres 中含 CJK 的字符串值数量（粗粒度）。"""
    t = io.open(path, encoding="utf-8").read()
    if path.endswith(".json"):
        try:
            d = json.loads(t)
        except Exception:  # noqa: BLE001
            return 0

        def walk(x):
            n = 0
            if isinstance(x, str):
                if RE_CJK.search(x):
                    n += 1
            elif isinstance(x, dict):
                for v in x.values():
                    n += walk(v)
            elif isinstance(x, list):
                for v in x:
                    n += walk(v)
            return n
        return walk(d)
    return sum(1 for m in RE_STR1.finditer(t) if RE_CJK.search(m.group(0)))


def tscn_scan(path):
    t = io.open(path, encoding="utf-8").read()
    return sum(1 for m in RE_TSCN_TEXT.finditer(t) if RE_CJK.search(m.group(2)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--top", type=int, default=8)
    args = ap.parse_args()

    groups = {}
    for path in iter_files(".gd", GD_DIRS):
        rel = os.path.relpath(path, ROOT).replace("\\", "/")
        lit, chars, _k = gd_scan(path)
        if not lit:
            continue
        if rel.startswith("数据脚本/事件效果"):
            g = "① 事件效果脚本"
        elif rel.startswith("数据脚本/事件定义"):
            g = "② 事件定义脚本"
        elif rel.startswith("场景/结局界面"):
            g = "⑥ 结局内容（NEW_TEXTS 常量表）"
        elif rel.startswith("数据脚本/systems"):
            g = "③ systems（战争结算等）"
        elif rel.startswith("场景"):
            g = "⑦ 场景/UI 脚本"
        else:
            g = "⑤ 其他 数据脚本"
        e = groups.setdefault(g, [0, 0, []])
        e[0] += lit
        e[1] += chars
        e[2].append((rel, lit))

    # 结局内容常量字典单独说明体量
    ending_chars = 0
    p = os.path.join(ROOT, "场景/结局界面/结局内容_基础.gd")
    if os.path.exists(p):
        ending_chars = len(RE_CJK.findall(io.open(p, encoding="utf-8").read()))

    print("=" * 74)
    print("多语言覆盖审计 —— 尚未键值化的中文字符串")
    print("=" * 74)
    grand = 0
    for g in sorted(groups):
        lit, chars, files = groups[g]
        grand += lit
        print("\n%s：%d 条 / 约 %d 字" % (g, lit, chars))
        for rel, lit in sorted(files, key=lambda x: -x[1])[: args.top]:
            print("   %5d  %s" % (lit, rel))
    print("\n合计 .gd 内未键值化中文串：%d 条" % grand)

    print("\n—— 单语数据文件 ——")
    for rel in DATA_FILES:
        p = os.path.join(ROOT, rel)
        if os.path.exists(p):
            print("  %s：CJK 值 %d 个（zh 单语）" % (rel, data_scan(p)))
    tres = list(iter_files(".tres", ["资产/数据"]))
    tj = [t for t in tres if data_scan(t)]
    print("  战争/事件 .tres 含中文的文件：%d / %d" % (len(tj), len(tres)))
    tscn = [(os.path.relpath(p, ROOT), tscn_scan(p)) for p in iter_files(".tscn", ["场景"])]
    tscn = [(r, c) for r, c in tscn if c]
    print("  场景 .tscn 内嵌中文 Label：%d 个文件 / %d 条" % (len(tscn), sum(c for _, c in tscn)))
    for r, c in sorted(tscn, key=lambda x: -x[1])[: args.top]:
        print("     %3d  %s" % (c, r))


if __name__ == "__main__":
    main()
