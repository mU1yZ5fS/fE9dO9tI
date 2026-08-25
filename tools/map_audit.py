# -*- coding: utf-8 -*-
"""地图数据审计工具 —— 地图类玩家 bug 的静态防线。

用法（项目根目录）：
    python tools/map_audit.py            # 全量审计，发现 blocking 问题时退出码 1
    python tools/map_audit.py --json     # 机器可读输出（CI 用）
    python tools/map_audit.py --skip-png # 跳过 PNG 对账（低配 CI）

审计内容：
  1. 必需文件存在性、JSON 根类型
  2. map_regions / map_countries / map_actors 字段白名单
  3. map_neighbors 键集合 == map_regions 键集合（双向）
  4. 国家认领一致性：
     - countries.regions 引用的 region 必须存在
     - region.owner_1976_gwcode == 认领国家主键（白名单例外）
     - 一个 region 只能被一个国家认领
     - owner>0 的 region 必须有国家认领，且 owner 必须是 map_countries 主键
  5. country_identity.json：legacy_id → gwcode 映射有效性
  6. map_color.png 非零颜色集合 == map_regions 键集合（防烘焙漂移）
  7. 数据脚本/地图数据/*.gd 中硬编码的 region id / legacy id 存在性

处置分三级：
  approved  tools/map_audit_exceptions.json   故意的 1976 殖民/飞地状态，永久放行
  baseline  tools/map_audit_baseline.json     已知未修 bug 棘轮，修一个删一条；新增违规即红灯
  其余      blocking                          红灯
"""

import argparse
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MAP_DIR = os.path.join(ROOT, "资产", "地图")
INITIAL_DIR = os.path.join(ROOT, "资产", "数据", "初始")
GD_MAP_DIR = os.path.join(ROOT, "数据脚本", "地图数据")

EXCEPTIONS_PATH = os.path.join(ROOT, "tools", "map_audit_exceptions.json")
BASELINE_PATH = os.path.join(ROOT, "tools", "map_audit_baseline.json")

REGION_FIELDS = {"name", "name_zh", "owner_1976_gwcode", "is_water", "longitude", "latitude"}
COUNTRY_FIELDS = {"name_1976", "name_zh", "gov_names", "regions"}
ACTOR_FIELDS = {"name_1976", "name_zh", "gov_names", "regions"}

FICTIONAL_OFFSET = 9000
FICTIONAL_MAX = 9200


class Report:
    def __init__(self):
        self.blocking = []          # (code, message)
        self.approved = []          # 命中白名单，仅计数展示
        self.baselined = []         # 命中基线（已知未修），提示收敛

    def block(self, code, msg):
        self.blocking.append((code, msg))

    def approve(self, code, msg):
        self.approved.append((code, msg))

    def ratchet(self, code, msg):
        self.baselined.append((code, msg))


def load_json(path):
    try:
        with io.open(path, "r", encoding="utf-8") as f:
            return json.load(f), None
    except FileNotFoundError:
        return None, "文件不存在"
    except Exception as e:  # noqa: BLE001
        return None, "解析失败: %s" % e


def load_two_tier_lists():
    """返回 (approved_set, baseline_set)。两个文件都容忍缺失。"""
    def load_set(path):
        data, err = load_json(path)
        if err or not isinstance(data, dict):
            return set()
        entries = data.get("entries", [])
        keys = set()
        for e in entries:
            if isinstance(e, dict) and "key" in e:
                keys.add(e["key"])
            elif isinstance(e, str):
                keys.add(e)
        return keys

    return load_set(EXCEPTIONS_PATH), load_set(BASELINE_PATH)


def classify(rep, key, code, msg, approved, baseline):
    """按 白名单→基线→红灯 的顺序归类一条发现。"""
    _classify_keys([key], code, msg, approved, baseline, rep)


def classify_multi(rep, keys, code, msg, approved, baseline):
    """同上，但任一候选 key 命中白名单/基线即按该级归类（用于方向无关的认领检查）。"""
    _classify_keys(keys, code, msg, approved, baseline, rep)


def _classify_keys(keys, code, msg, approved, baseline, rep):
    for k in keys:
        if k in approved:
            rep.approve(code, msg)
            return
    for k in keys:
        if k in baseline:
            rep.ratchet(code, msg)
            return
    rep.block(code, msg)


# ──────────────────────────── 各检查项 ────────────────────────────


def check_files(rep):
    required = [
        os.path.join(MAP_DIR, "map_meta.json"),
        os.path.join(MAP_DIR, "map_regions.json"),
        os.path.join(MAP_DIR, "map_countries.json"),
        os.path.join(MAP_DIR, "map_neighbors.json"),
        os.path.join(MAP_DIR, "map_actors.json"),
        os.path.join(MAP_DIR, "war_icon_anchors.json"),
        os.path.join(INITIAL_DIR, "country_identity.json"),
        os.path.join(MAP_DIR, "map_color.png"),
    ]
    for p in required:
        if not os.path.exists(p):
            rep.block("FILE_MISSING", os.path.relpath(p, ROOT))


def check_schema(rep, name, data, allowed):
    for key, entry in data.items():
        if not isinstance(entry, dict):
            rep.block("SCHEMA", "%s[%s] 不是对象" % (name, key))
            continue
        extra = set(entry.keys()) - allowed
        if extra:
            rep.block("SCHEMA", "%s[%s] 含白名单外字段 %s" % (name, key, sorted(extra)))


def check_claims(rep, regions, countries, approved, baseline):
    claim = {}
    for ck, c in countries.items():
        rids = c.get("regions", [])
        if not isinstance(rids, list) or not rids:
            rep.block("CLAIMS", "国家 %s 的 regions 为空或非法" % ck)
            continue
        for rid in rids:
            rs = str(rid)
            rr = regions.get(rs)
            key = "owner_mismatch:%s:%s" % (int(ck), int(rid))
            if rr is None:
                classify(rep, key, "CLAIMS",
                         "国家 %s 列出了不存在的 region %s" % (ck, rid),
                         approved, baseline)
            else:
                ow = int(rr["owner_1976_gwcode"])
                if ow != int(ck):
                    classify(rep, key, "CLAIMS",
                             "国家 %s(%s) 列出 region %s(%s)，但归属为 %s"
                             % (ck, str(c.get("name_zh", "?")), rid,
                                str(rr.get("name_zh", "?")), ow),
                             approved, baseline)
                claim.setdefault(int(rid), []).append(int(ck))

    for rid, owners in sorted(claim.items()):
        if len(owners) > 1:
            key = "double_claim:%d" % rid
            classify(rep, key, "CLAIMS",
                     "region %d 被多国认领 %s" % (rid, owners),
                     approved, baseline)

    country_ids = {int(k) for k in countries}
    for rk, rv in regions.items():
        rid = int(rk)
        ow = int(rv.get("owner_1976_gwcode", 0))
        if ow <= 0:
            continue
        # 正向孤儿：owner 不是合法国家键
        if ow not in country_ids and rid not in claim:
            key = "orphan_region:%d" % rid
            classify(rep, key, "CLAIMS",
                     "region %d(%s) 归属 %d 不在 map_countries 中，且无任何国家认领"
                     % (rid, str(rv.get("name_zh", "?")), ow),
                     approved, baseline)
        # 反向缺口：归属国存在但没有把该 region 列入自己的 regions。
        # 候选 key 同时包含正向（认领国视角）与反向（归属国视角），
        # 使殖民状态白名单对两个方向都生效。
        elif ow in country_ids and ow not in claim.get(rid, []):
            keys = ["owner_mismatch:%d:%d" % (ow, rid)]
            keys += ["owner_mismatch:%d:%d" % (c, rid) for c in claim.get(rid, [])]
            classify_multi(rep, keys, "CLAIMS",
                           "region %d(%s) 归属 %s(%s)，但该国 regions 未列出它"
                           % (rid, str(rv.get("name_zh", "?")), ow,
                              str(countries[str(ow)].get("name_zh", "?"))),
                           approved, baseline)


def check_identity(rep, identity, countries, approved, baseline):
    country_keys = set(countries.keys())
    for sid, gw in identity.items():
        gwi = int(gw)
        if FICTIONAL_OFFSET <= gwi <= FICTIONAL_MAX:
            continue
        key = "identity:%s" % sid
        if str(gwi) not in country_keys:
            classify(rep, key, "IDENTITY",
                     "country_identity: legacy %s -> gwcode %s 不存在于 map_countries" % (sid, gw),
                     approved, baseline)
    # 反向：map_countries 里每个真实 gwcode 至少要有一个 legacy 来源，
    # 否则运行时永远没有任何国家对象指向它（点击/合并都会落空）。
    mapped = {int(gw) for gw in identity.values() if int(gw) < FICTIONAL_OFFSET}
    for ck in country_keys:
        if int(ck) not in mapped:
            key = "identity_unmapped:%s" % ck
            classify(rep, key, "IDENTITY",
                     "gwcode %s(%s) 无任何 legacy 序号映射，地图事件无法引用该国"
                     % (ck, str(countries[ck].get("name_zh", "?"))),
                     approved, baseline)


def check_png(rep, regions, meta, skip_png, approved, baseline):
    png_path = os.path.join(MAP_DIR, "map_color.png")
    if skip_png:
        print("[skip] PNG 对账已跳过")
        return
    try:
        from PIL import Image
        Image.MAX_IMAGE_PIXELS = 1 << 28  # 底图 16384x8192 为已知可信资产
    except ImportError:
        print("[warn] 未安装 Pillow，跳过 PNG 对账（CI 请 pip install pillow）")
        return

    img = Image.open(png_path).convert("RGB")
    w, h = img.size
    colors = img.getcolors(maxcolors=1 << 24)
    if colors is None:
        rep.block("PNG", "底图颜色数超出预期上限，疑似烘焙污染")
        return
    present = set()
    for _count, rgb in colors:
        rid = (rgb[0] << 16) | (rgb[1] << 8) | rgb[2]
        if rid != 0:
            present.add(rid)

    declared = {int(k) for k in regions}
    for rid in sorted(declared - present):
        classify(rep, "png_missing:%d" % rid, "PNG",
                 "region %d 在 map_regions 中存在但底图上没有对应颜色" % rid,
                 approved, baseline)
    for rid in sorted(present - declared):
        classify(rep, "png_extra:%d" % rid, "PNG",
                 "region %d 在底图上存在但 map_regions 未声明" % rid,
                 approved, baseline)

    max_declared = max(declared) if declared else 0
    meta_max = int(meta.get("max_region_id", 0))
    if meta_max < max_declared:
        rep.block("META", "map_meta.max_region_id=%d 小于实际最大 id=%d" % (meta_max, max_declared))
    if (meta.get("width"), meta.get("height")) != (w, h):
        rep.block("META", "map_meta 尺寸 %sx%s 与底图 %dx%d 不一致"
                  % (meta.get("width"), meta.get("height"), w, h))


# ── gd 源码引用抽取 ──

RE_CONST_INT_ARRAY = re.compile(
    r"const\s+(\w+)\s*(?::\s*Array\[int\])?\s*:=?\s*\[([0-9\s,]+)\]", re.M)
RE_RULE_INLINE_ARRAY = re.compile(
    r"\"(regions|sources)\"\s*:\s*\[([0-9\s,\w.\+]+)\]")
RE_SET_REGION_OWNER = re.compile(r"set_region_owner\(\s*\[([0-9\s,]+)\)")
RE_MERGE_LEGACY = re.compile(r"_merge_legacy\(\s*w\s*,\s*(-?\w+)\s*,\s*(-?\w+)\s*\)")


def extract_gd_refs():
    """从 数据脚本/地图数据/*.gd 提取硬编码 region id 与 legacy id。"""
    region_refs = {}   # rid -> [出处]
    legacy_refs = {}   # idx -> [出处]

    def add(d, key, where):
        d.setdefault(key, []).append(where)

    for fname in sorted(os.listdir(GD_MAP_DIR)):
        if not fname.endswith(".gd"):
            continue
        path = os.path.join(GD_MAP_DIR, fname)
        with io.open(path, "r", encoding="utf-8") as f:
            text = f.read()
        rel = "数据脚本/地图数据/" + fname

        for m in RE_CONST_INT_ARRAY.finditer(text):
            line_no = text.count("\n", 0, m.start()) + 1
            for tok in m.group(2).split(","):
                tok = tok.strip()
                if tok.isdigit():
                    add(region_refs, int(tok), "%s:%d(%s)" % (rel, line_no, m.group(1)))

        for m in RE_RULE_INLINE_ARRAY.finditer(text):
            line_no = text.count("\n", 0, m.start()) + 1
            for tok in m.group(2).split(","):
                tok = tok.strip()
                if tok.isdigit():
                    add(region_refs, int(tok), "%s:%d(%s)" % (rel, line_no, m.group(1)))

        for m in RE_SET_REGION_OWNER.finditer(text):
            line_no = text.count("\n", 0, m.start()) + 1
            for tok in m.group(1).split(","):
                tok = tok.strip()
                if tok.isdigit():
                    add(region_refs, int(tok), "%s:%d(set_region_owner)" % (rel, line_no))

        for m in RE_MERGE_LEGACY.finditer(text):
            line_no = text.count("\n", 0, m.start()) + 1
            for tok in (m.group(1), m.group(2)):
                if tok.lstrip("-").isdigit():
                    add(legacy_refs, int(tok), "%s:%d(_merge_legacy)" % (rel, line_no))

    return region_refs, legacy_refs


def check_gd_refs(rep, regions, identity, approved, baseline):
    region_refs, legacy_refs = extract_gd_refs()
    known_regions = {int(k) for k in regions}
    identity_idx = {int(k) for k in identity}

    for rid in sorted(region_refs):
        if rid not in known_regions:
            key = "gd_region_ref:%d" % rid
            classify(rep, key, "GD_REF",
                     "脚本引用的 region id %d 不存在于 map_regions（%s）"
                     % (rid, ", ".join(region_refs[rid][:3])),
                     approved, baseline)

    for idx in sorted(legacy_refs):
        if idx <= 0:
            continue
        if idx not in identity_idx:
            key = "gd_legacy_ref:%d" % idx
            classify(rep, key, "GD_REF",
                     "脚本引用的 legacy 序号 %d 不在 country_identity（将落到 9000+ 虚拟国，地块转移必然无效）（%s）"
                     % (idx, ", ".join(legacy_refs[idx][:3])),
                     approved, baseline)


# ──────────────────────────── 主流程 ────────────────────────────


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", action="store_true", help="输出机器可读 JSON")
    ap.add_argument("--skip-png", action="store_true")
    args = ap.parse_args()

    rep = Report()
    approved, baseline = load_two_tier_lists()

    check_files(rep)

    regions_raw, err = load_json(os.path.join(MAP_DIR, "map_regions.json"))
    countries_raw, err2 = load_json(os.path.join(MAP_DIR, "map_countries.json"))
    actors_raw, err3 = load_json(os.path.join(MAP_DIR, "map_actors.json"))
    neighbors_raw, err4 = load_json(os.path.join(MAP_DIR, "map_neighbors.json"))
    identity_raw, err5 = load_json(os.path.join(INITIAL_DIR, "country_identity.json"))
    meta_raw, err6 = load_json(os.path.join(MAP_DIR, "map_meta.json"))
    for path, e in [("map_regions", err), ("map_countries", err2), ("map_actors", err3),
                    ("map_neighbors", err4), ("country_identity", err5), ("map_meta", err6)]:
        if e:
            rep.block("JSON", "%s: %s" % (path, e))
    if err or err2:
        finish(rep, args)

    check_schema(rep, "map_regions", regions_raw, REGION_FIELDS)
    check_schema(rep, "map_countries", countries_raw, COUNTRY_FIELDS)
    if isinstance(actors_raw, dict):
        check_schema(rep, "map_actors", actors_raw, ACTOR_FIELDS)

    if isinstance(neighbors_raw, dict):
        region_keys = set(regions_raw.keys())
        for nk, nlist in neighbors_raw.items():
            if nk not in region_keys:
                rep.block("NEIGHBORS", "map_neighbors 键 %s 不是合法 region_id" % nk)
            # 值侧校验：邻居列表引用的 region 必须存在
            if isinstance(nlist, list):
                for nv in nlist:
                    ns = str(nv)
                    if ns not in region_keys:
                        rep.block("NEIGHBORS",
                                  "map_neighbors[%s] 引用了不存在的 region %s" % (nk, nv))

    check_claims(rep, regions_raw, countries_raw, approved, baseline)
    if err5 is None and isinstance(identity_raw, dict):
        check_identity(rep, identity_raw, countries_raw, approved, baseline)
    check_gd_refs(rep, regions_raw, identity_raw if isinstance(identity_raw, dict) else {},
                  approved, baseline)
    check_png(rep, regions_raw, meta_raw if isinstance(meta_raw, dict) else {},
              args.skip_png, approved, baseline)

    finish(rep, args)


def finish(rep, args):
    n_block, n_base, n_ok = len(rep.blocking), len(rep.baselined), len(rep.approved)
    if args.json:
        out = {
            "blocking": [{"code": c, "message": m} for c, m in rep.blocking],
            "baseline": [{"code": c, "message": m} for c, m in rep.baselined],
            "approved_count": n_ok,
        }
        sys.stdout.write(json.dumps(out, ensure_ascii=False, indent=2))
        sys.exit(1 if n_block else 0)

    lines = []
    lines.append("=" * 72)
    lines.append("地图数据审计报告")
    lines.append("=" * 72)
    if rep.blocking:
        lines.append("")
        lines.append("[红灯] 新增/未登记问题 %d 条（必须处理或加入 baseline）：" % n_block)
        for c, m in rep.blocking:
            lines.append("  - [%s] %s" % (c, ascii_safe(m)))
    if rep.baselined:
        lines.append("")
        lines.append("[基线] 已知未修问题 %d 条（见 tools/map_audit_baseline.json，请逐步清零）：" % n_base)
        for c, m in rep.baselined:
            lines.append("  - [%s] %s" % (c, ascii_safe(m)))
    lines.append("")
    lines.append("[白名单] 放行的故意状态 %d 处（tools/map_audit_exceptions.json）" % n_ok)
    lines.append("")
    verdict = "FAIL" if n_block else "PASS"
    lines.append("结果: %s  (blocking=%d, baseline=%d, approved=%d)"
                 % (verdict, n_block, n_base, n_ok))
    text = "\n".join(lines)
    try:
        print(text)
    except UnicodeEncodeError:
        # Windows 控制台兜底
        sys.stdout.buffer.write(text.encode("utf-8", "replace") + b"\n")
    sys.exit(1 if n_block else 0)


def ascii_safe(s):
    try:
        s.encode(sys.stdout.encoding or "ascii")
        return s
    except UnicodeEncodeError:
        return s.encode(sys.stdout.encoding or "ascii", "replace").decode()


if __name__ == "__main__":
    main()
