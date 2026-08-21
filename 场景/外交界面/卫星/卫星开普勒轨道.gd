extends Node3D

## 开普勒轨道脚本 — 基于真实轨道力学的椭圆轨道运动
## 默认参数为东方红一号（DFH-1）的真实轨道根数。
##
## 用法：将本脚本挂到一个空 Node3D 上，卫星模型作为第一个子节点。
## 脚本每帧求解开普勒方程，将子节点放到椭圆轨道的正确位置。

## ── 轨道根数 ──

@export_group("轨道参数")
## 半长轴（游戏单位，地球半径 = 1.0）
@export var semi_major_axis: float = 1.222
## 离心率 (0 = 圆, 0-1 = 椭圆)
@export var eccentricity: float = 0.125
## 轨道倾角（度）
@export var inclination_deg: float = 68.5
## 升交点赤经（度）
@export var raan_deg: float = 30.0
## 近地点幅角（度）
@export var arg_perigee_deg: float = 45.0
## 可视轨道周期（秒）— 调整此值控制绕行快慢
@export var orbital_period: float = 25.0
## 初始平近点角（度）
@export var initial_anomaly_deg: float = 0.0

var _elapsed: float = 0.0
var _mean_motion: float
var _satellite: Node3D
var _base_basis: Basis

# 预计算旋转矩阵系数
var _r11: float
var _r12: float
var _r21: float
var _r22: float
var _r31: float
var _r32: float


func _ready() -> void:
	_mean_motion = TAU / orbital_period
	if get_child_count() > 0:
		_satellite = get_child(0) as Node3D
		_base_basis = _satellite.transform.basis
	_precompute_rotation()
	_update_position()


func _precompute_rotation() -> void:
	var i := deg_to_rad(inclination_deg)
	var O := deg_to_rad(raan_deg)
	var w := deg_to_rad(arg_perigee_deg)
	var cw := cos(w)
	var sw := sin(w)
	var ci := cos(i)
	var si := sin(i)
	var cO := cos(O)
	var sO := sin(O)
	_r11 = cO * cw - sO * sw * ci
	_r12 = -cO * sw - sO * cw * ci
	_r21 = sO * cw + cO * sw * ci
	_r22 = -sO * sw + cO * cw * ci
	_r31 = sw * si
	_r32 = cw * si


func _process(delta: float) -> void:
	if _satellite == null:
		return
	_elapsed += delta
	_update_position()


func _compute_orbital_pos(t: float) -> Vector3:
	var M := fposmod(deg_to_rad(initial_anomaly_deg) + _mean_motion * t, TAU)
	var E := _solve_kepler(M)
	var nu := _true_anomaly(E)
	var r := semi_major_axis * (1.0 - eccentricity * cos(E))
	var x_pf := r * cos(nu)
	var y_pf := r * sin(nu)
	var ax := _r11 * x_pf + _r12 * y_pf
	var ay := _r21 * x_pf + _r22 * y_pf
	var az := _r31 * x_pf + _r32 * y_pf
	return Vector3(ax, az, ay)


func _update_position() -> void:
	if _satellite == null:
		return
	var pos := _compute_orbital_pos(_elapsed)
	# 用微小时间差计算速度方向，让卫星朝向飞行方向
	var pos_next := _compute_orbital_pos(_elapsed + 0.01)
	var velocity_dir := (pos_next - pos).normalized()
	_satellite.position = pos
	if velocity_dir.length_squared() > 0.001:
		# look_at 方向 = 飞行方向，up = 径向（从地心指向卫星）
		var up := pos.normalized()
		_satellite.transform.basis = Basis.looking_at(velocity_dir, up) * _base_basis


## 牛顿-拉夫森法求解开普勒方程 M = E - e·sin(E)
func _solve_kepler(M: float) -> float:
	var E := M
	for _i in range(20):
		var dE := (E - eccentricity * sin(E) - M) / (1.0 - eccentricity * cos(E))
		E -= dE
		if absf(dE) < 1e-10:
			break
	return E


## 从偏近点角 E 计算真近点角 ν
func _true_anomaly(E: float) -> float:
	return 2.0 * atan2(
		sqrt(1.0 + eccentricity) * sin(E * 0.5),
		sqrt(1.0 - eccentricity) * cos(E * 0.5)
	)
