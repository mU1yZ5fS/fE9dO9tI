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

## 生成运行时资源

在 Godot 编辑器或工具脚本中执行：

```gdscript
var md := MapBuilder.build()
```

输出：

```
res://资产/地图/generated/map_data.res
```

运行时只加载 `map_data.res`，不再解析 JSON。
