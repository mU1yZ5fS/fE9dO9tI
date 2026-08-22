# 地图源数据目录

当前仍兼容读取 `res://资产/地图/` 根目录下的旧 JSON；本目录用于后续迁移和人工编辑。

## 计划文件

| 文件 | 作用 |
|---|---|
| `map_meta.json` | 地图元信息：尺寸、投影、色盘、最大 region_id |
| `map_countries.json` | 国家/行为体及其关联 region（含潜在归属） |
| `map_regions.json` | 每个 region 的基础属性与 1976 初始归属 |
| `map_neighbors.json` | region_id -> 邻接 region_id 数组（当前缺失，需补齐） |
| `map_claims.json` | 可选：显式宣称/分裂关系；缺省时由生成器从 map_countries 重复 region 自动推导 |

## 运行时数据源

运行时直接解析根目录下的 `map_meta.json` / `map_regions.json` / `map_countries.json`，
不再加载 `map_data.res`，也不需要先运行 MapBuilder。

`MapBuilder` / `MapData` 仅作为可选的离线生成工具保留，不参与游戏加载。
