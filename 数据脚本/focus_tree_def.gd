# ============================================================================
# FocusTreeDef — 分层树（原版 FocusTree.layers: List<List<Focus>>）
# ============================================================================
# 从 focus_def.gd 拆出独立文件：GDScript 规定一个文件只能有一个 class_name
# （第二个 class_name 会报 "Unexpected class_name in class body" 并使整个
# 文件的全局类注册失败）。拆分后 FocusDef / FocusTreeDef 全局类均可正常解析。
# ============================================================================
class_name FocusTreeDef
extends RefCounted


## 层列表：每层是 Array[FocusDef]，index_in_layer 由 build 时补
var layers: Array[Array] = []


func layer_count() -> int:
	return layers.size()


func get_layer(i: int) -> Array:
	if i < 0 or i >= layers.size():
		return []
	return layers[i]


## 供焦点界面按层/格绘制（原版 FocusesScript.CreateCountryFocuses 的双重循环）
func all_focuses_flat() -> Array[FocusDef]:
	var out: Array[FocusDef] = []
	for layer in layers:
		for f: FocusDef in layer:
			out.append(f)
	return out
