extends "res://数据脚本/event_script_base.gd"

## preload 而非 class_name 全局引用：新增全局类在未重建 .godot 类缓存时不可见。
const EndingSvc := preload("res://数据脚本/services/ending_service.gd")

## 1986-01-01 终局抉择（原作 TimeScript.cs:683 Reborn() 显示面板 + in1992_script.cs OnMouseDown）。
## 触发：event_ending_choice.tres 的 DATE_AFTER 1986.1.1（fire_only_once）。
## 左选项 = 继续掌权（原作 Reborn 隐藏面板恢复速度；Godot 返回外交场景自动恢复速度）。
## 右选项 = 功成身退：判定与世界收尾统一由 EndingService 执行（in1992_script.cs:43-137 逐条复刻），
##   与 ESC 菜单「结束」按钮（CascadScrupt.cs PostExit）共用同一份判定，保证两条入口行为一致。
##   - 63 号战争进行中 → data.war_resolve=63 + 事件18（in1992_script.cs:43-49）
##   - resultOfEvents[581]==2 → 结局13（:51-57）
##   - data.people_support<300 或 (diff==4 且 <500) → 结局1（:58-64）
##   - data.party_support<300 或 (diff==4 且 <500) → 结局2（:65-71）
##   - data.party_system==9 && data.econ_system==15 && data.press_policy==19 && modifies[5] && data.oligarch>=100 → 结局9（:72-78）
##   - 否则世界收尾更新 → 结局0（GoodEnd 自动判定）（:79-137）


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = "你决定继续掌权，直至永远。"
		1:
			_right_choice(context)


func _right_choice(context: Dictionary) -> void:
	context["result_text"] = ""
	EndingSvc.end_after_1986_via_event(ws, game, EventEngine)
