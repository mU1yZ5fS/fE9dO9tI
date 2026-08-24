#!/usr/bin/env python3
"""原版数据快照提取器（数据对齐工具链 第 1/3 步）。

从逆向工程目录读取 Unity 反编译产物，产出规范 JSON 快照：
  - Resources/*.txt 的原始数据表
  - GameStartScript.OnMouseDown() 的全部开局写操作（带上下文标注）

上下文（ctx）含义：
  always   无条件执行
  dlc3     if (GlobalScript.inst.dlc[3]) 块内（改版按全 DLC 恒真处理）
  diffN    if/else if (...gameState.diff == N) 块内
  other    其余受控块（for/普通 if 等）——diff 工具不会应用，只汇报，绝不静默丢弃

用法:
  python extract_original.py --assets <逆向Assets目录> --out snapshots/original
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------- 正则模式

RE_DATA_SET = re.compile(
    r"gameState\.data\[(\d+)\]\s*(\+=|-=|=)\s*([^;]+);")
RE_RNG = re.compile(r"Random\.Range\(\s*(-?\d+)\s*,\s*(-?\d+)\s*\)")
RE_COUNTRY_FIELD = re.compile(
    r"gameState\.allcountries\[(\d+)\]\.(\w+)\s*=\s*([^;]+);")
RE_LEAVE_ALLIANCES = re.compile(
    r"gameState\.allcountries\[(\d+)\]\.LeaveAlliances\(\)")
RE_POLIT_SIMPLE = re.compile(
    r"gameState\.politics\[(\d+|num\d+)\]\.(\w+)(?:\[(\d+)\])?\s*(\+=|-=|=)\s*([^;]+);")
COUNTRY_COPY = re.compile(
    r"gameState\.allcountries\[(\d+)\]\.(\w+)\s*=\s*"
    r"GlobalScript(?:\.inst)?\.gameState\.allcountries\[(\d+)\]\.(\w+)\s*;")
RE_POSITION = re.compile(
    r"gameState\.politics_dolshnost\[(\d+)\]\s*=\s*(-?\d+);")
RE_FACTION_LEADER = re.compile(
    r"gameState\.faction_leader\[(\d+)\]\s*=\s*(-?\d+);")
RE_MODIFIER_ON = re.compile(
    r"gameState\.modifies\[(\d+)\]\.active\s*=\s*true;")
RE_SCALAR = re.compile(
    r"gameState\.(\w+)\s*=\s*(-?\d+(?:\.\d+)?f?);")

# 静默跳过：纯本地化 / 外观 / 循环清零（Godot 默认值即一致）
SILENT_FIELDS = {
    "face_type", "jacket", "name", "wantedDolzh_face",
}
SILENT_PREFIXES = (
    "party_name", "doctr", "other_text", "names1", "names2", "country_texts",
    "politics[",  # politics[i].face_*/jacket 由 SILENT_FIELDS 覆盖，其余单独判
)

BOOL_COUNTRY_FIELDS = {
    "isSEV": "sev", "isOVD": "ovd", "Vyshi": "亲美", "proprc": "亲中",
    "prosov": "亲苏", "okb": "okb", "econ": "econ", "Torg": "对华贸易",
    "usalliance": "美国盟友", "sovalliance": "苏联盟友",
    "isASEAN": "asean", "isSENTO": "sento", "isSEATO": "seato",
    "isNATO": "nato", "isEU": "eu", "isSocEU": "soc_eu",
    "oar": "oar", "isOil": "oil", "isRIM": "rim", "isAU": "au",
    "isFXSEU": "fxseu", "isNAZIMAO": "nazimao", "isBALECON": "balecon",
    "isOLAS": "olas",
}
INT_COUNTRY_FIELDS = {
    "Gosstroy": "government", "SubGosstroy": "sub_government",
    "puppetOf": "puppet_of", "stab": "stab", "dev": "dev",
    "sovpower": "sovpower", "usapower": "usapower", "prcpower": "prcpower",
}

# Country.LeaveAlliances()（Country.cs:89-115）实际清除的标志 + puppetOf=-1
LEAVE_ALLIANCES_CLEARS = [
    "okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏", "亲美",
    "亲中", "asean", "seato", "oar", "oil", "对华贸易", "sento",
    "fxseu", "nazimao", "balecon", "rim", "au", "olas",
]


class CtxStack:
    """花括号深度 + 语义上下文栈（逐字符扫描，正确处理 "} else if (...) {"）。"""

    OPENERS = [
        (re.compile(r"GlobalScript\.inst\.dlc\[3\]"), "dlc3"),
        (re.compile(r"gameState\.diff\s*==\s*(\d+)"), "diff{n}"),
        (re.compile(r"@int\s*==\s*\d+"), "lang"),
        # 新游戏入口守卫，开局必真 → 透明处理（不入栈）
        (re.compile(r"this\.number\s*>\s*0"), "always"),
        (re.compile(r"^\s*(for|foreach|while|switch)\b"), "other"),
        (re.compile(r"^\s*(else\s*)?if\s*\("), "other"),
        (re.compile(r"^\s*else\b\s*$"), "other"),
        (re.compile(r"\bdo\b\s*$"), "other"),
        (re.compile(r"\btry\b"), "other"),
        (re.compile(r"\bcatch\b"), "other"),
        (re.compile(r"\b(void|int|bool|string|float)\s+\w+\s*\(\s*\)?\s*$"), "always"),
    ]

    # 不参与机械应用的“噪声”上下文段
    NOISE = {"other", "lang"}

    @staticmethod
    def applicable(path: str | None) -> bool:
        """路径形如 always / always>dlc3 / always>diff4>other。
        只有首段为 always 且其余段全部属于 {dlc3, diffN} 时才可机械应用。"""
        if not path:
            return False
        segs = path.split(">")
        if segs[0] != "always":
            return False
        for s in segs[1:]:
            if s == "dlc3" or (s.startswith("diff") and s[4:].isdigit()):
                continue
            return False
        return True

    def __init__(self) -> None:
        self.depth = 0
        self.stack: list[tuple[int, str]] = []  # (进入时的 depth, ctx)
        self.buf = ""  # 跨行累积（opener 的 if(...) 与 { 可能分处两行）

    def _match_opener(self, buf: str) -> str | None:
        s = buf.strip()
        if not s:
            return None
        for rx, name in self.OPENERS:
            m = rx.search(s)
            if m:
                return name.format(n=m.group(1)) if "{n}" in name else name
        return None

    def feed(self, line: str):
        """扫描一行，返回行内语句的 ctx 路径（如 "always>dlc3"），无语句返回 None。

        逐段处理：花括号之间的文本视为语句区，其 ctx 取当前栈顶；
        遇 '{' 时用自上次花括号以来累积的文本判定 opener 并入栈。
        文本缓冲跨行保留，兼容 "if (...)\n{" 分行写法。"""
        stmt_ctx: str | None = None
        i = 0
        n = len(line)
        while i < n:
            ch = line[i]
            if ch == "/" and i + 1 < n and line[i + 1] == "/":
                break  # 行注释，停止
            if ch == "{":
                name = self._match_opener(self.buf)
                if name != "always":  # 透明块不入栈
                    self.stack.append((self.depth, name or "other"))
                self.buf = ""
                self.depth += 1
            elif ch == "}":
                self.depth -= 1
                while self.stack and self.depth <= self.stack[-1][0]:
                    self.stack.pop()
                self.buf = ""
            else:
                self.buf += ch
                if not stmt_ctx and ("=" in self.buf or "(" in self.buf):
                    stripped = self.buf.strip()
                    if not stripped.endswith("(") and not stripped.endswith(","):
                        stmt_ctx = ">".join(
                            c for _, c in self.stack) if self.stack else "always"
            i += 1
        return stmt_ctx


def parse_int(token: str) -> int | None:
    t = token.strip()
    try:
        return int(t)
    except ValueError:
        return None


def parse_table_rows(text: str, row_sep: str, field_sep: str,
                     expected_fields: int):
    """逐字模拟原版 C# 解析：
    - Replace("\\n","") 只删 \\n，保留 \\r（int.Parse 容忍首尾空白）
    - split(row_sep) 后每段 split(field_sep)，只读前 expected_fields 个字段，
      多余字段忽略 —— Country_data_1.txt 尾部 166-172 行缺 ':' 分隔，
      原版实际只创建 166，167+ 保持 Unity 序列化默认值。
    返回 (rows, anomalies)：anomalies 记录被忽略的多余字段数等结构怪异。"""
    text = text.replace("\n", "")
    rows: list[list[int]] = []
    anomalies: list[str] = []
    for seg in text.split(row_sep):
        if not seg.strip():
            continue
        fields = [f.strip() for f in seg.split(field_sep)]
        vals = []
        for f in fields[:expected_fields]:
            v = parse_int(f)
            if v is None:
                raise ValueError(f"非整数字段: {f!r} (segment: {seg[:60]!r})")
            vals.append(v)
        if len(fields) > expected_fields:
            anomalies.append(
                f"段 {vals[0]}: {len(fields)} 字段（预期 {expected_fields}），"
                f"多余 {len(fields)-expected_fields} 个被原版忽略")
        elif len(fields) < expected_fields:
            raise ValueError(f"字段不足 {len(fields)} < {expected_fields}: {seg[:60]!r}")
        rows.append(vals)
    return rows, anomalies


def extract_tables(res: Path) -> dict:
    out: dict = {}

    data1 = (res / "Data1.txt").read_text(encoding="utf-8-sig", errors="replace")
    data1 = data1.replace("\r\n", "").replace("\n", "")
    parts = [p.strip() for p in data1.split(";")]
    # 原版: array[0]="" 跳过, data[1..len-1] 依次赋值
    assert parts[0] == "", "Data1.txt 必须以 ; 开头"
    values = [parse_int(p) for p in parts[1:]]
    assert all(v is not None for v in values), "Data1.txt 含非整数"
    out["data_values"] = values  # data_values[i] 对应原版 data[i+1]
    out["data_base_index"] = 1

    out["country_rows"], anom = parse_table_rows(
        (res / "Country_data_1.txt").read_text(encoding="utf-8-sig", errors="replace"),
        ":", ";", 19)
    out["country_parse_anomalies"] = anom

    out["south_country_rows"], sanom = parse_table_rows(
        (res / "South_data.txt").read_text(encoding="utf-8-sig", errors="replace"),
        ":", ";", 24)
    out["south_parse_anomalies"] = sanom

    out["faction_rows"], _ = parse_table_rows(
        (res / "Party_data_1.txt").read_text(encoding="utf-8-sig", errors="replace"),
        ":", ";", 4)

    # Politics_inf.txt 是单行: 行分隔 ';' 字段分隔 ':' （与其它文件相反！）
    inf_raw = (res / "Politics_inf.txt").read_text(encoding="utf-8-sig", errors="replace")
    inf_raw = inf_raw.replace("\r\n", "").replace("\n", "").strip()
    rows = []
    for seg in inf_raw.split(";"):
        seg = seg.strip()
        if not seg:
            continue
        rows.append([f.strip() for f in seg.split(":")])
    out["politics_inf_raw"] = rows

    leader = (res / "Politics_leader.txt").read_text(encoding="utf-8-sig", errors="replace")
    out["politics_leader_raw"] = [f.strip() for f in leader.strip().split(";")]

    return out


def extract_gamestart(cs_path: Path) -> dict:
    lines = cs_path.read_text(encoding="utf-8-sig", errors="replace").splitlines()

    # 定位 OnMouseDown 方法体
    start = next(i for i, l in enumerate(lines) if "private void OnMouseDown()" in l)
    end = len(lines)
    depth = 0
    seen_open = False
    for i in range(start, len(lines)):
        depth += lines[i].count("{") - lines[i].count("}")
        if "{" in lines[i]:
            seen_open = True
        if seen_open and depth == 0:
            end = i + 1
            break

    ctx_stack = CtxStack()
    ops: list[dict] = []
    modifiers = {"always": [], "dlc3": []}
    flags: dict[str, object] = {}
    unparsed: list[str] = []

    def ctx_of(line: str) -> str:
        got = ctx_stack.feed(line)
        return got if got else "always"

    for ln in range(start, end):
        raw = lines[ln]
        line = raw.strip()
        if not line or line.startswith("//"):
            ctx_stack.feed(raw)
            continue
        ctx = ctx_of(raw)

        m = RE_MODIFIER_ON.search(line)
        if m:
            bucket = "dlc3" if ctx == "dlc3" else "always"
            mid = int(m.group(1))
            if mid not in modifiers[bucket]:
                modifiers[bucket].append(mid)
            continue

        m = RE_LEAVE_ALLIANCES.search(line)
        if m:
            ops.append({"op": "leave_alliances", "id": int(m.group(1)),
                        "clears": LEAVE_ALLIANCES_CLEARS, "line": ln + 1, "ctx": ctx})
            continue

        m = RE_POSITION.search(line)
        if m:
            ops.append({"op": "position_set", "slot": int(m.group(1)),
                        "value": int(m.group(2)), "line": ln + 1, "ctx": ctx})
            continue

        m = RE_FACTION_LEADER.search(line)
        if m:
            ops.append({"op": "faction_leader_set", "faction": int(m.group(1)),
                        "value": int(m.group(2)), "line": ln + 1, "ctx": ctx})
            continue

        # parts 数组（地块可见性）与 africaOff
        pm = re.search(r"allcountries\[(\d+)\]\.parts\s*=\s*new bool\[(\d+)\]", line)
        if pm:
            ops.append({"op": "parts_size", "id": int(pm.group(1)),
                        "size": int(pm.group(2)), "line": ln + 1, "ctx": ctx})
            continue
        psm = re.search(r"allcountries\[(\d+)\]\.parts\[(\d+)\]\s*=\s*(true|false)", line)
        if psm:
            ops.append({"op": "parts_set", "id": int(psm.group(1)),
                        "index": int(psm.group(2)), "value": psm.group(3) == "true",
                        "line": ln + 1, "ctx": ctx})
            continue

        m = RE_COUNTRY_FIELD.search(line)
        if m:
            cid, field, value = int(m.group(1)), m.group(2), m.group(3).strip()
            cm = COUNTRY_COPY.search(line)
            if cm:
                ops.append({"op": "country_copy", "id": int(cm.group(1)),
                            "field": INT_COUNTRY_FIELDS.get(cm.group(2), cm.group(2)),
                            "src_id": int(cm.group(3)),
                            "src_field": INT_COUNTRY_FIELDS.get(cm.group(4), cm.group(4)),
                            "line": ln + 1, "ctx": ctx})
                continue
            if field == "africaOff" and value in ("true", "false"):
                ops.append({"op": "country_africa_off", "id": cid,
                            "value": value == "true", "line": ln + 1, "ctx": ctx})
                continue
            if field in SILENT_FIELDS:
                continue
            if field in BOOL_COUNTRY_FIELDS:
                if value not in ("true", "false"):
                    unparsed.append(f"{ln+1}: {line}")
                    continue
                ops.append({"op": "country_tag", "id": cid,
                            "tag": BOOL_COUNTRY_FIELDS[field],
                            "value": value == "true", "line": ln + 1, "ctx": ctx})
                continue
            if field in INT_COUNTRY_FIELDS:
                v = parse_int(value)
                if v is None:
                    unparsed.append(f"{ln+1}: {line}")
                    continue
                ops.append({"op": "country_field", "id": cid,
                            "field": INT_COUNTRY_FIELDS[field], "value": v,
                            "line": ln + 1, "ctx": ctx})
                continue
            # 未映射的国家字段（如 numberOfSpecialEnding）——记录供人工比对
            v = parse_int(value)
            if v is not None:
                ops.append({"op": "country_extra", "id": cid, "field": field,
                            "value": v, "line": ln + 1, "ctx": ctx})
                continue
            unparsed.append(f"{ln+1}: {line}")
            continue

        m = RE_DATA_SET.search(line)
        if m:
            idx, aop, value = int(m.group(1)), m.group(2), m.group(3).strip()
            rng = RE_RNG.search(value)
            if rng:
                lo, hi = int(rng.group(1)), int(rng.group(2))
                ops.append({"op": "data_rng", "index": idx,
                            "min": lo, "max": hi - 1,  # int Range 上界开区间
                            "line": ln + 1, "ctx": ctx})
                continue
            v = parse_int(value)
            if v is not None:
                kind = {"=": "data_set", "+=": "data_add", "-=": "data_sub"}[aop]
                ops.append({"op": kind, "index": idx, "value": v,
                            "line": ln + 1, "ctx": ctx})
                continue
            unparsed.append(f"{ln+1}: {line}")
            continue

        m = RE_POLIT_SIMPLE.search(line)
        if m:
            slot_raw, field, bracket, aop, value = (m.group(1), m.group(2),
                                                    m.group(3), m.group(4),
                                                    m.group(5).strip())
            if not slot_raw.isdigit():
                # 循环变量槽位（diff4 特质过滤加成等）——语义依赖运行时，记录待人工核对
                ops.append({"op": "pol_loop_note", "slot_var": slot_raw,
                            "field": field, "aop": aop, "value": value,
                            "line": ln + 1, "ctx": ctx})
                continue
            slot = int(slot_raw)
            if field in ("face_type", "jacket") or field.startswith("face_parts"):
                continue
            if field.startswith("loyality_to_other") and bracket is not None:
                v = parse_int(value)
                if v is None:
                    unparsed.append(f"{ln+1}: {line}")
                    continue
                ops.append({"op": "rel_" + {"=": "set", "+=": "add", "-=": "sub"}[aop],
                            "slot": slot, "target": int(bracket), "value": v,
                            "line": ln + 1, "ctx": ctx})
                continue
            if field in ("power", "loyality"):
                v = parse_int(value)
                if v is None:
                    unparsed.append(f"{ln+1}: {line}")
                    continue
                kind = "pol_" + {"=": "set", "+=": "add", "-=": "sub"}[aop]
                target = "power" if field == "power" else "loyalty"
                ops.append({"op": kind, "slot": slot, "stat": target, "value": v,
                            "line": ln + 1, "ctx": ctx})
                continue
            if field == "wantedDolzh":
                v = parse_int(value)
                if v is None:
                    unparsed.append(f"{ln+1}: {line}")
                    continue
                ops.append({"op": "pol_wanted", "slot": slot, "value": v,
                            "line": ln + 1, "ctx": ctx})
                continue
            unparsed.append(f"{ln+1}: {line}")
            continue

        # OilEat/OilProd 公式行 —— 原文留档，公式级比对属第 2 层（穷举测试）
        if re.search(r"gameState\.Oil(Eat|Prod)\b", line):
            ops.append({"op": "oil_formula", "raw": line, "line": ln + 1, "ctx": ctx})
            continue

        # 帝国/外交连接等复杂初始化 —— 留档待第 2 层专项比对
        if re.search(r"gameState\.(empires|SOV_PRC_PartiesConnection)\b", line) \
                or line.startswith("new ") or line.lstrip().startswith("modifies = new") \
                or re.search(r"gameState\.data\[\d+\]\+\+", line):
            ops.append({"op": "complex_init", "raw": line, "line": ln + 1, "ctx": ctx})
            continue

        m = RE_SCALAR.search(line)
        if m and m.group(1) in ("OilProd", "OilEat", "war", "AnthemCooldownTime"):
            val = m.group(2).rstrip("f")
            try:
                fv = float(val) if "." in val else int(val)
            except ValueError:
                unparsed.append(f"{ln+1}: {line}")
                continue
            ops.append({"op": "flag", "key": m.group(1), "value": fv,
                        "line": ln + 1, "ctx": ctx})
            continue

        # 布尔开局旗标 is_xxx = true/false
        mbool = re.search(r"\bgameState\.([A-Za-z_]\w*)\s*=\s*(true|false|[\d.]+f?);\s*$", line)
        if mbool:
            key, val = mbool.group(1), mbool.group(2)
            if val in ("true", "false"):
                flags[key] = {"value": val == "true", "ctx": ctx}
                continue
            try:
                num = float(val.rstrip("f")) if "." in val else int(float(val))
                flags[key] = {"value": num, "ctx": ctx}
                continue
            except ValueError:
                pass
            unparsed.append(f"{ln+1}: {line}")
            continue

        # 清零/重置循环体（Godot create_world 从零构建，默认值天然一致）
        if re.search(r"\.\w+\[(?:i|j|k|l|m|n|num|num\d+)\](?:\.\w+)*\s*=\s*(?:0|false|-1|true)\s*;", line):
            continue

        # 数据文件装载段（Data1/Country_en/Party_data/Politics_inf/Doctr/Part 等）
        # —— 这些表的最终值由本工具的表格快照承载，此处按装载代码跳过
        FILE_LOAD_SKIP = re.compile(
            r"\.(?:party_name|doctr|names1|names2|country_texts|influencePRC"
            r"|is_party_enabled|is_party_ally|party_ideology|party_number"
            r"|name_1|name_2|traits|age|power|face_type|face_parts|jacket"
            r"|is_sledstvie|is_sleshka|is_sagovor|you_fall|sled_slej"
            r"|days_sleshka|name_war)\b[^=;]*=.*$"
            r"|\[num\d+\]\s*=\s*(?:int\.Parse|array|\(byte\))"
            r"|iron_and_blood\s*=\s*\("
            r"|\.name\b\s*=\s*array\b"
            r"|CalcRel(?:Leader)?\(\s*num?\d*\s*\)"
            r"|CreateDecisions\(\)|FixSubs\(\)"
            r"|old_modify_desc\b|resultOfEvents\[\d+\]\s*=\s*-1"
            r"|^GlobalScript\.inst\.speed\s*=|^GlobalScript\.inst\.country_texts")
        if FILE_LOAD_SKIP.search(line) or "int.Parse(array" in line:
            continue

        # 已知可安全忽略的模式
        if (line.startswith(("for ", "TextAsset", "Resources.", "string ",
                             "string[]", "int ", "GlobalScript.inst.dlc",
                             "PlayerPrefs", "this.", "sceneFader", "SceneManager"))
                or line in ("{", "}", "};")
                or "Split(" in line or "Resources.Load" in line
                or ".text =" in line or line.startswith("if ") or line.startswith("else")
                or "new Country" in line or "new warinwars" in line
                or line.startswith("}")):
            continue
        if line.startswith("GlobalScript.inst.gameState.politics_dolshnost"):
            continue
        # 未识别 → 记录，绝不静默
        if line.startswith("GlobalScript.inst.") or "gameState." in line:
            unparsed.append(f"{ln+1}: {line}")

    return {"ops": ops, "start_modifiers": modifiers,
            "flags": flags, "unparsed": unparsed}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--assets", default=r"F:\work\毛的遗产改版逆向工程测试\改版最新完整逆向\Assets")
    ap.add_argument("--out", default=Path(__file__).parent / "snapshots" / "original")
    args = ap.parse_args()

    assets = Path(args.assets)
    res = assets / "Resources"
    cs = assets / "Scripts" / "GameStartScript.cs"
    if not res.is_dir() or not cs.is_file():
        print(f"[错误] 找不到 {res} 或 {cs}", file=sys.stderr)
        return 3

    snap = {"_meta": {"source": str(assets)}}
    snap.update(extract_tables(res))
    gs = extract_gamestart(cs)
    snap["ops"] = gs["ops"]
    snap["start_modifiers"] = gs["start_modifiers"]
    snap["flags"] = gs["flags"]
    snap["unparsed_count"] = len(gs["unparsed"])
    snap["unparsed_sample"] = gs["unparsed"][:40]

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "original_snapshot.json").write_text(
        json.dumps(snap, ensure_ascii=False, indent=1), encoding="utf-8")

    print(f"OK -> {out_dir / 'original_snapshot.json'}")
    print(f"  data_values:      {len(snap['data_values'])}")
    print(f"  country_rows:     {len(snap['country_rows'])}")
    print(f"  south_rows:       {len(snap['south_country_rows'])}")
    print(f"  faction_rows:     {len(snap['faction_rows'])}")
    print(f"  politics_inf:     {len(snap['politics_inf_raw'])}")
    print(f"  ops:              {len(snap['ops'])}")
    print(f"  modifiers always/dlc3: {len(snap['start_modifiers']['always'])}/"
          f"{len(snap['start_modifiers']['dlc3'])}")
    print(f"  UNPARSED:         {snap['unparsed_count']}"
          + ("  <-- 需要人工检查!" if snap["unparsed_count"] else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
