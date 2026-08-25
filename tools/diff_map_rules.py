# -*- coding: utf-8 -*-
"""原版地图规则 ↔ Godot 规则表 对照检查。

用法：
    python tools/diff_map_rules.py

强制保证：
  1. tools/generated/original_map_rules.json（从逆向 C# Repaint() 提取的规格）
     中每一条规则，必须在 tools/generated/map_rules_manifest.json 登记，
     且 status 为四种合法值之一。
  2. manifest 中登记的 cs_line 必须真实存在于最新提取结果
     （防止提取更新后 manifest 陈旧）。
  3. status=pending_decision 的条目不阻塞 CI，但持续打印曝光，
     直到负责人拍板改成 matched / divergent_equivalent / display_only。

退出码：存在未登记/陈旧条目时为 1。
"""

import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
GEN_DIR = os.path.join(HERE, "generated")
SPEC_PATH = os.path.join(GEN_DIR, "original_map_rules.json")
MANIFEST_PATH = os.path.join(GEN_DIR, "map_rules_manifest.json")

VALID_STATUS = {"matched", "divergent_equivalent", "display_only", "pending_decision"}


def load(path):
    with io.open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def main():
    spec = load(SPEC_PATH)
    manifest = load(MANIFEST_PATH)

    generated_ids = {"repaint:%d" % r["cs_line"] for r in spec["rules"]}
    registered = {}
    errors = []
    pending = []

    for entry in manifest.get("rules", []):
        rid = entry.get("id")
        status = entry.get("status")
        if rid in registered:
            errors.append("manifest 中 id 重复: %s" % rid)
            continue
        registered[rid] = entry
        if status not in VALID_STATUS:
            errors.append("%s 非法 status: %r" % (rid, status))
        elif status == "pending_decision":
            pending.append(entry)

    unregistered = sorted(generated_ids - set(registered))
    stale = sorted(set(registered) - generated_ids - {"repaint:0"})  # repaint:0 允许不存在

    for rid in unregistered:
        errors.append("原版规则 %s 未在 manifest 登记 —— 存在无人知晓的领土规则" % rid)
    for rid in stale:
        errors.append("manifest 条目 %s 在最新提取结果中已不存在（提取更新后未同步）" % rid)

    print("=" * 72)
    print("原版地图规则对照报告")
    print("=" * 72)
    print("提取规则总数: %d   已登记: %d" % (len(generated_ids), len(generated_ids & set(registered))))
    cov = 100.0 * (len(generated_ids) - len(unregistered)) / max(len(generated_ids), 1)
    print("登记覆盖率: %.1f%%" % cov)
    if pending:
        print("")
        print("[待决策] %d 条（不阻塞，但请尽快拍板）:" % len(pending))
        for e in pending:
            print("  - %s  %s" % (e["id"], e.get("summary", "")[:60]))
    if errors:
        print("")
        print("[红灯] %d 条:" % len(errors))
        for msg in errors:
            print("  - %s" % msg)
    print("")
    print("结果: %s" % ("FAIL" if errors else "PASS"))
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
