# ============================================================================
# LoadingScreenConfig — 启动加载屏配置资源
# ============================================================================
# 一个 .tres = 一份加载屏配置:轮播插画、每张停留、提示语、最短展示时间。
# 加图/改文案在 Godot Inspector 编辑 .tres 即可,无需改代码。
# 设计参考 event_def.gd:数据与逻辑分离,字段全 @export。
# ============================================================================
class_name LoadingScreenConfig
extends Resource

## 轮播插画(留空则显示纯色背景,不报错)
@export var images: Array[Texture2D] = []

## 每张插画停留秒数
@export var seconds_per_image: float = 4.0

## 是否随机打散轮播顺序
@export var randomize_order: bool = false

## 底部提示语列表(轮流显示)
@export var tips: PackedStringArray = PackedStringArray()

## 每条提示语停留秒数
@export var seconds_per_tip: float = 3.5

## 最短展示秒数(防止热启动缓存命中时一闪而过)
@export var min_display_seconds: float = 2.5
