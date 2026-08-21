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
| `factory/` | 构建/工厂（WorldFactory、EventFactory、SaveCatalog、ResScan） |
| `ui/` | ViewModel（GameViewModel、StatusBarViewModel） |
| `地图数据/` | 地图数据模型、MapBuilder、MapService |
| `外交互动/` | 外交动作目录、批次、DiploActionDef/Loader |
| `事件效果/` | 事件效果脚本 |
| `政治家池/` | 政治家池数据 |

## 原则
- 能用 UID 就不要写死 `res://` 路径。
- 新文件优先放入对应子目录，避免根目录继续膨胀。
