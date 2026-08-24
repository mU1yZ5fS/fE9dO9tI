# 数据脚本目录结构

## 顶层
- `game_manager.gd`：全局编排/代理
- `world_state.gd`：状态根
- `event_script_base.gd`：事件脚本基类
- `启动加载配置.gd`：启动配置
- 其余根级脚本为少量目录/工具类

## 子目录
| 目录 | 内容 |
|---|---|
| `core/` | 领域模型/数据类（CountryData、WarData、EventDef、ExprNode 等） |
| `systems/` | 系统逻辑（WarSystem、PoliticianSystem、EventEngine、DecisionSystem 等） |
| `services/` | 服务（SettingsService、SaveService、EconomyService、FortnightSimulator、PolicyService） |
| `factory/` | 构建/工厂（WorldFactory、EventDefBuilder、SaveCatalog、ResScan） |
| `ui/` | ViewModel（GameViewModel、StatusBarViewModel） |
| `地图数据/` | 地图数据模型、MapBuilder、MapService |
| `外交互动/` | 外交动作目录、批次、DiploActionDef/Loader |
| `事件效果/` | 事件效果脚本；多数文件尾部含本事件 `const META`（结构定义，文案走本地化键） |
| `事件定义/` | 纯声明式 / 共享脚本事件的独立 META 定义 |

## 事件系统（2026-08 迁移后）
- 一个事件 = 一个 `.gd`（META 结构 + execute 效果），`.tres` 已删除。
- 全部文案在 `资产/本地化/events_zh_CN.csv`，键约定：`event.<id>.title/desc/option_N.text/disabled/result`、脚本动态文案 `event.script.<文件名>.c*/i*`。
- 显示时经 EventText.t() 翻译；加语言 = CSV 加一列 + 项目设置注册 translation。
- 校验：`tools/verify_event_migration.gd`（对照迁移清单全量比对）。
| `政治家池/` | 政治家池数据 |

## 原则
- 能用 UID 就不要写死 `res://` 路径。
- 新文件优先放入对应子目录，避免根目录继续膨胀。
