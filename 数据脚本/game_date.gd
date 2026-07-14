class_name GameDate
extends Resource

@export var day: int = 1
@export var month: int = 1
@export var year: int = 1976
@export var tick_count: int = 0

func _init(p_day: int = 1, p_month: int = 1, p_year: int = 1976, p_tick_count: int = 0) -> void:
	day = p_day
	month = p_month
	year = p_year
	tick_count = p_tick_count

## 推进一天。返回 true 如果需要月末/年末处理。
func advance() -> void:
	tick_count += 1
	day += 1
	var days_in_month: int = _days_in_current_month()
	if day > days_in_month:
		day = 1
		month += 1
		if month > 12:
			month = 1
			year += 1

func _days_in_current_month() -> int:
	match month:
		1, 3, 5, 7, 8, 10, 12: return 31
		4, 6, 9, 11: return 30
		2:
			if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
				return 29
			return 28
	return 30

## "1976年1月1日"
func format() -> String:
	return "%d年%d月%d日" % [year, month, day]

## 用于比较/排序的紧凑整数
func to_int() -> int:
	return year * 10000 + month * 100 + day
