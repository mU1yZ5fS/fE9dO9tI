# -*- coding: utf-8 -*-
"""从逆向 C# 提取"地图归属重映射规格"。

用法：
    python tools/extract_original_map_rules.py \
        --cs "F:/work/毛的遗产改版逆向工程测试/改版最新完整逆向_语义还原/Assets/Scripts/CountryScript.cs" \
        --out tools/generated/original_map_rules.json

原理：
  原版的地图合并规则全部集中在 CountryScript.Repaint()：
  每个 56 国地图对象每次重绘时按世界状态改写 this.this_number（10<->46、38->1、
  111->49……），再按阵营旗标着色。因此 Repaint() 的重映射分支就是原版领土规则的
  完整规格。本脚本用行级括号状态机提取每个 `this.this_number = N;` 赋值点的
  守卫条件链，生成机器可 diff 的 JSON 规格。

产物提交进仓库（tools/generated/original_map_rules.json），
CI 只跑 tools/diff_map_rules.py 做对照，不需要访问逆向目录。
"""

import argparse
import io
import json
import os
import re
from datetime import datetime, timezone

RE_ASSIGN = re.compile(r"this\.this_number\s*=\s*(-?\d+)\s*;")
RE_IF = re.compile(r"^\s*(?:else\s+)?if\s*\((.+)\)\s*(\{\s*)?$")
RE_ELSEIF = re.compile(r"^\s*else\s+if\s*\((.+)\)\s*(\{\s*)?$")
RE_ELSE = re.compile(r"^\s*else\s*(\{\s*)?$")
RE_CLOSE = re.compile(r"^\s*\}\s*$")
RE_OPEN = re.compile(r"^\s*\{\s*$")
RE_METHOD_START = re.compile(r"^\s*public\s+void\s+Repaint\(\)\s*$")

# 从守卫文本中提取人类可读摘要：data[83]==2 / parts[0] / completedDecisions[7] ...
RE_DATA = re.compile(r"data\[(\d+)\]\s*(==|>=|<=|>|<)\s*(-?\w+)")
RE_PARTS = re.compile(r"allcountries\[(\d+)\]\.parts\[(\d+)\]")
RE_DECISION = re.compile(r"completedDecisions\[(\d+)\]")
RE_EVENT_DONE = re.compile(r"(?:!|not\s+)event_done\[(\d+)\]|event_done\[(\d+)\]")
RE_SELF_EQ = re.compile(r"this\.this_number\s*==\s*(-?\d+)")


def summarize_condition(cond):
    """把 C# 条件表达式压成短摘要，供人审与 diff 展示。"""
    parts = []
    neg = cond.strip().startswith("!")
    for m in RE_DATA.finditer(cond):
        parts.append("data[%s]%s%s" % (m.group(1), m.group(2), m.group(3)))
    for m in RE_PARTS.finditer(cond):
        parts.append("country[%s].parts[%s]" % (m.group(1), m.group(2)))
    for m in RE_DECISION.finditer(cond):
        parts.append("completedDecisions[%s]" % m.group(1))
    for m in RE_EVENT_DONE.finditer(cond):
        g = m.group(1) or m.group(2)
        if g:
            prefix = "!" if "!" in m.group(0)[:m.start(1) or 1] or cond.strip().startswith("!") else ""
            parts.append("%sevent_done[%s]" % (prefix, g))
    if not parts:
        for m in RE_SELF_EQ.finditer(cond):
            parts.append("this_number==%s" % m.group(1))
    text = " AND ".join(parts) if parts else re.sub(r"\s+", " ", cond).strip()
    return ("NOT " + text) if (neg and not text.startswith("NOT ")) else text


def extract_method_lines(lines, start_re):
    """定位方法起始行并按大括号配平返回方法体行号区间 [start, end]。"""
    start = None
    for i, ln in enumerate(lines):
        if start_re.match(ln):
            start = i
            break
    if start is None:
        return None, None
    depth = 0
    opened = False
    for i in range(start, len(lines)):
        depth += lines[i].count("{") - lines[i].count("}")
        if "{" in lines[i]:
            opened = True
        if opened and depth <= 0:
            return start, i
    return start, len(lines) - 1


def extract_repaint_rules(cs_path):
    with io.open(cs_path, "r", encoding="utf-8", errors="replace") as f:
        lines = f.read().splitlines()

    s, e = extract_method_lines(lines, RE_METHOD_START)
    if s is None:
        raise SystemExit("未找到 public void Repaint()")

    rules = []
    guard_stack = []          # [(kind, raw_cond_or_None)]
    pending_else_depth = None

    for i in range(s, e + 1):
        raw = lines[i]
        stripped = raw.strip()
        line_no = i + 1

        # 赋值点：记录当前守卫链快照
        m = RE_ASSIGN.search(stripped)
        if m and not stripped.startswith("//"):
            guards = []
            from_hint = None
            for kind, cond in guard_stack:
                if kind == "close":
                    continue
                summ = summarize_condition(cond) if cond else "ELSE"
                guards.append(summ)
                fm = RE_SELF_EQ.search(cond or "")
                if fm:
                    from_hint = int(fm.group(1))
            rules.append({
                "cs_line": line_no,
                "to": int(m.group(1)),
                "from_hint": from_hint,
                "guards": guards,
                "raw_guards": [c for _, c in guard_stack if c],
            })

        # 括号/条件栈维护
        if RE_OPEN.match(stripped):
            continue
        if RE_CLOSE.match(stripped):
            if guard_stack:
                guard_stack.pop()
            continue

        m_elif = RE_ELSEIF.match(stripped)
        if m_elif:
            if guard_stack:
                guard_stack.pop()      # else-if 与前一 if 同层
            guard_stack.append(("elseif", m_elif.group(1)))
            continue

        m_if = RE_IF.match(stripped)
        if m_if:
            guard_stack.append(("if", m_if.group(1)))
            continue

        if RE_ELSE.match(stripped):
            if guard_stack:
                guard_stack.pop()
            guard_stack.append(("else", None))
            continue

        # 单行内联块兜底：`if (x) { y; }`
        inline = re.match(r"^(?:else\s+)?if\s*\((.+)\)\s*\{.*\}\s*,?\s*$", stripped)
        if inline:
            rules_snapshot = list(guard_stack)
            guard_stack.append(("inline", inline.group(1)))
            am = RE_ASSIGN.search(stripped)
            _ = am, rules_snapshot
            guard_stack.pop()

    return {"method_start_line": s + 1, "method_end_line": e + 1, "rules": rules}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cs", required=True, help="CountryScript.cs 路径")
    ap.add_argument("--out", default=os.path.join("tools", "generated", "original_map_rules.json"))
    args = ap.parse_args()

    result = extract_repaint_rules(args.cs)

    out = {
        "_readme": [
            "由 tools/extract_original_map_rules.py 自动生成，勿手改。",
            "来源: CountryScript.cs Repaint() —— 原版地图归属重映射的完整规格。",
            "guards 为人审用的条件链摘要（AND 连接；'ELSE' 表示走 else 分支）；",
            "精确语义以 cs_line 行号回查源码为准。",
            "注意: ShowParts() 的 parts 覆盖层对象名在场景文件里，无法静态提取，",
            "(legacy, part) 组合的对照仍需人工维护 manifest。",
        ],
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source_file": os.path.basename(args.cs),
        "repaint_span": [result["method_start_line"], result["method_end_line"]],
        "rule_count": len(result["rules"]),
        "rules": result["rules"],
    }

    os.makedirs(os.path.dirname(args.out) or ".", exist_ok=True)
    with io.open(args.out, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
    print("extracted %d remap rules -> %s" % (len(result["rules"]), args.out))


if __name__ == "__main__":
    main()
