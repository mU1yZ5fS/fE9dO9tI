# 外交动作数据目录

目标：把 `外交互动_批1~6 + 补遗` 中的手写 `_def_N` 逐步迁移到这里。

## 文件格式

一个动作一个对象，也可以一个数组包含多个动作：

```json
{
  "id": 9,
  "caption": "发 展 贸 易",
  "opis": "与对方签署贸易协定",
  "conditions": [],
  "effects": [],
  "dormant": false,
  "source": "DiploButtonScript._def_9"
}
```

- `conditions` / `effects` 后续接入 ExprNode / EffectNode DSL。
- 当前运行时仍以代码批次为权威；`DiploActionLoader` 已可加载，等待逐步切换。
