#!/usr/bin/env python3
"""数据对齐比对器（数据对齐工具链 第 3/3 步）。

读取原版快照（extract_original.py 产物）与 Godot 快照
（export_godot_snapshot.gd 产物），逐难度重建原版"最终开局状态"
（数据表 + 全部开局写操作 + FixSubs 归一化），与 Godot 真实
create_world() 输出做精确比对。

判定级别：
  PASS      完全一致
  APPROVED  与原版不一致但已在 parity_exceptions.json 登记理由
  FAIL      不一致且未登记 —— 需要修复或登记
  GAP       双方语义结构不同、本层无法机械比对（如忠诚度矩阵）
  RNG       随机槽位，只校验取值范围

用法:
  python diff_snapshots.py [--diff N]
退出码: 0=无 FAIL, 1=存在 FAIL
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
RNG_DATA_INDICES = {47, 48, 49}

# Politics_inf.txt 字段序 → 语义特质槽（GameStartScript.cs:337-344）
# traits[0]=f2, traits[3]=f3, traits[1]=f4, traits[2]=f5
# Godot 语义命名：personality=t0(f2), alignment=t1(f4),
#                 special=t2(f5), background=t3(f3)
# GameStartScript 硬编码的国家附加字段 → CountryData 字段
EXTRA_FIELD_MAP = {
    "level_of_unstab": "level_of_unstab",
    "level_of_dev": "level_of_dev",
    "numberOfSpecialEnding": "special_ending",
    "spec": "special",
    "inflCh": "influence_china",
    "inflNATO": "influence_nato",
    "prcinfl": "prc_influence",
    "soc_stab": "social_stability",
}

INF_TRAIT_MAP = {
    "trait_personality": 2,
    "trait_background": 3,
    "trait_alignment": 4,
    "trait_special": 5,
}


def load_json(p: Path):
    return json.loads(p.read_text(encoding="utf-8"))


# ---------------------------------------------------------------- 原版期望态构建


def build_base(snap: dict) -> dict:
    """由原始数据表构建基础状态（未应用开局操作）。"""
    # ---- data ----
    data = [0] * 200
    for i, v in enumerate(snap["data_values"]):
        data[i + snap["data_base_index"]] = v

    # ---- countries ----
    countries = {}

    def row_to_country(row: list[int]) -> dict:
        tags = {}
        for fi, key in [(1, "sev"), (2, "ovd"), (3, "亲美"), (4, "亲中"),
                        (5, "亲苏"), (6, "okb"), (7, "econ"), (8, "对华贸易"),
                        (9, "美国盟友"), (10, "苏联盟友")]:
            if row[fi] == 1:
                tags[key] = True
        c = {
            "tags": tags,
            "stab_file12": row[12],
            "dev": row[13],
            "sovpower": row[14],
            "usapower": row[15],
            "prcpower": row[16],
            "government": row[17],
            "sub_government": row[18],
            # C# Country 字段默认值（Country.cs:421,499-503）
            "level_of_dev": 0,
            "level_of_unstab": 0,
            "election_day": 22,
            "election_month": 2,
            "election_year": 2222,
            "puppet_of": -1,
            "africa_off": False,
            "parts_size": 0,
            "parts_true": [],
            "special_ending": -1,
            # C# 其余 int 字段默认值均为 0
            "special": 0,
            "influence_china": 0,
            "influence_nato": 0,
            "prc_influence": 0,
            "social_stability": 0,
        }
        return c

    for row in snap["country_rows"]:
        c = row_to_country(row)
        countries[row[0]] = c
    for row in snap["south_country_rows"]:
        c = row_to_country(row)
        # South_data 专属字段（DLC00, GameStartScript.cs:1729-1731）
        c["level_of_dev"] = row[19]
        c["level_of_unstab"] = row[20]
        c["election_day"] = row[21]
        c["election_month"] = row[22]
        c["election_year"] = row[23]
        countries[row[0]] = c

    # ---- factions ----
    factions = []
    for row in snap["faction_rows"]:
        factions.append({
            "is_enabled": row[0] == 1,
            "is_ally": row[1] == 1,
            "ideology": row[2],
            "support": row[3],
        })

    # ---- politicians ----
    # 原版 Politic 默认值（Politic.cs 字段初始化）：
    #   power 由 inf 表 f7*10；wantedDolzh 默认 0；loyalty 默认见 GAP
    politicians = []
    for i, row in enumerate(snap["politics_inf_raw"]):
        f = [int(x) for x in row[:8]]
        politicians.append({
            "slot": i,
            "name_first": f[0],
            "name_last": f[1],
            "age": 1976 - f[6],
            "power": f[7] * 10,
            "trait_personality": f[INF_TRAIT_MAP["trait_personality"]],
            "trait_background": f[INF_TRAIT_MAP["trait_background"]],
            "trait_alignment": f[INF_TRAIT_MAP["trait_alignment"]],
            "trait_special": f[INF_TRAIT_MAP["trait_special"]],
            "wanted_position": 0,
            "faction": None,  # 原版开局不设置，GAP
            "loyalty": None,  # CalcRel 计算，GAP
        })

    return {
        "data": data,
        "countries": countries,
        "factions": factions,
        "politicians": politicians,
        "modifiers_active": [],
        "positions": [-1] * 8,
        "faction_leader": {},
    }


def op_applies(ctx_path: str, diff: int) -> bool:
    """路径任一段为噪声(other/lang)即不应用；dlc3 视为恒真；
    diffN 仅在难度匹配时应用。"""
    if not ctx_path:
        return False
    for s in ctx_path.split(">"):
        if s == "always" or s == "dlc3":
            continue
        if s.startswith("diff") and s[4:].isdigit():
            if int(s[4:]) != diff:
                return False
            continue
        return False
    return True


def fix_subs(countries: dict) -> None:
    """GameState.FixSubs()（GameState.cs:4831-4856），71-83 跳过。"""
    sub_groups = [
        ({0, 7, 9, 10, 13, 19, 20, 22}, 0),
        ({1, 2, 16, 17, 18}, 1),
        ({3, 8, 11, 14, 15, 21}, 2),
        ({4, 5, 6, 12}, 3),
    ]
    for cid, c in countries.items():
        if 71 <= cid <= 83:
            continue
        g, sg = c["government"], c["sub_government"]
        if g == 0 and sg == 0:
            continue
        for subs, want in sub_groups:
            if g != want and sg in subs:
                c["government"] = want
                break


def build_expected(snap: dict, diff: int) -> tuple[dict, list[str]]:
    st = build_base(snap)
    skipped_ops: list[str] = []

    for op in snap["ops"]:
        kind = op["op"]
        ctx = op.get("ctx", "always")
        if kind in ("oil_formula", "complex_init", "pol_loop_note"):
            skipped_ops.append(kind)
            continue
        if not op_applies(ctx, diff):
            continue

        if kind == "data_set":
            if op["index"] < len(st["data"]):
                st["data"][op["index"]] = op["value"]
        elif kind == "data_add":
            if op["index"] < len(st["data"]):
                st["data"][op["index"]] += op["value"]
        elif kind == "data_sub":
            if op["index"] < len(st["data"]):
                st["data"][op["index"]] -= op["value"]
        elif kind == "flag":
            if op["key"] == "OilProd":
                pass  # 浮点初值单独比对（见下方 expected_extra）
            elif op["key"] == "war":
                pass
        elif kind == "country_tag":
            c = st["countries"].get(op["id"])
            if c is None:
                skipped_ops.append(f"{kind}:{op['id']}")
                continue
            if op["value"]:
                c["tags"][op["tag"]] = True
            else:
                c["tags"].pop(op["tag"], None)
        elif kind == "country_field":
            c = st["countries"].get(op["id"])
            if c is None or op["field"] not in (
                    "government", "sub_government", "puppet_of",
                    "stab_file12", "dev", "sovpower", "usapower", "prcpower"):
                skipped_ops.append(f"{kind}:{op.get('id')}.{op.get('field')}")
                continue
            c[op["field"]] = op["value"]
        elif kind == "country_copy":
            dst, src = st["countries"].get(op["id"]), st["countries"].get(op["src_id"])
            if dst is None or src is None:
                skipped_ops.append(f"{kind}")
                continue
            dst[op["field"]] = src[op["src_field"]]
        elif kind == "leave_alliances":
            c = st["countries"].get(op["id"])
            if c is None:
                skipped_ops.append(f"{kind}:{op['id']}")
                continue
            for t in op["clears"]:
                c["tags"].pop(t, None)
            c["puppet_of"] = -1
        elif kind == "country_africa_off":
            c = st["countries"].get(op["id"])
            if c is not None:
                c["africa_off"] = op["value"]
        elif kind == "parts_size":
            c = st["countries"].get(op["id"])
            if c is not None:
                c["parts_size"] = op["size"]
                c["parts_true"] = []
        elif kind == "parts_set":
            c = st["countries"].get(op["id"])
            if c is not None:
                while len(c["parts_true"]) <= op["index"]:
                    c["parts_true"].append(None)
                c["parts_true"][op["index"]] = op["value"]
        elif kind == "country_extra":
            c = st["countries"].get(op["id"])
            target = EXTRA_FIELD_MAP.get(op.get("field"))
            if c is not None and target:
                c[target] = op["value"]
            elif op.get("field") == "soc_stab" or op.get("field") == "prcinfl":
                pass
        elif kind == "pol_wanted":
            p = st["politicians"][op["slot"]]
            p["wanted_position"] = op["value"]
        elif kind in ("pol_set", "pol_add", "pol_sub"):
            p = st["politicians"][op["slot"]]
            cur = p.get(op["stat"]) or 0
            p[op["stat"]] = cur + (-op["value"] if kind == "pol_sub" else op["value"]) \
                if kind != "pol_set" else op["value"]
        elif kind in ("rel_set", "rel_add", "rel_sub"):
            skipped_ops.append(kind)  # 忠诚矩阵属 GAP
        elif kind == "position_set":
            st["positions"][op["slot"]] = op["value"]
        elif kind == "faction_leader_set":
            st["faction_leader"][op["faction"]] = op["value"]

    fix_subs(st["countries"])

    # parts_true 还原为索引列表（None 位表示显式 false）
    for cid, c in st["countries"].items():
        pt = c["parts_true"]
        c["parts_true"] = sorted(i for i, v in enumerate(pt) if v is True)

    return st, skipped_ops


# ---------------------------------------------------------------- 比对


def cmp_table(name: str, issues: list, approved: set, section: str,
              ident, field: str, exp, got):
    if exp == got:
        return
    key = f"{section}:{ident}.{field}"
    level = "APPROVED" if key in approved or f"{section}:{ident}" in approved else "FAIL"
    issues.append({"table": name, "level": level, "key": key,
                   "expected": exp, "got": got})


def compare_one(snap: dict, godot: dict, diff: int, exceptions: dict) -> tuple[list, list]:
    issues: list = []
    gaps: list = []
    approved = set(exceptions.get("approved", []))
    expected, skipped = build_expected(snap, diff)
    g_countries = {int(k): v for k, v in godot["countries"].items()}
    g_politicians = godot["politicians"]

    # ---- data ----
    for i in range(len(expected["data"])):
        if i in RNG_DATA_INDICES:
            gv = godot["data"][i]
            if not 1 <= gv <= 4:
                issues.append({"table": "data", "level": "FAIL", "key": f"data:{i}.rng",
                               "expected": "1..4", "got": gv})
            continue
        cmp_table("data", issues, approved, "data", i, "v",
                  expected["data"][i], godot["data"][i])

    # ---- countries ----
    only_godot = sorted(set(g_countries) - set(expected["countries"]))
    if only_godot:
        gaps.append(f"国家: Godot 多出 {only_godot}（原版该槽位为 Unity 序列化默认值/null）")
    for cid in sorted(set(expected["countries"]) & set(g_countries)):
        e, g = expected["countries"][cid], g_countries[cid]
        for field in ("government", "sub_government", "puppet_of", "stab_file12",
                      "dev", "sovpower", "usapower", "prcpower",
                      "level_of_dev", "level_of_unstab",
                      "election_day", "election_month", "election_year",
                      "africa_off", "special_ending",
                      "special", "influence_china", "influence_nato",
                      "prc_influence", "social_stability"):
            cmp_table("countries", issues, approved, "country", cid, field,
                      e[field], g[field])
        et, gt = set(e["tags"]), set(g["tags"])
        if et != gt:
            key = f"country:{cid}.tags"
            lvl = "APPROVED" if key in approved else "FAIL"
            issues.append({"table": "countries", "level": lvl, "key": key,
                           "expected": sorted(et), "got": sorted(gt)})
        # parts 数组不比：原版 OnMouseDown 手工 new bool[N]，Godot 由地图层
        # （map_service/map_regions）按地块归属驱动，机制不同，属结构差量。

    # ---- politicians ----
    if len(g_politicians) < len(expected["politicians"]):
        gaps.append(f"政治家: Godot 初始池 {len(g_politicians)} < 原版 18")
    for ep in expected["politicians"]:
        slot = ep["slot"]
        if slot >= len(g_politicians):
            break
        gp = g_politicians[slot]
        for field in ("name_first", "name_last", "age", "power",
                      "trait_personality", "trait_alignment",
                      "trait_special", "trait_background", "wanted_position"):
            cmp_table("politicians", issues, approved, "pol", slot, field,
                      ep[field], gp.get(field))

    # ---- factions ----
    for fi, ef in enumerate(expected["factions"]):
        if fi >= len(godot["factions"]):
            break
        gf = godot["factions"][fi]
        for field in ("is_enabled", "is_ally", "ideology", "support"):
            cmp_table("factions", issues, approved, "faction", fi, field,
                      ef[field], gf[field])

    # ---- modifiers / positions ----
    em = sorted(set(snap["start_modifiers"]["always"])
                | set(snap["start_modifiers"]["dlc3"]))
    gm = sorted(godot["modifiers_active"])
    if em != gm:
        lvl = "APPROVED" if "modifiers.active" in approved else "FAIL"
        issues.append({"table": "modifiers", "level": lvl, "key": "modifiers.active",
                       "expected": em, "got": gm})
    cmp_table("positions", issues, approved, "positions", 0, "array",
              expected["positions"], godot["positions"])

    # ---- 结构性 GAP（本层无法机械比对，列出供第 2/3 层覆盖）----
    if skipped:
        gaps.append(f"未机械应用的上下文操作 {len(skipped)} 条"
                    f"（忠诚矩阵/公式/复杂初始化）：{sorted(set(skipped))[:8]}")
    gaps.append("忠诚度(loyalty)/政治家 faction：依赖 CalcRel 计算与默认值差异，属第 2 层")
    gaps.append("国家 parts 数组：原版手工分配，Godot 由地图层驱动 —— 第 3 层回放覆盖")
    return issues, gaps


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--diff", type=int, help="只比对指定难度")
    args = ap.parse_args()

    orig_path = HERE / "snapshots" / "original" / "original_snapshot.json"
    godot_dir = HERE / "snapshots" / "godot"
    exc_path = HERE / "parity_exceptions.json"

    snap = load_json(orig_path)
    exceptions = load_json(exc_path) if exc_path.exists() else {}
    # 允许条目带 "# 理由" 注释
    exceptions["approved"] = [a.split("#")[0].strip()
                              for a in exceptions.get("approved", [])]

    diffs = [args.diff] if args.diff is not None else [0, 1, 2, 3, 4]
    total_fail = 0
    total_approved = 0

    for d in diffs:
        gp = godot_dir / f"diff_{d}.json"
        if not gp.exists():
            print(f"[错误] 缺少 {gp}，先运行 export_godot_snapshot.gd")
            return 1
        godot = load_json(gp)
        issues, gaps = compare_one(snap, godot, d, exceptions)
        fails = [i for i in issues if i["level"] == "FAIL"]
        appr = [i for i in issues if i["level"] == "APPROVED"]
        total_fail += len(fails)
        total_approved += len(appr)
        print(f"\n===== 难度 {d} =====")
        if not fails and not appr:
            print("  PASS：全部一致")
        for a in appr:
            print(f"  APPROVED {a['key']}  期望={a['expected']} 实际={a['got']}")
        for f_ in fails[:40]:
            print(f"  FAIL    {f_['key']}  期望={f_['expected']}  实际={f_['got']}")
        if len(fails) > 40:
            print(f"  ... 其余 {len(fails)-40} 条 FAIL 略")
        for g in gaps:
            print(f"  GAP     {g}")

    print(f"\n总结：FAIL={total_fail}  APPROVED={total_approved}"
          f"  （登记例外请编辑 parity_exceptions.json）")
    return 1 if total_fail else 0


if __name__ == "__main__":
    sys.exit(main())
