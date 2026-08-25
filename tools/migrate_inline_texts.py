# -*- coding: utf-8 -*-
"""内联硬编码文案迁移工具：把 .gd 里 const 的中文长文本搬进本地化 CSV。

用法（项目根目录）：
    python tools/migrate_inline_texts.py --dry-run    # 只打印计划，不改文件
    python tools/migrate_inline_texts.py              # 执行迁移

规则：
  - 仅处理 数据脚本/事件效果 与 数据脚本/事件定义 下的 const 字符串
  - 值含 CJK 且不以 event.script. 开头才算硬编码文案
  - 名字符合 TXT_* 惯例的长度>=2 即收；其余名字长度>=10 才收（避免误伤逻辑标签）
  - 生成的键：event.script.<文件名去 event_NNN_ 前缀>.<const小写>
  - 同文件内所有裸引用自动包 tr()（已包的不重复）
  - CSV 追加到表尾；GDScript 转义（\\n \\t \\" \\\\）入表前还原为真实字符
"""

import argparse
import csv
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(ROOT, "资产", "本地化", "events_zh_CN.csv")
SCAN_DIRS = ["数据脚本/事件效果", "数据脚本/事件定义"]

RE_CJK = re.compile(r"[\u3400-\u9fff]")

# 两组模式分别匹配单引号串与三引号串（re.S 让 . 跨行）
RE_STR1 = re.compile(r'"(?P<sval>(?:\\.|[^"\\])*)"')
RE_STR3 = re.compile(r'"""(?P<tval>(?:(?:"""))[\s\S]*?)"""')

RE_DECL = re.compile(
    r"const\s+(?P<name>[A-Z][A-Za-z0-9_]*)\s*(?::\s*String\s*)?"
    r"(?P<assign>:=|=)\s*"
    r'(?P<q>"""|")'
)

GD_ESCAPES = [("\\n", "\n"), ('\\"', '"'), ("\\t", "\t"), ("\\\\", "\\")]


def gd_unescape(s):
    for a, b in GD_ESCAPES:
        s = s.replace(a, b)
    return s


def find_declarations(text):
    """返回 [{name, span, val}]，span 覆盖整个声明（const … 结束引号）。"""
    out = []
    for m in RE_DECL.finditer(text):
        name = m.group("name")
        q = m.group("q")
        if q == '"""':
            end = text.find('"""', m.end())
            if end < 0:
                continue
            val = text[m.end():end]
            span = (m.start(), end + 3)
        else:
            m2 = RE_STR1.match(text, m.end() - 1)
            if not m2:
                continue
            val = m2.group("sval")
            span = (m.start(), m2.end())
        out.append({"name": name, "span": span, "val": gd_unescape(val)})
    return out


def should_migrate(name, val):
    v = val.strip()
    if v.startswith("event.script.") or v.startswith("res://") or v.startswith("uid://"):
        return False
    if not RE_CJK.search(v):
        return False
    if name.upper().startswith("TXT_"):
        return len(v) >= 2
    return len(v) >= 10


def wrap_usages(text, name):
    out = []
    pos = 0
    count = 0
    pat = re.compile(r"(?<![A-Za-z0-9_])" + name + r"(?![A-Za-z0-9_])")
    decl_pat = re.compile(r"\bconst\s+$")
    while True:
        m = pat.search(text, pos)
        if not m:
            out.append(text[pos:])
            break
        line_start = text.rfind("\n", 0, m.start()) + 1
        # 声明行：名字紧跟在 “const ” 后面
        if decl_pat.search(text[line_start:m.start()]):
            out.append(text[pos:m.end()])
            pos = m.end()
            continue
        if text[max(0, m.start() - 3):m.start()].endswith(("tr(", "_t(")):
            out.append(text[pos:m.end()])
            pos = m.end()
            continue
        out.append(text[pos:m.start()])
        out.append("tr(" + name + ")")
        count += 1
        pos = m.end()
    return "".join(out), count


def load_rows():
    with io.open(CSV_PATH, "r", encoding="utf-8-sig", newline="") as f:
        return list(csv.reader(f))


def save_rows(rows):
    with io.open(CSV_PATH, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerows(rows)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    rows = load_rows()
    keys = {r[0].strip() for r in rows[1:] if r and r[0].strip()}
    taken = set(keys)
    plan, file_new_text = [], {}

    for d in SCAN_DIRS:
        full = os.path.join(ROOT, d)
        for n in sorted(os.listdir(full)):
            if not n.endswith(".gd"):
                continue
            path = os.path.join(full, n)
            with io.open(path, "r", encoding="utf-8") as f:
                text = f.read()
            decls = find_declarations(text)
            mig = [x for x in decls if should_migrate(x["name"], x["val"])]
            if not mig:
                continue
            base = n[:-3]  # 保留完整文件名（含事件号），与既有 CSV 键约定一致
            # 从后往前替换声明，避免 span 失效
            for x in reversed(mig):
                key = "event.script.%s.%s" % (base, x["name"].lower())
                if key in keys:
                    x["key"] = key          # 复用既有键（内容同源）
                    continue
                k = key
                i = 2
                while k in taken:
                    k = "%s_%d" % (key, i)
                    i += 1
                taken.add(k)
                x["key"] = k
                s, e = x["span"]
                text = text[:s] + 'const %s := "%s"' % (x["name"], k) + text[e:]
            # 包引用
            total_wrapped = 0
            for x in mig:
                text, c = wrap_usages(text, x["name"])
                total_wrapped += c
            file_new_text[path] = text
            for x in reversed(mig):
                plan.append((d + "/" + n, x["name"], x["key"], total_wrapped,
                             x["val"]))
    plan.reverse()  # 恢复阅读顺序

    print("待迁移条目: %d" % len(plan))
    for rel, name, key, wrapped, val in plan[:50]:
        print("  %-46s %-12s wraps=%-2d %s…" % (rel.split("/")[-1], name, wrapped,
              val.strip().replace("\n", " ")[:40]))
    if len(plan) > 50:
        print("  … 其余 %d 条略" % (len(plan) - 50))

    if args.dry_run:
        print("\n(dry-run，未写入)")
        return

    for path, txt in file_new_text.items():
        io.open(path, "w", encoding="utf-8").write(txt)
    added = [[p[2], p[4]] for p in plan if p[2] not in keys]
    rows.extend(added)
    save_rows(rows)
    print("\n已写入 %d 个文件、新增 %d 行 CSV（复用既有键 %d）"
          % (len(file_new_text), len(added), len(plan) - len(added)))


if __name__ == "__main__":
    main()
