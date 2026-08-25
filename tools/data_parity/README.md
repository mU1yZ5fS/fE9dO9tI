# 数据对齐工具链（data parity）

> 目标：机械保证 Godot 重制版的**开局数据**与逆向原版完全一致，
> 消灭"数值抄错 / d1 混入 / 覆盖漏移植"这类细节偏差。

## 原理

原版是确定性数据驱动游戏，开局状态 = 数据表 + GameStartScript.OnMouseDown()
的 ~500 条写操作 + FixSubs() 归一化。本工具链把它完整建模成"期望态"，
与 Godot 真实跑出来的 `WorldFactory.create_world()` 快照逐字段精确比对。

```
extract_original.py          export_godot_snapshot.gd         diff_snapshots.py
逆向 Assets ──────────────► snapshots/original/*.json
（txt 表 + C# 操作解析）                      ┌──────────────► 逐难度比对
                                             │                FAIL=退出码1
Godot 引擎(无头) ─────────► snapshots/godot/diff_N.json ─────┘
（真实 create_world × 难度0-4）
```

## 用法

```bash
# 1. 原版快照（逆向目录更新后重跑）
python tools/data_parity/extract_original.py

# 2. Godot 快照（改了任何初始数据/世界构建代码后重跑）
F:/work/Godot_v4.7-stable_win64.exe/Godot_v4.7-stable_win64_console.exe \
  --headless --path . --script res://tools/data_parity/export_godot_snapshot.gd

# 3. 比对（全部难度；--diff N 只看单难度）
python tools/data_parity/diff_snapshots.py
```

## 判定级别

| 级别 | 含义 |
|---|---|
| PASS | 与原版一致 |
| APPROVED | 不一致但已在 `parity_exceptions.json` 登记理由 |
| FAIL | 未登记的不一致 —— **修数据或登记，禁止无视** |
| GAP | 本层无法机械比对的语义差量（忠诚矩阵/公式/parts 等），由第 2/3 层覆盖 |

## 已登记的故意偏离（parity_exceptions.json）

- `positions:0.array`：领袖哨兵 150 → -2
- `data:82.v`：war_resolve 负哨兵 -10 → -1（行为等价，只判 <0）
- `data:96.v`：苏联领导人支持度并入 EmpireLeader（待第 2 层验证 Event89）
- `country:1.special_ending`：原版置 0 但无读取方
- `country:{106,111,128,142,161}.*`：地图归属/政体呈现属 CountryScript.Repaint()
  初始规则，权威源在 `tools/generated/map_rules_manifest.json`

## 覆盖范围（本层 = 第 1 层数据）

✅ data[0..199] 数值表、国家 19+5 字段及全部开局覆盖、派系表、政治家 18 人槽位
   （特质/年龄/权力/意向职位）、职位表、派系领袖、开局修正集、FixSubs 归一化、
   难度分支（diff0/1/3/4）、dlc[3] 块、RNG 槽位范围校验（47/48/49）

⏳ 第 2 层（公式穷举测试）：OilEat/OilProd 公式、CalcRel 忠诚矩阵、Empire 内部结构
⏳ 第 3 层（行为回放）：parts 地块机制、随机数流一致性
