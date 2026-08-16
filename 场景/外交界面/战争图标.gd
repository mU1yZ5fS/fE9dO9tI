extends Sprite3D

## 地图战争小图标 — 逐行移植原版 at_war_script.Repaint()（Assets/Scripts/at_war_script.cs）。
## 原版逻辑坐标是 3D 平面地图坐标；本端口经 125 个原版国家精灵锚点反距离插值换算为经纬度，
## 再按 世界地图渲染.gd.region_id_at_3d 的逆公式放到 Godot 球面（用户确认方案）。
## 插值脚本离线运行，换算结果固化在下方 LL_BY_KEY，运行期不做插值。

@export var initial_war_index: int = 0   # 原版 this_num 初始值
@export var special: bool = false        # 原版 special
@export var home_key: String = ""        # 原版场景 localPosition 的 key

var _war_index: int = 0                  # 原版 this_num（运行期可被 Repaint 改写，不复位）
var _key: String = ""                    # 当前逻辑坐标 key（原版 localPosition）

## 原版图标贴球面半径（地球 SphereMesh 默认半径 0.5，仅抬高 0.001 避免穿插）
const EARTH_RADIUS := 0.501

## 逻辑坐标 key → 经纬度（lon, lat）。数据源：Diplomacy.unity 内 37 个 ogon 对象
## （TimeScript.re_war 实际接线 36 个，this_num=-5 的 ogon (36) 是场景死对象未接线）+
## at_war_script.cs 全部 new Vector3 字面量；离线用原版国家精灵锚点 IDW 换算。
const LL_BY_KEY := {
	"-12.44,-23.763,-61.186": Vector2(-7.79, 28.36),
	"-2.11,-15.58,-60": Vector2(12.27, 43.03),
	"-6.8418,-24.2018,-61.186": Vector2(3.41, 34.40),
	"-7.83,-16.71,-60": Vector2(-2.93, 40.35),
	"-9.44,-16.31,-60": Vector2(-3.64, 40.22),
	"-9.99,-17.74,-60": Vector2(-4.67, 39.99),
	"1.07,-27.13,-60": Vector2(17.35, 21.13),
	"1.34,-17.56,-60": Vector2(21.18, 41.38),
	"1.34,-17.56,-61.186": Vector2(21.18, 41.38),
	"1.5256,-13.6456,-61.186": Vector2(19.17, 46.37),
	"1.56,-15.93,-60": Vector2(23.54, 42.43),
	"10.6,-18.54,-60": Vector2(38.13, 34.14),
	"10.88,-31.53,-60": Vector2(41.98, 11.51),
	"11.73,-20.97,-60": Vector2(44.62, 33.29),
	"11.88,-19.25,-100": Vector2(41.55, 33.45),
	"12.31,-17.86,-60": Vector2(41.19, 33.35),
	"12.65,-34.19,-60": Vector2(43.77, 6.80),
	"12.88,-30.32,-60": Vector2(44.45, 14.91),
	"13.1418,-29.506,-61.186": Vector2(45.46, 14.99),
	"13.22,-22.7,-60": Vector2(47.83, 29.46),
	"13.2255,-23.7383,-61.186": Vector2(47.93, 29.18),
	"13.94,-22.24,-60": Vector2(47.78, 29.72),
	"15.4382,-25.386,-61.186": Vector2(51.37, 25.44),
	"15.5746,-26.1182,-61.186": Vector2(51.37, 25.19),
	"16.03,-21.84,-60": Vector2(51.60, 33.82),
	"16.6382,-25.986,-61.186": Vector2(53.79, 23.97),
	"16.9201,-27.8328,-61.186": Vector2(56.63, 22.43),
	"17.8218,-27.686,-61.186": Vector2(57.03, 22.48),
	"2.44,-11.73,-60": Vector2(18.90, 47.55),
	"21.87,-20.67,-60": Vector2(67.50, 34.18),
	"27.3034,-20.5657,-33.7328": Vector2(75.95, 30.34),
	"27.89,-25.99,-60": Vector2(82.00, 24.61),
	"28.8911,-14.0417,-61.186": Vector2(85.05, 31.87),
	"3.6093,-14.9236,-33.7328": Vector2(24.95, 42.82),
	"30.5943,-23.7075,-61.186": Vector2(84.13, 28.10),
	"34.49,-24.14,-60": Vector2(90.38, 26.70),
	"35.1161,-25.4621,-61.186": Vector2(90.84, 24.66),
	"36.5145,-25.9402,-61.186": Vector2(94.98, 21.89),
	"37.7471,-27.402,-61.186": Vector2(102.37, 17.93),
	"37.94,-30.06,-60": Vector2(102.06, 14.79),
	"38.0637,-34.7,-32.31": Vector2(104.23, 11.30),
	"38.0637,-34.7,-61.186": Vector2(104.23, 11.30),
	"38.72,-28.11,-60": Vector2(103.75, 18.01),
	"39.2947,-16.2163,-61.186": Vector2(110.12, 33.02),
	"39.7727,-26.591,-61.186": Vector2(103.96, 17.81),
	"40.35,-31.58,-60": Vector2(104.71, 12.28),
	"40.72,-26.78,-60": Vector2(104.65, 17.37),
	"43.8464,-35.7903,-32.3098": Vector2(113.80, 4.55),
	"46.4036,-25.6491,-33.7328": Vector2(120.89, 23.93),
	"47.0255,-39.349,-32.3098": Vector2(115.20, -3.57),
	"47.2941,-27.5894,-61.186": Vector2(120.71, 22.71),
	"48.52,-31.22,-60": Vector2(122.35, 12.13),
	"49.35,-16.98,-60": Vector2(127.10, 39.83),
	"49.9,-18.42,-60": Vector2(127.50, 37.73),
	"50.35,-16.98,-60": Vector2(127.08, 39.91),
	"50.61,-11.05,-60": Vector2(125.45, 37.50),
	"51.09,-20.4655,-61.186": Vector2(128.45, 36.03),
	"51.6068,-36.4784,-61.186": Vector2(120.01, 2.43),
	"55.31,-19.16,-60": Vector2(134.77, 35.36),
	"7.316,-19.368,-60": Vector2(33.47, 34.87),
	"8.1,-17.88,-60": Vector2(34.25, 34.99),
	"8.27,-21.39,-60": Vector2(35.44, 33.24),
	"9.02,-31.55,-60": Vector2(40.06, 10.77),
	"9.3637,-22.38,-61.186": Vector2(36.18, 32.68),
	"9.64,-20.08,-61.186": Vector2(37.33, 34.53),
	"9.7,-19.36,-60": Vector2(37.20, 34.39),
	"9.92,-33.09,-60": Vector2(41.21, 9.34),
}


func _ready() -> void:
	_war_index = initial_war_index
	_key = home_key


## 原版 TimeScript.Awake:23 与月结 6015-6019 调用 re_war[i].Repaint()。
func repaint() -> void:
	var w: WorldState = GameManager.world if GameManager else null
	if w == null:
		visible = false
		return

	if not special:
		_repaint_normal(w)
	else:
		_repaint_special(w)


## at_war_script.cs:12-208 的换位链（逐行）。
func _repaint_normal(w: WorldState) -> void:
	if _country(w, 34) != null and _country(w, 34).内战中 and _war_index == 2:
		_move_to("38.0637,-34.7,-32.31", 34)
	if w.event_done_num(376) and not w.war_going(15) and _war_index == 15:
		_move_to("43.8464,-35.7903,-32.3098", 34)
	if w.war_going(35) and (_war_index == 15 or _war_index == 34):
		_move_to("47.0255,-39.349,-32.3098", 35)
	if _war_index == 4 and w.war_going(37):
		_move_to("13.1418,-29.506,-61.186", 37)
	if _war_index == 22 and w.war_going(70):
		_war_index = 70
	if _war_index == 1 and w.war_going(70):
		_move_to("28.8911,-14.0417,-61.186", 70)
	if _war_index == 25 and w.war_going(69):
		_move_to("39.2947,-16.2163,-61.186", 69)
	if w.event_done_num(642) and _war_index == 25 and w.war_going(70):
		_move_to("39.2947,-16.2163,-61.186", 70)
	if (_war_index == 3 or (_war_index == 43 and _key == "15.4382,-25.386,-61.186")) and w.war_going(37):
		_move_to("9.3637,-22.38,-61.186", 37)
	if (_war_index == 8 or (_war_index == 43 and _key == "16.6382,-25.986,-61.186")) and w.war_going(37):
		_move_to("15.5746,-26.1182,-61.186", 37)
	if (_war_index == 42 or _war_index == 29 or (_war_index == 43 and _key == "17.8218,-27.686,-61.186")) and w.war_going(37):
		_move_to("16.9201,-27.8328,-61.186", 37)
	if (_war_index == 38 or _war_index == 28) and w.war_going(37):
		_move_to("13.2255,-23.7383,-61.186", 37)
	if _war_index == 28 and w.war_going(38):
		_war_index = 38
	if (_war_index == 29 or _war_index == 42) and w.war_going(43):
		_move_to("17.8218,-27.686,-61.186", 43)
	if _war_index == 8 and w.war_going(43):
		_move_to("16.6382,-25.986,-61.186", 43)
	if _war_index == 3 and w.war_going(43):
		_move_to("15.4382,-25.386,-61.186", 43)
	if _war_index == 21 and w.war_going(39):
		_move_to("-12.44,-23.763,-61.186", 39)
	if (_war_index == 21 or _war_index == 39) and w.war_going(40):
		_move_to("-6.8418,-24.2018,-61.186", 40)
	if _war_index == 19 and w.war_going(41):
		_move_to("9.64,-20.08,-61.186", 41)
	if _war_index == 41 and w.war_going(19):
		_move_to("1.34,-17.56,-61.186", 19)
	if _war_index == 29 and w.war_going(42):
		_war_index = 42
	if _war_index == 29 and w.war_going(88):
		_war_index = 88
	if (_war_index == 42 or _war_index == 88) and w.war_going(29):
		_war_index = 29
	if _war_index == 36 and w.war_going(90):
		_move_to("51.09,-20.4655,-61.186", 90)
	if _war_index == 90 and w.war_going(36):
		_war_index = 36
	if _war_index == 0 and w.war_going(90) and not (_country(w, 10) != null and _country(w, 10).parts.size() > 0 and _country(w, 10).parts[0]):
		_war_index = 90
	if _war_index == 90 and w.war_going(16):
		_war_index = 0
	if _war_index == 16 and w.war_going(71):
		_move_to("39.7727,-26.591,-61.186", 71)
	if _war_index == 1 and w.war_going(71):
		_move_to("36.5145,-25.9402,-61.186", 71)
	if _war_index == 27 and w.war_going(71):
		_move_to("37.7471,-27.402,-61.186", 71)
	if _war_index == 16 and w.war_going(72):
		_war_index = 72
	if _war_index == 16 and w.war_going(73):
		_move_to("47.2941,-27.5894,-61.186", 73)
	if _war_index == 1 and w.war_going(73):
		_move_to("38.0637,-34.7,-61.186", 73)
	if _war_index == 27 and w.war_going(73):
		_move_to("51.6068,-36.4784,-61.186", 73)
	if _war_index == 16 and w.war_going(74):
		_move_to("27.3034,-20.5657,-33.7328", 74)
	if _war_index == 1 and w.war_going(74):
		_move_to("30.5943,-23.7075,-61.186", 74)
	if _war_index == 27 and w.war_going(74):
		_move_to("35.1161,-25.4621,-61.186", 74)
	if _war_index == 16 and w.war_going(75):
		_move_to("46.4036,-25.6491,-33.7328", 75)
	if _war_index == 17 and w.war_going(76):
		_war_index = 76
	if _war_index == 16 and w.war_going(76):
		_move_to("3.6093,-14.9236,-33.7328", 76)
	if _war_index == 27 and w.war_going(76):
		_move_to("1.5256,-13.6456,-61.186", 76)

	# at_war_script.cs:210-218
	visible = w.war_going(_war_index)
	if visible:
		_apply_sphere_position()


## at_war_script.cs:220-228：特殊图标。
func _repaint_special(w: WorldState) -> void:
	var d37 := 0
	if w.数值表.size() > 37:
		d37 = w.数值表[37]
	visible = (
		(_war_index == -1 and w.get_flag("iranrev"))
		or (_war_index == -2 and w.war_state == 2)
		or (_war_index == -3 and w.war_state == 1)
		or (_war_index == -4 and d37 > 0 and d37 < 1000)
		or _war_index == -5
	)
	if visible:
		_apply_sphere_position()


func _move_to(key: String, idx: int) -> void:
	_key = key
	_war_index = idx


func _country(w: WorldState, legacy_index: int) -> CountryData:
	return w.get_country_by_legacy_index(legacy_index)


## 经纬度 → Godot 球面坐标。逆公式与 世界地图渲染.gd:region_id_at_3d 严格互逆。
##   u=(lon+180)/360, v=(90-lat)/180, theta=(1-v)*PI, phi=u*TAU
##   x=sin(phi)*sin(theta), y=-cos(theta), z=cos(phi)*sin(theta)
## 图标不做 billboard：basis 取「东/北/法线」三轴，像平面一样贴在球面区域上，
## 随地球局部坐标一起转（原版 SpriteRenderer 同样是固定在地图平面上的）。
func _apply_sphere_position() -> void:
	var ll: Vector2 = LL_BY_KEY.get(_key, Vector2.ZERO)
	var u := (ll.x + 180.0) / 360.0
	var v := (90.0 - ll.y) / 180.0
	var theta := (1.0 - v) * PI
	var phi := u * TAU
	var sphere_pos := Vector3(
		sin(phi) * sin(theta),
		-cos(theta),
		cos(phi) * sin(theta)
	) * EARTH_RADIUS
	position = sphere_pos

	# 东向切线：p 对 phi 求导；北向切线：p 对 theta 求导。
	var east := Vector3(cos(phi), 0.0, -sin(phi))
	var north := Vector3(sin(phi) * cos(theta), sin(theta), cos(phi) * cos(theta))
	basis = Basis(east, north, sphere_pos.normalized())
